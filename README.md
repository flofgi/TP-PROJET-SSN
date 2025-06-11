
# Rapport de Projet SSN : Shell sur Netcat

## Auteurs
Florentin Girardet & Paul Geniaux  
Polytech Dijon, TP Systèmes UNIX

## Objectif

L’objectif du projet est de concevoir un shell distant basé sur Netcat permettant à un client
d’envoyer des commandes à un serveur, qui les exécute et retourne les résultats.
Le projet évolue en quatre étapes : écoute simple, exécution distante, authentification,
et chiffrement monoalphabétique.

## 1. Fonctionnement global

Le système repose sur une communication entre un client et un serveur via Netcat (`nc`).
Les échanges transitent par deux fichiers FIFO pour simuler des canaux bidirectionnels,
tandis que les données sont chiffrées à l’aide d’un chiffrement par substitution monoalphabétique.

```
Utilisateur → Client → [Chiffrement] → FIFO → Netcat → FIFO → Serveur → Exécution
Serveur → [Chiffrement] → FIFO → Netcat → FIFO → Client → Déchiffrement → Affichage
```

## 2. Exécution et utilisation

### Lancement du serveur

```
./serveur.sh
```

Le serveur :
- crée les FIFOs nécessaires,
- lit le mot de passe et la clé de chiffrement depuis un fichier `config`,
- attend une connexion sur le port TCP `12345` avec `nc`,
- déchiffre les commandes entrantes, les exécute, chiffre le résultat, et le renvoie.

Exemple de fichier `config` :
```
mdp=1234
cle=azertyuiopqsdfghjklmwxcvbn
```

### Lancement du client

```
./client.sh
```

Le client :
- demande à l’utilisateur un mot de passe et une clé de chiffrement (26 lettres distinctes),
- chiffre les commandes à l’aide de la clé,
- envoie les données via Netcat,
- reçoit les réponses chiffrées, qu’il déchiffre et affiche.

## 3. Architecture du code

### Exercice 1 – Serveur en écoute

Le script suivant permet de créer un serveur qui :
- écoute sur `localhost:12345`,
- affiche la date de connexion,
- reste en écoute même après la fin de la connexion.

```bash
date | nc -l -s localhost -p 12345
$0
```

### Exercice 2 – Exécution de commandes distantes

Une fonction `interpret` est utilisée pour :
- afficher la date,
- lire les lignes entrantes,
- exécuter la commande et renvoyer la sortie.

```bash
interpret () {
  date
  while read line; do
    echo "Debug, received == $line ==" >&2
    if [ "$line" == "exit" ]; then
       echo "Bye bye"
       exit
    fi
    $line >&1
  done
}
```

Le serveur et le client utilisent des FIFOs pour établir un canal duplex :
```bash
nc -l -s localhost -p 12345 < ./fifo | interpret > ./fifo
```

### Exercice 3 – Authentification par mot de passe

L’utilisateur doit saisir un mot de passe, qui est comparé à celui contenu dans `config`.

```bash
mdp=$(cat config)
if [ "$line" == "$mdp" ]; then
  echo "Vous êtes connecté"
```

### Exercice 4 – Chiffrement monoalphabétique

#### Côté client

```bash
encode() {
  echo "$1" | tr 'abcdefghijklmnopqrstuvwxyz' "$cle"
}

decode() {
  echo "$1" | tr "$cle" 'abcdefghijklmnopqrstuvwxyz'
}
```

#### Côté serveur

- Le serveur déchiffre la commande entrante avant exécution.
- Puis chiffre chaque ligne de sortie avant de la renvoyer.
- Le message `"FIN"` est utilisé pour signaler la fin d’un bloc de réponse.

```bash
encode "FIN" >&4
```

## 4. Sécurité et limites

- Le système utilise un chiffrement simple par substitution, facilement cassable.
- Le mot de passe est stocké en clair dans un fichier.
- Aucun chiffrement réseau natif (Netcat reste en clair).
- Pas de gestion multi-utilisateur ni journalisation.

## 5. Conclusion

Ce projet met en œuvre les bases d’un shell distant avec une communication sécurisée simple.
Il démontre la maîtrise des concepts UNIX tels que les FIFOs, les sockets Netcat, les scripts Bash
et une sécurité rudimentaire. Il peut être amélioré avec du chiffrement fort, une meilleure interface
et une authentification plus robuste.

## Annexe – Commandes utiles

```bash
# Nettoyage des FIFOs
rm ./fifo*

# Création
mkfifo fifo_client_to_server.fifo
mkfifo fifo_server_to_client.fifo
```
