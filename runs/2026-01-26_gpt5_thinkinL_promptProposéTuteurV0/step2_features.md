Parfait — voici l’**ÉTAPE 2 (conversion en Features Karate)** prête à déposer dans ton repo. J’ai organisé par domaine (`pet`, `store`, `user`), configuré headers & auth (optionnels), et intégré des IDs/données dynamiques via `#()` / validations `##`.

---

# Features Karate (.feature)

### `features/pet/pet-create-update.feature`

```gherkin
Feature: PET - Création & Mise à jour (/pet)

Background:
  * url baseUrl
  * configure headers = { Accept: 'application/json', Content-Type: 'application/json' }
  * if (karate.get('apiKey')) header api_key = apiKey
  * if (karate.get('oauthToken')) header Authorization = 'Bearer ' + oauthToken
  * def petId = 100000 + Math.floor(Math.random() * 100000)
  * def petValid =
  """
  {
    "id": #(petId),
    "name": "doggie",
    "photoUrls": ["https://example.com/pets/doggie.png"],
    "status": "available",
    "tags": [ { "id": 1, "name": "cute" } ],
    "category": { "id": 10, "name": "dogs" }
  }
  """
  * def petInvalid = { "id": "abc" }

@happy
Scenario: POST /pet - cas nominal (2xx)
  * path 'pet'
  * request petValid
  * method post
  * assert responseStatus >= 200 && responseStatus < 300
  * match response contains { id: #(petId), name: 'doggie' }

@error
Scenario: POST /pet - 405 Invalid input
  * path 'pet'
  * request { }
  * method post
  * status 405

@happy
Scenario: PUT /pet - mise à jour existante (2xx)
  * def updated = karate.clone(petValid)
  * set updated.status = 'sold'
  * path 'pet'
  * request updated
  * method put
  * assert responseStatus >= 200 && responseStatus < 300
  * match response contains { id: #(petId), status: 'sold' }

@error
Scenario: PUT /pet - 400 Invalid ID supplied
  * path 'pet'
  * request petInvalid
  * method put
  * status 400

@error
Scenario: PUT /pet - 404 Pet not found
  * def petUnknown = karate.clone(petValid)
  * set petUnknown.id = 999999
  * path 'pet'
  * request petUnknown
  * method put
  * status 404

@error
Scenario: PUT /pet - 405 Validation exception
  * path 'pet'
  * request { "name": "", "photoUrls": [] }
  * method put
  * status 405
```

---

### `features/pet/pet-search.feature`

```gherkin
Feature: PET - Recherche (/pet/findByStatus, /pet/findByTags)

Background:
  * url baseUrl
  * configure headers = { Accept: 'application/json', Content-Type: 'application/json' }
  * if (karate.get('apiKey')) header api_key = apiKey
  * if (karate.get('oauthToken')) header Authorization = 'Bearer ' + oauthToken

@happy
Scenario Outline: GET /pet/findByStatus - statut valide → 200
  * path 'pet', 'findByStatus'
  * param status = <status>
  * method get
  * status 200
  * match response == '#[]'
  * match each response contains { id: '#number', name: '#string' }

  Examples:
    | status    |
    | available |
    | pending   |
    | sold      |

@error
Scenario: GET /pet/findByStatus - 400 Invalid status value
  * path 'pet', 'findByStatus'
  * param status = 'unknown'
  * method get
  * status 400

@deprecated @happy
Scenario: GET /pet/findByTags - 200
  * path 'pet', 'findByTags'
  * param tags = ['cute','brown']
  * method get
  * status 200
  * match response == '#[]'

@deprecated @limit @error
Scenario: GET /pet/findByTags - 400 Invalid tag value (chaine vide)
  * path 'pet', 'findByTags'
  * param tags = ['']
  * method get
  * status 400
```

---

### `features/pet/pet-by-id.feature`

