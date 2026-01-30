Feature: User API - Read, Update, Delete Operations
  As a system administrator
  I need to manage user accounts
  So that I can maintain accurate user records

  Background:
    * url baseUrl
    * def generateUsername = function(){ return 'testuser_' + Math.floor(Math.random() * 1000000) }

  @critical @smoke @user @read
  Scenario: TC-USER-023 - Successfully retrieve user by username
    * def username = generateUsername()
    # Create user first
    Given path 'user'
    And request
      """
      {
        "username": "#(username)",
        "firstName": "ReadTest",
        "lastName": "User",
        "email": "readtest@test.com"
      }
      """
    When method POST
    Then status 200
    
    # Retrieve user
    Given path 'user', username
    When method GET
    Then status 200
    And match response.username == username
    And match response.firstName == 'ReadTest'
    And match response.lastName == 'User'
    And match response.email == 'readtest@test.com'

  @negative @user @read @validation
  Scenario: TC-USER-024 - Return 404 for non-existent username
    Given path 'user', 'nonexistentuser999xyz'
    When method GET
    Then status 404

  @user @read @content-negotiation
  Scenario: TC-USER-026 - Retrieve user in XML format
    * def username = generateUsername()
    Given path 'user'
    And request { username: '#(username)' }
    When method POST
    Then status 200
    
    Given path 'user', username
    And header Accept = 'application/xml'
    When method GET
    Then status 200
    And match header Content-Type contains 'application/xml'

  @user @read @security
  Scenario: TC-USER-027 - Verify password handling in response
    * def username = generateUsername()
    Given path 'user'
    And request { username: '#(username)', password: 'secretpassword123' }
    When method POST
    Then status 200
    
    Given path 'user', username
    When method GET
    Then status 200

  @critical @user @update
  Scenario: TC-USER-028 - Successfully update user information
    * def username = generateUsername()
    # Create user
    Given path 'user'
    And request { username: '#(username)', firstName: 'Original', lastName: 'Name', email: 'original@test.com' }
    When method POST
    Then status 200
    
    # Update user
    Given path 'user', username
    And header Content-Type = 'application/json'
    And request
      """
      {
        "username": "#(username)",
        "firstName": "UpdatedFirstName",
        "lastName": "UpdatedLastName",
        "email": "updated@test.com"
      }
      """
    When method PUT
    Then status 200
    
    # Verify update
    Given path 'user', username
    When method GET
    Then status 200
    And match response.firstName == 'UpdatedFirstName'
    And match response.lastName == 'UpdatedLastName'
    And match response.email == 'updated@test.com'

  @user @update
  Scenario: TC-USER-029 - Update user password
    * def username = generateUsername()
    Given path 'user'
    And request { username: '#(username)', password: 'oldpassword' }
    When method POST
    Then status 200
    
    Given path 'user', username
    And header Content-Type = 'application/json'
    And request { username: '#(username)', password: 'NewSecurePass456!' }
    When method PUT
    Then status 200

  @user @update
  Scenario: TC-USER-030 - Update user status
    * def username = generateUsername()
    Given path 'user'
    And request { username: '#(username)', userStatus: 1 }
    When method POST
    Then status 200
    
    Given path 'user', username
    And header Content-Type = 'application/json'
    And request { username: '#(username)', userStatus: 0 }
    When method PUT
    Then status 200

  @negative @user @update @validation
  Scenario: TC-USER-031 - Return 404 when updating non-existent user
    Given path 'user', 'nonexistentuser999xyz'
    And header Content-Type = 'application/json'
    And request { username: 'nonexistentuser999xyz', firstName: 'Test' }
    When method PUT
    Then status 404

  @user @update @idempotency
  Scenario: TC-USER-033 - Verify PUT request idempotency
    * def username = generateUsername()
    Given path 'user'
    And request { username: '#(username)', firstName: 'Original' }
    When method POST
    Then status 200
    
    # First PUT
    Given path 'user', username
    And request { username: '#(username)', firstName: 'Updated' }
    When method PUT
    Then status 200
    
    # Second PUT (same request)
    Given path 'user', username
    And request { username: '#(username)', firstName: 'Updated' }
    When method PUT
    Then status 200
    
    # Verify final state
    Given path 'user', username
    When method GET
    Then status 200
    And match response.firstName == 'Updated'

  @critical @user @delete
  Scenario: TC-USER-034 - Successfully delete an existing user
    * def username = generateUsername()
    # Create user
    Given path 'user'
    And request { username: '#(username)' }
    When method POST
    Then status 200
    
    # Delete user
    Given path 'user', username
    When method DELETE
    Then status 200
    
    # Verify deletion
    Given path 'user', username
    When method GET
    Then status 404

  @negative @user @delete @validation
  Scenario: TC-USER-035 - Return 404 when deleting non-existent user
    Given path 'user', 'nonexistentuser999xyz'
    When method DELETE
    Then status 404

  @user @delete @idempotency
  Scenario: TC-USER-037 - Verify DELETE idempotency behavior
    * def username = generateUsername()
    Given path 'user'
    And request { username: '#(username)' }
    When method POST
    Then status 200
    
    # First delete
    Given path 'user', username
    When method DELETE
    Then status 200
    
    # Second delete
    Given path 'user', username
    When method DELETE
    Then status 404

  @user @read @schema
  Scenario: TC-USER-SCHEMA-001 - Verify user response schema
    * def username = generateUsername()
    Given path 'user'
    And request { username: '#(username)', firstName: 'Schema', lastName: 'Test', email: 'schema@test.com', phone: '555-1234', userStatus: 1 }
    When method POST
    Then status 200
    
    Given path 'user', username
    When method GET
    Then status 200
    And match response ==
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
