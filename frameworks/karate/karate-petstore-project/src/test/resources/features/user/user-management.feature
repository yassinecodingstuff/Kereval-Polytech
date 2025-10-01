Feature: User account management (authentication and CRUD)
  Background:
    * def baseUrl = 'https://petstore.swagger.io/v2'
    * url baseUrl
    * configure headers = { Accept: 'application/json' }
    * def userSchema =
    """
    {
      id: '##number',
      username: '#string',
      firstName: '##string',
      lastName: '##string',
      email: '##string',
      password: '##string',
      phone: '##string',
      userStatus: '##number'
    }
    """

  @critical @user @create @schema
  Scenario: Create a user and verify retrieval by username
    * configure headers = { Accept: 'application/json', Content-Type: 'application/json' }
    * def u =
    """
    {
      "id": 501,
      "username": "qa_user_501",
      "firstName": "QA",
      "lastName": "User",
      "email": "qa501@example.com",
      "password": "Secret#123",
      "phone": "+33123456789",
      "userStatus": 1
    }
    """
    Given path 'user'
    And request u
    When method post
    Then status 200
    * configure headers = { Accept: 'application/json' }
    Given path 'user', 'qa_user_501'
    When method get
    Then status 200
    And match response == userSchema
    And match response.email == 'qa501@example.com'

  @critical @user @auth
  Scenario: Login with valid credentials returns session info headers
    * configure headers = { Accept: 'application/json' }
    Given path 'user', 'login'
    And param username = 'qa_user_501'
    And param password = 'Secret#123'
    When method get
    Then status 200
    And match response contains 'logged in user session'
    * match responseHeaders['X-Rate-Limit'][0] == '#present'
    * match responseHeaders['X-Expires-After'][0] == '#present'

  @high @user @auth @negative
  Scenario: Login with invalid credentials fails
    * configure headers = { Accept: 'application/json' }
    Given path 'user', 'login'
    And param username = 'qa_user_501'
    And param password = 'WrongPass!'
    When method get
    Then status 400

  @medium @user @auth
  Scenario: Logout current user session
    * configure headers = { Accept: 'application/json' }
    Given path 'user', 'logout'
    When method get
    Then status 200

  @high @user @bulk
  Scenario: Create multiple users with array input
    * configure headers = { Accept: 'application/json', Content-Type: 'application/json' }
    * def arr =
    """
    [
      {
        "id": 601,
        "username": "qa_user_601",
        "firstName": "QA",
        "lastName": "One",
        "email": "qa601@example.com",
        "password": "Secret#123",
        "phone": "+33111111111",
        "userStatus": 1
      },
      {
        "id": 602,
        "username": "qa_user_602",
        "firstName": "QA",
        "lastName": "Two",
        "email": "qa602@example.com",
        "password": "Secret#123",
        "phone": "+33222222222",
        "userStatus": 1
      }
    ]
    """
    Given path 'user', 'createWithArray'
    And request arr
    When method post
    Then status 200
    * configure headers = { Accept: 'application/json' }
    Given path 'user', 'qa_user_601'
    When method get
    Then status 200
    Given path 'user', 'qa_user_602'
    When method get
    Then status 200

  @medium @user @bulk
  Scenario: Create multiple users with list input
    * configure headers = { Accept: 'application/json', Content-Type: 'application/json' }
    * def list =
    """
    [
      {
        "id": 611,
        "username": "qa_user_611",
        "firstName": "QA",
        "lastName": "List",
        "email": "qa611@example.com",
        "password": "Secret#123",
        "phone": "+33333333333",
        "userStatus": 1
      }
    ]
    """
    Given path 'user', 'createWithList'
    And request list
    When method post
    Then status 200
    * configure headers = { Accept: 'application/json' }
    Given path 'user', 'qa_user_611'
    When method get
    Then status 200

  @high @user @update
  Scenario: Update existing user details
    * configure headers = { Accept: 'application/json', Content-Type: 'application/json' }
    * def ensure =
    """
    {
      "id": 501,
      "username": "qa_user_501",
      "firstName": "QA",
      "lastName": "User",
      "email": "qa501@example.com",
      "password": "Secret#123",
      "phone": "+33123456789",
      "userStatus": 1
    }
    """
    Given path 'user'
    And request ensure
    When method post
    Then status 200
    * def update =
    """
    {
      "id": 501,
      "username": "qa_user_501",
      "firstName": "QA",
      "lastName": "User-Updated",
      "email": "qa501.updated@example.com",
      "password": "Secret#123",
      "phone": "+33999999999",
      "userStatus": 2
    }
    """
    Given path 'user', 'qa_user_501'
    And request update
    When method put
    Then status 200
    * configure headers = { Accept: 'application/json' }
    Given path 'user', 'qa_user_501'
    When method get
    Then status 200
    And match response.lastName == 'User-Updated'
    And match response.userStatus == 2

  @critical @user @delete
  Scenario: Delete user and verify subsequent lookup returns 404
    * configure headers = { Accept: 'application/json', Content-Type: 'application/json' }
    * def toCreate =
    """
    {
      "id": 5120,
      "username": "qa_user_to_delete",
      "firstName": "QA",
      "lastName": "Del",
      "email": "qa_delete@example.com",
      "password": "Secret#123",
      "phone": "+33000000001",
      "userStatus": 1
    }
    """
    Given path 'user'
    And request toCreate
    When method post
    Then status 200
    * configure headers = { Accept: 'application/json' }
    Given path 'user', 'qa_user_to_delete'
    When method delete
    Then status 200
    Given path 'user', 'qa_user_to_delete'
    When method get
    Then status 404

  @medium @user @negative
  Scenario Outline: User operations with invalid usernames return client error
    * configure headers = { Accept: 'application/json' }
    Given path 'user', <username>
    When method get
    Then status 400
    Examples:
      | username     |
      | ''           |
      | ' '          |
      | '../../etc'  |

  @medium @user @negative @validation
  Scenario: Create a user with invalid email format should be rejected
    * configure headers = { Accept: 'application/json', Content-Type: 'application/json' }
    * def invalid =
    """
    {
      "id": 512,
      "username": "qa_user_512",
      "firstName": "QA",
      "lastName": "User",
      "email": "invalid-email",
      "password": "Secret#123",
      "phone": "+33000000000",
      "userStatus": 1
    }
    """
    Given path 'user'
    And request invalid
    When method post
    Then status 400
