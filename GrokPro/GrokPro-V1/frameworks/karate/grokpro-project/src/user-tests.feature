
Feature: User API Risk-Based Comprehensive Tests

  Background:
    * url baseUrl

  Scenario: Create a user successfully
    Given path 'user'
    And request { id: 1, username: 'testuser', password: 'password' }
    When method post
    Then status 200

  Scenario: Create users with array input successfully
    Given path 'user/createWithArray'
    And request
    """
    [
      { id: 2, username: 'user1', password: 'pass1' },
      { id: 3, username: 'user2', password: 'pass2' }
    ]
    """
    When method post
    Then status 200

  Scenario: Login user successfully
    Given path 'user/login'
    And param username = 'testuser'
    And param password = 'password'
    When method get
    Then status 200
    And match response.message contains 'logged in user session'

  Scenario: Fail login with invalid credentials
    Given path 'user/login'
    And param username = 'invaliduser'
    And param password = 'wrongpassword'
    When method get
    Then status 400

  Scenario: Logout user successfully
    Given path 'user/logout'
    When method get
    Then status 200

  Scenario: Get user by username successfully
    Given path 'user', 'testuser'
    When method get
    Then status 200
    And match response.username == 'testuser'

  Scenario: Update user successfully
    Given path 'user', 'testuser'
    And request { id: 1, username: 'testuser', firstName: 'Test', lastName: 'User', email: 'testuser@example.com', password: 'password' }
    When method put
    Then status 200

  Scenario: Delete user successfully
    Given path 'user', 'testuser'
    When method delete
    Then status 200
