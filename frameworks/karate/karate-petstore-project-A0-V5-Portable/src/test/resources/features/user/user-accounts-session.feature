Feature: User API — Accounts & Session Management — Swagger Petstore v2
  Background:
    * url baseUrl
    * configure headers = { Accept: 'application/json' }

  Scenario: Create User and verify retrieval by username
    * def uname = 'qa_user_1201'
    Given path 'user'
    And header Content-Type = 'application/json'
    And request { "id": 1201, "username": "#(uname)", "firstName": "QA", "lastName": "User", "email": "qa.user@example.com", "password": "P@ssw0rd!", "phone": "+33123456789", "userStatus": 1 }
    When method post
    Then status 200

    Given path 'user', uname
    When method get
    Then status 200
    And match response contains { id: '#number', username: '#string', email: 'qa.user@example.com', userStatus: '#number' }

  Scenario: Update existing User and verify changes
    * def uname = 'qa_user_1202'
    Given path 'user'
    And header Content-Type = 'application/json'
    And request { "id": 1202, "username": "#(uname)", "firstName": "QA", "lastName": "User", "email": "qa.user@example.com", "password": "old", "phone": "+33123456789", "userStatus": 1 }
    When method post
    Then status 200

    Given path 'user', uname
    And header Content-Type = 'application/json'
    And request { "id": 1202, "username": "#(uname)", "firstName": "QA2", "lastName": "User2", "email": "qa.user2@example.com", "password": "N3wP@ss!", "phone": "+33987654321", "userStatus": 2 }
    When method put
    Then status 200

    Given path 'user', uname
    When method get
    Then status 200
    And match response contains { firstName: 'QA2', email: 'qa.user2@example.com' }

  Scenario: Delete User and verify 404 on subsequent retrieval
    * def uname = 'qa_user_1203'
    Given path 'user'
    And header Content-Type = 'application/json'
    And request { "id": 1203, "username": "#(uname)", "password": "x" }
    When method post
    Then status 200

    Given path 'user', uname
    When method delete
    Then match [200,204,404] contains responseStatus

    Given path 'user', uname
    When method get
    Then match [404] contains responseStatus

  Scenario: Successful login returns token string and session headers
    * def uname = 'login_user_1204'
    Given path 'user'
    And header Content-Type = 'application/json'
    And request { "id": 1204, "username": "#(uname)", "password": "password1" }
    When method post
    Then status 200

    Given path 'user', 'login'
    And param username = uname
    And param password = 'password1'
    When method get
    Then status 200
    And match response == '#string'
    * def rl = responseHeaders['X-Rate-Limit'][0]
    * match rl == '#? /^\\d+$/.test(_)'
    * def exp = responseHeaders['X-Expires-After'][0]
    * match exp == '#string'

  Scenario: Failed login with bad credentials returns 400 with typed body
    Given path 'user', 'login'
    And param username = 'invalid'
    And param password = 'bad'
    When method get
    Then status 400
    * def t = karate.typeOf(response)
    * if (t == 'map') match response contains { message: '#string' }
    * else match response == '#string'

  Scenario: Create users with array input
    Given path 'user', 'createWithArray'
    And header Content-Type = 'application/json'
    And request
      """
      [
        { "id": 1205, "username": "bulk_array_1", "password": "a" },
        { "id": 1206, "username": "bulk_array_2", "password": "b" }
      ]
      """
    When method post
    Then status 200

  Scenario: Create users with list input
    Given path 'user', 'createWithList'
    And header Content-Type = 'application/json'
    And request
      """
      [
        { "id": 1207, "username": "bulk_list_1", "password": "a" },
        { "id": 1208, "username": "bulk_list_2", "password": "b" }
      ]
      """
    When method post
    Then status 200

  Scenario: Logout current user session
    Given path 'user', 'logout'
    When method get
    Then status 200

  Scenario: Get non-existing user returns 404 (typed body)
    Given path 'user', 'no_such_user_9999'
    When method get
    Then status 404
    * def t = karate.typeOf(response)
    * if (t == 'map') match response contains { message: '#string' }
    * else match response == '#string'

  Scenario: Update non-existing user returns tolerant status
    Given path 'user', 'ghost_user_7777'
    And header Content-Type = 'application/json'
    And request { "id": 1299, "username": "ghost_user_7777", "password": "x" }
    When method put
    Then match [200,404] contains responseStatus

  Scenario: Login with wildcard Accept negotiates text
    Given path 'user', 'login'
    And header Accept = '*/*'
    And param username = 'anonymous'
    And param password = 'nopass'
    When method get
    Then match [200,400] contains responseStatus
    * if (responseStatus == 200) match response == '#string'
