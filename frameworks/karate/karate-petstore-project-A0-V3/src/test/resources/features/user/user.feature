Feature: User API — Lifecycle and Session Management (High-Risk Coverage)

Background:
  * url baseUrl
  * configure headers = { Accept: 'application/json' }
  * def userSchema =
  """
  {
    id: '#number',
    username: '#string',
    firstName: '##string',
    lastName: '##string',
    email: '##string',
    password: '##string',
    phone: '##string',
    userStatus: '##number'
  }
  """

Scenario: Create user with POST /user
  * def user =
  """
  {
    id: 3101,
    username: "qa_user_1",
    firstName: "QA",
    lastName: "User",
    email: "qa.user1@example.com",
    password: "P@ssw0rd!",
    phone: "+12025550123",
    userStatus: 1
  }
  """
  Given path 'user'
  And request user
  When method post
  Then status 200
  And match response == userSchema

Scenario: Get user by username returns created user (seed-before-read)
  * def user =
  """
  {
    id: 3102,
    username: "qa_user_2",
    firstName: "QA",
    lastName: "User2",
    email: "qa.user2@example.com",
    password: "P@ssw0rd!",
    phone: "+12025550124",
    userStatus: 1
  }
  """
  Given path 'user'
  And request user
  When method post
  Then status 200
  Given path 'user', 'qa_user_2'
  When method get
  Then status 200
  And match response.username == 'qa_user_2'
  And match response.email == 'qa.user2@example.com'

Scenario: Update user by username (seed-before-read)
  * def user =
  """
  {
    id: 3103,
    username: "qa_user_3",
    firstName: "QA",
    lastName: "User3",
    email: "qa.user3@example.com",
    password: "old",
    phone: "1000000003",
    userStatus: 1
  }
  """
  Given path 'user'
  And request user
  When method post
  Then status 200
  * def upd =
  """
  {
    id: 3103,
    username: "qa_user_3",
    firstName: "QA",
    lastName: "User-Updated",
    email: "qa.user3+updated@example.com",
    password: "N3wP@ss!",
    phone: "1000000004",
    userStatus: 2
  }
  """
  Given path 'user', 'qa_user_3'
  And request upd
  When method put
  Then status 200
  Given path 'user', 'qa_user_3'
  When method get
  Then status 200
  And match response.lastName == 'User-Updated'
  And match response.email == 'qa.user3+updated@example.com'

Scenario: User login returns 200 and session token details (seed-before-read)
  * def user =
  """
  { id: 3104, username: "qa_user_4", firstName: "Q", lastName: "U4", email: "u4@example.com", password: "pwd4", phone: "1000000005", userStatus: 1 }
  """
  Given path 'user'
  And request user
  When method post
  Then status 200
  Given path 'user', 'login'
  And param username = 'qa_user_4'
  And param password = 'pwd4'
  When method get
  Then status 200
  * def t = karate.typeOf(response)
  * if (t == 'map') match response contains { code: '#number', type: '##string', message: '#string' }
  * else match response == '#string'

Scenario: User logout succeeds
  Given path 'user', 'logout'
  When method get
  Then status 200

Scenario: Delete user by username and confirm deletion (seed-before-read)
  * def user =
  """
  { id: 3105, username: "qa_user_del", firstName: "Del", lastName: "Me", email: "del@example.com", password: "x", phone: "1", userStatus: 0 }
  """
  Given path 'user'
  And request user
  When method post
  Then status 200
  Given path 'user', 'qa_user_del'
  When method delete
  Then match [200,204] contains responseStatus
  Given path 'user', 'qa_user_del'
  When method get
  Then status 404

Scenario: Create multiple users via array
  * def users =
  """
  [
    {"id": 3201, "username": "qa_batch_1", "firstName": "A", "lastName": "One", "email": "a1@example.com", "password": "a1", "phone": "1000000001", "userStatus": 0},
    {"id": 3202, "username": "qa_batch_2", "firstName": "B", "lastName": "Two", "email": "b2@example.com", "password": "b2", "phone": "1000000002", "userStatus": 0}
  ]
  """
  Given path 'user', 'createWithArray'
  And request users
  When method post
  Then status 200
  Given path 'user', 'qa_batch_1'
  When method get
  Then status 200
  Given path 'user', 'qa_batch_2'
  When method get
  Then status 200

Scenario: Create multiple users via list
  * def users =
  """
  [
    {"id": 3301, "username": "qa_list_1", "firstName": "C", "lastName": "Three", "email": "c3@example.com", "password": "c3", "phone": "1000000003", "userStatus": 0},
    {"id": 3302, "username": "qa_list_2", "firstName": "D", "lastName": "Four", "email": "d4@example.com", "password": "d4", "phone": "1000000004", "userStatus": 0}
  ]
  """
  Given path 'user', 'createWithList'
  And request users
  When method post
  Then status 200
  Given path 'user', 'qa_list_1'
  When method get
  Then status 200
  Given path 'user', 'qa_list_2'
  When method get
  Then status 200

Scenario Outline: User operations with invalid usernames
  Given path 'user', '<username>'
  When method <method>
  Then status <status>
  * def t = karate.typeOf(response)
  * if (t == 'map') match response contains { message: '#string' }
  * else match response == '#string'
  Examples:
    | method | username     | status |
    | GET    | '!nv@lid'    | 400    |
    | GET    | 'non_exist'  | 404    |
    | DELETE | 'non_exist'  | 404    |
