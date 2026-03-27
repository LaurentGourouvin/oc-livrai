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
- **Accès aux données** : migration du pattern DAO/JDBC manuel vers **Spring Data JPA** (ORM Hibernate), apportant une meilleure abstraction, 
moins de code verbeux et une gestion des transactions plus robuste.

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

## Architecture Cible

### Backend

L'équipe informatique de LiVrai maîtrise l'environnement Java. Je propose une architecture backend réalisable à l'aide du framework Spring Boot.

L'architecture de l'ancienne version reposait sur une architecture MVC qui n'était pas correctement implémentée. J'ai retrouvé des informations métier
dans la partie présentation, ce qui, à terme, pourrait rendre complexe la maintenabilité du code et sa scalabilité horizontale.

Pour cette nouvelle version du CRM, je propose une architecture en couches, courante dans un environnement Spring Boot. Cette architecture garde la
même logique que l'architecture de base de l'application, donc son implémentation sera plus facile pour l'équipe et aucune formation ne sera nécessaire
pour la compréhension de celle-ci. Le contexte métier étant bien défini et non complexe, cette architecture me semble la plus adaptée au projet.

Les couches qui seront présentes :
- Controller  → reçoit les requêtes HTTP (Remplace les `Servlets`)
- Service     → contient la logique métier (Remplace le code métier contenu dans les `Servlets`de l'ancienne version)
- Repository  → accès aux données (Spring Data JPA) (Remplace les `DAO`)
- Model       → entités métier mappées sur la base de données (JPA Entities) (remplace les `Beans`)

Grâce à l'architecture MVC de base de l'application, nous avons déjà nos `Controllers` qui correspondent principalement aux `Servlets`. Pour cette
version nous aurons 5 controllers :
1. AuthentificationController
2. UserController
3. CommandController
4. DeliveryController
5. BillController (**nouveauté**: gestion de la facturation absente de l'ancienne version)

Chaque controller aura comme rôle de recevoir les requêtes HTTP du client. Une fois la requête reçue, nous allons traiter l'information à l'aide des services
liés à ce controller. Nous aurons donc, aussi, 5 services :
1. AuthentificationController → AuthentificationService
2. UserController → UserService
3. CommandController → CommandService
4. DeliveryController → DeliveryService
5. BillController → BillService

Enfin, afin de gérer la persistance des données, l'implémentation des repositories sera utilisée dans nos services via **Spring Data JPA** (ORM Hibernate).
Chaque entité métier disposera de son propre repository.

La sécurité de l'application sera assurée par **Spring Security**, qui permettra de gérer l'authentification des utilisateurs ainsi que les autorisations
par rôle (Client, Administrateur, Service Commercial, Service Livraison), une évolution nécessaire face au système de rôles plus complexe de cette nouvelle version.  

La gestion des connexions à la base de données sera assurée par un **pool de connexions HikariCP**, inclus par défaut dans Spring Boot. Contrairement à l'ancienne version qui 
recréait une connexion à chaque instanciation de DAO, HikariCP maintient un ensemble de connexions réutilisables, ce qui améliore significativement les performances sous forte 
charge et répond directement au risque de saturation identifié dans l'audit.

```mermaid
graph TD
    Client["Client Angular"]

    subgraph Security["Spring Security + JWT"]
        Auth["Vérification token JWT"]
        Roles["Contrôle des rôles"]
    end

    subgraph Controllers["Couche Controller"]
        AC["AuthentificationController"]
        UC["UserController"]
        CC["CommandController"]
        DC["DeliveryController"]
        BC["BillController"]
    end

    subgraph Services["Couche Service"]
        AS["AuthentificationService"]
        US["UserService"]
        CS["CommandService"]
        DS["DeliveryService"]
        BS["BillService"]
    end

    subgraph Repositories["Couche Repository - Spring Data JPA"]
        UR["UserRepository"]
        CR["CommandRepository"]
        DR["DeliveryRepository"]
        BR["BillRepository"]
    end

    subgraph Models["Couche Model - JPA Entities"]
        UM["User"]
        CM["Command"]
        DM["Delivery"]
        BM["Bill"]
    end

    subgraph Database["Base de données"]
        PG["PostgreSQL 18"]
        HK["HikariCP - Pool de connexions"]
    end

    Client -->|"API REST / JSON + JWT"| Auth
    Auth --> Roles
    Roles --> Controllers
    AC --> AS
    UC --> US
    CC --> CS
    DC --> DS
    BC --> BS
    AS --> UR
    US --> UR
    CS --> CR
    DS --> DR
    BS --> BR
    Repositories --> Models
    Models --> HK
    HK --> PG
```

### Authentification — JWT

Pour la gestion de l'authentification, nous allons opter pour une approche basée sur les **JWT (JSON Web Token)**.

Dans l'ancienne version, l'authentification reposait sur un système de session côté serveur. Cette approche est incompatible avec une architecture REST et 
complique la scalabilité horizontale, si plusieurs instances du serveur tournent en parallèle, la session est perdue en changeant d'instance.

Avec JWT, le serveur génère un token signé lors de la connexion et le retourne au client. Ce token est ensuite envoyé dans chaque requête HTTP via le header 
`Authorization`. Le serveur n'a pas besoin de stocker l'état de la session, il vérifie simplement la validité du token. Cette approche est dite **stateless** et 
s'intègre naturellement avec Spring Security et Angular.

Ce choix répond directement aux enjeux de **disponibilité** et de **scalabilité** identifiés dans l'audit.

### Base de données - Ancienne structure

La base de données actuelle est composée de seulement deux tables : `user` et `delivery`.  

La table `user` stocke l'ensemble des utilisateurs de l'application. La gestion des rôles repose sur un simple champ booléen `admin`, ce qui ne 
permet de distinguer que deux types d'utilisateurs. Cette approche est incompatible avec le nouveau système de rôles à quatre niveaux attendu dans
la refonte. De plus, les mots de passe sont stockés en clair et aucune information complémentaire sur le client (adresse, téléphone...) n'est présente.  

La table `delivery` stocke les livraisons liées à un utilisateur via une clé étrangère `userId`. Le statut est un champ `VARCHAR` libre sans contrainte 
sur les valeurs possibles, ce qui représente un risque d'incohérence des données. Le prix est nullable car il n'est renseigné qu'au moment de la facturation, 
il n'existe pas de table dédiée à la facturation.  

On notera également l'absence de séparation entre la notion de **commande** et de **livraison**, ainsi que l'absence d'index explicites sur les colonnes 
fréquemment interrogées (`userId`, `status`).

Cette structure minimale ne peut pas supporter les nouveaux besoins fonctionnels et devra être entièrement repensée.

### Base de données - Nouvelle structure  

La base de données sera migrée de **MySQL 8** vers **PostgreSQL 18**. Ce choix est imposé par le service informatique de LiVrai et répond aux besoins de robustesse et de scalabilité
identifiés dans l'audit. PostgreSQL offre de meilleures garanties en termes de conformité SQL, de gestion des transactions et de performances sous forte volumétrie.  

La nouvelle base de données PostgreSQL sera repensée pour répondre aux besoins fonctionnels
de la refonte. Elle s'articulera autour des entités métier suivantes :

**`user`** : Stocke les informations de tous les utilisateurs de la plateforme. Le champ booléen `admin` est remplacé par une relation vers 
une table `role`, permettant une gestion fine des quatre niveaux d'accès. Le mot de passe sera hashé (bcrypt).

**`role`** : Table dédiée à la gestion des rôles (Client, Administrateur, Service Commercial, Service Livraison). Cette séparation permet 
d'ajouter de nouveaux rôles sans modifier la structure de la table `user`.

**`address`** : Stocke les adresses de livraison liées à un utilisateur. Un utilisateur peut posséder plusieurs adresses. Cette table répond 
au besoin de gestion des informations client mentionné dans la fiche descriptive.

**`command`** : Représente une commande passée par un client. La séparation entre commande et livraison permet de mieux modéliser le cycle de vie d'une demande.

**`delivery`** : Représente la livraison associée à une commande. Le statut sera contraint par une énumération afin d'éviter les incohérences de données constatées dans 
l'ancienne version.

**`bill`** : Table dédiée à la facturation, absente de l'ancienne version. Elle permettra au Service Commercial et au Service Livraison d'accéder à la facturation de façon structurée.  

Afin de concevoir la base de donnée, j'utilise la méthide MERISE pour m'aider à cette conception.

#### Dictionnaire de données
| Attribut | Entité | Type | Contraintes | Description |
|----------|--------|------|-------------|-------------|
| **Role** | | | | |
| id | Role | SERIAL | PK, NOT NULL | Identifiant unique |
| name | Role | VARCHAR(64) | NOT NULL, UNIQUE | Nom du rôle (CLIENT, ADMIN, COMMERCIAL, LIVRAISON) |
| created_at | Role | TIMESTAMP | NOT NULL | Date de création |
| updated_at | Role | TIMESTAMP | NOT NULL | Date de dernière modification |
| **User** | | | | |
| id | User | SERIAL | PK, NOT NULL | Identifiant unique |
| email | User | VARCHAR(255) | NOT NULL, UNIQUE | Adresse email de connexion |
| name | User | VARCHAR(128) | NOT NULL | Nom complet |
| password | User | VARCHAR(255) | NOT NULL | Mot de passe hashé (bcrypt) |
| phone | User | VARCHAR(20) | NULLABLE | Numéro de téléphone |
| created_at | User | TIMESTAMP | NOT NULL | Date de création du compte |
| updated_at | User | TIMESTAMP | NOT NULL | Date de dernière modification |
| role_id | User | INT | FK → Role, NOT NULL | Rôle de l'utilisateur |
| **Address** | | | | |
| id | Address | SERIAL | PK, NOT NULL | Identifiant unique |
| street | Address | VARCHAR(255) | NOT NULL | Rue et numéro |
| city | Address | VARCHAR(128) | NOT NULL | Ville |
| zip_code | Address | VARCHAR(16) | NOT NULL | Code postal |
| country | Address | VARCHAR(64) | NOT NULL | Pays |
| created_at | Address | TIMESTAMP | NOT NULL | Date de création |
| updated_at | Address | TIMESTAMP | NOT NULL | Date de dernière modification |
| user_id | Address | INT | FK → User, NOT NULL | Propriétaire de l'adresse |
| **Command** | | | | |
| id | Command | SERIAL | PK, NOT NULL | Identifiant unique |
| volume | Command | INT | NOT NULL, > 0 | Volume en m³ |
| weight | Command | INT | NOT NULL, > 0 | Poids en kg |
| created_at | Command | TIMESTAMP | NOT NULL | Date de création |
| updated_at | Command | TIMESTAMP | NOT NULL | Date de dernière modification |
| user_id | Command | INT | FK → User, NOT NULL | Client ayant passé la commande |
| address_id | Command | INT | FK → Address, NOT NULL | Adresse de livraison |
| **Delivery** | | | | |
| id | Delivery | SERIAL | PK, NOT NULL | Identifiant unique |
| status | Delivery | VARCHAR(32) | NOT NULL, ENUM | Statut (PENDING, ACCEPTED, REJECTED, DONE) |
| scheduled_at | Delivery | TIMESTAMP | NULLABLE | Date prévue de livraison |
| created_at | Delivery | TIMESTAMP | NOT NULL | Date de création |
| updated_at | Delivery | TIMESTAMP | NOT NULL | Date de dernière modification |
| command_id | Delivery | INT | FK → Command, NOT NULL, UNIQUE | Commande associée (1-1) |
| **Bill** | | | | |
| id | Bill | SERIAL | PK, NOT NULL | Identifiant unique |
| amount | Bill | DECIMAL(10,2) | NOT NULL, > 0 | Montant de la facture |
| created_at | Bill | TIMESTAMP | NOT NULL | Date de facturation |
| updated_at | Bill | TIMESTAMP | NOT NULL | Date de dernière modification |
| delivery_id | Bill | INT | FK → Delivery, NOT NULL, UNIQUE | Livraison facturée (1-1) |
#### MLD
```
ROLE (id, name, created_at, updated_at)
USER (id, email, name, password, phone, created_at, updated_at, #role_id)
ADDRESS (id, street, city, zip_code, country, created_at, updated_at, #user_id)
COMMAND (id, volume, weight, created_at, updated_at, #user_id, #address_id)
DELIVERY (id, status, scheduled_at, created_at, updated_at, #command_id)
BILL (id, amount, created_at, updated_at, #delivery_id)
```

#### MCD