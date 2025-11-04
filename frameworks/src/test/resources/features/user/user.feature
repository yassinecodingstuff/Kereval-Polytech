Feature: Comprehensive User Management API Tests
  Background:
    * url baseUrl = 'https://petstore.swagger.io/v2'
    * configure headers = { 'Content-Type': 'application/json' }

  # Positive Scenarios
  Scenario: Create a new user
    Given path '/user'
    And request { id: 3001, username: 'karateUser', firstName: 'John', lastName: 'Doe', email: 'john@example.com', password: '12345', phone: '123456789', userStatus: 1 }
    When method post
    Then status 200
    And match response.message == '3001'

  Scenario: Get user by username
    Given path '/user/karateUser'
    When method get
    Then status 200
    And match response.username == 'karateUser'

  Scenario: Update user information
    Given path '/user/karateUser'
    And request { id: 3001, username: 'karateUser', firstName: 'Johnny', lastName: 'Doe', email: 'johnny@example.com', password: '54321', phone: '987654321', userStatus: 1 }
    When method put
    Then status 200

  Scenario: User login with valid credentials
    Given path '/user/login'
    And param username = 'karateUser'
    And param password = '54321'
    When method get
    Then status 200
    And match response contains 'logged in user session'

  Scenario: User logout
    Given path '/user/logout'
    When method get
    Then status 200

  Scenario: Delete user
    Given path '/user/karateUser'
    When method delete
    Then status 200
    And match response.message == 'karateUser'





  # Negative Scenarios
  Scenario: Retrieve a non-existent user
    Given path '/user/ghost'
    When method get
    Then status 404

  Scenario: Login with invalid credentials
    Given path '/user/login'
    And param username = 'fakeUser'
    And param password = 'wrong'
    When method get
    Then status 400


  Scenario: Delete user that does not exist
    Given path '/user/nonexistent'
    When method delete
    Then status 404