Feature: User — Account Management

Background:
  * url baseUrl
  * configure headers = { Accept: 'application/json' }

@P0 @user @create
Scenario: [TC-USER-001] Create single user returns success
  Given path 'user'
  And request
  """
  {
    "id": 1301,
    "username": "karate_user_01",
    "firstName": "Pat",
    "lastName": "Lee",
    "email": "pat.lee@example.com",
    "password": "s3cret!",
    "phone": "+1-555-0001",
    "userStatus": 1
  }
  """
  When method post
  Then status 200

@P1 @user @create @bulk
Scenario: [TC-USER-002] Create users with array returns success
  Given path 'user', 'createWithArray'
  And request
  """
  [
    { "id": 1302, "username": "array_user_1", "firstName": "A", "lastName": "U", "email": "a1@example.com", "password": "p1", "phone": "1" },
    { "id": 1303, "username": "array_user_2", "firstName": "B", "lastName": "U", "email": "a2@example.com", "password": "p2", "phone": "2" }
  ]
  """
  When method post
  Then status 200

@P1 @user @create @bulk
Scenario: [TC-USER-003] Create users with list returns success
  Given path 'user', 'createWithList'
  And request
  """
  [
    { "id": 1304, "username": "list_user_1", "firstName": "L", "lastName": "U", "email": "l1@example.com", "password": "p1", "phone": "1" },
    { "id": 1305, "username": "list_user_2", "firstName": "L2", "lastName": "U2", "email": "l2@example.com", "password": "p2", "phone": "2" }
  ]
  """
  When method post
  Then status 200

@P0 @user @auth @login
Scenario: [TC-USER-004] Login with valid credentials returns session string and headers
  * def uname = 'karate_login_01'
  * def pwd = 'p@ssW0rd'
  Given path 'user'
  And request
  """
  { "id": 1306, "username": "karate_login_01", "firstName": "K", "lastName": "L", "email": "kl@example.com", "password": "p@ssW0rd", "phone": "9" }
  """
  When method post
  Then status 200
  Given path 'user', 'login'
  And param username = uname
  And param password = pwd
  When method get
  Then status 200
  And match response == '#string'
  * def rate = responseHeaders['X-Rate-Limit'] ? responseHeaders['X-Rate-Limit'][0] : '0'
  And match rate == '#regex ^\d+$'
  * def expires = responseHeaders['X-Expires-After'][0]
  And match expires == '#regex ^\d{4}-\d{2}-\d{2}T.+$'

@P0 @user @auth @login @negative
Scenario: [TC-USER-005] Login with invalid credentials returns 400
  Given path 'user', 'login'
  And param username = 'karate_login_01'
  And param password = 'bad'
  When method get
  Then status 400
  And match response.message contains 'Invalid username/password supplied'

@P2 @user @auth @logout
Scenario: [TC-USER-006] Logout returns success
  Given path 'user', 'logout'
  When method get
  Then status 200

@P0 @user @read
Scenario: [TC-USER-007] Get user by username returns User schema
  * def uname = 'karate_user_read'
  Given path 'user'
  And request
  """
  { "id": 1307, "username": "karate_user_read", "firstName": "R", "lastName": "D", "email": "rd@example.com", "password": "pw", "phone": "1" }
  """
  When method post
  Then status 200
  Given path 'user', uname
  When method get
  Then status 200
  And match response ==
  """
  {
    "id": "#number",
    "username": "karate_user_read",
    "firstName": "#string",
    "lastName": "#string",
    "email": "#string",
    "password": "##string",
    "phone": "##string",
    "userStatus": "##number"
  }
  """

@P0 @user @update
Scenario: [TC-USER-008] Update user replaces fields
  * def uname = 'karate_user_update'
  Given path 'user'
  And request
  """
  { "id": 1308, "username": "karate_user_update", "firstName": "Old", "lastName": "Name", "email": "old@example.com", "password": "pw", "phone": "1" }
  """
  When method post
  Then status 200
  Given path 'user', uname
  And request
  """
  { "id": 1308, "username": "karate_user_update", "firstName": "Casey", "lastName": "Nguyen", "email": "casey.nguyen@example.com", "password": "pw", "phone": "1" }
  """
  When method put
  Then status 200
  Given path 'user', uname
  When method get
  Then status 200
  And match response.firstName == 'Casey'
  And match response.lastName == 'Nguyen'
  And match response.email == 'casey.nguyen@example.com'

@P0 @user @delete @notFound
Scenario: [TC-USER-009] Delete user then verify 404 on read
  * def uname = 'karate_user_delete'
  Given path 'user'
  And request
  """
  { "id": 1309, "username": "karate_user_delete", "firstName": "Del", "lastName": "Me", "email": "del@example.com", "password": "pw", "phone": "1" }
  """
  When method post
  Then status 200
  Given path 'user', uname
  When method delete
  Then match [200,204] contains responseStatus
  Given path 'user', uname
  When method get
  Then status 404

@P0 @user @validation @negative
Scenario: [TC-USER-010A] Get with invalid username returns 400 or 404
  Given path 'user', 'nonexistent'
  When method get
  Then match [400,404] contains responseStatus

@P0 @user @validation @negative
Scenario: [TC-USER-010B] Update with invalid username returns 400 or 404
  Given path 'user', 'nonexistent'
  And request {}
  When method put
  Then match [400,404] contains responseStatus

@P0 @user @validation @negative
Scenario: [TC-USER-010C] Delete with invalid username returns 400 or 404
  Given path 'user', 'nonexistent'
  When method delete
  Then match [400,404] contains responseStatus
