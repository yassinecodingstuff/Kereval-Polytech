Feature: User API — Account CRUD & Sessions

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
  * def apiRespSchema =
  """
  {
    code: '##number',
    type: '##string',
    message: '##string'
  }
  """
  * def userA = 'userA'
  * def arr1 = 'arr1'
  * def arr2 = 'arr2'

Scenario: Create single User
  Given path 'user'
  And request { username: #(userA), firstName: 'Ann', lastName: 'Example', email: 'ann@example.com', password: 'p@ssw0rd', phone: '+1000000000', userStatus: 1 }
  When method post
  Then match [200,201,202] contains responseStatus

Scenario: Create Users with Array
  Given path 'user', 'createWithArray'
  And request [ { username: #(arr1), password: 'x' }, { username: #(arr2), password: 'y' } ]
  When method post
  Then status 200

Scenario: Create Users with List
  Given path 'user', 'createWithList'
  And request [ { username: 'list1', password: 'x' }, { username: 'list2', password: 'y' } ]
  When method post
  Then status 200

Scenario: Get User by username
  Given path 'user', userA
  When method get
  Then status 200
  And match response == userSchema
  And match response.username == userA

Scenario: Update User by username
  Given path 'user', userA
  And request { username: #(userA), firstName: 'Annie', lastName: 'Example', email: 'annie@example.com' }
  When method put
  Then match [200,204] contains responseStatus
  Given path 'user', userA
  When method get
  Then status 200
  And match response.firstName == 'Annie'

Scenario: Delete User by username
  Given path 'user', userA
  When method delete
  Then match [200,204] contains responseStatus
  Given path 'user', userA
  When method get
  Then status 404

Scenario: Login returns token string and session headers
  Given path 'user', 'login'
  And param username = arr1
  And param password = 'x'
  When method get
  Then status 200
  And match response == '#string'
  * def rate = responseHeaders['X-Rate-Limit'][0]
  * match rate == '#? /^\\d+$/.test(_)'
  * def expires = responseHeaders['X-Expires-After'][0]
  * match expires == '#? /^\\d{4}-\\d{2}-\\d{2}T\\d{2}:\\d{2}:\\d{2}(\\.\\d+)?Z$/.test(_)'

Scenario: Logout succeeds
  Given path 'user', 'logout'
  When method get
  Then status 200

Scenario: Get User not found yields 404
  Given path 'user', 'does-not-exist'
  When method get
  Then status 404
  And match response == apiRespSchema

Scenario: Update User invalid body yields 400
  Given path 'user', arr1
  And request { userStatus: 'ACTIVE' }
  When method put
  Then status 400
  And match response == apiRespSchema
