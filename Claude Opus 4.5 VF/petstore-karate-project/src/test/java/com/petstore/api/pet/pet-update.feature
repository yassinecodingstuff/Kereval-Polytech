Feature: Pet API - Update Operations
  As a pet store operator
  I need to update pet information
  So that I can maintain accurate inventory records

  Background:
    * url baseUrl
    * def generatePetId = function(){ return Math.floor(Math.random() * 900000) + 100000 }

  @critical @pet @update
  Scenario: TC-PET-012 - Successfully update an existing pet
    * def petId = generatePetId()
    # First create a pet
    Given path 'pet'
    And header Content-Type = 'application/json'
    And request
      """
      {
        "id": #(petId),
        "name": "OriginalName",
        "photoUrls": ["https://example.com/original.jpg"],
        "status": "available"
      }
      """
    When method POST
    Then status 200
    
    # Then update it
    Given path 'pet'
    And header Content-Type = 'application/json'
    And request
      """
      {
        "id": #(petId),
        "name": "UpdatedName",
        "photoUrls": ["https://example.com/updated.jpg"],
        "status": "sold"
      }
      """
    When method PUT
    Then status 200
    And match response.name == 'UpdatedName'
    And match response.status == 'sold'
    
    # Verify update
    Given path 'pet', petId
    And header api_key = apiKey
    When method GET
    Then status 200
    And match response.name == 'UpdatedName'
    And match response.status == 'sold'

  @negative @pet @update @validation
  Scenario: TC-PET-013 - Handle update for non-existent pet ID
    Given path 'pet'
    And header Content-Type = 'application/json'
    And request
      """
      {
        "id": 999999999999,
        "name": "NonExistent",
        "photoUrls": ["https://example.com/none.jpg"],
        "status": "available"
      }
      """
    When method PUT
    Then assert responseStatus == 404 || responseStatus == 200

  @negative @pet @update @validation
  Scenario: TC-PET-014 - Reject update with invalid pet ID format
    Given path 'pet'
    And header Content-Type = 'application/json'
    And request
      """
      {
        "id": "invalid_id_string",
        "name": "InvalidId",
        "photoUrls": ["https://example.com/invalid.jpg"]
      }
      """
    When method PUT
    Then assert responseStatus == 400 || responseStatus == 500

  @pet @update @idempotency
  Scenario: TC-PET-016 - Verify PUT request idempotency
    * def petId = generatePetId()
    # Create pet
    Given path 'pet'
    And request { id: #(petId), name: 'OriginalName', photoUrls: ['https://example.com/orig.jpg'], status: 'available' }
    When method POST
    Then status 200
    
    # First PUT
    Given path 'pet'
    And request { id: #(petId), name: 'NewName', photoUrls: ['https://example.com/new.jpg'], status: 'pending' }
    When method PUT
    Then status 200
    * def firstResponse = response
    
    # Second PUT (same request)
    Given path 'pet'
    And request { id: #(petId), name: 'NewName', photoUrls: ['https://example.com/new.jpg'], status: 'pending' }
    When method PUT
    Then status 200
    And match response.name == firstResponse.name
    And match response.status == firstResponse.status

  @pet @update @form
  Scenario: TC-PET-035 - Update pet name using form data
    * def petId = generatePetId()
    Given path 'pet'
    And request { id: #(petId), name: 'FormPet', photoUrls: ['https://example.com/form.jpg'], status: 'available' }
    When method POST
    Then status 200
    
    Given path 'pet', petId
    And header Content-Type = 'application/x-www-form-urlencoded'
    And form field name = 'FormUpdatedName'
    When method POST
    Then status 200

  @pet @update @form
  Scenario: TC-PET-036 - Update pet status using form data
    * def petId = generatePetId()
    Given path 'pet'
    And request { id: #(petId), name: 'StatusFormPet', photoUrls: ['https://example.com/status.jpg'], status: 'available' }
    When method POST
    Then status 200
    
    Given path 'pet', petId
    And header Content-Type = 'application/x-www-form-urlencoded'
    And form field status = 'sold'
    When method POST
    Then status 200

  @pet @update @form
  Scenario: TC-PET-037 - Update both name and status using form data
    * def petId = generatePetId()
    Given path 'pet'
    And request { id: #(petId), name: 'BothFieldsPet', photoUrls: ['https://example.com/both.jpg'], status: 'available' }
    When method POST
    Then status 200
    
    Given path 'pet', petId
    And header Content-Type = 'application/x-www-form-urlencoded'
    And form field name = 'NewPetName'
    And form field status = 'pending'
    When method POST
    Then status 200

  @pet @update @category
  Scenario: TC-PET-UPDATE-001 - Update pet category
    * def petId = generatePetId()
    Given path 'pet'
    And request { id: #(petId), name: 'CategoryPet', photoUrls: ['https://example.com/cat.jpg'], status: 'available', category: { id: 1, name: 'Dogs' } }
    When method POST
    Then status 200
    
    Given path 'pet'
    And request { id: #(petId), name: 'CategoryPet', photoUrls: ['https://example.com/cat.jpg'], status: 'available', category: { id: 2, name: 'Cats' } }
    When method PUT
    Then status 200
    And match response.category.name == 'Cats'

  @pet @update @tags
  Scenario: TC-PET-UPDATE-002 - Update pet tags
    * def petId = generatePetId()
    Given path 'pet'
    And request { id: #(petId), name: 'TagPet', photoUrls: ['https://example.com/tag.jpg'], status: 'available', tags: [{ id: 1, name: 'original' }] }
    When method POST
    Then status 200
    
    Given path 'pet'
    And request { id: #(petId), name: 'TagPet', photoUrls: ['https://example.com/tag.jpg'], status: 'available', tags: [{ id: 2, name: 'updated' }, { id: 3, name: 'new' }] }
    When method PUT
    Then status 200
    And match response.tags == '#[2]'

  @pet @update @photos
  Scenario: TC-PET-UPDATE-003 - Update pet photo URLs
    * def petId = generatePetId()
    Given path 'pet'
    And request { id: #(petId), name: 'PhotoPet', photoUrls: ['https://example.com/original.jpg'], status: 'available' }
    When method POST
    Then status 200
    
    Given path 'pet'
    And request { id: #(petId), name: 'PhotoPet', photoUrls: ['https://example.com/new1.jpg', 'https://example.com/new2.jpg'], status: 'available' }
    When method PUT
    Then status 200
    And match response.photoUrls == '#[2]'