```gherkin
Feature: PET - Par ID, Form Update & Delete (/pet/{petId})

Background:
  * url baseUrl
  * configure headers = { Accept: 'application/json', Content-Type: 'application/json' }
  * if (karate.get('apiKey')) header api_key = apiKey
  * if (karate.get('oauthToken')) header Authorization = 'Bearer ' + oauthToken

@happy
Scenario: GET /pet/{petId} - 200
  * path 'pet', 1
  * method get
  * status 200
  * match response contains { id: 1 }

@error
Scenario: GET /pet/{petId} - 400 Invalid ID supplied
  * path 'pet', 'abc'
  * method get
  * status 400

@error
Scenario: GET /pet/{petId} - 404 Pet not found
  * path 'pet', 999999
  * method get
  * status 404

@error
Scenario: POST /pet/{petId} (form) - 405 Invalid input
  * path 'pet', 1
  * form field name = ''
  * form field status = ''
  * method post
  * status 405

@error
Scenario: DELETE /pet/{petId} - 400 Invalid ID supplied
  * path 'pet', 'abc'
  * method delete
  * status 400

@error
Scenario: DELETE /pet/{petId} - 404 Pet not found
  * path 'pet', 999999
  * method delete
  * status 404
```

---

### `features/pet/pet-upload-image.feature`

```gherkin
Feature: PET - Upload image (/pet/{petId}/uploadImage)

Background:
  * url baseUrl
  * configure headers = { Accept: 'application/json' }
  * if (karate.get('apiKey')) header api_key = apiKey
  * if (karate.get('oauthToken')) header Authorization = 'Bearer ' + oauthToken
  * def samplePath = 'classpath:files/sample.png'

@happy
Scenario: POST /pet/{petId}/uploadImage - 200
  * path 'pet', 1, 'uploadImage'
  * multipart file file = { read: #(samplePath), filename: 'sample.png', contentType: 'image/png' }
  * multipart field additionalMetadata = 'avatar'
  * method post
  * status 200
  * match response contains { code: '#number', message: '##string' }
```

---

### `features/store/store.feature`

```gherkin
Feature: STORE - Inventaire & Commandes

Background:
  * url baseUrl
  * configure headers = { Accept: 'application/json', Content-Type: 'application/json' }
  * if (karate.get('apiKey')) header api_key = apiKey
  * if (karate.get('oauthToken')) header Authorization = 'Bearer ' + oauthToken
  * def orderId = 11

@happy
Scenario: GET /store/inventory - 200
  * path 'store', 'inventory'
  * method get
  * status 200
  * match response == '#object'
  * match each response.* == '#number'

@happy
Scenario: POST /store/order - 200
  * def orderValid =
  """
  { "id": #(orderId), "petId": 1001, "quantity": 1, "status": "placed", "complete": true }
  """
  * path 'store', 'order'
  * request orderValid
  * method post
  * status 200
  * match response contains { id: #(orderId), status: '#string' }

@error
Scenario: POST /store/order - 400 Invalid Order
  * path 'store', 'order'
  * request { "id": 12, "quantity": -1 }
  * method post
  * status 400

@happy
Scenario: GET /store/order/{orderId} - 200 (1..10)
  * path 'store', 'order', 5
  * method get
  * status 200
  * match response contains { id: 5 }

@limit @error
Scenario: GET /store/order/{orderId} - 400 Invalid ID supplied
  * path 'store', 'order', 0
  * method get
  * status 400

@error
Scenario: GET /store/order/{orderId} - 404 Order not found
  * path 'store', 'order', 9999
  * method get
  * status 404

@limit @error
Scenario: DELETE /store/order/{orderId} - 400 Invalid ID supplied
  * path 'store', 'order', 0
  * method delete
  * status 400

@error
Scenario: DELETE /store/order/{orderId} - 404 Order not found
  * path 'store', 'order', 9999
  * method delete
  * status 404
```

---

### `features/user/user.feature`

