Feature: User Management API

  Background:
    * url 'https://petstore.swagger.io/v2'

  @user @smoke @high
  Scenario: Create a new user with valid data
    Given path '/user'
    And request { "username": "testuser", "firstName": "Test", "lastName": "User", "email": "test@example.com", "password": "password123", "phone": "1234567890", "userStatus": 1 }
    And header Content-Type = 'application/json'
    When method POST
    Then status 200

  @user @smoke @high
  Scenario: Create a list of users with valid data
    Given path '/user/createWithList'
    And request [ { "username": "user1", "firstName": "User", "lastName": "One", "email": "user1@example.com", "password": "password123", "phone": "1234567890", "userStatus": 1 } ]
    And header Content-Type = 'application/json'
    When method POST
    Then status 200

  @user @smoke @high
  Scenario: Get user by valid username
    Given path '/user/testuser'
    When method GET
    Then status 200
    And match response.username == 'testuser'

  @user @negative @high
  Scenario: Get user by invalid username
    Given path '/user/invaliduser'
    When method GET
    Then status 400
    And match response contains { "code": 400, "type": "unknown", "message": "Invalid username supplied" }

  @user @smoke @high
  Scenario: Update user with valid data
    Given path '/user/testuser'
    And request { "username": "testuser", "firstName": "Updated", "lastName": "User", "email": "updated@example.com", "password": "newpassword123", "phone": "0987654321", "userStatus": 1 }
    And header Content-Type = 'application/json'
    When method PUT
    Then status 200
    And match response.firstName == 'Updated'

  @user @negative @high
  Scenario: Update user with invalid username
    Given path '/user/invaliduser'
    And request { "username": "invaliduser", "firstName": "Updated", "lastName": "User", "email": "updated@example.com", "password": "newpassword123", "phone": "0987654321", "userStatus": 1 }
    And header Content-Type = 'application/json'
    When method PUT
    Then status 400
    And match response contains { "code": 400, "type": "unknown", "message": "Invalid user supplied" }

  @user @smoke @high
  Scenario: Delete user by valid username
    Given path '/user/testuser'
    When method DELETE
    Then status 200

  @user @negative @high
  Scenario: Delete user by invalid username
    Given path '/user/invaliduser'
    When method DELETE
    Then status 400
    And match response contains { "code": 400, "type": "unknown", "message": "Invalid username supplied" }

  @user @smoke @high
  Scenario: Login with valid credentials
    Given path '/user/login'
    And param username = 'testuser'
    And param password = 'password123'
    When method GET
    Then status 200
    And match response contains 'logged in user session:'

  @user @negative @high
  Scenario: Login with invalid credentials
    Given path '/user/login'
    And param username = 'invaliduser'
    And param password = 'wrongpassword'
    When method GET
    Then status 400
    And match response contains { "code": 400, "type": "unknown", "message": "Invalid username/password supplied" }

  @user @medium
  Scenario: Logout current user session
    Given path '/user/logout'
    When method GET
    Then status 200