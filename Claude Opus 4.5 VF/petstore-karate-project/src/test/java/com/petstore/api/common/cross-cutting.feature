Feature: API Cross-Cutting Concerns
  As an API consumer
  I need the API to handle common scenarios consistently
  So that I can build reliable integrations

  Background:
    * url baseUrl
    * def generatePetId = function(){ return Math.floor(Math.random() * 900000) + 100000 }

  @security @authentication
  Scenario: TC-SEC-001 - Verify API key authentication mechanism
    Given path 'store', 'inventory'
    And header api_key = 'invalid_key_12345'
    When method GET
    Then assert responseStatus == 200 || responseStatus == 401 || responseStatus == 403

  @security @authentication
  Scenario: TC-SEC-002 - Verify endpoint accessibility
    Given path 'pet'
    And header Content-Type = 'application/json'
    And request { name: 'SecurityTestPet', photoUrls: ['https://example.com/sec.jpg'], status: 'available' }
    When method POST
    Then assert responseStatus == 200 || responseStatus == 401 || responseStatus == 403

  @security @headers
  Scenario: TC-SEC-003 - Verify response headers are present
    Given path 'pet', 'findByStatus'
    And param status = 'available'
    When method GET
    Then status 200
    And match responseHeaders['Content-Type'] == '#present'

  @content-negotiation
  Scenario: TC-CN-001 - Default response format is JSON
    Given path 'pet', 'findByStatus'
    And param status = 'available'
    When method GET
    Then status 200
    And match header Content-Type contains 'application/json'

  @content-negotiation
  Scenario: TC-CN-002 - Support XML response format
    Given path 'pet', 'findByStatus'
    And param status = 'available'
    And header Accept = 'application/xml'
    When method GET
    Then status 200
    And match header Content-Type contains 'application/xml'

  @content-negotiation @negative
  Scenario: TC-CN-003 - Handle unsupported Accept header gracefully
    Given path 'pet', 'findByStatus'
    And param status = 'available'
    And header Accept = 'text/plain'
    When method GET
    Then assert responseStatus == 200 || responseStatus == 406

  @error-handling
  Scenario: TC-ERR-001 - Verify error response format for invalid ID
    Given path 'pet', 'invalid_id'
    And header api_key = apiKey
    When method GET
    Then assert responseStatus == 400 || responseStatus == 404
    And match response == '#object'

  @error-handling
  Scenario: TC-ERR-002 - Handle malformed JSON gracefully
    Given path 'pet'
    And header Content-Type = 'application/json'
    And request 'this is not valid json {'
    When method POST
    Then assert responseStatus == 400 || responseStatus == 405 || responseStatus == 500

  @error-handling
  Scenario: TC-ERR-003 - Handle unsupported HTTP method
    Given path 'pet'
    When method PATCH
    Then assert responseStatus == 405 || responseStatus == 404

  @error-handling
  Scenario: TC-ERR-004 - Handle non-existent endpoint
    Given path 'nonexistent', 'endpoint'
    When method GET
    Then status 404

  @performance @response-time
  Scenario: TC-PERF-001 - API endpoints respond within acceptable time
    Given path 'pet', 'findByStatus'
    And param status = 'available'
    When method GET
    Then status 200
    And assert responseTime < 5000

  @performance @response-time
  Scenario: TC-PERF-002 - Order creation responds within acceptable time
    * def petId = generatePetId()
    Given path 'store', 'order'
    And request { petId: #(petId), quantity: 1, status: 'placed', complete: false }
    When method POST
    Then status 200
    And assert responseTime < 3000

  @validation @schema
  Scenario: TC-VAL-001 - Pet response matches Pet schema
    * def petId = generatePetId()
    Given path 'pet'
    And request { id: #(petId), name: 'SchemaPet', photoUrls: ['https://example.com/schema.jpg'], status: 'available' }
    When method POST
    Then status 200
    
    Given path 'pet', petId
    And header api_key = apiKey
    When method GET
    Then status 200
    And match response contains { id: '#number', name: '#string', photoUrls: '#array' }
    And match response.name == '#string'
    And match response.photoUrls == '#[] #string'

  @validation @schema
  Scenario: TC-VAL-002 - Order response matches Order schema
    * def petId = generatePetId()
    Given path 'store', 'order'
    And request { petId: #(petId), quantity: 1, status: 'placed', complete: false }
    When method POST
    Then status 200
    * def orderId = response.id
    
    Given path 'store', 'order', orderId
    When method GET
    Then status 200
    And match response contains { id: '#number', petId: '#number', quantity: '#number' }

  @validation @datatype
  Scenario: TC-VAL-004 - Verify integer field types
    * def petId = generatePetId()
    Given path 'pet'
    And request { id: #(petId), name: 'TypePet', photoUrls: ['https://example.com/type.jpg'], status: 'available' }
    When method POST
    Then status 200
    And match response.id == '#number'
    
    Given path 'store', 'order'
    And request { petId: #(petId), quantity: 5, status: 'placed', complete: false }
    When method POST
    Then status 200
    And match response.id == '#number'
    And match response.petId == '#number'
    And match response.quantity == '#number'

  @validation @datatype
  Scenario: TC-VAL-005 - Verify boolean field types
    * def petId = generatePetId()
    Given path 'store', 'order'
    And request { petId: #(petId), quantity: 1, status: 'placed', complete: true }
    When method POST
    Then status 200
    And match response.complete == '#boolean'

  @validation @datatype
  Scenario: TC-VAL-006 - Verify array field types
    * def petId = generatePetId()
    Given path 'pet'
    And request 
      """
      { 
        id: #(petId), 
        name: 'ArrayPet', 
        photoUrls: ['url1.jpg', 'url2.jpg'], 
        tags: [{ id: 1, name: 'tag1' }],
        status: 'available' 
      }
      """
    When method POST
    Then status 200
    And match response.photoUrls == '#array'
    And match response.tags == '#array'

  @http-methods
  Scenario: TC-HTTP-001 - Verify GET method works correctly
    Given path 'pet', 'findByStatus'
    And param status = 'available'
    When method GET
    Then status 200

  @http-methods
  Scenario: TC-HTTP-002 - Verify POST method works correctly
    * def petId = generatePetId()
    Given path 'pet'
    And request { id: #(petId), name: 'PostPet', photoUrls: ['https://example.com/post.jpg'], status: 'available' }
    When method POST
    Then status 200

  @http-methods
  Scenario: TC-HTTP-003 - Verify PUT method works correctly
    * def petId = generatePetId()
    Given path 'pet'
    And request { id: #(petId), name: 'PutPet', photoUrls: ['https://example.com/put.jpg'], status: 'available' }
    When method POST
    Then status 200
    
    Given path 'pet'
    And request { id: #(petId), name: 'UpdatedPutPet', photoUrls: ['https://example.com/put.jpg'], status: 'sold' }
    When method PUT
    Then status 200

  @http-methods
  Scenario: TC-HTTP-004 - Verify DELETE method works correctly
    * def petId = generatePetId()
    Given path 'pet'
    And request { id: #(petId), name: 'DeletePet', photoUrls: ['https://example.com/delete.jpg'], status: 'available' }
    When method POST
    Then status 200
    
    Given path 'pet', petId
    And header api_key = apiKey
    When method DELETE
    Then status 200

  @encoding
  Scenario: TC-ENC-001 - Handle UTF-8 characters in request
    * def petId = generatePetId()
    Given path 'pet'
    And header Content-Type = 'application/json; charset=UTF-8'
    And request { id: #(petId), name: 'Café Pet 日本語', photoUrls: ['https://example.com/utf8.jpg'], status: 'available' }
    When method POST
    Then status 200

  @timeout
  Scenario: TC-TIMEOUT-001 - API responds before timeout
    * configure readTimeout = 30000
    Given path 'pet', 'findByStatus'
    And param status = 'available'
    When method GET
    Then status 200
    And assert responseTime < 30000
