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

exec 3<> fifo_client_to_server.fifo
exec 4<> fifo_server_to_client.fifo

nc localhost 12345 < ./fifo_client_to_server.fifo > ./fifo_server_to_client.fifo | interpret
