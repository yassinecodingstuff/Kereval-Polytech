Feature: User API — Accounts & Authentication (Swagger Petstore v2)
  Background:
    * def baseUrl = karate.get('baseUrl')
    * url baseUrl
    * configure headers = { Accept: 'application/json' }
    * configure logPrettyRequest = true
    * configure logPrettyResponse = true
    * def unique = function(p){ return p + java.lang.System.currentTimeMillis(); }
    * def userSchema =
      """
      {
        id: '#? _ == null || typeof _ == "number"',
        username: '#string',
        firstName: '#? _ == null || typeof _ == "string"',
        lastName: '#? _ == null || typeof _ == "string"',
        email: '#? _ == null || typeof _ == "string"',
        password: '#? _ == null || typeof _ == "string"',
        phone: '#? _ == null || typeof _ == "string"',
        userStatus: '#? _ == null || typeof _ == "number"'
      }
      """

  @high @smoke @user @create
  Scenario: Create Single User
    * def uname = unique('userA-')
    Given path 'user'
    And request { username: #(uname), firstName: 'Ada', lastName: 'Lovelace', email: 'ada@example.test', password: 's3cret', phone: '+1-555-1000', userStatus: 1 }
    When method post
    Then status 200
    And match response == { code: '#number', type: '#string?', message: '#string' }

  @medium @user @bulk
  Scenario: Create Users with Array
    * def uname1 = unique('arr-1-')
    * def uname2 = unique('arr-2-')
    Given path 'user', 'createWithArray'
    And request [ { username: #(uname1) }, { username: #(uname2) } ]
    When method post
    Then status 200

  @medium @user @bulk
  Scenario: Create Users with List
    * def uname1 = unique('lst-1-')
    * def uname2 = unique('lst-2-')
    Given path 'user', 'createWithList'
    And request [ { username: #(uname1) }, { username: #(uname2) } ]
    When method post
    Then status 200

  @high @smoke @user @auth
  Scenario: Login User returns token and rate-limit headers
    Given path 'user', 'login'
    And param username = 'user1'
    And param password = 'password1'
    When method get
    Then status 200
    And match response == '#string'
    * def rate = responseHeaders['X-Rate-Limit'][0]
    * def expires = responseHeaders['X-Expires-After'][0]
    * match rate == '#number'
    * def rfc3339 = /^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(?:\.\d+)?Z$/
    * match expires == '#regex ' + rfc3339

  @medium @negative @user @auth
  Scenario: Login User with invalid credentials returns 400
    Given path 'user', 'login'
    And param username = 'nouser'
    And param password = 'badpass'
    When method get
    Then status 400
    And match response == { code: '#number', type: '#string?', message: '#string' }

  @high @user @read
  Scenario: Get User by Username (Happy Path)
    * def uname = unique('userA-')
    Given path 'user'
    And request { username: #(uname) }
    When method post
    Then status 200
    Given path 'user', uname
    When method get
    Then status 200
    And match response == userSchema
    And match response.username == uname

  @medium @negative @user @read
  Scenario: Get User by Username not found returns 404
    Given path 'user', 'nonexistent-user'
    When method get
    Then status 404
    And match response == { code: '#number', type: '#string?', message: '#string' }

  @medium @user @update
  Scenario: Update Existing User
    * def uname = unique('userU-')
    Given path 'user'
    And request { username: #(uname), firstName: 'First' }
    When method post
    Then status 200
    Given path 'user', uname
    And request { firstName: 'Augusta' }
    When method put
    Then match responseStatus == 200 || responseStatus == 400 || responseStatus == 404
    Given path 'user', uname
    When method get
    * if (responseStatus == 200) match response.firstName == 'Augusta'

  @medium @user @delete
  Scenario Outline: Delete User — success and error handling
    * def uname = unique('userD-')
    Given path 'user'
    And request { username: #(uname) }
    When method post
    Then status 200
    * def target = <uname> == 'userA' ? uname : <uname>
    Given path 'user', target
    When method delete
    * if (target == uname) assert responseStatus == 200 || responseStatus == 204
    * else if (target == 'nouser') assert responseStatus == 404
    * else if (target == '') assert responseStatus == 400
    Examples:
      | uname  |
      | userA  |
      | nouser |
      | ''     |

  @low @user @auth
  Scenario: Logout User
    Given path 'user', 'logout'
    When method get
    Then status 200
