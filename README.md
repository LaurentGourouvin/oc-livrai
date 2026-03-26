# Mise en place de l'environnement de développement

## Initialisation de la base de données Option A
Télécharger MySql 8

Créer un utilisateur

Créer une nouvelle base de données nommée `livrai`

Appliquer le script SQL db/init-script.sql

## Initilisation de la base de données Option B

```shell
docker compose up -d  
```

Pour se connecter à la base de donnée 

```shell
mysql -u livrai_user -p livrai
```

## Lancement du serveur
Télécharger Eclipse (un jdk > 6 est nécessaire)

Importer le projet Maven dans Eclipse.

Télécharger tomcat 8.5 et l'ajouter à la vue Server d'Eclipse.

**La version 8.5 n'étant plus disponible, prendre la version 9 :**   
- https://dlcdn.apache.org/tomcat/tomcat-9/v9.0.116/bin/apache-tomcat-9.0.116.tar.gz

Ajouter le projet `app` au server.

Modifier le fichier `AbstractDao.java` et ajuster le port, username et password de votre base de données.

Lancer le serveur.

Visiter l'URL localhost:8080/app

## 1ère connexion
Il est nécessaire de créer un utilisateur admin en base:
```
INSERT INTO user (email, name, password, admin) VALUES
  ('<email>', 'Livrai', '<password>', TRUE);

```
