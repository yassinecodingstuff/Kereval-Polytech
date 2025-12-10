Feature: API Contract and Schema Validation
  As a Petstore API consumer
  I want to verify response schemas match the OpenAPI specification
  So that I can rely on consistent API behavior
  
  Priority: HIGH - Contract Testing
  ISO/IEC/IEEE 29119 Alignment: Schema validation and contract verification

  Background:
    * url baseUrl
    * def generateUniqueId = function(){ return Math.floor(Math.random() * 900000000) + 100000000 }

  @high @contract @schema @pet
  Scenario: TC-SCHEMA-001 - Verify Pet response matches schema definition
    * def petId = generateUniqueId()
    * def petPayload =
      """
      {
        id: #(petId),
        name: 'SchemaTestPet',
        category: { id: 1, name: 'Dogs' },
        photoUrls: ['https://example.com/pet.jpg'],
        tags: [{ id: 1, name: 'friendly' }],
        status: 'available'
      }
      """
    Given path 'pet'
    And header Content-Type = 'application/json'
    And request petPayload
    When method post
    Then status 200
    
    Given path 'pet', petId
    And header api_key = apiKey
    When method get
    Then status 200
    And match response.id == '#number'
    And match response.name == '#string'
    And match response.photoUrls == '#[] #string'
    And match response.status == '#? _ == "available" || _ == "pending" || _ == "sold"'

  @high @contract @schema @pet
  Scenario: TC-SCHEMA-002 - Verify Category nested object schema
    * def petId = generateUniqueId()
    * def petPayload = { id: #(petId), name: 'CategorySchemaPet', category: { id: 100, name: 'Exotic' }, photoUrls: ['https://example.com/pet.jpg'] }
    Given path 'pet'
    And header Content-Type = 'application/json'
    And request petPayload
    When method post
    Then status 200
    
    Given path 'pet', petId
    And header api_key = apiKey
    When method get
    Then status 200
    And match response.category == { id: '#number', name: '#string' }
    And match response.category.id == 100
    And match response.category.name == 'Exotic'

  @high @contract @schema @pet
  Scenario: TC-SCHEMA-003 - Verify Tag nested object schema in array
    * def petId = generateUniqueId()
    * def petPayload =
      """
      {
        id: #(petId),
        name: 'TagSchemaPet',
        photoUrls: ['https://example.com/pet.jpg'],
        tags: [{ id: 1, name: 'cute' }, { id: 2, name: 'friendly' }]
      }
      """
    Given path 'pet'
    And header Content-Type = 'application/json'
    And request petPayload
    When method post
    Then status 200
    
    Given path 'pet', petId
    And header api_key = apiKey
    When method get
    Then status 200
    And match response.tags == '#array'
    And match each response.tags == { id: '#number', name: '#string' }

  @high @contract @schema @pet
  Scenario: TC-SCHEMA-004 - Verify required fields in Pet creation response
    * def petId = generateUniqueId()
    * def petPayload = { id: #(petId), name: 'RequiredFieldsPet', photoUrls: ['https://example.com/1.jpg', 'https://example.com/2.jpg'] }
    Given path 'pet'
    And header Content-Type = 'application/json'
    And request petPayload
    When method post
    Then status 200
    And match response contains { name: '#string', photoUrls: '#array' }
    And match response.name == 'RequiredFieldsPet'
    And match response.photoUrls == '#[2]'

  @high @contract @schema @pet @findByStatus
  Scenario: TC-SCHEMA-005 - Verify findByStatus returns array of pets with correct schema
    Given path 'pet', 'findByStatus'
    And param status = 'available'
    And header Accept = 'application/json'
    When method get
    Then status 200
    And match response == '#array'
    And match each response contains { id: '#number', name: '#string', photoUrls: '#array' }

  @high @contract @schema @order
  Scenario: TC-SCHEMA-006 - Verify Order response matches schema definition
    * def orderId = generateUniqueId()
    * def orderPayload = { id: #(orderId), petId: 1, quantity: 1, status: 'placed', complete: false }
    Given path 'store', 'order'
    And header Content-Type = 'application/json'
    And request orderPayload
    When method post
    Then status 200
    And match response.id == '#number'
    And match response.petId == '#number'
    And match response.quantity == '#number'
    And match response.status == '#? _ == "placed" || _ == "approved" || _ == "delivered"'
    And match response.complete == '#boolean'

  @high @contract @schema @order
  Scenario: TC-SCHEMA-007 - Verify Order retrieval by ID returns correct schema
    Given path 'store', 'order', 1
    And header Accept = 'application/json'
    When method get
    Then status 200
    And match response == { id: '#number', petId: '#number', quantity: '#number', shipDate: '##string', status: '#string', complete: '#boolean' }

  @high @contract @schema @user
  Scenario: TC-SCHEMA-008 - Verify User response matches schema definition
    * def username = 'schema_user_' + generateUniqueId()
    * def userId = generateUniqueId()
    * def userPayload =
      """
      {
        id: #(userId),
        username: '#(username)',
        firstName: 'Schema',
        lastName: 'Test',
        email: '#(username + "@test.com")',
        password: 'Password123',
        phone: '1234567890',
        userStatus: 1
      }
      """
    Given path 'user'
    And header Content-Type = 'application/json'
    And request userPayload
    When method post
    Then status 200
    
    Given path 'user', username
    And header Accept = 'application/json'
    When method get
    Then status 200
    And match response.id == '#number'
    And match response.username == '#string'
    And match response.firstName == '#string'
    And match response.lastName == '#string'
    And match response.email == '#string'
    And match response.phone == '#string'

  @medium @contract @schema @inventory
  Scenario: TC-SCHEMA-009 - Verify Inventory response schema
    Given path 'store', 'inventory'
    And header api_key = apiKey
    When method get
    Then status 200
    And match response == '#object'

  @medium @contract @schema @error
  Scenario: TC-SCHEMA-010 - Verify 404 error response format
    Given path 'pet', 999999999999
    And header api_key = apiKey
    When method get
    Then status 404
    And match response == '#object'

  @medium @contract @datatype
  Scenario: TC-SCHEMA-011 - Verify Pet ID is int64 format
    * def petId = 9007199254740991
    * def petPayload = { id: #(petId), name: 'Int64Pet', photoUrls: ['https://example.com/pet.jpg'] }
    Given path 'pet'
    And header Content-Type = 'application/json'
    And request petPayload
    When method post
    Then status 200
    And match response.id == '#number'

  @medium @contract @enum
  Scenario: TC-SCHEMA-012 - Verify Pet status enum values
    * def petId = generateUniqueId()
    Given path 'pet'
    And header Content-Type = 'application/json'
    And request { id: #(petId), name: 'EnumPet', photoUrls: ['https://example.com/pet.jpg'], status: 'available' }
    When method post
    Then status 200
    And match response.status == '#? _ == "available" || _ == "pending" || _ == "sold"'

  @medium @contract @enum
  Scenario: TC-SCHEMA-013 - Verify Order status enum values
    * def orderId = generateUniqueId()
    Given path 'store', 'order'
    And header Content-Type = 'application/json'
    And request { id: #(orderId), petId: 1, quantity: 1, status: 'placed', complete: false }
    When method post
    Then status 200
    And match response.status == '#? _ == "placed" || _ == "approved" || _ == "delivered"'

  @low @contract @datatype
  Scenario: TC-SCHEMA-014 - Verify boolean fields accept true/false
    * def orderId = generateUniqueId()
    * def orderPayloadTrue = { id: #(orderId), petId: 1, quantity: 1, status: 'delivered', complete: true }
    Given path 'store', 'order'
    And header Content-Type = 'application/json'
    And request orderPayloadTrue
    When method post
    Then status 200
    And match response.complete == true
    
    * def orderId2 = generateUniqueId()
    * def orderPayloadFalse = { id: #(orderId2), petId: 1, quantity: 1, status: 'placed', complete: false }
    Given path 'store', 'order'
    And header Content-Type = 'application/json'
    And request orderPayloadFalse
    When method post
    Then status 200
    And match response.complete == false
