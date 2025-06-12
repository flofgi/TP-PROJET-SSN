## Ex 1 Serveur:
```Bash
function interpret() {
date
echo "Bienvenue sur le serveur"
}


interpret | nc -l -s localhost -p 12345
$0
```

## Ex 2 Serveur:
```Bash
rm ./fifo
mkfifo ./fifo

function interpret (){
  date
  echo "Bienvenue sur le serveur"
  while read line;
  do
    echo "Debug, received == $line ==" >&2
    if [ $line == "exit" ]; then
       echo "Bye bye"
       exit
    fi
    $line >&1
  done 
}

echo "start."
nc -l -s localhost -p 12345 < ./fifo | interpret > ./fifo
echo "End."
$0
```
## Ex 3 Serveur:
```Bash
rm ./fifo
mkfifo ./fifo

function interpret (){
  date
  echo "Bienvenue sur le serveur"
  echo "entrer le mot de passe"
  while read line;
  do
  mdp=$(cat config )
  if [ $line == $mdp ]; then
  echo "Vous etes connecté"
  while read line;
  do
     echo "Debug, received == $line ==" >&2
     if [ $line == "exit" ]; then
        echo "Bye bye"
        exit
     fi
     $line >&1
   done
  fi 
  done
}

echo "start."
nc -l -s localhost -p 12345 < ./fifo | interpret > ./fifo
echo "End."
$0
```
## Ex 4 Serveur:
```Bash
#!/bin/bash

rm ./fifo_client_to_server.fifo
mkfifo ./fifo_client_to_server.fifo
rm ./fifo_server_to_client.fifo
mkfifo ./fifo_server_to_client.fifo


decode() {
  echo "$1" | tr "$cle" 'abcdefghijklmnopqrstuvwxyz'
}

encode() {
  echo "$1" | tr 'abcdefghijklmnopqrstuvwxyz' "$cle"
}

function interpret() {
  date >&2
  echo "Entrer le mot de passe : " >&2
  read -r mdp < /dev/tty

  echo "Entrer la clé : " >&2
  read -r cle < /dev/tty
  while [ $( echo "$cle" | grep -o . | sort | uniq | wc -l ) != 26 ]
  do
  echo "Redonne une cle valide" >&2
  read -r cle< /dev/tty
  done

  input="$mdp|$cle"

  echo "$input" >&3
  read -r response <&4

  echo "Réponse serveur : $response" >&2

  if [ "$response" = "Vous etes connecté" ]; then
    while true; do
      printf "Server> " >&2
      read -r input < /dev/tty
      encode "$input" >&3
      while read -r encoded_msg <&4 && [ "$(decode "$encoded_msg")" != "FIN" ]; do
         decoded_msg=$(decode "$encoded_msg")
         echo "$decoded_msg" >&2
      done

      if [ "$input" = "exit" ]; then
        break
      fi
    done
  fi
}


nc localhost 12345 < ./fifo_client_to_server.fifo > ./fifo_server_to_client.fifo | interpret
```
## Ex 4 Client:
```Bash
#!/bin/bash

rm ./fifo_client_to_server.fifo
mkfifo ./fifo_client_to_server.fifo
rm ./fifo_server_to_client.fifo
mkfifo ./fifo_server_to_client.fifo


encode() {
echo "$1" | tr 'abcdefghijklmnopqrstuvwxyz' "$cle"
}

decode() {
echo "$1" | tr "$cle" 'abcdefghijklmnopqrstuvwxyz'
}

function interpret() {
echo "Start serveur." >&2

exec 3<> fifo_client_to_server.fifo
exec 4<> fifo_server_to_client.fifo

read -r input <&3
mdpclient="${input%%|*}"
cleclient="${input#*|}"
echo -e "$mdpclient|$cleclient"

source config

if [ "$mdpclient" = "$mdp" ] && [ $( echo "$cle" | grep -o . | sort | uniq | wc -l ) = 26 ]; then
echo -e "mdp=$mdp\ncle=$cleclient" > config
echo "Vous etes connecté" >&4
source config
while read -r line <&3; do
# Déchiffrement
dec=$(decode "$line")
echo "Debug reçu: $dec" >&2

if [ "$dec" = "exit" ]; then
echo "Bye bye" | encode >&4
break
fi


output=$($dec)

while IFS= read -r out_line; do
encode "$out_line" >&4
done <<< "$output"

encode "FIN" >&4

done

else
echo "Echec de la connection" >&4
fi

echo "End serveur." >&2
}

exec 3<> fifo_client_to_server.fifo
exec 4<> fifo_server_to_client.fifo


nc -l -p 12345 >&3  <&4 | interpret
$0
```
