Feature: User Account Management
  As a test automation engineer
  I want to verify the User management operations
  So that I can ensure user accounts are secure and mutable

  Background:
    * url 'https://petstore.swagger.io/v2'
    * def getRandomId = function(){ return Math.floor(Math.random() * 100000000) + 1 }
    * def userId = getRandomId()
    * def username = 'user_' + userId
    * def password = 'password123'

  Scenario: Create user, login, and delete user
    # Create
    Given path 'user'
    And request
    """
    {
      "id": #(userId),
      "username": "#(username)",
      "firstName": "Test",
      "lastName": "Engineer",
      "email": "test@example.com",
      "password": "#(password)",
      "phone": "1234567890",
      "userStatus": 1
    }
    """
    When method post
    Then status 200

    # Login
    Given path 'user', 'login'
    And param username = username
    And param password = password
    When method get
    Then status 200
    And match response contains 'Logged in user session'

    # Get
    Given path 'user', username
    When method get
    Then status 200
    And match response.username == username

    # Delete
    Given path 'user', username
    When method delete
    Then status 200

  Scenario: Update a user that does not exist
    * def nonExistentUser = 'unknown_user_' + getRandomId()
    Given path 'user', nonExistentUser
    And request { "id": #(getRandomId()), "username": "#(nonExistentUser)" }
    When method put
    Then status 404

  Scenario: Create a list of users with Array
    * def batchUser1 = 'batch_' + getRandomId()
    Given path 'user', 'createWithArray'
    And request [ { "id": #(getRandomId()), "username": "#(batchUser1)" } ]
    When method post
    Then status 200

    Given path 'user', batchUser1
    When method get
    Then status 200
    And match response.username == batchUser1