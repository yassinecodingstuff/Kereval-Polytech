Feature: User API - Create Operations
  As a system administrator
  I need to create user accounts
  So that customers can access the pet store system

  Background:
    * url baseUrl
    * def generateUsername = function(){ return 'testuser_' + Math.floor(Math.random() * 1000000) }

  @critical @smoke @user @create
  Scenario: TC-USER-001 - Successfully create a new user
    * def username = generateUsername()
    Given path 'user'
    And header Content-Type = 'application/json'
    And request
      """
      {
        "username": "#(username)",
        "firstName": "John",
        "lastName": "Doe",
        "email": "john.doe@test.com",
        "password": "SecurePass123!",
        "phone": "555-1234",
        "userStatus": 1
      }
      """
    When method POST
    Then status 200

  @user @create
  Scenario: TC-USER-002 - Create user with minimal required fields
    * def username = generateUsername()
    Given path 'user'
    And header Content-Type = 'application/json'
    And request
      """
      {
        "username": "#(username)"
      }
      """
    When method POST
    Then status 200

  @user @create @datatype
  Scenario: TC-USER-003 - Verify user creation response format
    * def username = generateUsername()
    Given path 'user'
    And header Content-Type = 'application/json'
    And request
      """
      {
        "username": "#(username)",
        "firstName": "DataType",
        "lastName": "User"
      }
      """
    When method POST
    Then status 200
    And match response == '#object'

  @user @create @boundary
  Scenario: TC-USER-004 - Create user with maximum length username
    * def longUsername = ''
    * eval for(var i = 0; i < 100; i++) longUsername += 'a'
    Given path 'user'
    And header Content-Type = 'application/json'
    And request
      """
      {
        "username": "#(longUsername)",
        "firstName": "Long",
        "lastName": "Username"
      }
      """
    When method POST
    Then status 200

  @user @create @special-characters
  Scenario: TC-USER-005 - Create user with special characters in fields
    * def username = generateUsername()
    Given path 'user'
    And header Content-Type = 'application/json'
    And request
      """
      {
        "username": "#(username)",
        "firstName": "José",
        "lastName": "O'Brien",
        "email": "user+test@test.com"
      }
      """
    When method POST
    Then status 200

  @user @create @bulk
  Scenario: TC-USER-006 - Successfully create multiple users with array
    * def user1 = generateUsername()
    * def user2 = generateUsername()
    * def user3 = generateUsername()
    Given path 'user', 'createWithArray'
    And header Content-Type = 'application/json'
    And request
      """
      [
        {
          "username": "#(user1)",
          "email": "array1@test.com"
        },
        {
          "username": "#(user2)",
          "email": "array2@test.com"
        },
        {
          "username": "#(user3)",
          "email": "array3@test.com"
        }
      ]
      """
    When method POST
    Then status 200

  @user @create @bulk
  Scenario: TC-USER-007 - Create users with array containing single user
    * def username = generateUsername()
    Given path 'user', 'createWithArray'
    And header Content-Type = 'application/json'
    And request
      """
      [
        {
          "username": "#(username)",
          "email": "single@test.com"
        }
      ]
      """
    When method POST
    Then status 200

  @user @create @bulk @boundary
  Scenario: TC-USER-008 - Create users with large array
    * def users = []
    * def createUser = function(i){ return { username: 'bulkuser_' + i + '_' + Math.floor(Math.random() * 10000), email: 'bulk' + i + '@test.com' } }
    * eval for(var i = 0; i < 50; i++) users.push(createUser(i))
    Given path 'user', 'createWithArray'
    And header Content-Type = 'application/json'
    And request users
    When method POST
    Then status 200

  @negative @user @create @bulk
  Scenario: TC-USER-009 - Handle empty array for user creation
    Given path 'user', 'createWithArray'
    And header Content-Type = 'application/json'
    And request []
    When method POST
    Then assert responseStatus == 200 || responseStatus == 400

  @user @create @bulk
  Scenario: TC-USER-010 - Successfully create multiple users with list
    * def user1 = generateUsername()
    * def user2 = generateUsername()
    Given path 'user', 'createWithList'
    And header Content-Type = 'application/json'
    And request
      """
      [
        {
          "username": "#(user1)",
          "email": "list1@test.com"
        },
        {
          "username": "#(user2)",
          "email": "list2@test.com"
        }
      ]
      """
    When method POST
    Then status 200

  @user @create @bulk
  Scenario: TC-USER-011 - Create users with list containing single user
    * def username = generateUsername()
    Given path 'user', 'createWithList'
    And header Content-Type = 'application/json'
    And request
      """
      [
        {
          "username": "#(username)",
          "email": "singlelist@test.com"
        }
      ]
      """
    When method POST
    Then status 200

  @user @create @performance
  Scenario: TC-USER-PERF-001 - User creation responds within acceptable time
    * def username = generateUsername()
    Given path 'user'
    And request { username: '#(username)' }
    When method POST
    Then status 200
    And assert responseTime < 3000
