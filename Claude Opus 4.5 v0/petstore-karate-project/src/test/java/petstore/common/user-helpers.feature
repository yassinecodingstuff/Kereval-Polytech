@ignore
Feature: User API Reusable Scenarios
  Reusable background scenarios for User API testing
  ISO/IEC/IEEE 29119-5 Keyword-Driven Testing Support

  Background:
    * url baseUrl
    * def utils = call read('classpath:petstore/common/common-utils.feature')

  @ignore @reusable
  Scenario: Create user helper
    * def userId = __arg.userId || utils.generateUniqueId()
    * def username = __arg.username || utils.generateUniqueUsername('user')
    * def firstName = __arg.firstName || 'Test'
    * def lastName = __arg.lastName || 'User'
    * def email = __arg.email || (username + '@test.com')
    * def password = __arg.password || 'Password123'
    * def phone = __arg.phone || '1234567890'
    * def userStatus = __arg.userStatus || 1
    
    * def userPayload =
      """
      {
        id: #(userId),
        username: '#(username)',
        firstName: '#(firstName)',
        lastName: '#(lastName)',
        email: '#(email)',
        password: '#(password)',
        phone: '#(phone)',
        userStatus: #(userStatus)
      }
      """
    
    Given path 'user'
    And header Content-Type = 'application/json'
    And header Accept = 'application/json'
    And request userPayload
    When method post

  @ignore @reusable
  Scenario: Create users with array helper
    * def users = __arg.users
    Given path 'user', 'createWithArray'
    And header Content-Type = 'application/json'
    And header Accept = 'application/json'
    And request users
    When method post

  @ignore @reusable
  Scenario: Create users with list helper
    * def users = __arg.users
    Given path 'user', 'createWithList'
    And header Content-Type = 'application/json'
    And header Accept = 'application/json'
    And request users
    When method post

  @ignore @reusable
  Scenario: Get user by username helper
    * def username = __arg.username
    Given path 'user', username
    And header Accept = 'application/json'
    When method get

  @ignore @reusable
  Scenario: Update user helper
    * def username = __arg.username
    * def userPayload = __arg.userPayload
    Given path 'user', username
    And header Content-Type = 'application/json'
    And header Accept = 'application/json'
    And request userPayload
    When method put

  @ignore @reusable
  Scenario: Delete user helper
    * def username = __arg.username
    Given path 'user', username
    When method delete

  @ignore @reusable
  Scenario: Login user helper
    * def username = __arg.username
    * def password = __arg.password
    Given path 'user', 'login'
    And param username = username
    And param password = password
    And header Accept = 'application/json'
    When method get

  @ignore @reusable
  Scenario: Logout user helper
    Given path 'user', 'logout'
    And header Accept = 'application/json'
    When method get
