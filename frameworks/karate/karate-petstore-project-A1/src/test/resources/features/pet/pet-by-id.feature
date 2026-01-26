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
