# Analyse du contexte de LiVrai
LiVrai est une entreprise de livraison B2B en forte croissance d’une part par le nombre de client d’autre part par le volume de commande.  

La société possède une application de Customer Relationship Management (CRM). Suite à cette croissance les équipes constatent sur leur application :
-	Lenteurs
-	Difficultés de maintenance
     Cette croissance crée une pression directe sur le CRM, rendant un état des lieux structuré nécessaire avant toute décision.
     L’email de Meilin, responsable du CRM de Livrai, demande d’effectuer un audit suite à l’analyse de l’application actuelle.
     A l’aide de cet audit, je dois mettre en évidence :
-	Les fonctionnalités disponibles de la CRM, pour quels types d’utilisateurs :
-	Comment l’application est conçue techniquement ;
-	Les principaux point forts de la solution ;
-	Ses limites au regard de notre croissance (volumétrie) et de nos besoins de disponibilité  

Le but cet audit permettra la direction d’envisager ou non cette évolution de l’application.   

Le plan d’audit concernant LiVrai est le suivant :
1.	Contexte et périmètre
2.	Fonctionnalités (+ diagramme UML)
3.	Expérience utilisateur
4.	Description technique (+ diagramme de composants)
5.	Points forts et déficiences
6.	Conclusion

## Analyse de l'application après test

## Fonctionnalités

La page d'accueil du CRM est une page de connexion contenant un formulaire simple : 
- Email
- Mot de passe

### Parcours Admin

Lorsqu'on se connecte via un compte admin, nous avons deux fonctionnalités visible dans le menu : 
- Clients
- Livraisons

#### Clients
Sur l'écran **clients** il y a deux actions : 
- l'affichage de l'ensemble des clients
- la possibilité de créer des nouveaux client au CRM

#### Livraisons
Cet écran permet d'afficher les livraisons à venir et mes livraisons passées.

Pour les livraisons à venir : 

| ID | Volume    | Poids | Statut |            |                  |
|----|-----------|-------|--------|------------|------------------|
| 1  | NomClient | 10    | En 120 | En Attente | Accepter/Refuser |

Lorsqu'on clique sur l'action `Accepter`, un formulaire remplace ce bouton avec un champ pour saisir le montant à facturer.  
Du côté client, la livraison est passé au statut `Acceptée`.  
Une fois qu'on facture cette livraison, cette livraison est positionnée dans nos livraison passées sous cette forme :  

| ID | Volume    | Poids | Prix      | Statut   |
|----|-----------|-------|-----------|----------|
| 1  | NomClient | 10    | 120 120.0 | Terminée |

**Attention lors d'un refus d'une livraison, nous avons une erreur HTTP 405 sur l'application. Un admin ne peut donc pas refuser de livraison !**

### Parcours Client

Lorsqu'on se connecte via un compte client, nous avons deux fonctionnalités visible dans le menu :
- Commande
- Livraisons

#### Commande
Cet écran nous permet de créer une nouvelle demande de livraison.  
Un formulaire de nous permet de saisir :
- Le volume
- Le poids

Une fois le formulaire validé, cette commande est disponible dans l'onglet Livraisons.

#### Livraisons
Cet écran affiche nos livraisons à venir sous cette forme :   

| ID | Volume | Poids | Statut |
|----|--------|-------|--------|
| 1  | 10     | 120   | En attente |

Mais aussi nos livraisons passées sous cette forme : 

| ID | Volume | Poids     | Prix     | Statut     |
|----|--------|-----------|----------|------------|
| 1  | 10     | 120 120.0 | Terminée | En Attente | 

#### Anomalies d'affichage
L'affichage des données dans les tableaux présente des incohérences :
- Les colonnes **Poids** et **Prix** semblent fusionnées (`120 120.0`)
  dans la vue des livraisons passées, côté admin et client.
- L'en-tête des colonnes ne correspond pas toujours aux données affichées.

#### Fonctionnalité manquante
- L'action **Refuser** une livraison provoque une erreur **HTTP 405**
  (méthode POST non supportée). La fonctionnalité est présente dans l'UI
  mais non implémentée côté serveur.

Cette erreur est causée par une faute de frappe dans le fichier `deliveries.jsp` :
le formulaire "Refuser" poste sur l'URL `livraisons` au lieu de `livraison`,
ciblant ainsi un servlet qui ne gère pas les requêtes POST.

La fonctionnalité de refus est donc **non opérationnelle** : un admin ne peut pas
refuser une livraison, qui restera bloquée indéfiniment au statut `En attente`
côté client. Ce bug révèle également une absence de tests sur cette fonctionnalité.

#### Fonctionnalité de connexion
Lorsque nous saisissons de mauvaises informations, aucune alerte ou message n'est affiché sur la page.
Il semblerait qu'il y ait un simple rafraîchissement de la page.

#### Fonctionnalité de facturation
Lorsque nous facturons une livraison, aucune demande de confirmation n'est demandée. Si une erreur de saisie est effectuée,
l'action se déclenche quand même sans avoir la possibilité de revenir en arrière ou d'annuler la facturation.