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
