Feature: User Deletion

Background:
  * url baseUrl
  * def userId = ~~(Math.random() * 10000)
  * def username = 'deleteuser_' + userId

Scenario: Successfully delete an existing user
  Given path 'user'
  And request { id: '#(userId)', username: '#(username)', email: 'delete@example.com', password: 'pass123' }
  When method post
  Then status 200
  
  Given path 'user', username
  When method delete
  Then status 200
  
  Given path 'user', username
  When method get
  Then status 404

Scenario: Attempt to delete a user that does not exist
  Given path 'user', 'ghostuser'
  When method delete
  Then status 404
