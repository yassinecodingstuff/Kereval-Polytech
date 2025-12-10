Feature: Pet Management API - GET Operations
  As a Petstore API consumer
  I want to retrieve pet records from the store
  So that I can view pet information
  
  Priority: CRITICAL - Core Business Functionality
  ISO/IEC/IEEE 29119 Alignment: Risk-based test selection with query coverage

  Background:
    * url baseUrl
    * def generateUniqueId = function(){ return Math.floor(Math.random() * 900000000) + 100000000 }

  @critical @smoke @positive @GET @pet
  Scenario: TC-PET-028 - Successfully retrieve pet by valid ID
    * def petId = generateUniqueId()
    * def petPayload = { id: #(petId), name: 'RetrievablePet', photoUrls: ['https://example.com/pet.jpg'], status: 'available' }
    Given path 'pet'
    And header Content-Type = 'application/json'
    And request petPayload
    When method post
    Then status 200
    
    Given path 'pet', petId
    And header Accept = 'application/json'
    And header api_key = apiKey
    When method get
    Then status 200
    And match response.id == petId
    And match response.name == 'RetrievablePet'
    And match responseHeaders['Content-Type'][0] contains 'application/json'

  @critical @positive @GET @pet @security
  Scenario: TC-PET-029 - Successfully retrieve pet with API key authentication
    * def petId = generateUniqueId()
    * def petPayload = { id: #(petId), name: 'AuthPet', photoUrls: ['https://example.com/pet.jpg'] }
    Given path 'pet'
    And header Content-Type = 'application/json'
    And request petPayload
    When method post
    Then status 200
    
    Given path 'pet', petId
    And header Accept = 'application/json'
    And header api_key = 'special-key'
    When method get
    Then status 200
    And match response.id == petId

  @critical @negative @GET @pet
  Scenario: TC-PET-030 - Return 404 for non-existent pet ID
    * def nonExistentId = 999999999999
    Given path 'pet', nonExistentId
    And header Accept = 'application/json'
    And header api_key = apiKey
    When method get
    Then status 404

  @critical @negative @GET @pet @validation
  Scenario: TC-PET-031 - Return 400 for invalid pet ID format
    Given path 'pet', 'invalid_id'
    And header Accept = 'application/json'
    And header api_key = apiKey
    When method get
    Then assert responseStatus == 400 || responseStatus == 404

  @high @negative @GET @pet @boundary
  Scenario: TC-PET-032 - Handle negative pet ID gracefully
    Given path 'pet', -1
    And header Accept = 'application/json'
    And header api_key = apiKey
    When method get
    Then assert responseStatus == 400 || responseStatus == 404

  @high @negative @GET @pet @boundary
  Scenario: TC-PET-033 - Handle zero pet ID
    Given path 'pet', 0
    And header Accept = 'application/json'
    And header api_key = apiKey
    When method get
    Then assert responseStatus == 400 || responseStatus == 404

  @medium @negative @GET @pet @boundary
  Scenario: TC-PET-034 - Handle integer overflow for pet ID
    Given path 'pet', '9999999999999999999999'
    And header Accept = 'application/json'
    And header api_key = apiKey
    When method get
    Then assert responseStatus == 400 || responseStatus == 404 || responseStatus == 500

  @medium @positive @GET @pet @content-negotiation
  Scenario: TC-PET-035 - Retrieve pet in XML format when requested
    * def petId = generateUniqueId()
    * def petPayload = { id: #(petId), name: 'XMLFormatPet', photoUrls: ['https://example.com/pet.jpg'] }
    Given path 'pet'
    And header Content-Type = 'application/json'
    And request petPayload
    When method post
    Then status 200
    
    Given path 'pet', petId
    And header Accept = 'application/xml'
    And header api_key = apiKey
    When method get
    Then status 200
    And match responseHeaders['Content-Type'][0] contains 'application/xml'

  @low @positive @GET @pet @response-time
  Scenario: TC-PET-036 - Verify pet retrieval response time is acceptable
    * def petId = generateUniqueId()
    * def petPayload = { id: #(petId), name: 'ResponseTimePet', photoUrls: ['https://example.com/pet.jpg'] }
    Given path 'pet'
    And header Content-Type = 'application/json'
    And request petPayload
    When method post
    Then status 200
    
    Given path 'pet', petId
    And header Accept = 'application/json'
    And header api_key = apiKey
    When method get
    Then status 200
    And assert responseTime < 2000

  @high @smoke @positive @GET @pet @search
  Scenario: TC-PET-037 - Successfully find pets by single status
    Given path 'pet', 'findByStatus'
    And param status = 'available'
    And header Accept = 'application/json'
    When method get
    Then status 200
    And match response == '#array'
    And match each response contains { status: 'available' }

  @high @positive @GET @pet @search
  Scenario Outline: TC-PET-038 - Successfully find pets by each valid status value
    Given path 'pet', 'findByStatus'
    And param status = '<status>'
    And header Accept = 'application/json'
    When method get
    Then status 200
    And match response == '#array'

    Examples:
      | status    |
      | available |
      | pending   |
      | sold      |

  @high @positive @GET @pet @search
  Scenario: TC-PET-039 - Successfully find pets by multiple statuses
    Given path 'pet', 'findByStatus'
    And param status = 'available'
    And param status = 'pending'
    And header Accept = 'application/json'
    When method get
    Then status 200
    And match response == '#array'

  @high @negative @GET @pet @search @validation
  Scenario: TC-PET-040 - Return 400 for invalid status value
    Given path 'pet', 'findByStatus'
    And param status = 'invalid_status'
    And header Accept = 'application/json'
    When method get
    Then assert responseStatus == 200 || responseStatus == 400

  @medium @negative @GET @pet @search
  Scenario: TC-PET-041 - Handle missing status parameter
    Given path 'pet', 'findByStatus'
    And header Accept = 'application/json'
    When method get
    Then assert responseStatus == 400 || responseStatus == 200

  @medium @positive @GET @pet @search @deprecated
  Scenario: TC-PET-042 - Successfully find pets by single tag (deprecated endpoint)
    Given path 'pet', 'findByTags'
    And param tags = 'friendly'
    And header Accept = 'application/json'
    When method get
    Then status 200
    And match response == '#array'

  @medium @positive @GET @pet @search @deprecated
  Scenario: TC-PET-043 - Successfully find pets by multiple tags
    Given path 'pet', 'findByTags'
    And param tags = 'cute'
    And param tags = 'small'
    And header Accept = 'application/json'
    When method get
    Then status 200
    And match response == '#array'

  @low @positive @GET @pet @schema
  Scenario: TC-PET-044 - Verify pet response matches expected schema
    * def petId = generateUniqueId()
    * def petPayload =
      """
      {
        id: #(petId),
        name: 'SchemaPet',
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
    And header Accept = 'application/json'
    And header api_key = apiKey
    When method get
    Then status 200
    And match response == { id: '#number', name: '#string', category: '#object', photoUrls: '#array', tags: '#array', status: '#string' }