```gherkin
Feature: USER - Création, Login, CRUD

Background:
  * url baseUrl
  * configure headers = { Accept: 'application/json', Content-Type: 'application/json' }
  * if (karate.get('apiKey')) header api_key = apiKey
  * if (karate.get('oauthToken')) header Authorization = 'Bearer ' + oauthToken
  * def userValid =
  """
  { "id": 201, "username": "user1", "firstName": "Ada", "lastName": "Lovelace",
    "email": "ada@example.com", "password": "P@ssw0rd", "phone": "0600000000", "userStatus": 1 }
  """

@happy
Scenario: POST /user - succès
  * path 'user'
  * request userValid
  * method post
  * assert responseStatus >= 200 && responseStatus < 300

@happy
Scenario: POST /user/createWithArray - succès
  * path 'user', 'createWithArray'
  * request [ userValid ]
  * method post
  * assert responseStatus >= 200 && responseStatus < 300

@happy
Scenario: POST /user/createWithList - succès
  * path 'user', 'createWithList'
  * request [ userValid ]
  * method post
  * assert responseStatus >= 200 && responseStatus < 300

@happy
Scenario: GET /user/login - 200 + entêtes
  * path 'user', 'login'
  * param username = 'user1'
  * param password = 'P@ssw0rd'
  * method get
  * status 200
  * match responseHeaders['X-Rate-Limit'][0] == '#number'
  * match responseHeaders['X-Expires-After'][0] == '#string'

@error
Scenario: GET /user/login - 400 Invalid username/password supplied
  * path 'user', 'login'
  * param username = 'user1'
  * param password = ''
  * method get
  * status 400

@happy
Scenario: GET /user/logout - succès
  * path 'user', 'logout'
  * method get
  * assert responseStatus >= 200 && responseStatus < 300

@happy
Scenario: GET /user/{username} - 200
  * path 'user', 'user1'
  * method get
  * status 200
  * match response contains { username: 'user1' }

@error
Scenario: GET /user/{username} - 400 Invalid username supplied
  * path 'user', ''
  * method get
  * status 400

@error
Scenario: GET /user/{username} - 404 User not found
  * path 'user', 'ghost-user'
  * method get
  * status 404

@error
Scenario: PUT /user/{username} - 400 Invalid user supplied
  * path 'user', 'user1'
  * request { "id": "abc" }
  * method put
  * status 400

@error
Scenario: PUT /user/{username} - 404 User not found
  * path 'user', 'ghost-user'
  * request userValid
  * method put
  * status 404

@error
Scenario: DELETE /user/{username} - 400 Invalid username supplied
  * path 'user', ''
  * method delete
  * status 400

@error
Scenario: DELETE /user/{username} - 404 User not found
  * path 'user', 'ghost-user'
  * method delete
  * status 404
```

---

# Tableau de couverture (Étape 2)

> Lignes indiquent la ligne du mot-clé `Scenario` dans le fichier correspondant.

