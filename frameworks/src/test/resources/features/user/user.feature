Feature: User API - Authentication and Account Management
  Background:
    * url 'https://petstore.swagger.io/v2'
    * configure headers = { 'Content-Type': 'application/json' }

  @critical @user-create
  Scenario: Create new user
    * def user = { id: 4001, username: 'tester123', firstName: 'Test', lastName: 'User', email: 'tester@example.com', password: 's3cr3t', phone: '1234567890', userStatus: 1 }
    Given path 'user'
    And request user
    When method post
    Then status 200
    Given path 'user', user.username
    When method get
    Then status 200
    And match response.username == user.username
    And match response does not contain 'password'

  @high @user-login
  Scenario: User login and logout
    * def username = 'tester123'
    * def password = 's3cr3t'
    Given path 'user/login'
    And param username = username
    And param password = password
    When method get
    Then status 200
    * def token = response.message
    Given path 'user/logout'
    When method get
    Then status 200

  @medium @user-login-failed
  Scenario: User login with wrong password
    Given path 'user/login'
    And param username = 'tester123'
    And param password = 'wrongpass'
    When method get
    Then status 400
    And match response.message contains 'Invalid'

  @security @auth
  Scenario: Delete pet without API key
    * configure headers = { 'Content-Type': 'application/json' }
    Given path 'pet', 1003
    When method delete
    Then status 401
