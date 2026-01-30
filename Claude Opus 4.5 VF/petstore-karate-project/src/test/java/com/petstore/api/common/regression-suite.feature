Feature: Automated Regression Test Suite
  As a QA engineer
  I need automated regression tests
  So that I can quickly validate API stability after changes

  Background:
    * url baseUrl
    * def generatePetId = function(){ return Math.floor(Math.random() * 900000) + 100000 }
    * def generateUsername = function(){ return 'reg_user_' + Math.floor(Math.random() * 1000000) }

  @regression @smoke @quick
  Scenario: TC-REG-001 - Quick smoke test - all endpoints accessible
    # Pet endpoints
    Given path 'pet', 'findByStatus'
    And param status = 'available'
    When method GET
    Then assert responseStatus < 500
    And assert responseTime < 10000
    
    # Store endpoints
    Given path 'store', 'inventory'
    And header api_key = apiKey
    When method GET
    Then assert responseStatus < 500
    And assert responseTime < 10000
    
    # User endpoints
    Given path 'user', 'logout'
    When method GET
    Then assert responseStatus < 500
    And assert responseTime < 10000

  @regression @data-integrity
  Scenario: TC-REG-002 - Data integrity verification after CRUD operations
    * def petId = generatePetId()
    * def originalName = 'IntegrityPet'
    * def originalStatus = 'available'
    * def updatedName = 'UpdatedIntegrityPet'
    * def updatedStatus = 'sold'
    
    # CREATE - Create pet with known values
    Given path 'pet'
    And header Content-Type = 'application/json'
    And request
      """
      {
        "id": #(petId),
        "name": "#(originalName)",
        "photoUrls": ["https://example.com/integrity.jpg"],
        "status": "#(originalStatus)"
      }
      """
    When method POST
    Then status 200
    And match response.id == petId
    And match response.name == originalName
    And match response.status == originalStatus
    
    # READ - Retrieve and verify all fields match
    Given path 'pet', petId
    And header api_key = apiKey
    When method GET
    Then status 200
    And match response.id == petId
    And match response.name == originalName
    And match response.status == originalStatus
    
    # UPDATE - Update specific fields
    Given path 'pet'
    And header Content-Type = 'application/json'
    And request
      """
      {
        "id": #(petId),
        "name": "#(updatedName)",
        "photoUrls": ["https://example.com/integrity.jpg"],
        "status": "#(updatedStatus)"
      }
      """
    When method PUT
    Then status 200
    And match response.name == updatedName
    And match response.status == updatedStatus
    
    # READ - Verify only updated fields changed
    Given path 'pet', petId
    And header api_key = apiKey
    When method GET
    Then status 200
    And match response.id == petId
    And match response.name == updatedName
    And match response.status == updatedStatus
    
    # DELETE
    Given path 'pet', petId
    And header api_key = apiKey
    When method DELETE
    Then status 200
    
    # VERIFY DELETION
    Given path 'pet', petId
    And header api_key = apiKey
    When method GET
    Then status 404

  @regression @boundary
  Scenario: TC-REG-003 - Boundary value verification for ID fields
    # Pet boundary tests
    Given path 'pet', 0
    And header api_key = apiKey
    When method GET
    Then assert responseStatus == 400 || responseStatus == 404
    
    Given path 'pet', -1
    And header api_key = apiKey
    When method GET
    Then assert responseStatus == 400 || responseStatus == 404
    
    # Order boundary tests (valid range 1-10)
    Given path 'store', 'order', 0
    When method GET
    Then assert responseStatus == 400 || responseStatus == 404
    
    Given path 'store', 'order', 1
    When method GET
    Then assert responseStatus == 200 || responseStatus == 404
    
    Given path 'store', 'order', 10
    When method GET
    Then assert responseStatus == 200 || responseStatus == 404
    
    Given path 'store', 'order', 11
    When method GET
    Then status 404

  @regression @security
  Scenario: TC-REG-004 - Security regression for authentication
    # Test store inventory with different API key scenarios
    Given path 'store', 'inventory'
    When method GET
    * def noAuthStatus = responseStatus
    
    Given path 'store', 'inventory'
    And header api_key = 'invalid_api_key'
    When method GET
    * def invalidAuthStatus = responseStatus
    
    Given path 'store', 'inventory'
    And header api_key = apiKey
    When method GET
    Then status 200
    
    # Test user login with invalid credentials
    Given path 'user', 'login'
    And param username = 'nonexistent_user_xyz_999'
    And param password = 'invalidpassword'
    When method GET
    Then assert responseStatus == 400 || responseStatus == 200

  @regression @schema
  Scenario: TC-REG-005 - Schema validation for all response types
    * def petId = generatePetId()
    
    # Pet schema validation
    Given path 'pet'
    And request { id: #(petId), name: 'SchemaPet', photoUrls: ['https://example.com/schema.jpg'], status: 'available' }
    When method POST
    Then status 200
    And match response == { id: '#number', name: '#string', photoUrls: '#array', status: '#string', category: '##object', tags: '##array' }
    
    Given path 'pet', petId
    And header api_key = apiKey
    When method GET
    Then status 200
    And match response.id == '#number'
    And match response.name == '#string'
    And match response.photoUrls == '#array'
    
    # Order schema validation
    Given path 'store', 'order'
    And request { petId: #(petId), quantity: 1, status: 'placed', complete: false }
    When method POST
    Then status 200
    And match response == { id: '#number', petId: '#number', quantity: '#number', shipDate: '##string', status: '##string', complete: '##boolean' }
    * def orderId = response.id
    
    # User schema validation
    * def username = generateUsername()
    Given path 'user'
    And request { username: '#(username)', firstName: 'Schema', lastName: 'User', email: 'schema@test.com' }
    When method POST
    Then status 200
    
    Given path 'user', username
    When method GET
    Then status 200
    And match response contains { username: '#string' }
    
    # Cleanup
    Given path 'pet', petId
    And header api_key = apiKey
    When method DELETE
    Then status 200
    
    Given path 'store', 'order', orderId
    When method DELETE
    Then assert responseStatus == 200 || responseStatus == 404
    
    Given path 'user', username
    When method DELETE
    Then status 200

  @regression @status-codes
  Scenario: TC-REG-006 - HTTP status code verification
    * def petId = generatePetId()
    
    # 200 OK - Successful GET
    Given path 'pet', 'findByStatus'
    And param status = 'available'
    When method GET
    Then status 200
    
    # 200 OK - Successful POST
    Given path 'pet'
    And request { id: #(petId), name: 'StatusCodePet', photoUrls: ['https://example.com/status.jpg'], status: 'available' }
    When method POST
    Then status 200
    
    # 200 OK - Successful PUT
    Given path 'pet'
    And request { id: #(petId), name: 'UpdatedStatusCodePet', photoUrls: ['https://example.com/status.jpg'], status: 'sold' }
    When method PUT
    Then status 200
    
    # 200 OK - Successful DELETE
    Given path 'pet', petId
    And header api_key = apiKey
    When method DELETE
    Then status 200
    
    # 404 Not Found
    Given path 'pet', 999999999999
    And header api_key = apiKey
    When method GET
    Then status 404

  @regression @performance
  Scenario: TC-REG-007 - Performance regression verification
    # Pet findByStatus performance
    Given path 'pet', 'findByStatus'
    And param status = 'available'
    When method GET
    Then status 200
    And assert responseTime < 5000
    
    # Store inventory performance
    Given path 'store', 'inventory'
    And header api_key = apiKey
    When method GET
    Then status 200
    And assert responseTime < 3000
    
    # User logout performance
    Given path 'user', 'logout'
    When method GET
    Then status 200
    And assert responseTime < 2000

  @regression @idempotency
  Scenario: TC-REG-008 - Idempotency verification for PUT and DELETE
    * def petId = generatePetId()
    
    # Create pet
    Given path 'pet'
    And request { id: #(petId), name: 'IdempotentPet', photoUrls: ['https://example.com/idem.jpg'], status: 'available' }
    When method POST
    Then status 200
    
    # PUT idempotency - same request twice should yield same result
    Given path 'pet'
    And request { id: #(petId), name: 'UpdatedIdempotent', photoUrls: ['https://example.com/idem.jpg'], status: 'sold' }
    When method PUT
    Then status 200
    * def firstPutResponse = response
    
    Given path 'pet'
    And request { id: #(petId), name: 'UpdatedIdempotent', photoUrls: ['https://example.com/idem.jpg'], status: 'sold' }
    When method PUT
    Then status 200
    And match response.name == firstPutResponse.name
    And match response.status == firstPutResponse.status
    
    # DELETE idempotency - first succeeds, second returns 404
    Given path 'pet', petId
    And header api_key = apiKey
    When method DELETE
    Then status 200
    
    Given path 'pet', petId
    And header api_key = apiKey
    When method DELETE
    Then status 404

  @regression @concurrent
  Scenario: TC-REG-009 - Sequential request handling
    # Multiple rapid requests to same endpoint
    Given path 'store', 'inventory'
    And header api_key = apiKey
    When method GET
    Then status 200
    
    Given path 'store', 'inventory'
    And header api_key = apiKey
    When method GET
    Then status 200
    
    Given path 'store', 'inventory'
    And header api_key = apiKey
    When method GET
    Then status 200
    
    # All pet status requests
    Given path 'pet', 'findByStatus'
    And param status = 'available'
    When method GET
    Then status 200
    
    Given path 'pet', 'findByStatus'
    And param status = 'pending'
    When method GET
    Then status 200
    
    Given path 'pet', 'findByStatus'
    And param status = 'sold'
    When method GET
    Then status 200

  @regression @enum-values
  Scenario: TC-REG-010 - Enum value validation
    * def petId = generatePetId()
    
    # Valid pet status values
    Given path 'pet'
    And request { id: #(petId), name: 'EnumPet1', photoUrls: ['https://example.com/enum.jpg'], status: 'available' }
    When method POST
    Then status 200
    And match response.status == 'available'
    
    Given path 'pet'
    And request { id: #(petId), name: 'EnumPet1', photoUrls: ['https://example.com/enum.jpg'], status: 'pending' }
    When method PUT
    Then status 200
    And match response.status == 'pending'
    
    Given path 'pet'
    And request { id: #(petId), name: 'EnumPet1', photoUrls: ['https://example.com/enum.jpg'], status: 'sold' }
    When method PUT
    Then status 200
    And match response.status == 'sold'
    
    # Valid order status values
    Given path 'store', 'order'
    And request { petId: #(petId), quantity: 1, status: 'placed', complete: false }
    When method POST
    Then status 200
    And match response.status == 'placed'
    
    # Cleanup
    Given path 'pet', petId
    And header api_key = apiKey
    When method DELETE
    Then status 200
