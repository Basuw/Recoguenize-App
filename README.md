# Guide d'utilisation de l'application Recoguenize

Cette application a pour but de retrouver le nom d'une musique enregistrée à l'aide du micro du téléphone.

## Musiques présentes

L'application est configurée pour reconnaître trois morceaux de musiques différents :

1. Thunderstruck d'AC/DC

2. Houdini d'Eminem

3. Gitano de Kendji Girac

Seulement les premières minutes sont enregistrées en base. Il est donc possible de reconnaitre seulement la première minute des 3 musiques ci-dessus.

## Installation de l'application mobile

Pour installer l'application sur votre smartphone (disponible sur Android uniquement), suivez les instructions suivantes :

1. Télécharger le fichier app-debug.apk présent dans le repository git.
2. Il est possible que votre smartphone bloque l'installation de l'application. Pour cela, assurez-vous que dans les paramètres du téléphone, la case "Mes fichiers" soit cochée dans la section "installation d'applis inconnues".
3. En branchant votre smartphone à l'ordinateur, copiez-collez le fichier .apk dans les fichiers de votre smartphone.
4. Depuis votre smartphone, lancez le fichier .apk
5. La partie adresse ip" n'est nécessaire que si vous installez l'application en local comme décrit ci-dessous.

## Installation du serveur en local

| :exclamation:  Si le temps de réponse est anormalement long, c'est que la machine virtuelle rencontre des problèmes   |
|-----------------------------------------|


Le serveur de l'application est hébergé sur une machine virtuelle Azure. Celle-ci pouvant avoir des problèmes techniques indépendants de notre volonté, voici le guide d'installation de l'application en local.
Il est nécessaire que le smartphone et l'ordinateur utilisé pour lancer l'appli soient sur le même réseau wifi.

1. Cloner le repository git :

```bash
git clone https://github.com/Basuw/Recoguenize-App.git
```

2. Lancer docker :

```bash
cd recoguenize-backend
docker-compose up 
```

3. Au bout d'une minute environ, le serveur est démarré et prêt à être utilisé.

4. Pour que votre smartphone soit connecté au serveur local, rentrez votre adresse ip dans la section prévue à cet effet sur l'application.

5. Pour cela, dans un invite de commande, sur votre ordnateur, tapez "ipconfig" et rentrez la valeur du champ "adresse ipv4", de la partie "carte réseau sans fil wi-fi", dans l'application.
