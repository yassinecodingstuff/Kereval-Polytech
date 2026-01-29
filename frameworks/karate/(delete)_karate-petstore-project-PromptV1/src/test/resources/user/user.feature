Feature: User API v2 - Identity CRUD, auth, and error handling

  Background:
    * url 'https://petstore.swagger.io/v2'
    * configure headers = { Accept: 'application/json' }
    * def userSchema =
    """
    {
      id: '#? _ == null || typeof _ == "number"',
      username: '#string',
      firstName: '#? _ == null || typeof _ == "string"',
      lastName:  '#? _ == null || typeof _ == "string"',
      email:     '#? _ == null || typeof _ == "string"',
      password:  '#? _ == null || typeof _ == "string"',
      phone:     '#? _ == null || typeof _ == "string"',
      userStatus:'#? _ == null || typeof _ == "number"'
    }
    """

  @user @positive @critical
  Scenario: Create user and retrieve by username
    * def uname = 'user_' + karate.uuid()
    Given path 'user'
    And request { id: #(Math.floor(Math.random()*900000000)+1), username: '#(uname)', firstName: 'Ada', lastName: 'Lovelace', email: 'ada@example.com', password: 's3cret', phone: '123456', userStatus: 1 }
    When method post
    Then status 200

    Given path 'user', uname
    When method get
    Then status 200
    And match response == userSchema
    And match response.username == uname

  @user @positive
  Scenario: Update user by username
    * def uname = 'user_' + karate.uuid()
    Given path 'user'
    And request { username: '#(uname)', firstName: 'Lin', lastName: 'Init', email: 'lin@example.com', password: 'p@ss', phone: '555' }
    When method post
    Then status 200

    Given path 'user', uname
    And request { id: #(Math.floor(Math.random()*900000000)+1), username: '#(uname)', firstName: 'Linus', lastName: 'Init', email: 'linus@example.com', password: 'p@ss2', phone: '777', userStatus: 2 }
    When method put
    Then status 200

    Given path 'user', uname
    When method get
    Then status 200
    And match response.firstName == 'Linus'
    And match response.userStatus == 2

  @user @positive @cleanup
  Scenario: Delete user by username
    * def uname = 'user_' + karate.uuid()
    Given path 'user'
    And request { username: '#(uname)', firstName: 'Del', lastName: 'Me', email: 'del@example.com', password: 'x', phone: '0' }
    When method post
    Then status 200

    Given path 'user', uname
    When method delete
    Then status 200

    Given path 'user', uname
    When method get
    Then status 404

  @user @positive @medium
  Scenario: Create users with array
    * def u1 = 'arr_' + karate.uuid()
    * def u2 = 'arr_' + karate.uuid()
    Given path 'user/createWithArray'
    And request
    """
    [
      { "id": #(Math.floor(Math.random()*900000000)+1), "username": "#(u1)", "firstName": "A", "lastName": "B", "password": "p" },
      { "id": #(Math.floor(Math.random()*900000000)+1), "username": "#(u2)", "firstName": "C", "lastName": "D", "password": "p" }
    ]
    """
    When method post
    Then status 200

    Given path 'user', u1
    When method get
    Then status 200
    And match response.username == u1

  @user @positive
  Scenario: Create users with list
    * def u1 = 'lst_' + karate.uuid()
    Given path 'user/createWithList'
    And request
    """
    [
      { "id": #(Math.floor(Math.random()*900000000)+1), "username": "#(u1)", "firstName": "L", "lastName": "S", "password": "p" }
    ]
    """
    When method post
    Then status 200

    Given path 'user', u1
    When method get
    Then status 200
    And match response.username == u1

  @user @positive @critical @security
  Scenario: Login with valid credentials returns session info and headers
    * def uname = 'login_' + karate.uuid()
    Given path 'user'
    And request { username: '#(uname)', firstName: 'Log', lastName: 'In', email: 'li@example.com', password: 'pw', phone: '1' }
    When method post
    Then status 200

    Given path 'user/login'
    And param username = uname
    And param password = 'pw'
    When method get
    Then status 200
    And match response contains 'logged in user session'
    And match responseHeaders contains { 'X-Rate-Limit': '#string', 'X-Expires-After': '#string' }

  @user @negative @security
  Scenario: Login with invalid credentials -> 400
    Given path 'user/login'
    And param username = 'nope'
    And param password = 'wrong'
    When method get
    Then status 400

  @user @positive
  Scenario: Logout current user session
    Given path 'user/logout'
    When method get
    Then status 200

  @user @negative
  Scenario: Get user by username not found -> 404
    Given path 'user', 'unknown_user_404'
    When method get
    Then status 404

  @user @negative @validation
  Scenario: Update user with invalid username -> 400
    Given path 'user', ''
    And request { username: '', firstName: 'X' }
    When method put
    Then status 400

  @user @negative
  Scenario: Delete user with invalid username -> 400
    Given path 'user', ''
    When method delete
    Then status 400
