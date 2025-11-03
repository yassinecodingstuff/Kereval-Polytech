Ce que j’ai remarqué

Dans le Gherkin généré, il manque de nombreux cas d’erreur et aucune vérification de l’idempotence.

Le Swagger Petstore v2 prévoit pourtant des réponses d’erreur (ex : 405, 404, 415…), mais presque aucun scénario ne cible ces cas.

Détails vus dans Swagger (petstore v2)

POST /pet (Add a new pet to the store)

Swagger mentionne le code 405 : Invalid input.

Aucun scénario ne couvre le cas où le payload est invalide (statut hors enum, mauvais type, etc.).

Le code 415 (Content-Type incorrect) n’est pas du tout testé.

PUT /pet (Update an existing pet)

Cas attendus selon Swagger :

400 (Invalid ID supplied)

404 (Pet not found)

405 (Validation exception)

Aucun scénario ne traite explicitement ces retours d’erreur (typiquement lors d’un update avec un id inexistant, un id invalide, ou un schéma incorrect).

Erreurs Génériques

Il manque la couverture des cas d’erreur génériques : 415 (bad Content-Type), 401/403 (auth, même si non obligatoire ici), et 422 (payload avec mauvais schéma si applicable).

Ce qui manque de façon générale

Couverture d’erreurs incomplète : Pas de test pour 405, 415, 400, 404 sur la plupart des endpoints.

Idempotence non testée :

PUT x2 : Un deuxième appel identique sur le même id devrait laisser l’état du pet strictement inchangé (pas de doublon ni de modification indésirable).

DELETE x2 : Le deuxième appel devrait retourner un 404 (pet déjà supprimé) ou 204 en fonction de l’API : on doit vérifier la suppression effective.

POST x2 : Normalement non idempotent, mais il faut documenter et vérifier le comportement (nouvel id généré à chaque POST ou protection via idempotency key si supportée).

Pourquoi c’est un problème

Sans ces tests, des régressions et des comportements inattendus peuvent passer en production :

Acceptation de mauvais Content-Type, défaut de gestion d’un schéma incorrect, risque de doublons lors de retry, etc.

En production, des retry automatiques (suite à timeout, réseau, double click UI ou via un proxy) arrivent fréquemment. Sans tests sur l’idempotence, ces bugs ne sont découverts qu’après coup.
