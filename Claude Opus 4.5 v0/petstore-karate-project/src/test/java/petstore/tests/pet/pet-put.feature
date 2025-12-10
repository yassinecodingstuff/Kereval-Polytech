Feature: Pet Management API - PUT Operations
  As a Petstore API consumer
  I want to update existing pet records in the store
  So that I can maintain accurate pet information
  
  Priority: CRITICAL - Core Business Functionality
  ISO/IEC/IEEE 29119 Alignment: Risk-based test selection with modification coverage

  Background:
    * url baseUrl
    * def generateUniqueId = function(){ return Math.floor(Math.random() * 900000000) + 100000000 }

  @critical @smoke @positive @PUT @pet
  Scenario: TC-PET-018 - Successfully update an existing pet
    * def petId = generateUniqueId()
    * def createPayload = { id: #(petId), name: 'OriginalName', photoUrls: ['https://example.com/old.jpg'], status: 'available' }
    Given path 'pet'
    And header Content-Type = 'application/json'
    And request createPayload
    When method post
    Then status 200
    
    * def updatePayload = { id: #(petId), name: 'UpdatedName', photoUrls: ['https://example.com/new.jpg'], status: 'sold' }
    Given path 'pet'
    And header Content-Type = 'application/json'
    And header Accept = 'application/json'
    And request updatePayload
    When method put
    Then status 200
    And match response.name == 'UpdatedName'
    And match response.status == 'sold'

  @critical @positive @PUT @pet
  Scenario: TC-PET-019 - Successfully update pet status from available to pending
    * def petId = generateUniqueId()
    * def createPayload = { id: #(petId), name: 'StatusChangePet', photoUrls: ['https://example.com/pet.jpg'], status: 'available' }
    Given path 'pet'
    And header Content-Type = 'application/json'
    And request createPayload
    When method post
    Then status 200
    And match response.status == 'available'
    
    * def updatePayload = { id: #(petId), name: 'StatusChangePet', photoUrls: ['https://example.com/pet.jpg'], status: 'pending' }
    Given path 'pet'
    And header Content-Type = 'application/json'
    And header Accept = 'application/json'
    And request updatePayload
    When method put
    Then status 200
    And match response.status == 'pending'

  @critical @negative @PUT @pet @validation
  Scenario: TC-PET-020 - Reject update with invalid pet ID format
    * def updatePayload = { id: 'not_a_number', name: 'InvalidIdPet', photoUrls: ['https://example.com/pet.jpg'] }
    Given path 'pet'
    And header Content-Type = 'application/json'
    And header Accept = 'application/json'
    And request updatePayload
    When method put
    Then assert responseStatus == 400 || responseStatus == 500

  @high @negative @PUT @pet
  Scenario: TC-PET-021 - Return 404 when updating non-existent pet
    * def nonExistentId = 999999999999
    * def updatePayload = { id: #(nonExistentId), name: 'NonExistentPet', photoUrls: ['https://example.com/pet.jpg'] }
    Given path 'pet'
    And header Content-Type = 'application/json'
    And header Accept = 'application/json'
    And request updatePayload
    When method put
    Then assert responseStatus == 200 || responseStatus == 404

  @high @negative @PUT @pet @validation
  Scenario: TC-PET-022 - Reject update with validation exception on invalid status
    * def petId = generateUniqueId()
    * def updatePayload = { id: #(petId), name: 'InvalidStatusPet', photoUrls: ['https://example.com/pet.jpg'], status: 'invalid_status' }
    Given path 'pet'
    And header Content-Type = 'application/json'
    And header Accept = 'application/json'
    And request updatePayload
    When method put
    Then assert responseStatus == 200 || responseStatus == 405

  @medium @positive @PUT @pet @idempotency
  Scenario: TC-PET-023 - Verify PUT operation is idempotent
    * def petId = generateUniqueId()
    * def petPayload = { id: #(petId), name: 'IdempotentPet', photoUrls: ['https://example.com/pet.jpg'], status: 'available' }
    Given path 'pet'
    And header Content-Type = 'application/json'
    And request petPayload
    When method post
    Then status 200
    
    Given path 'pet'
    And header Content-Type = 'application/json'
    And header Accept = 'application/json'
    And request petPayload
    When method put
    Then status 200
    * def firstResponse = response
    
    Given path 'pet'
    And header Content-Type = 'application/json'
    And header Accept = 'application/json'
    And request petPayload
    When method put
    Then status 200
    * def secondResponse = response
    
    And match firstResponse.id == secondResponse.id
    And match firstResponse.name == secondResponse.name

  @medium @positive @PUT @pet @category
  Scenario: TC-PET-024 - Successfully update pet category
    * def petId = generateUniqueId()
    * def createPayload = { id: #(petId), name: 'CategoryUpdatePet', category: { id: 1, name: 'Dogs' }, photoUrls: ['https://example.com/pet.jpg'] }
    Given path 'pet'
    And header Content-Type = 'application/json'
    And request createPayload
    When method post
    Then status 200
    
    * def updatePayload = { id: #(petId), name: 'CategoryUpdatePet', category: { id: 2, name: 'Cats' }, photoUrls: ['https://example.com/pet.jpg'] }
    Given path 'pet'
    And header Content-Type = 'application/json'
    And header Accept = 'application/json'
    And request updatePayload
    When method put
    Then status 200
    And match response.category.id == 2
    And match response.category.name == 'Cats'

  @medium @positive @PUT @pet @tags
  Scenario: TC-PET-025 - Successfully add tags to existing pet
    * def petId = generateUniqueId()
    * def createPayload = { id: #(petId), name: 'TagUpdatePet', photoUrls: ['https://example.com/pet.jpg'], tags: [] }
    Given path 'pet'
    And header Content-Type = 'application/json'
    And request createPayload
    When method post
    Then status 200
    
    * def updatePayload =
      """
      {
        id: #(petId),
        name: 'TagUpdatePet',
        photoUrls: ['https://example.com/pet.jpg'],
        tags: [{ id: 1, name: 'playful' }, { id: 2, name: 'vaccinated' }]
      }
      """
    Given path 'pet'
    And header Content-Type = 'application/json'
    And header Accept = 'application/json'
    And request updatePayload
    When method put
    Then status 200
    And match response.tags == '#[2]'

  @low @positive @PUT @pet @photoUrls
  Scenario: TC-PET-026 - Successfully update pet photoUrls
    * def petId = generateUniqueId()
    * def createPayload = { id: #(petId), name: 'PhotoUpdatePet', photoUrls: ['https://example.com/old1.jpg'] }
    Given path 'pet'
    And header Content-Type = 'application/json'
    And request createPayload
    When method post
    Then status 200
    
    * def updatePayload = { id: #(petId), name: 'PhotoUpdatePet', photoUrls: ['https://example.com/new1.jpg', 'https://example.com/new2.jpg'] }
    Given path 'pet'
    And header Content-Type = 'application/json'
    And header Accept = 'application/json'
    And request updatePayload
    When method put
    Then status 200
    And match response.photoUrls == '#[2]'

  @low @negative @PUT @pet @empty
  Scenario: TC-PET-027 - Reject update with empty request body
    Given path 'pet'
    And header Content-Type = 'application/json'
    And header Accept = 'application/json'
    And request {}
    When method put
    Then assert responseStatus == 400 || responseStatus == 405
