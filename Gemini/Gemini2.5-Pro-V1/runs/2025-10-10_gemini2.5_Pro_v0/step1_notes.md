Ce que j’ai remarqué
- Dans le Gherkin généré, il manque pas mal de cas d’erreur et rien sur l’idempotence.
- Swagger, lui, prévoit des réponses d’erreur (ex. 405, 404…), mais aucun scénario ne les teste.

Détails vus dans Swagger (petstore v2)

POST /pet (Add a new pet to the store)
- Swagger mentionne 405 – Invalid input.
- Aucun scénario ne couvre ce 405 

PUT /pet (Update an existing pet)
- Cas attendus : 400 (Invalid ID supplied), 404 (Pet not found), 405 (Validation exception).
- Constat : Aucun scénario ne traite ces cas 400/404/405.

Ce qui manque de façon générale
- Couverture d’erreurs incomplète : on ne teste presque pas les codes 405 / 415 / 401 / 403 / 422.
- Idempotence non testée
 - PUT répété doit laisser le même état (pas de doublons).
 - DELETE répété : 1ʳᵉ fois OK, 2ᵉ fois 404 (ou 204 selon l’API) → l’état final reste “supprimé”.
 - POST répété : par défaut non idempotent (risque de doublons).
  - Si l’API supporte une idempotency key, le 2ᵉ POST ne doit pas créer une nouvelle ressource.

Pourquoi c’est un problème 
- Sans ces tests, on peut passer à côté de régressions et de mauvais comportements (mauvais Content-Type accepté, schéma non respecté, doublons en cas de retry, etc.).
- En prod, il y a des retries (timeout, double clic, proxy). Si on ne teste pas l’idempotence, on découvre les soucis trop tard.

Ce que je propose d’ajouter dans la prompt:
1. Négatifs clés
   - POST /pet → 415 si Content-Type ≠ application/json.
   - POST /pet → 405 si payload invalide (status hors enum, photoUrls au mauvais type).
   - PUT /pet → 404 si id inexistant ; 400 si id invalide (string, 0, négatif).
2. Idempotence
   - PUT x2 → même état.
   - DELETE x2 → 404 la 2ᵉ fois.
   - POST x2 → définir l’attendu (deux IDs ou une seule ressource avec idempotency key).


