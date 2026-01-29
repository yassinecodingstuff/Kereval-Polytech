Feature: User API - Accounts and Sessions

  Background:
    * url baseUrl
    * header Accept = 'application/json'
    * def uuid = function(){ return java.util.UUID.randomUUID() + '' }

  # --- CRITICAL / HAPPY PATHS ---

  Scenario: Create a single user via POST /user
    * def username = 'user_' + uuid()
    Given path 'user'
    And request
    """
    {
      "id": 1001,
      "username": "#(username)",
      "firstName": "Pat",
      "lastName": "Store",
      "email": "pat.store@example.com",
      "password": "Passw0rd!",
      "phone": "+12025550123",
      "userStatus": 1
    }
    """
    When method post
    Then status 200

  Scenario: Login with valid credentials via GET /user/login
    * def username = 'login_' + uuid()
    * def password = 'Passw0rd!'
    Given path 'user'
    And request
    """
    {
      "id": 2001,
      "username": "#(username)",
      "firstName": "Log",
      "lastName": "In",
      "email": "login.user@example.com",
      "password": "#(password)",
      "phone": "123",
      "userStatus": 1
    }
    """
    When method post
    Then status 200
    Given path 'user', 'login'
    And param username = username
    And param password = password
    When method get
    Then status 200
    And match responseHeaders['X-Rate-Limit'] == '#present'
    And match responseHeaders['X-Expires-After'] == '#present'
    And match response contains 'logged in user session'

  Scenario: Logout current user via GET /user/logout
    Given path 'user', 'logout'
    When method get
    Then status 200

  Scenario: Get user by username via GET /user/{username}
    * def username = 'get_' + uuid()
    Given path 'user'
    And request { id: 3001, username: '#(username)', firstName: 'G', lastName: 'U', email: 'g.u@example.com', password: 'Passw0rd!', phone: '555', userStatus: 1 }
    When method post
    Then status 200
    Given path 'user', username
    When method get
    Then status 200
    And match response.username == username

  Scenario: Update user via PUT /user/{username}
    * def username = 'upd_' + uuid()
    Given path 'user'
    And request { id: 4001, username: '#(username)', firstName: 'Pat', lastName: 'User', email: 'p.user@example.com', password: 'Passw0rd!', phone: '555', userStatus: 1 }
    When method post
    Then status 200
    Given path 'user', username
    And request
    """
    {
      "id": 4001,
      "username": "#(username)",
      "firstName": "Patched",
      "lastName": "User",
      "email": "patched.user@example.com",
      "password": "Passw0rd!",
      "phone": "+12025550123",
      "userStatus": 2
    }
    """
    When method put
    Then status 200
    Given path 'user', username
    When method get
    Then status 200
    And match response.firstName == 'Patched'
    And match response.userStatus == 2

  Scenario: Delete user via DELETE /user/{username}
    * def username = 'del_' + uuid()
    Given path 'user'
    And request { id: 5001, username: '#(username)', firstName: 'D', lastName: 'U', email: 'd.u@example.com', password: 'Passw0rd!', phone: '555', userStatus: 1 }
    When method post
    Then status 200
    Given path 'user', username
    When method delete
    Then status 200
    Given path 'user', username
    When method get
    Then status 404

  # --- BULK CREATION & NEGATIVE ---

  Scenario: Create users with array via POST /user/createWithArray
    Given path 'user', 'createWithArray'
    And request
    """
    [
      { "id": 6001, "username": "batchUserA", "firstName": "A", "lastName": "One", "email": "a.one@example.com", "password": "pA!", "phone": "123", "userStatus": 1 },
      { "id": 6002, "username": "batchUserB", "firstName": "B", "lastName": "Two", "email": "b.two@example.com", "password": "pB!", "phone": "456", "userStatus": 1 }
    ]
    """
    When method post
    Then status 200

  Scenario: Create users with list via POST /user/createWithList
    Given path 'user', 'createWithList'
    And request
    """
    [
      { "id": 7001, "username": "listUserA", "firstName": "LA", "lastName": "One", "email": "la.one@example.com", "password": "pLA!", "phone": "789", "userStatus": 1 }
    ]
    """
    When method post
    Then status 200

  Scenario Outline: Login with invalid credentials is rejected via GET /user/login
    Given path 'user', 'login'
    And param username = <user>
    And param password = <pass>
    When method get
    Then status 400
    Examples:
      | user      | pass      |
      | 'invalid' | 'wrong'   |
      | ''        | ''        |

  Scenario: Login with wrong password for existing user is rejected via GET /user/login
    * def username = 'badlogin_' + uuid()
    Given path 'user'
    And request { id: 8001, username: '#(username)', firstName: 'B', lastName: 'L', email: 'b.l@example.com', password: 'GoodPass1!', phone: '111', userStatus: 1 }
    When method post
    Then status 200
    Given path 'user', 'login'
    And param username = username
    And param password = 'WrongPass!'
    When method get
    Then status 400

  Scenario Outline: Get user with invalid usernames returns error
    Given path 'user', <uname>
    When method get
    Then status 400
    Examples:
      | uname |
      | ''    |
      | ' '   |

  Scenario Outline: Delete user with invalid usernames returns error
    Given path 'user', <uname>
    When method delete
    Then status 400
    Examples:
      | uname |
      | ''    |
      | ' '   |
