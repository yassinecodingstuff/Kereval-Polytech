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
