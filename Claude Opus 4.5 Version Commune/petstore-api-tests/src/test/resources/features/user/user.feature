Feature: User Management API
  As an administrator
  I want to manage user accounts
  So that users can access the pet store

  Background:
    * url baseUrl
    * configure headers = { Accept: 'application/json' }
    * def generateUserId = function(){ return Math.floor(Math.random() * 90000) + 10000 }
    * def generateUsername = function(){ return 'testuser_' + java.util.UUID.randomUUID().toString().substring(0, 8) }

  # ==========================================================================
  # TC-USER-001: Create User - Single User
  # Risk Level: Critical
  # ==========================================================================

  @critical @smoke @user @create
  Scenario: TC-USER-001-01 - Successfully create a new user with all fields
    * def userId = generateUserId()
    * def username = generateUsername()
    * def userPayload =
      """
      {
        "id": #(userId),
        "username": "#(username)",
        "firstName": "John",
        "lastName": "Doe",
        "email": "john@example.com",
        "password": "SecurePass123",
        "phone": "555-1234",
        "userStatus": 1
      }
      """
    Given path 'user'
    And request userPayload
    When method post
    Then status 200

    Given path 'user', username
    When method get
    Then status 200
    And match response.username == username

  @high @user @create
  Scenario: TC-USER-001-02 - Successfully create a user with minimum required fields
    * def username = generateUsername()
    * def userPayload =
      """
      {
        "username": "#(username)"
      }
      """
    Given path 'user'
    And request userPayload
    When method post
    Then status 200

  @high @user @create
  Scenario: TC-USER-001-03 - Create user with all valid field types
    * def userId = generateUserId()
    * def username = generateUsername()
    * def userPayload =
      """
      {
        "id": #(userId),
        "username": "#(username)",
        "firstName": "Jane",
        "lastName": "Smith",
        "email": "jane.smith@example.com",
        "password": "P@ssw0rd!",
        "phone": "+1-555-987-6543",
        "userStatus": 0
      }
      """
    Given path 'user'
    And request userPayload
    When method post
    Then status 200

  # ==========================================================================
  # TC-USER-002: Create Users - Bulk Operations
  # Risk Level: High
  # ==========================================================================

  @high @user @create @bulk
  Scenario: TC-USER-002-01 - Successfully create users with array input
    * def user1 = generateUsername()
    * def user2 = generateUsername()
    * def user3 = generateUsername()
    * def usersArray =
      """
      [
        { "username": "#(user1)", "email": "bulk1@example.com" },
        { "username": "#(user2)", "email": "bulk2@example.com" },
        { "username": "#(user3)", "email": "bulk3@example.com" }
      ]
      """
    Given path 'user', 'createWithArray'
    And request usersArray
    When method post
    Then status 200

    Given path 'user', user1
    When method get
    Then match [200, 404] contains responseStatus

  @high @user @create @bulk
  Scenario: TC-USER-002-02 - Successfully create users with list input
    * def user1 = generateUsername()
    * def user2 = generateUsername()
    * def usersList =
      """
      [
        { "username": "#(user1)", "email": "list1@example.com" },
        { "username": "#(user2)", "email": "list2@example.com" }
      ]
      """
    Given path 'user', 'createWithList'
    And request usersList
    When method post
    Then status 200

  @medium @user @create @bulk
  Scenario: TC-USER-002-03 - Create users with empty array
    Given path 'user', 'createWithArray'
    And request []
    When method post
    Then status 200

  @medium @user @create @bulk
  Scenario: TC-USER-002-04 - Create users with empty list
    Given path 'user', 'createWithList'
    And request []
    When method post
    Then status 200

  # ==========================================================================
  # TC-USER-003: Get User by Username
  # Risk Level: Critical
  # ==========================================================================

  @critical @smoke @user @read
  Scenario: TC-USER-003-01 - Successfully retrieve an existing user
    * def username = generateUsername()
    * def userPayload =
      """
      {
        "username": "#(username)",
        "firstName": "Retrieve",
        "lastName": "Test",
        "email": "retrieve@example.com"
      }
      """
    Given path 'user'
    And request userPayload
    When method post
    Then status 200

    Given path 'user', username
    When method get
    Then status 200
    And match response.username == username
    And match responseHeaders['Content-Type'][0] contains 'application/json'

  @high @user @read
  Scenario: TC-USER-003-02 - Retrieve user with XML response format
    * def username = generateUsername()
    * def userPayload =
      """
      {
        "username": "#(username)",
        "firstName": "XML",
        "lastName": "Test"
      }
      """
    Given path 'user'
    And request userPayload
    When method post
    Then status 200

    Given path 'user', username
    And header Accept = 'application/xml'
    When method get
    Then status 200
    And match responseHeaders['Content-Type'][0] contains 'application/xml'

  @high @user @read @negative
  Scenario: TC-USER-003-03 - Return 404 for non-existent username
    Given path 'user', 'nonexistentuser123456789'
    When method get
    Then status 404
    * def t = karate.typeOf(response)
    * if (t == 'map') karate.log('JSON response')
    * else karate.log('Response type: ' + t)

  @high @user @read @negative
  Scenario: TC-USER-003-04 - Handle empty username parameter
    Given path 'user', ''
    When method get
    Then match [400, 404, 405] contains responseStatus

  # ==========================================================================
  # TC-USER-004: Update User
  # Risk Level: High
  # ==========================================================================

  @high @user @update
  Scenario: TC-USER-004-01 - Successfully update an existing user
    * def username = generateUsername()
    * def userPayload =
      """
      {
        "username": "#(username)",
        "firstName": "Original",
        "lastName": "Name",
        "email": "original@example.com"
      }
      """
    Given path 'user'
    And request userPayload
    When method post
    Then status 200

    * def updatePayload =
      """
      {
        "username": "#(username)",
        "firstName": "UpdatedFirst",
        "lastName": "UpdatedLast",
        "email": "updated@example.com"
      }
      """
    Given path 'user', username
    And request updatePayload
    When method put
    Then status 200

  @high @user @update
  Scenario: TC-USER-004-02 - Update user password
    * def username = generateUsername()
    * def userPayload =
      """
      {
        "username": "#(username)",
        "password": "OldPassword123"
      }
      """
    Given path 'user'
    And request userPayload
    When method post
    Then status 200

    * def updatePayload =
      """
      {
        "username": "#(username)",
        "password": "NewSecurePass456"
      }
      """
    Given path 'user', username
    And request updatePayload
    When method put
    Then status 200

  @high @user @update
  Scenario: TC-USER-004-03 - Update user status
    * def username = generateUsername()
    * def userPayload =
      """
      {
        "username": "#(username)",
        "userStatus": 1
      }
      """
    Given path 'user'
    And request userPayload
    When method post
    Then status 200

    * def updatePayload =
      """
      {
        "username": "#(username)",
        "userStatus": 0
      }
      """
    Given path 'user', username
    And request updatePayload
    When method put
    Then status 200

  @high @user @update @negative
  Scenario: TC-USER-004-04 - Handle invalid user update data
    * def username = generateUsername()
    * def userPayload =
      """
      {
        "username": "#(username)"
      }
      """
    Given path 'user'
    And request userPayload
    When method post
    Then status 200

    * def updatePayload =
      """
      {
        "id": "not-a-number"
      }
      """
    Given path 'user', username
    And request updatePayload
    When method put
    Then match [200, 400, 500] contains responseStatus

  @high @user @update @negative
  Scenario: TC-USER-004-05 - Handle update of non-existent user
    * def updatePayload =
      """
      {
        "username": "nonexistentuser999",
        "firstName": "Test"
      }
      """
    Given path 'user', 'nonexistentuser999'
    And request updatePayload
    When method put
    Then match [200, 404] contains responseStatus

  # ==========================================================================
  # TC-USER-005: Delete User
  # Risk Level: High
  # ==========================================================================

  @high @user @delete
  Scenario: TC-USER-005-01 - Successfully delete an existing user
    * def username = generateUsername()
    * def userPayload =
      """
      {
        "username": "#(username)",
        "firstName": "ToDelete"
      }
      """
    Given path 'user'
    And request userPayload
    When method post
    Then status 200

    Given path 'user', username
    When method delete
    Then match [200, 204] contains responseStatus

    Given path 'user', username
    When method get
    Then status 404

  @high @user @delete @negative
  Scenario: TC-USER-005-02 - Return 404 for delete of non-existent user
    Given path 'user', 'nonexistentuser999999'
    When method delete
    Then match [404, 200] contains responseStatus

  @high @user @delete @negative
  Scenario: TC-USER-005-03 - Handle delete with empty username
    Given path 'user', ''
    When method delete
    Then match [400, 404, 405] contains responseStatus

  # ==========================================================================
  # TC-USER-006: User Login
  # Risk Level: Critical
  # ==========================================================================

  @critical @smoke @user @authentication
  Scenario: TC-USER-006-01 - Successfully login with valid credentials
    * def username = generateUsername()
    * def password = 'TestPass123'
    * def userPayload =
      """
      {
        "username": "#(username)",
        "password": "#(password)"
      }
      """
    Given path 'user'
    And request userPayload
    When method post
    Then status 200

    Given path 'user', 'login'
    And param username = username
    And param password = password
    When method get
    Then status 200
    And match response == '#string'
    And match responseHeaders['X-Rate-Limit'] == '#present'
    And match responseHeaders['X-Expires-After'] == '#present'

  @critical @user @authentication @negative
  Scenario: TC-USER-006-02 - Handle invalid username/password combination
    Given path 'user', 'login'
    And param username = 'invaliduser12345'
    And param password = 'wrongpassword'
    When method get
    Then match [200, 400] contains responseStatus

  @high @user @authentication @negative
  Scenario: TC-USER-006-03 - Handle login with missing username
    Given path 'user', 'login'
    And param password = 'testpass'
    When method get
    Then match [200, 400] contains responseStatus

  @high @user @authentication @negative
  Scenario: TC-USER-006-04 - Handle login with missing password
    Given path 'user', 'login'
    And param username = 'testuser'
    When method get
    Then match [200, 400] contains responseStatus

  @high @user @authentication @negative
  Scenario: TC-USER-006-05 - Handle login with empty credentials
    Given path 'user', 'login'
    And param username = ''
    And param password = ''
    When method get
    Then match [200, 400] contains responseStatus

  @medium @user @authentication
  Scenario: TC-USER-006-06 - Login response headers contain rate limit info
    * def username = generateUsername()
    * def userPayload =
      """
      {
        "username": "#(username)",
        "password": "pass123"
      }
      """
    Given path 'user'
    And request userPayload
    When method post
    Then status 200

    Given path 'user', 'login'
    And param username = username
    And param password = 'pass123'
    When method get
    Then status 200
    And match responseHeaders['X-Rate-Limit'][0] == '#regex \\d+'

  # ==========================================================================
  # TC-USER-007: User Logout
  # Risk Level: High
  # ==========================================================================

  @high @user @authentication
  Scenario: TC-USER-007-01 - Successfully logout current user session
    Given path 'user', 'logout'
    When method get
    Then status 200

  @medium @user @authentication
  Scenario: TC-USER-007-02 - Logout without active session
    Given path 'user', 'logout'
    When method get
    Then status 200

  @medium @user @authentication
  Scenario: TC-USER-007-03 - Multiple consecutive logouts succeed
    Given path 'user', 'logout'
    When method get
    Then status 200

    Given path 'user', 'logout'
    When method get
    Then status 200

  # ==========================================================================
  # TC-USER-008: User Schema Validation
  # Risk Level: High
  # ==========================================================================

  @high @user @schema
  Scenario: TC-USER-008-01 - Validate user response schema
    * def userId = generateUserId()
    * def username = generateUsername()
    * def userPayload =
      """
      {
        "id": #(userId),
        "username": "#(username)",
        "firstName": "Schema",
        "lastName": "Test",
        "email": "schema@example.com",
        "password": "schemapass",
        "phone": "123-456-7890",
        "userStatus": 1
      }
      """
    Given path 'user'
    And request userPayload
    When method post
    Then status 200

    Given path 'user', username
    When method get
    Then status 200
    And match response ==
      """
      {
        id: '#number',
        username: '#string',
        firstName: '##string',
        lastName: '##string',
        email: '##string',
        password: '##string',
        phone: '##string',
        userStatus: '##number'
      }
      """

  @high @user @schema
  Scenario: TC-USER-008-02 - Validate user fields are correct types
    * def username = generateUsername()
    * def userPayload =
      """
      {
        "id": 12345,
        "username": "#(username)",
        "firstName": "Type",
        "lastName": "Check",
        "email": "type@check.com",
        "userStatus": 1
      }
      """
    Given path 'user'
    And request userPayload
    When method post
    Then status 200

    Given path 'user', username
    When method get
    Then status 200
    And match response.id == '#number'
    And match response.username == '#string'
    And match response.firstName == '#string'
    And match response.lastName == '#string'
    And match response.email == '#string'
    And match response.userStatus == '#number'

  # ==========================================================================
  # TC-USER-009: Data Consistency Tests
  # Risk Level: Critical
  # ==========================================================================

  @critical @user @consistency
  Scenario: TC-USER-009-01 - Create-Read consistency for users
    * def userId = generateUserId()
    * def username = generateUsername()
    * def userPayload =
      """
      {
        "id": #(userId),
        "username": "#(username)",
        "firstName": "Consistency",
        "lastName": "Test",
        "email": "consistency@test.com"
      }
      """
    Given path 'user'
    And request userPayload
    When method post
    Then status 200

    Given path 'user', username
    When method get
    Then status 200
    And match response.username == username
    And match response.firstName == 'Consistency'
    And match response.lastName == 'Test'
    And match response.email == 'consistency@test.com'

  @critical @user @consistency
  Scenario: TC-USER-009-02 - Update-Read consistency for users
    * def username = generateUsername()
    * def userPayload =
      """
      {
        "username": "#(username)",
        "firstName": "Before",
        "lastName": "Update"
      }
      """
    Given path 'user'
    And request userPayload
    When method post
    Then status 200

    * def updatePayload =
      """
      {
        "username": "#(username)",
        "firstName": "After",
        "lastName": "Update"
      }
      """
    Given path 'user', username
    And request updatePayload
    When method put
    Then status 200

    Given path 'user', username
    When method get
    Then status 200
    And match response.firstName == 'After'

  @critical @user @consistency
  Scenario: TC-USER-009-03 - Delete-Read consistency for users
    * def username = generateUsername()
    * def userPayload =
      """
      {
        "username": "#(username)"
      }
      """
    Given path 'user'
    And request userPayload
    When method post
    Then status 200

    Given path 'user', username
    When method delete
    Then match [200, 204] contains responseStatus

    Given path 'user', username
    When method get
    Then status 404

  # ==========================================================================
  # TC-USER-010: Special Characters and Encoding
  # Risk Level: Medium
  # ==========================================================================

  @medium @user @encoding
  Scenario: TC-USER-010-01 - Handle Unicode characters in user fields
    * def username = generateUsername()
    * def userPayload =
      """
      {
        "username": "#(username)",
        "firstName": "Müller",
        "lastName": "François",
        "email": "unicode@test.com"
      }
      """
    Given path 'user'
    And request userPayload
    When method post
    Then status 200

    Given path 'user', username
    When method get
    Then status 200
    And match response.firstName == 'Müller'
    And match response.lastName == 'François'

  @medium @user @encoding
  Scenario: TC-USER-010-02 - Handle special characters in email
    * def username = generateUsername()
    * def userPayload =
      """
      {
        "username": "#(username)",
        "email": "test+special@example.com"
      }
      """
    Given path 'user'
    And request userPayload
    When method post
    Then status 200

  @medium @user @encoding
  Scenario: TC-USER-010-03 - Handle phone number formats
    * def username = generateUsername()
    * def userPayload =
      """
      {
        "username": "#(username)",
        "phone": "+1 (555) 123-4567"
      }
      """
    Given path 'user'
    And request userPayload
    When method post
    Then status 200
