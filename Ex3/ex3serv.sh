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
