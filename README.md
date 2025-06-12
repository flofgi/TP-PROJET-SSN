![Polytech Dijon](https://www.google.com/url?sa=i&url=https%3A%2F%2Fpolytech.ube.fr%2F&psig=AOvVaw33v0Lwgbf_kfxAiDA_--vP&ust=1749817358907000&source=images&cd=vfe&opi=89978449&ved=0CBQQjRxqFwoTCKD02-Lv640DFQAAAAAdAAAAABAE "Polytech Dijon")

# Rapport de Projet TP – SSN (Shell sur Netcat)

**Étudiants :** Florentin Girardet & Paul GENIAUX
**Systèmes UNIX**
**Date :** 12/06/2025

### 1\. Objectif du projet

[cite\_start]L'objectif du projet est de concevoir un shell distant basé sur Netcat permettant à un client d'envoyer des commandes à un serveur, qui les exécute et retourne les résultats à partir de Bash[cite: 2]. [cite\_start]Le projet évolue en quatre étapes : écoute simple, exécution distante, authentification, et chiffrement monoalphabétique[cite: 3].

### 2\. Détail des exercices

[cite\_start]Pour les 3 premiers exercices, le client est vraiment basique[cite: 4]. [cite\_start]On lance seulement la commande : `nc localhost 12345`[cite: 5].

#### 2.1. Exercice 1 – Serveur en écoute

[cite\_start]Pour réaliser cet exercice, nous envoyons à la commande Netcat `date` et le message "Bienvenue sur le serveur"[cite: 6]. [cite\_start]Nous exécutons Netcat avec `nc -l -s localhost -p 12345` ce qui indique que l’on est en mode écoute et que l’on se concentre sur la machine sur le port 12345[cite: 6].

#### 2.2. Exercice 2 – Exécution distante de commandes

[cite\_start]Cette fois-ci, on passe par des tunnels FIFO[cite: 7]. [cite\_start]Pour ce faire, on exécute la commande `nc -l -s localhost -p 12345 < ./fifo | interpret > ./fifo`[cite: 7]. [cite\_start]Ce qui permet de communiquer sans arrêt entre `nc` et notre fonction[cite: 8]. [cite\_start]Celle-ci va afficher la saisie du client, si la saisie est « exit », la fonction va s’arrêter[cite: 9]. [cite\_start]Sinon elle va exécuter et retourner le résultat au client[cite: 10].

#### 2.3. Exercice 3 – Authentification par mot de passe

[cite\_start]Le serveur va récupérer dans le fichier `config` le mot de passe utilisateur, il va ensuite le comparer avec la saisie client et si la saisie est bonne, il va réaliser l’exercice 2[cite: 11].

#### 2.4. Exercice 4 – Chiffrement monoalphabétique

[cite\_start]Dans cet exercice, nous avons 2 fichiers, un pour le client et l’autre pour le serveur[cite: 1].

**Côté Serveur :**
[cite\_start]Nous récupérons déjà l’input du client qui contient le mot de passe et la clé du client ainsi que le mot de passe contenu dans le fichier `config`[cite: 12]. [cite\_start]Si les mots de passe sont identiques et que la clé est valide, nous passons à l’étape suivante : On récupère l’entrée client et on la déchiffre puis on l’exécute et on la renvoie chiffrée[cite: 13]. [cite\_start]Pour chiffrer et déchiffrer le message, on utilise le chiffrement monoalphabétique avec : `encode() { echo "$1" | tr 'abcdefghijklmnopqrstuvwxyz' "$cle"}`[cite: 14]. [cite\_start]Et inversement pour décoder[cite: 15]. [cite\_start]Cette fois-ci, on utilise encore des FIFOs mais on les a encodées en tant que sortie de bash pour rendre le code plus lisible[cite: 15]:

```bash
exec 3<> fifo_client_to_server.fifo
exec 4<> fifo_server_to_client.fifo
[cite_start]nc -l -p 12345 >&3 <&4 | interpret [cite: 16]
```

**Côté Client :**
[cite\_start]Dans un premier temps, nous récupérons le mot de passe de l’utilisateur ainsi que la clé de chiffrement en nous assurant qu’elle soit valable[cite: 17]. [cite\_start]Dès que nous sommes bien connectés au serveur, nous faisons l’interface entre le serveur et le client en récupérant ses prompts et en les envoyant chiffrés au serveur avec les mêmes méthodes que celui-ci[cite: 17]. [cite\_start]Puis on récupère les réponses du serveur, on les déchiffre et on les affiche[cite: 18].

### 3\. Lancement et utilisation des scripts

[cite\_start]Pour lancer les scripts, on commence par s’assurer qu’ils sont exécutables, si ce n’est pas le cas, on réalise : `chmod +x [nom du fichier]`[cite: 19]. [cite\_start]On le fait pour les fichiers `./Client.sh` et/ou `./Serveur.sh`[cite: 20].

### 4\. Annexes

Le code : [TP-PROJET-SSN](https://github.com/flofgi/TP-PROJET-SSN/)
