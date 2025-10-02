Feature: User Update

Background:
  * url baseUrl
  * def userId = ~~(Math.random() * 10000)
  * def username = 'updateuser_' + userId

Scenario: Successfully update existing user information
  Given path 'user'
  And request { id: '#(userId)', username: '#(username)', firstName: 'Original', lastName: 'Name', email: 'original@example.com', password: 'pass123', phone: '1111111111', userStatus: 0 }
  When method post
  Then status 200
  
  Given path 'user', username
  And request { id: '#(userId)', username: '#(username)', firstName: 'Updated', lastName: 'Name', email: 'updated@example.com', password: 'newpass123', phone: '2222222222', userStatus: 1 }
  When method put
  Then status 200

Scenario: Attempt to update a user that does not exist
  Given path 'user', 'missinguser'
  And request { username: 'missinguser', email: 'missing@example.com', password: 'pass123' }
  When method put
  Then status 404