| Endpoint                     | Méthode |      Code Retour | Feature Karate                | Ligne | Couvert |
| ---------------------------- | ------- | ---------------: | ----------------------------- | ----: | :-----: |
| /pet                         | POST    |              2xx | pet/pet-create-update.feature |    23 |    ✅    |
| /pet                         | POST    |              405 | pet/pet-create-update.feature |    31 |    ✅    |
| /pet                         | PUT     |              2xx | pet/pet-create-update.feature |    38 |    ✅    |
| /pet                         | PUT     |              400 | pet/pet-create-update.feature |    48 |    ✅    |
| /pet                         | PUT     |              404 | pet/pet-create-update.feature |    55 |    ✅    |
| /pet                         | PUT     |              405 | pet/pet-create-update.feature |    64 |    ✅    |
| /pet/findByStatus            | GET     |              200 | pet/pet-search.feature        |    10 |    ✅    |
| /pet/findByStatus            | GET     |              400 | pet/pet-search.feature        |    25 |    ✅    |
| /pet/findByTags (deprecated) | GET     |              200 | pet/pet-search.feature        |    32 |    ✅    |
| /pet/findByTags (deprecated) | GET     |              400 | pet/pet-search.feature        |    40 |    ✅    |
| /pet/{petId}                 | GET     |              200 | pet/pet-by-id.feature         |    10 |    ✅    |
| /pet/{petId}                 | GET     |              400 | pet/pet-by-id.feature         |    17 |    ✅    |
| /pet/{petId}                 | GET     |              404 | pet/pet-by-id.feature         |    23 |    ✅    |
| /pet/{petId}                 | POST    |              405 | pet/pet-by-id.feature         |    29 |    ✅    |
| /pet/{petId}                 | DELETE  |              400 | pet/pet-by-id.feature         |    37 |    ✅    |
| /pet/{petId}                 | DELETE  |              404 | pet/pet-by-id.feature         |    43 |    ✅    |
| /pet/{petId}/uploadImage     | POST    |              200 | pet/pet-upload-image.feature  |    11 |    ✅    |
| /store/inventory             | GET     |              200 | store/store.feature           |    11 |    ✅    |
| /store/order                 | POST    |              200 | store/store.feature           |    19 |    ✅    |
| /store/order                 | POST    |              400 | store/store.feature           |    31 |    ✅    |
| /store/order/{orderId}       | GET     |              200 | store/store.feature           |    38 |    ✅    |
| /store/order/{orderId}       | GET     |              400 | store/store.feature           |    45 |    ✅    |
| /store/order/{orderId}       | GET     |              404 | store/store.feature           |    51 |    ✅    |
| /store/order/{orderId}       | DELETE  |              400 | store/store.feature           |    57 |    ✅    |
| /store/order/{orderId}       | DELETE  |              404 | store/store.feature           |    63 |    ✅    |
| /user                        | POST    | default (succès) | user/user.feature             |    15 |    ✅    |
| /user/createWithArray        | POST    | default (succès) | user/user.feature             |    22 |    ✅    |
| /user/createWithList         | POST    | default (succès) | user/user.feature             |    29 |    ✅    |
| /user/login                  | GET     |              200 | user/user.feature             |    36 |    ✅    |
| /user/login                  | GET     |              400 | user/user.feature             |    46 |    ✅    |
| /user/logout                 | GET     | default (succès) | user/user.feature             |    54 |    ✅    |
| /user/{username}             | GET     |              200 | user/user.feature             |    60 |    ✅    |
| /user/{username}             | GET     |              400 | user/user.feature             |    67 |    ✅    |
| /user/{username}             | GET     |              404 | user/user.feature             |    73 |    ✅    |
| /user/{username}             | PUT     |              400 | user/user.feature             |    79 |    ✅    |
| /user/{username}             | PUT     |              404 | user/user.feature             |    86 |    ✅    |
| /user/{username}             | DELETE  |              400 | user/user.feature             |    93 |    ✅    |
| /user/{username}             | DELETE  |              404 | user/user.feature             |    99 |    ✅    |

---

## Choix techniques & justifications (court)

* **Karate idiomatique** : `*` pour les steps, `match`, `status`, `assert` et validations de headers.
* **Headers & Auth** : configuration dans `Background` + **ajout conditionnel** d’`api_key` et `Authorization` s’ils existent dans `karate-config.js`.
* **Dynamique** : IDs via `#()` (ex. `petId`, `orderId`), tolérance de 2xx quand le Swagger n’impose pas un code précis.
* **Robustesse** : validations de structure (`#[]`, `#object`, `#number`, `##string`) et cas limites (IDs non numériques, bornes, champs vides).

---

## Prochaines étapes / améliorations

1. **`karate-config.js`** : définir `baseUrl`, `apiKey`, `oauthToken` par environnement (dev/stage/prod).
2. **Seeds & hooks** : utilitaires réutilisables pour créer/supprimer des entités avant/après tests (ex. `callSingle` pour créer un `Pet`).
3. **Tagging CI** : `@smoke` (inventory, findByStatus, login), `@regression` (tout), `@negative`.
4. **Données aléatoires** : utiliser `karate.randomUUID()` / générateurs pour éviter les collisions.
5. **Runners Maven/Gradle + reporting** : JUnit XML + HTML intégré de Karate.

Tu veux que je te génère aussi le **squelette Maven/Gradle + `karate-config.js`** avec ces features déjà rangées ?
