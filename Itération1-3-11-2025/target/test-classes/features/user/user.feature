Feature: User Management API

  Background:
    * url 'https://petstore.swagger.io/v2'

  @smoke @high-priority
  Scenario: Create a new user with valid data
    Given request { "username": "testuser", "firstName": "Test", "lastName": "User", "email": "test@example.com", "password": "testpass", "phone": "1234567890", "userStatus": 0 }
    When method POST
    And path '/user'
    Then status 200
    And match response == { "username": "testuser", "firstName": "Test", "lastName": "User", "email": "test@example.com", "userStatus": 0 }

  @regression @medium-priority
  Scenario: Create a new user with missing required fields
    Given request { "firstName": "Test", "lastName": "User", "email": "test@example.com", "password": "testpass", "phone": "1234567890", "userStatus": 0 }
    When method POST
    And path '/user'
    Then status 400
    And match response contains { "message": "#string" }

  @regression @medium-priority
  Scenario: Create a new user with duplicate username
    Given request { "username": "existinguser", "firstName": "Test", "lastName": "User", "email": "test@example.com", "password": "testpass", "phone": "1234567890", "userStatus": 0 }
    When method POST
    And path '/user'
    Then status 400
    And match response contains { "message": "#string" }

  @smoke @high-priority
  Scenario: Get user by valid username
    When method GET
    And path '/user/testuser'
    Then status 200
    And match response == { "username": "testuser", "firstName": "#string", "lastName": "#string", "email": "#string", "userStatus": "#number" }

  @regression @medium-priority
  Scenario: Get user by invalid username
    When method GET
    And path '/user/unknownuser'
    Then status 404
    And match response contains { "message": "#string" }

  @smoke @high-priority
  Scenario: Update an existing user with valid data
    Given request { "username": "testuser", "firstName": "Updated", "lastName": "User", "email": "updated@example.com", "password": "updatedpass", "phone": "0987654321", "userStatus": 1 }
    When method PUT
    And path '/user/testuser'
    Then status 200
    And match response == { "username": "testuser", "firstName": "Updated", "lastName": "User", "email": "updated@example.com", "userStatus": 1 }

  @regression @medium-priority
  Scenario: Update a non-existent user
    Given request { "username": "unknownuser", "firstName": "Updated", "lastName": "User", "email": "updated@example.com", "password": "updatedpass", "phone": "0987654321", "userStatus": 1 }
    When method PUT
    And path '/user/unknownuser'
    Then status 404
    And match response contains { "message": "#string" }

  @smoke @high-priority
  Scenario: Delete an existing user
    When method DELETE
    And path '/user/testuser'
    Then status 200
    And match response contains { "message": "#string" }

  @regression @medium-priority
  Scenario: Delete a non-existent user
    When method DELETE
    And path '/user/unknownuser'
    Then status 404
    And match response contains { "message": "#string" }

  @regression @medium-priority
  Scenario: Login with valid credentials
    When method GET
    And path '/user/login'
    And param username = 'testuser'
    And param password = 'testpass'
    Then status 200
    And match response contains { "message": "#string" }

  @regression @medium-priority
  Scenario: Login with invalid credentials
    When method GET
    And path '/user/login'
    And param username = 'unknownuser'
    And param password = 'wrongpass'
    Then status 401
    And match response contains { "message": "#string" }

  @regression @medium-priority
  Scenario: Logout an existing user session
    When method GET
    And path '/user/logout'
    Then status 200
    And match response contains { "message": "#string" }
