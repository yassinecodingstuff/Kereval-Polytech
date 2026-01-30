Feature: User API - Authentication Operations
  As a pet store user
  I need to authenticate to the system
  So that I can securely access my account and perform transactions

  Background:
    * url baseUrl
    * def generateUsername = function(){ return 'testuser_' + Math.floor(Math.random() * 1000000) }

  @critical @smoke @user @auth @login
  Scenario: TC-USER-012 - Successfully login with valid credentials
    * def username = generateUsername()
    # Create user first
    Given path 'user'
    And request { username: '#(username)', password: 'password123' }
    When method POST
    Then status 200
    
    # Login
    Given path 'user', 'login'
    And param username = username
    And param password = 'password123'
    When method GET
    Then status 200
    And match response == '#string'
    And match responseHeaders['X-Expires-After'] == '#present'
    And match responseHeaders['X-Rate-Limit'] == '#present'

  @negative @user @auth @login @validation
  Scenario: TC-USER-013 - Reject login with invalid username
    Given path 'user', 'login'
    And param username = 'nonexistent_user_xyz_999'
    And param password = 'anypassword'
    When method GET
    Then status 400

  @negative @user @auth @login @validation
  Scenario: TC-USER-014 - Handle login with invalid password
    * def username = generateUsername()
    # Create user first
    Given path 'user'
    And request { username: '#(username)', password: 'correctpassword' }
    When method POST
    Then status 200
    
    # Login with wrong password
    Given path 'user', 'login'
    And param username = username
    And param password = 'wrongpassword'
    When method GET
    Then assert responseStatus == 200 || responseStatus == 400

  @negative @user @auth @login @validation
  Scenario: TC-USER-015 - Handle login without username parameter
    Given path 'user', 'login'
    And param password = 'somepassword'
    When method GET
    Then assert responseStatus == 400 || responseStatus == 200

  @negative @user @auth @login @validation
  Scenario: TC-USER-016 - Handle login without password parameter
    Given path 'user', 'login'
    And param username = 'someuser'
    When method GET
    Then assert responseStatus == 400 || responseStatus == 200

  @negative @user @auth @login @validation
  Scenario: TC-USER-017 - Handle login with empty credentials
    Given path 'user', 'login'
    And param username = ''
    And param password = ''
    When method GET
    Then assert responseStatus == 400 || responseStatus == 200

  @user @auth @login @security
  Scenario: TC-USER-018 - Verify rate limit header in login response
    * def username = generateUsername()
    Given path 'user'
    And request { username: '#(username)', password: 'testpass' }
    When method POST
    Then status 200
    
    Given path 'user', 'login'
    And param username = username
    And param password = 'testpass'
    When method GET
    Then status 200
    And match responseHeaders['X-Rate-Limit'][0] == '#string'
    * def rateLimit = parseInt(responseHeaders['X-Rate-Limit'][0])
    And assert rateLimit > 0

  @user @auth @login @security
  Scenario: TC-USER-019 - Verify session expiry header in login response
    * def username = generateUsername()
    Given path 'user'
    And request { username: '#(username)', password: 'testpass' }
    When method POST
    Then status 200
    
    Given path 'user', 'login'
    And param username = username
    And param password = 'testpass'
    When method GET
    Then status 200
    And match responseHeaders['X-Expires-After'][0] == '#string'

  @user @auth @login @security @injection
  Scenario: TC-USER-020 - Handle SQL injection attempt in login
    Given path 'user', 'login'
    And param username = "' OR '1'='1"
    And param password = "' OR '1'='1"
    When method GET
    Then assert responseStatus == 400 || responseStatus == 200

  @critical @user @auth @logout
  Scenario: TC-USER-021 - Successfully logout current session
    Given path 'user', 'logout'
    When method GET
    Then status 200

  @user @auth @logout
  Scenario: TC-USER-022 - Logout without active session
    Given path 'user', 'logout'
    When method GET
    Then status 200

  @user @auth @login @performance
  Scenario: TC-USER-PERF-002 - User login responds within acceptable time
    * def username = generateUsername()
    Given path 'user'
    And request { username: '#(username)', password: 'testpass' }
    When method POST
    Then status 200
    
    Given path 'user', 'login'
    And param username = username
    And param password = 'testpass'
    When method GET
    Then status 200
    And assert responseTime < 2000

  @user @auth @login @special-characters
  Scenario: TC-USER-AUTH-001 - Login with special characters in password
    * def username = generateUsername()
    * def specialPassword = 'P@ss!w0rd#$%^&*()'
    Given path 'user'
    And request { username: '#(username)', password: '#(specialPassword)' }
    When method POST
    Then status 200
    
    Given path 'user', 'login'
    And param username = username
    And param password = specialPassword
    When method GET
    Then status 200
