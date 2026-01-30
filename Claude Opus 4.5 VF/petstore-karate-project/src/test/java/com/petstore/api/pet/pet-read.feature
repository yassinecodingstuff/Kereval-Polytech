Feature: Pet API - Read Operations
  As a pet store customer
  I need to retrieve pet information
  So that I can view available pets and their details

  Background:
    * url baseUrl
    * def generatePetId = function(){ return Math.floor(Math.random() * 900000) + 100000 }

  @critical @smoke @pet @read
  Scenario: TC-PET-017 - Successfully retrieve pet by valid ID
    * def petId = generatePetId()
    # Create pet first
    Given path 'pet'
    And request { id: #(petId), name: 'RetrievePet', photoUrls: ['https://example.com/retrieve.jpg'], status: 'available' }
    When method POST
    Then status 200
    
    # Retrieve it
    Given path 'pet', petId
    And header api_key = apiKey
    When method GET
    Then status 200
    And match response contains { id: '#number', name: '#string', photoUrls: '#array' }
    And match response.name == 'RetrievePet'
    And match response.id == petId

  @negative @pet @read @validation
  Scenario: TC-PET-018 - Return 404 for non-existent pet ID
    Given path 'pet', 999999999999
    And header api_key = apiKey
    When method GET
    Then status 404

  @negative @pet @read @validation
  Scenario: TC-PET-019 - Return 400 for invalid pet ID format
    Given path 'pet', 'invalid_id'
    And header api_key = apiKey
    When method GET
    Then assert responseStatus == 400 || responseStatus == 404

  @negative @pet @read @boundary
  Scenario: TC-PET-020 - Handle negative pet ID
    Given path 'pet', -1
    And header api_key = apiKey
    When method GET
    Then assert responseStatus == 400 || responseStatus == 404

  @pet @read @security
  Scenario: TC-PET-021 - Retrieve pet with API key authentication
    * def petId = generatePetId()
    Given path 'pet'
    And request { id: #(petId), name: 'ApiKeyPet', photoUrls: ['https://example.com/apikey.jpg'], status: 'available' }
    When method POST
    Then status 200
    
    Given path 'pet', petId
    And header api_key = 'special-key'
    When method GET
    Then status 200
    And match response.name == 'ApiKeyPet'

  @pet @read @content-negotiation
  Scenario: TC-PET-022 - Retrieve pet in XML format
    * def petId = generatePetId()
    Given path 'pet'
    And request { id: #(petId), name: 'XMLFormatPet', photoUrls: ['https://example.com/xml.jpg'], status: 'available' }
    When method POST
    Then status 200
    
    Given path 'pet', petId
    And header Accept = 'application/xml'
    And header api_key = apiKey
    When method GET
    Then status 200
    And match header Content-Type contains 'application/xml'

  @pet @read @boundary
  Scenario: TC-PET-023 - Handle maximum int64 pet ID
    Given path 'pet', 9223372036854775807
    And header api_key = apiKey
    When method GET
    Then assert responseStatus == 404 || responseStatus == 400

  @critical @pet @search
  Scenario: TC-PET-024 - Find all available pets
    Given path 'pet', 'findByStatus'
    And param status = 'available'
    When method GET
    Then status 200
    And match response == '#array'
    And match each response contains { status: 'available' }

  @pet @search
  Scenario: TC-PET-025 - Find all pending pets
    Given path 'pet', 'findByStatus'
    And param status = 'pending'
    When method GET
    Then status 200
    And match response == '#array'

  @pet @search
  Scenario: TC-PET-026 - Find all sold pets
    Given path 'pet', 'findByStatus'
    And param status = 'sold'
    When method GET
    Then status 200
    And match response == '#array'

  @pet @search
  Scenario: TC-PET-027 - Find pets with multiple status values
    Given path 'pet', 'findByStatus'
    And param status = 'available'
    And param status = 'pending'
    When method GET
    Then status 200
    And match response == '#array'

  @pet @search
  Scenario: TC-PET-028 - Find pets with all status values
    Given path 'pet', 'findByStatus'
    And param status = 'available'
    And param status = 'pending'
    And param status = 'sold'
    When method GET
    Then status 200
    And match response == '#array'

  @negative @pet @search @validation
  Scenario: TC-PET-029 - Handle invalid status value
    Given path 'pet', 'findByStatus'
    And param status = 'invalid_status'
    When method GET
    Then assert responseStatus == 200 || responseStatus == 400

  @pet @search @performance
  Scenario: TC-PET-031 - Verify response time for findByStatus
    Given path 'pet', 'findByStatus'
    And param status = 'available'
    When method GET
    Then status 200
    And assert responseTime < 3000

  @pet @search @deprecated
  Scenario: TC-PET-032 - Find pets by single tag
    Given path 'pet', 'findByTags'
    And param tags = 'friendly'
    When method GET
    Then status 200
    And match response == '#array'

  @pet @search @deprecated
  Scenario: TC-PET-033 - Find pets by multiple tags
    Given path 'pet', 'findByTags'
    And param tags = 'friendly'
    And param tags = 'vaccinated'
    When method GET
    Then status 200

  @negative @pet @search @deprecated @validation
  Scenario: TC-PET-034 - Reject findByTags without tags parameter
    Given path 'pet', 'findByTags'
    When method GET
    Then status 400

  @pet @read @schema
  Scenario: TC-PET-SCHEMA-001 - Verify pet response schema
    * def petId = generatePetId()
    Given path 'pet'
    And request { id: #(petId), name: 'SchemaPet', photoUrls: ['https://example.com/schema.jpg'], status: 'available', category: { id: 1, name: 'Dogs' }, tags: [{ id: 1, name: 'test' }] }
    When method POST
    Then status 200
    
    Given path 'pet', petId
    And header api_key = apiKey
    When method GET
    Then status 200
    And match response ==
      """
      {
        id: '#number',
        name: '#string',
        photoUrls: '#array',
        status: '#string',
        category: '##object',
        tags: '##array'
      }
      """
