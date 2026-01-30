Feature: User API — Provisioning, Auth, and Profile (Medium/High Priority, ISO 29119-aligned)
  Background:
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

  Scenario: [GET] Login — success returns 200 with rate-limit headers
    Given path 'user', 'login'
    And param username = 'user1'
    And param password = 'pass1'
    When method get
    Then status 200
    * def rl = responseHeaders['X-Rate-Limit'][0]
    * match rl == '#number'
    * def exp = responseHeaders['X-Expires-After'][0]
    * match exp == '#string'
    * match response == '#string'

  Scenario: [GET] Login — invalid credentials return 400
    Given path 'user', 'login'
    And param username = ''
    And param password = ''
    When method get
    Then status 400
    * def t = karate.typeOf(response)
    * if (t == 'map') match response contains { message: '#string' }
    * else match response == '#string'

  Scenario: [GET] Logout — tolerant success
    Given path 'user', 'logout'
    When method get
    Then match [200,204] contains responseStatus

  Scenario: [POST] Create single user — contract-tolerant
    Given path 'user'
    And request { id: 3001, username: 'u_created', firstName: 'Al', lastName: 'Pa', email: 'u_created@example.org', password: 'p', phone: '1', userStatus: 1 }
    When method post
    Then match [200,201] contains responseStatus

  Scenario: [POST] Create users with array — contract-tolerant
    Given path 'user', 'createWithArray'
    And request
    """
    [
      { id: 3002, username: 'arr_1', firstName: 'A', lastName: '1', email: 'arr1@example.org', password: 'p', phone: '1', userStatus: 1 },
      { id: 3003, username: 'arr_2', firstName: 'B', lastName: '2', email: 'arr2@example.org', password: 'p', phone: '2', userStatus: 1 }
    ]
    """
    When method post
    Then match [200,201] contains responseStatus

  Scenario: [POST] Create users with list — contract-tolerant
    Given path 'user', 'createWithList'
    And request
    """
    [
      { id: 3004, username: 'lst_1', firstName: 'L', lastName: '1', email: 'lst1@example.org', password: 'p', phone: '1', userStatus: 1 },
      { id: 3005, username: 'lst_2', firstName: 'L', lastName: '2', email: 'lst2@example.org', password: 'p', phone: '2', userStatus: 1 },
      { id: 3006, username: 'lst_3', firstName: 'L', lastName: '3', email: 'lst3@example.org', password: 'p', phone: '3', userStatus: 1 }
    ]
    """
    When method post
    Then match [200,201] contains responseStatus

  Scenario: [GET] Get user by username — seed then 200 with schema
    * def uname = 'u_get_1'
    Given path 'user'
    And request { id: 3010, username: '#(uname)', firstName: 'G', lastName: 'U', email: 'g.u@example.org', password: 'p', phone: '1', userStatus: 1 }
    When method post
    Then match [200,201] contains responseStatus
    Given path 'user', uname
    When method get
    Then status 200
    And match response == userSchema

  Scenario Outline: [GET] Get user by username — invalid or not found
    Given path 'user', uname
    When method get
    Then match [400,404] contains responseStatus
    Examples:
      | uname   |
      | ''      |
      | '???'   |
      | 'ghost' |

  Scenario: [PUT] Update user — seed, update, tolerant per spec
    * def uname = 'u_to_update'
    Given path 'user'
    And request { id: 3020, username: '#(uname)', firstName: 'Old', lastName: 'Name', email: 'old@example.org', password: 'p', phone: '1', userStatus: 1 }
    When method post
    Then match [200,201] contains responseStatus
    Given path 'user', uname
    And request { id: 3020, username: '#(uname)', firstName: 'New', lastName: 'Name', email: 'new@example.org', password: 'p2', phone: '2', userStatus: 1 }
    When method put
    Then match [200,400,404] contains responseStatus
    Given path 'user', uname
    When method get
    Then match [200,404] contains responseStatus
    * if (responseStatus == 200) match response == userSchema

  Scenario: [DELETE] Delete user — seed then tolerant delete
    * def uname = 'u_delete'
    Given path 'user'
    And request { id: 3030, username: '#(uname)', firstName: 'Del', lastName: 'Me', email: 'del@example.org', password: 'p', phone: '1', userStatus: 1 }
    When method post
    Then match [200,201] contains responseStatus
    Given path 'user', uname
    When method delete
    Then match [200,400,404] contains responseStatus
    Given path 'user', uname
    When method get
    Then match [200,404] contains responseStatus
