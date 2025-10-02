Feature: User Creation

Background:
  * url baseUrl

Scenario: Successfully create a new user
  * def userId = ~~(Math.random() * 10000)
  * def username = 'testuser_' + userId
  
  Given path 'user'
  And request { id: '#(userId)', username: '#(username)', firstName: 'Test', lastName: 'User', email: 'test@example.com', password: 'password123', phone: '1234567890', userStatus: 0 }
  When method post
  Then status 200

Scenario: Create users with array
  Given path 'user', 'createWithArray'
  And request [{ id: '#(~~(Math.random() * 10000))', username: 'arrayuser1', email: 'array1@example.com', password: 'pass1' }, { id: '#(~~(Math.random() * 10000))', username: 'arrayuser2', email: 'array2@example.com', password: 'pass2' }]
  When method post
  Then status 200

Scenario: Create users with list
  Given path 'user', 'createWithList'
  And request [{ id: '#(~~(Math.random() * 10000))', username: 'listuser1', email: 'list1@example.com', password: 'pass1' }, { id: '#(~~(Math.random() * 10000))', username: 'listuser2', email: 'list2@example.com', password: 'pass2' }]
  When method post
  Then status 200
