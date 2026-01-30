Feature: API Security, Contract and Content Negotiation
  As an API consumer and security administrator
  I want to ensure proper security, schema compliance and content negotiation
  So that the API is protected and reliable

  Background:
    * url baseUrl
    * configure headers = { Accept: 'application/json' }
    * def generatePetId = function(){ return Math.floor(Math.random() * 900) + 1001 }
    * def generateUsername = function(){ return 'testuser_' + java.util.UUID.randomUUID().toString().substring(0, 8) }
    * def allowedPetStatuses = ['available', 'pending', 'sold']
    * def allowedOrderStatuses = ['placed', 'approved', 'delivered']

  # ==========================================================================
  # TC-SEC-001: API Key Authentication
  # Risk Level: Critical
  # ==========================================================================

  @critical @security @authentication
  Scenario: TC-SEC-001-01 - Successfully access protected endpoint with valid API key
    * def petId = generatePetId()
    * def petPayload =
      """
      {
        "id": #(petId),
        "name": "SecureAccessPet",
        "photoUrls": ["https://example.com/pet.jpg"],
        "status": "available"
      }
      """
    Given path 'pet'
    And request petPayload
    When method post
    Then status 200

    Given path 'pet', petId
    And header api_key = 'special-key'
    When method get
    Then status 200

  @critical @security @authentication
  Scenario: TC-SEC-001-02 - Access protected endpoint without API key
    * def petId = generatePetId()
    * def petPayload =
      """
      {
        "id": #(petId),
        "name": "NoKeyPet",
        "photoUrls": ["https://example.com/pet.jpg"],
        "status": "available"
      }
      """
    Given path 'pet'
    And request petPayload
    When method post
    Then status 200

    Given path 'pet', petId
    When method get
    Then match [200, 401, 403] contains responseStatus

  @high @security @authentication @negative
  Scenario: TC-SEC-001-03 - Handle invalid API key
    * def petId = generatePetId()
    * def petPayload =
      """
      {
        "id": #(petId),
        "name": "InvalidKeyPet",
        "photoUrls": ["https://example.com/pet.jpg"],
        "status": "available"
      }
      """
    Given path 'pet'
    And request petPayload
    When method post
    Then status 200

    Given path 'pet', petId
    And header api_key = 'invalid-key-12345'
    When method get
    Then match [200, 401, 403] contains responseStatus

  # ==========================================================================
  # TC-SEC-002: Authorization Scopes
  # Risk Level: Critical
  # ==========================================================================

  @critical @security @authorization
  Scenario: TC-SEC-002-01 - Write operations with authentication
    * def petPayload =
      """
      {
        "name": "AuthTestPet",
        "photoUrls": ["https://example.com/auth.jpg"],
        "status": "available"
      }
      """
    Given path 'pet'
    And request petPayload
    When method post
    Then match [200, 401, 403] contains responseStatus

  @critical @security @authorization
  Scenario: TC-SEC-002-02 - Read operations on findByStatus
    Given path 'pet', 'findByStatus'
    And param status = 'available'
    When method get
    Then status 200
    And match response == '#array'

  @high @security @authorization
  Scenario: TC-SEC-002-03 - Store inventory requires api_key
    Given path 'store', 'inventory'
    And header api_key = 'special-key'
    When method get
    Then status 200

  # ==========================================================================
  # TC-SEC-003: Input Validation and Injection Prevention
  # Risk Level: High
  # ==========================================================================

  @high @security @injection
  Scenario: TC-SEC-003-01 - Handle SQL injection attempt in pet name
    * def petId = generatePetId()
    * def petPayload =
      """
      {
        "id": #(petId),
        "name": "'; DROP TABLE pets; --",
        "photoUrls": ["https://example.com/pet.jpg"],
        "status": "available"
      }
      """
    Given path 'pet'
    And request petPayload
    When method post
    Then match [200, 400, 500] contains responseStatus
    * def t = karate.typeOf(response)
    * if (t == 'map' && response.error) karate.log('Error response received')

  @high @security @injection
  Scenario: TC-SEC-003-02 - Handle XSS attempt in pet name
    * def petId = generatePetId()
    * def petPayload =
      """
      {
        "id": #(petId),
        "name": "<script>alert('xss')</script>",
        "photoUrls": ["https://example.com/pet.jpg"],
        "status": "available"
      }
      """
    Given path 'pet'
    And request petPayload
    When method post
    Then match [200, 400] contains responseStatus

  @high @security @injection
  Scenario: TC-SEC-003-03 - Handle path traversal attempt
    Given path 'pet', '..', '..', '..', 'etc', 'passwd'
    When method get
    Then match [400, 404] contains responseStatus

  @high @security @injection
  Scenario: TC-SEC-003-04 - Handle JSON injection in user data
    * def username = generateUsername()
    * def userPayload =
      """
      {
        "username": "#(username)",
        "firstName": "{\"malicious\":\"data\"}",
        "lastName": "Test"
      }
      """
    Given path 'user'
    And request userPayload
    When method post
    Then match [200, 400] contains responseStatus

  @medium @security @injection
  Scenario: TC-SEC-003-05 - Handle null byte injection
    Given path 'pet', '1%00admin'
    When method get
    Then match [400, 404] contains responseStatus

  # ==========================================================================
  # TC-CONTENT-001: JSON and XML Response Formats
  # Risk Level: Medium
  # ==========================================================================

  @medium @content-type @json
  Scenario: TC-CONTENT-001-01 - Receive JSON response when Accept header is application/json
    * def petId = generatePetId()
    * def petPayload =
      """
      {
        "id": #(petId),
        "name": "JSONPet",
        "photoUrls": ["https://example.com/json.jpg"],
        "status": "available"
      }
      """
    Given path 'pet'
    And request petPayload
    When method post
    Then status 200

    Given path 'pet', petId
    And header Accept = 'application/json'
    When method get
    Then status 200
    And match responseHeaders['Content-Type'][0] contains 'application/json'
    And match response == '#object'

  @medium @content-type @xml
  Scenario: TC-CONTENT-001-02 - Receive XML response when Accept header is application/xml
    * def petId = generatePetId()
    * def petPayload =
      """
      {
        "id": #(petId),
        "name": "XMLPet",
        "photoUrls": ["https://example.com/xml.jpg"],
        "status": "available"
      }
      """
    Given path 'pet'
    And request petPayload
    When method post
    Then status 200

    Given path 'pet', petId
    And header Accept = 'application/xml'
    When method get
    Then status 200
    And match responseHeaders['Content-Type'][0] contains 'application/xml'

  @medium @content-type
  Scenario: TC-CONTENT-001-03 - Default to JSON when no Accept header is provided
    * def petId = generatePetId()
    * def petPayload =
      """
      {
        "id": #(petId),
        "name": "DefaultPet",
        "photoUrls": ["https://example.com/default.jpg"],
        "status": "available"
      }
      """
    Given path 'pet'
    And request petPayload
    When method post
    Then status 200

    Given path 'pet', petId
    * configure headers = {}
    When method get
    Then status 200
    And match responseHeaders['Content-Type'][0] contains 'json'

  # ==========================================================================
  # TC-CONTENT-002: Request Body Content Types
  # Risk Level: Medium
  # ==========================================================================

  @medium @content-type @request
  Scenario: TC-CONTENT-002-01 - Accept JSON request body for pet creation
    * def petId = generatePetId()
    * def petPayload =
      """
      {
        "id": #(petId),
        "name": "JSONRequestPet",
        "photoUrls": ["https://example.com/jsonreq.jpg"],
        "status": "available"
      }
      """
    Given path 'pet'
    And header Content-Type = 'application/json'
    And request petPayload
    When method post
    Then status 200

  @medium @content-type @request
  Scenario: TC-CONTENT-002-02 - Accept form data for pet update
    * def petId = generatePetId()
    * def petPayload =
      """
      {
        "id": #(petId),
        "name": "FormDataPet",
        "photoUrls": ["https://example.com/form.jpg"],
        "status": "available"
      }
      """
    Given path 'pet'
    And request petPayload
    When method post
    Then status 200

    Given path 'pet', petId
    And header Content-Type = 'application/x-www-form-urlencoded'
    And form field name = 'UpdatedFormPet'
    When method post
    Then match [200, 405] contains responseStatus

  # ==========================================================================
  # TC-ERROR-001: HTTP Method Errors
  # Risk Level: High
  # ==========================================================================

  @high @error-handling @method
  Scenario: TC-ERROR-001-01 - Handle unsupported HTTP method PATCH on /pet
    * def petPayload = { "name": "PatchPet" }
    Given path 'pet'
    And request petPayload
    When method patch
    Then match [405, 400, 404] contains responseStatus

  @high @error-handling @method
  Scenario: TC-ERROR-001-02 - Handle unsupported HTTP method PUT on /store/order
    * def orderPayload = { "id": 1, "petId": 1 }
    Given path 'store', 'order'
    And request orderPayload
    When method put
    Then match [405, 400, 404] contains responseStatus

  @high @error-handling @method
  Scenario: TC-ERROR-001-03 - Handle DELETE on /pet without ID
    Given path 'pet'
    When method delete
    Then match [405, 400, 404] contains responseStatus

  # ==========================================================================
  # TC-ERROR-002: Boundary Value Testing
  # Risk Level: High
  # ==========================================================================

  @high @boundary @pet
  Scenario: TC-ERROR-002-01 - Handle maximum safe integer for pet ID
    * def maxSafeId = '9007199254740991'
    Given path 'pet', maxSafeId
    When method get
    Then match [200, 404] contains responseStatus

  @high @boundary @pet
  Scenario: TC-ERROR-002-02 - Handle large integer string for pet ID
    * def bigId = '9223372036854710002'
    Given path 'pet', bigId
    When method get
    Then match [200, 400, 404] contains responseStatus

  @high @boundary @order
  Scenario: TC-ERROR-002-03 - Handle minimum boundary for order ID (1)
    * def petId = generatePetId()
    * def orderPayload =
      """
      {
        "id": 1,
        "petId": #(petId),
        "quantity": 1
      }
      """
    Given path 'store', 'order'
    And request orderPayload
    When method post
    Then status 200

    Given path 'store', 'order', '1'
    When method get
    Then match [200, 404] contains responseStatus

  @high @boundary @order
  Scenario: TC-ERROR-002-04 - Handle maximum boundary for order ID (10)
    * def petId = generatePetId()
    * def orderPayload =
      """
      {
        "id": 10,
        "petId": #(petId),
        "quantity": 1
      }
      """
    Given path 'store', 'order'
    And request orderPayload
    When method post
    Then status 200

    Given path 'store', 'order', '10'
    When method get
    Then match [200, 404] contains responseStatus

  # ==========================================================================
  # TC-ERROR-003: Special Characters and Encoding
  # Risk Level: Medium
  # ==========================================================================

  @medium @encoding @special-chars
  Scenario: TC-ERROR-003-01 - Handle URL-encoded characters in username
    Given path 'user', 'test%20user'
    When method get
    Then match [200, 404] contains responseStatus

  @medium @encoding @special-chars
  Scenario: TC-ERROR-003-02 - Handle Unicode characters in pet name
    * def petId = generatePetId()
    * def petPayload =
      """
      {
        "id": #(petId),
        "name": "Flüffy Kïtty 猫",
        "photoUrls": ["https://example.com/unicode.jpg"],
        "status": "available"
      }
      """
    Given path 'pet'
    And request petPayload
    When method post
    Then status 200
    And match response.name == 'Flüffy Kïtty 猫'

  @medium @encoding @special-chars
  Scenario: TC-ERROR-003-03 - Handle special characters in status query parameter
    Given path 'pet', 'findByStatus'
    And param status = 'available&sold'
    When method get
    Then match [200, 400] contains responseStatus

  # ==========================================================================
  # TC-ERROR-004: Large Payload Handling
  # Risk Level: Medium
  # ==========================================================================

  @medium @boundary @payload
  Scenario: TC-ERROR-004-01 - Handle pet with very long name
    * def petId = generatePetId()
    * def generateLongString =
      """
      function(length) {
        var result = '';
        for (var i = 0; i < length; i++) {
          result += 'a';
        }
        return result;
      }
      """
    * def longName = generateLongString(5000)
    * def petPayload =
      """
      {
        "id": #(petId),
        "name": "#(longName)",
        "photoUrls": ["https://example.com/long.jpg"],
        "status": "available"
      }
      """
    Given path 'pet'
    And request petPayload
    When method post
    Then match [200, 400, 413, 500] contains responseStatus

  @medium @boundary @payload
  Scenario: TC-ERROR-004-02 - Handle pet with many photoUrls
    * def petId = generatePetId()
    * def generateUrls =
      """
      function(count) {
        var urls = [];
        for (var i = 0; i < count; i++) {
          urls.push('https://example.com/photo' + i + '.jpg');
        }
        return urls;
      }
      """
    * def manyUrls = generateUrls(100)
    * def petPayload =
      """
      {
        "id": #(petId),
        "name": "ManyPhotosPet",
        "photoUrls": #(manyUrls),
        "status": "available"
      }
      """
    Given path 'pet'
    And request petPayload
    When method post
    Then match [200, 400, 413] contains responseStatus

  @medium @boundary @payload
  Scenario: TC-ERROR-004-03 - Handle pet with many tags
    * def petId = generatePetId()
    * def generateTags =
      """
      function(count) {
        var tags = [];
        for (var i = 0; i < count; i++) {
          tags.push({ id: i, name: 'tag' + i });
        }
        return tags;
      }
      """
    * def manyTags = generateTags(50)
    * def petPayload =
      """
      {
        "id": #(petId),
        "name": "ManyTagsPet",
        "photoUrls": ["https://example.com/tags.jpg"],
        "status": "available",
        "tags": #(manyTags)
      }
      """
    Given path 'pet'
    And request petPayload
    When method post
    Then match [200, 400, 413] contains responseStatus

  # ==========================================================================
  # TC-PERF-001: Response Time Requirements
  # Risk Level: High
  # ==========================================================================

  @high @performance @response-time
  Scenario: TC-PERF-001-01 - GET pet by ID responds within acceptable time
    * def petId = generatePetId()
    * def petPayload =
      """
      {
        "id": #(petId),
        "name": "PerfTestPet",
        "photoUrls": ["https://example.com/perf.jpg"],
        "status": "available"
      }
      """
    Given path 'pet'
    And request petPayload
    When method post
    Then status 200

    Given path 'pet', petId
    When method get
    Then status 200
    And assert responseTime < 5000

  @high @performance @response-time
  Scenario: TC-PERF-001-02 - GET inventory responds within acceptable time
    Given path 'store', 'inventory'
    And header api_key = 'special-key'
    When method get
    Then status 200
    And assert responseTime < 5000

  @high @performance @response-time
  Scenario: TC-PERF-001-03 - POST pet creation responds within acceptable time
    * def petId = generatePetId()
    * def petPayload =
      """
      {
        "id": #(petId),
        "name": "PerfCreatePet",
        "photoUrls": ["https://example.com/perfcreate.jpg"],
        "status": "available"
      }
      """
    Given path 'pet'
    And request petPayload
    When method post
    Then status 200
    And assert responseTime < 5000

  @high @performance @response-time
  Scenario: TC-PERF-001-04 - GET findByStatus responds within acceptable time
    Given path 'pet', 'findByStatus'
    And param status = 'available'
    When method get
    Then status 200
    And assert responseTime < 5000

  # ==========================================================================
  # TC-TRANSPORT-001: HTTPS Enforcement
  # Risk Level: High
  # ==========================================================================

  @high @security @https
  Scenario: TC-TRANSPORT-001-01 - API responds over HTTPS
    * url 'https://petstore.swagger.io/v2'
    Given path 'pet', 'findByStatus'
    And param status = 'available'
    When method get
    Then status 200

  @high @security @https
  Scenario: TC-TRANSPORT-001-02 - Verify base URL uses HTTPS
    * def isHttps = baseUrl.startsWith('https')
    * if (!isHttps) karate.log('Warning: Base URL does not use HTTPS')
    * assert isHttps || baseUrl.contains('localhost') || baseUrl.contains('127.0.0.1')

  # ==========================================================================
  # TC-SCHEMA-001: Swagger Contract Validation
  # Risk Level: High
  # ==========================================================================

  @high @contract @swagger
  Scenario: TC-SCHEMA-001-01 - Validate pet endpoint returns correct schema
    * def petId = generatePetId()
    * def petPayload =
      """
      {
        "id": #(petId),
        "name": "ContractPet",
        "photoUrls": ["https://example.com/contract.jpg"],
        "status": "available",
        "category": { "id": 1, "name": "Dogs" },
        "tags": [{ "id": 1, "name": "friendly" }]
      }
      """
    Given path 'pet'
    And request petPayload
    When method post
    Then status 200

    Given path 'pet', petId
    When method get
    Then status 200
    And match response ==
      """
      {
        id: '#number',
        name: '#string',
        photoUrls: '#[] #string',
        status: '##string',
        category: '##object',
        tags: '##[] #object'
      }
      """

  @high @contract @swagger
  Scenario: TC-SCHEMA-001-02 - Validate order endpoint returns correct schema
    * def orderId = Math.floor(Math.random() * 9) + 1
    * def petId = generatePetId()
    * def orderPayload =
      """
      {
        "id": #(orderId),
        "petId": #(petId),
        "quantity": 1,
        "shipDate": "2025-01-15T10:00:00.000Z",
        "status": "placed",
        "complete": false
      }
      """
    Given path 'store', 'order'
    And request orderPayload
    When method post
    Then status 200

    Given path 'store', 'order', orderId
    When method get
    Then status 200
    And match response ==
      """
      {
        id: '#number',
        petId: '#number',
        quantity: '#number',
        shipDate: '#string',
        status: '#string',
        complete: '#boolean'
      }
      """

  @high @contract @swagger
  Scenario: TC-SCHEMA-001-03 - Validate user endpoint returns correct schema
    * def username = generateUsername()
    * def userPayload =
      """
      {
        "id": 12345,
        "username": "#(username)",
        "firstName": "Contract",
        "lastName": "Test",
        "email": "contract@test.com",
        "password": "pass123",
        "phone": "555-1234",
        "userStatus": 1
      }
      """
    Given path 'user'
    And request userPayload
    When method post
    Then status 200

    Given path 'user', username
    When method get
    Then status 200
    And match response ==
      """
      {
        id: '#number',
        username: '#string',
        firstName: '##string',
        lastName: '##string',
        email: '##string',
        password: '##string',
        phone: '##string',
        userStatus: '##number'
      }
      """

  @high @contract @swagger
  Scenario: TC-SCHEMA-001-04 - Validate inventory endpoint returns map of integers
    Given path 'store', 'inventory'
    And header api_key = 'special-key'
    When method get
    Then status 200
    And match response == '#object'
    * def validateInventory =
      """
      function(obj) {
        for (var key in obj) {
          if (typeof obj[key] !== 'number') return false;
        }
        return true;
      }
      """
    * assert validateInventory(response)

  @high @contract @swagger
  Scenario: TC-SCHEMA-001-05 - Validate findByStatus returns array of pets
    Given path 'pet', 'findByStatus'
    And param status = 'available'
    When method get
    Then status 200
    And match response == '#[] #object'
    And match each response contains { id: '#number', name: '#string', photoUrls: '#array' }

  @medium @contract @swagger
  Scenario: TC-SCHEMA-001-06 - Validate pet status enum constraint
    * def petId = generatePetId()
    * def petPayload =
      """
      {
        "id": #(petId),
        "name": "EnumTestPet",
        "photoUrls": ["https://example.com/enum.jpg"],
        "status": "available"
      }
      """
    Given path 'pet'
    And request petPayload
    When method post
    Then status 200

    Given path 'pet', petId
    When method get
    Then status 200
    And match allowedPetStatuses contains response.status

  @medium @contract @swagger
  Scenario: TC-SCHEMA-001-07 - Validate order status enum constraint
    * def orderId = Math.floor(Math.random() * 9) + 1
    * def petId = generatePetId()
    * def orderPayload =
      """
      {
        "id": #(orderId),
        "petId": #(petId),
        "quantity": 1,
        "status": "approved"
      }
      """
    Given path 'store', 'order'
    And request orderPayload
    When method post
    Then status 200

    Given path 'store', 'order', orderId
    When method get
    Then status 200
    And match allowedOrderStatuses contains response.status
