# Orientation de l'application LiVrai

## Contexte de la mission 

Le produit CRM LiVrai qui connait à l'heure actuelle une grande croissance d'activité rencontre des difficultés techniques.
Après un rapport d'audit effectué par mes soins, je dois maintenant proposer une solution technique leur permettant d'affronter leurs
prochains défis professionnels.

Pour rappel, le CRM permettait à des administrateurs de la plateforme, de créer des nouveaux comptes clients et de gérer les différentes
livraisons. Les clients, devaient passer par le service commercial afin d'obtenir un compte pour leur permettre de créer eux mêmes leurs
commandes, qui entrainaient une livraison.

## Objectifs de la refonte

L'audit de l'application existante a mis en évidence plusieurs problématiques qui justifient une refonte complète :

- **Performance** : absence de pool de connexions, requêtes sans pagination
- **Sécurité** : mots de passe en clair, absence de validation des données
- **Maintenabilité** : architecture MVC incomplète, logique métier dans les contrôleurs (servlet)
- **Évolutivité** : architecture monolithique difficile à faire évoluer et à scaler

## Grandes orientations de l'architecture cible

La refonte s'appuiera sur une stack moderne imposée par le service informatique de LiVrai :

- **Back-end** : Java 21 + Spring Boot 3.4.x (LTS)
- **Front-end** : Angular (SPA) v.21.0.0 (LTS)
- **Base de données** : PostgreSQL v.18
- **Déploiement** : conteneurisation Docker

L'architecture cible reposera sur une séparation claire front/back communiquant via une API REST, en remplacement de l'architecture monolithique
JSP/Servlet actuelle. Cette approche offre également une ouverture vers d'autres clients potentiels de l'API, comme une application mobile, sans
modification du back-end.  

## Les utilisateurs 

Dans la précédente version de l'application il y avait deux types d'utilisateurs :  

| Rôle           | Actions                                                        |
|----------------|----------------------------------------------------------------|
| Client         | Se connecter, Créer une commande, Voir ses livraisons          |
| Administrateur | Se connecter, Créer des clients, Gérer les livraisons          |

Dans la nouvelle version, les clients peuvent créer leur compte de façon autonome, sans passer par le service commercial.  

La plateforme devra accueillir un nouveau type d'utilisateur :  

| Rôle               | Actions                                                                                        |
|--------------------|------------------------------------------------------------------------------------------------|
| Client             | Créer un compte, Se connecter, Créer une commande, Voir ses livraisons, Gérer ses informations |
| Administrateur     | Se connecter, Créer des clients, Gérer les livraisons                                          |
| Service Commercial | Se connecter, Créer des clients, Gérer les livraisons, Accès à la facturation                  | 
| Service Livraison  | Se connecter, Gérer les livraisons, Accès à la facturation                                     | 

## Les fonctionnalités

Pour la nouvelle version de l'application il n'y a pas de grande évolution concernant les fonctionnalités.  
Il faut implémenter un système de rôles plus complexe que la précédente version.  
Cependant deux fonctionnalités nouvelles sont à prévoir :

1. La gestion de la facturation, qui devra être plus fine et accessible aux rôles concernés
2. La gestion des informations client (modification des coordonnées, adresses...)

Les fonctionnalités existantes seront conservées et retravaillées dans le cadre de la refonte
technique, sans ajout de périmètre fonctionnel majeur.