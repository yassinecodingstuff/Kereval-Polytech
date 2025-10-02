Feature: User Retrieval by Username

Background:
  * url baseUrl
  * def userId = ~~(Math.random() * 10000)
  * def username = 'getuser_' + userId

Scenario: Successfully retrieve user information by username
  Given path 'user'
  And request { id: '#(userId)', username: '#(username)', firstName: 'Get', lastName: 'User', email: 'getuser@example.com', password: 'test123', phone: '1234567890', userStatus: 0 }
  When method post
  Then status 200
  
  Given path 'user', username
  When method get
  Then status 200
  And match response.username == username
  And match response.id == '#notnull'
  And match response.email == '#notnull'

Scenario: Attempt to retrieve a user that does not exist
  Given path 'user', 'nonexistentuser'
  When method get
  Then status 404
