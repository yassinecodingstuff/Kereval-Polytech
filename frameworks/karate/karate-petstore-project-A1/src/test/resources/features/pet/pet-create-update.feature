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
