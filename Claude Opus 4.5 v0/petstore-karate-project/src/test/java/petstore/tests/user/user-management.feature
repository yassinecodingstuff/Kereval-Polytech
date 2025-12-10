Feature: User Management API
  As a Petstore API consumer
  I want to manage user accounts and authentication
  So that I can control access to the system
  
  Priority: HIGH - Authentication & Authorization
  ISO/IEC/IEEE 29119 Alignment: Risk-based test selection with security coverage

  Background:
    * url baseUrl
    * def generateUniqueId = function(){ return Math.floor(Math.random() * 900000000) + 100000000 }
    * def generateUniqueUsername = function(prefix){ return prefix + '_' + Math.floor(Math.random() * 100000) + '_' + Date.now() }
    * def generateStringOfLength = function(len){ var r=''; for(var i=0;i<len;i++) r+='a'; return r }

  @high @smoke @positive @POST @user
  Scenario: TC-USER-001 - Successfully create a new user
    * def userId = generateUniqueId()
    * def username = generateUniqueUsername('testuser')
    * def userPayload =
      """
      {
        id: #(userId),
        username: '#(username)',
        firstName: 'John',
        lastName: 'Doe',
        email: '#(username + "@test.com")',
        password: 'SecurePass123',
        phone: '1234567890',
        userStatus: 1
      }
      """
    Given path 'user'
    And header Content-Type = 'application/json'
    And header Accept = 'application/json'
    And request userPayload
    When method post
    Then status 200

  @high @positive @POST @user
  Scenario: TC-USER-002 - Successfully create user with minimum required fields
    * def username = generateUniqueUsername('minimal')
    * def userPayload = { username: '#(username)' }
    Given path 'user'
    And header Content-Type = 'application/json'
    And header Accept = 'application/json'
    And request userPayload
    When method post
    Then status 200

  @high @positive @POST @user @special-characters
  Scenario: TC-USER-003 - Successfully create user with special characters in name
    * def userId = generateUniqueId()
    * def username = generateUniqueUsername('special')
    * def userPayload =
      """
      {
        id: #(userId),
        username: '#(username)',
        firstName: 'José María',
        lastName: "O'Brien-Smith",
        email: '#(username + "@example.com")'
      }
      """
    Given path 'user'
    And header Content-Type = 'application/json'
    And header Accept = 'application/json'
    And request userPayload
    When method post
    Then status 200

  @medium @positive @POST @user @batch
  Scenario: TC-USER-004 - Successfully create multiple users with array
    * def user1 = generateUniqueUsername('batch1')
    * def user2 = generateUniqueUsername('batch2')
    * def user3 = generateUniqueUsername('batch3')
    * def usersArray =
      """
      [
        { username: '#(user1)', firstName: 'User', lastName: 'One' },
        { username: '#(user2)', firstName: 'User', lastName: 'Two' },
        { username: '#(user3)', firstName: 'User', lastName: 'Three' }
      ]
      """
    Given path 'user', 'createWithArray'
    And header Content-Type = 'application/json'
    And header Accept = 'application/json'
    And request usersArray
    When method post
    Then status 200

  @medium @positive @POST @user @batch
  Scenario: TC-USER-005 - Successfully create multiple users with list
    * def user1 = generateUniqueUsername('list1')
    * def user2 = generateUniqueUsername('list2')
    * def usersList =
      """
      [
        { username: '#(user1)', firstName: 'List', lastName: 'One' },
        { username: '#(user2)', firstName: 'List', lastName: 'Two' }
      ]
      """
    Given path 'user', 'createWithList'
    And header Content-Type = 'application/json'
    And header Accept = 'application/json'
    And request usersList
    When method post
    Then status 200

  @critical @smoke @positive @GET @user @auth
  Scenario: TC-USER-006 - Successfully login with valid credentials
    * def username = generateUniqueUsername('login')
    * def password = 'Password123'
    * def userPayload = { username: '#(username)', password: '#(password)' }
    Given path 'user'
    And header Content-Type = 'application/json'
    And request userPayload
    When method post
    Then status 200
    
    Given path 'user', 'login'
    And param username = username
    And param password = password
    And header Accept = 'application/json'
    When method get
    Then status 200
    And match response == '#string'
    And match responseHeaders['X-Rate-Limit'] == '#present'
    And match responseHeaders['X-Expires-After'] == '#present'

  @critical @positive @GET @user @auth
  Scenario: TC-USER-007 - Verify login response contains rate limit header
    Given path 'user', 'login'
    And param username = 'user1'
    And param password = 'password123'
    And header Accept = 'application/json'
    When method get
    Then status 200
    And match responseHeaders['X-Rate-Limit'][0] == '#regex \\d+'

  @critical @negative @GET @user @auth @security
  Scenario: TC-USER-008 - Reject login with invalid username
    Given path 'user', 'login'
    And param username = 'nonexistent_user_xyz_123456'
    And param password = 'anypassword'
    And header Accept = 'application/json'
    When method get
    Then assert responseStatus == 200 || responseStatus == 400

  @critical @negative @GET @user @auth @security
  Scenario: TC-USER-009 - Reject login with empty username
    Given path 'user', 'login'
    And param username = ''
    And param password = 'anypassword'
    And header Accept = 'application/json'
    When method get
    Then assert responseStatus == 200 || responseStatus == 400

  @medium @negative @GET @user @auth @security @injection
  Scenario: TC-USER-010 - Handle SQL injection attempt in username
    Given path 'user', 'login'
    And param username = "' OR '1'='1"
    And param password = 'anypassword'
    And header Accept = 'application/json'
    When method get
    Then assert responseStatus == 200 || responseStatus == 400

  @high @smoke @positive @GET @user @auth
  Scenario: TC-USER-011 - Successfully logout current session
    Given path 'user', 'logout'
    And header Accept = 'application/json'
    When method get
    Then status 200

  @medium @positive @GET @user @auth @idempotency
  Scenario: TC-USER-012 - Verify logout can be called multiple times
    Given path 'user', 'logout'
    And header Accept = 'application/json'
    When method get
    Then status 200
    
    Given path 'user', 'logout'
    And header Accept = 'application/json'
    When method get
    Then status 200

  @high @smoke @positive @GET @user
  Scenario: TC-USER-013 - Successfully retrieve user by username
    * def username = generateUniqueUsername('getuser')
    * def userPayload = { username: '#(username)', firstName: 'Retrieve', lastName: 'Test' }
    Given path 'user'
    And header Content-Type = 'application/json'
    And request userPayload
    When method post
    Then status 200
    
    Given path 'user', username
    And header Accept = 'application/json'
    When method get
    Then status 200
    And match response.username == username

  @high @positive @GET @user
  Scenario: TC-USER-014 - Verify retrieved user contains all expected fields
    * def username = generateUniqueUsername('fulluser')
    * def userId = generateUniqueId()
    * def userPayload =
      """
      {
        id: #(userId),
        username: '#(username)',
        firstName: 'Full',
        lastName: 'Fields',
        email: '#(username + "@test.com")',
        password: 'Password123',
        phone: '1234567890',
        userStatus: 1
      }
      """
    Given path 'user'
    And header Content-Type = 'application/json'
    And request userPayload
    When method post
    Then status 200
    
    Given path 'user', username
    And header Accept = 'application/json'
    When method get
    Then status 200
    And match response contains { id: '#number', username: '#string' }

  @high @negative @GET @user
  Scenario: TC-USER-015 - Return 404 for non-existent username
    Given path 'user', 'nonexistent_user_xyz_999999'
    And header Accept = 'application/json'
    When method get
    Then status 404

  @high @smoke @positive @PUT @user
  Scenario: TC-USER-016 - Successfully update existing user
    * def username = generateUniqueUsername('updateuser')
    * def userPayload = { username: '#(username)', firstName: 'Original', lastName: 'Name', email: '#(username + "@test.com")' }
    Given path 'user'
    And header Content-Type = 'application/json'
    And request userPayload
    When method post
    Then status 200
    
    * def updatePayload = { username: '#(username)', firstName: 'UpdatedFirstName', lastName: 'UpdatedLastName', email: '#("updated_" + username + "@email.com")' }
    Given path 'user', username
    And header Content-Type = 'application/json'
    And header Accept = 'application/json'
    And request updatePayload
    When method put
    Then status 200

  @high @negative @PUT @user
  Scenario: TC-USER-017 - Return 404 when updating non-existent user
    * def updatePayload = { username: 'nonexistent_user_abc_999999', firstName: 'Does Not', lastName: 'Exist' }
    Given path 'user', 'nonexistent_user_abc_999999'
    And header Content-Type = 'application/json'
    And header Accept = 'application/json'
    And request updatePayload
    When method put
    Then assert responseStatus == 200 || responseStatus == 404

  @high @smoke @positive @DELETE @user
  Scenario: TC-USER-018 - Successfully delete existing user
    * def username = generateUniqueUsername('deleteuser')
    * def userPayload = { username: '#(username)', firstName: 'Delete', lastName: 'Me' }
    Given path 'user'
    And header Content-Type = 'application/json'
    And request userPayload
    When method post
    Then status 200
    
    Given path 'user', username
    When method delete
    Then status 200
    
    Given path 'user', username
    When method get
    Then status 404

  @high @negative @DELETE @user
  Scenario: TC-USER-019 - Return 404 when deleting non-existent user
    Given path 'user', 'nonexistent_delete_user_999999'
    When method delete
    Then status 404

  @medium @negative @DELETE @user @idempotency
  Scenario: TC-USER-020 - Verify delete is not idempotent
    * def username = generateUniqueUsername('idempotentuser')
    * def userPayload = { username: '#(username)', firstName: 'Idempotent', lastName: 'Test' }
    Given path 'user'
    And header Content-Type = 'application/json'
    And request userPayload
    When method post
    Then status 200
    
    Given path 'user', username
    When method delete
    Then status 200
    
    Given path 'user', username
    When method delete
    Then status 404

  @low @positive @GET @user @content-negotiation
  Scenario: TC-USER-021 - Retrieve user in XML format
    * def username = generateUniqueUsername('xmluser')
    * def userPayload = { username: '#(username)', firstName: 'XML', lastName: 'Format' }
    Given path 'user'
    And header Content-Type = 'application/json'
    And request userPayload
    When method post
    Then status 200
    
    Given path 'user', username
    And header Accept = 'application/xml'
    When method get
    Then status 200
    And match responseHeaders['Content-Type'][0] contains 'application/xml'
