Feature: User Authentication

Background:
  * url baseUrl

Scenario: Successfully login with valid credentials
  Given path 'user', 'login'
  And param username = 'testuser'
  And param password = 'password123'
  When method get
  Then status 200
  And match responseHeaders['X-Rate-Limit'] == '#present'
  And match responseHeaders['X-Expires-After'] == '#present'

Scenario: Attempt to login with invalid credentials
  Given path 'user', 'login'
  And param username = 'invaliduser'
  And param password = 'wrongpassword'
  When method get
  Then status 400

Scenario: Successfully logout current user session
  Given path 'user', 'logout'
  When method get
  Then status 200
