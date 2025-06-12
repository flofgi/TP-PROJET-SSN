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
