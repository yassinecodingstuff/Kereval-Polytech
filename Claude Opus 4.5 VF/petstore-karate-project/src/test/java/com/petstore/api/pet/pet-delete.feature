Feature: Pet API - Delete Operations
  As a pet store operator
  I need to remove pets from the store inventory
  So that I can manage inventory accurately

  Background:
    * url baseUrl
    * def generatePetId = function(){ return Math.floor(Math.random() * 900000) + 100000 }

  @critical @pet @delete
  Scenario: TC-PET-039 - Successfully delete an existing pet
    * def petId = generatePetId()
    Given path 'pet'
    And request { id: #(petId), name: 'DeletePet', photoUrls: ['https://example.com/delete.jpg'], status: 'available' }
    When method POST
    Then status 200
    
    Given path 'pet', petId
    And header api_key = apiKey
    When method DELETE
    Then status 200
    
    # Verify deletion
    Given path 'pet', petId
    And header api_key = apiKey
    When method GET
    Then status 404

  @negative @pet @delete @validation
  Scenario: TC-PET-040 - Return 404 when deleting non-existent pet
    Given path 'pet', 999999999999
    And header api_key = apiKey
    When method DELETE
    Then status 404

  @negative @pet @delete @validation
  Scenario: TC-PET-041 - Handle invalid pet ID on delete
    Given path 'pet', 'invalid_id'
    And header api_key = apiKey
    When method DELETE
    Then assert responseStatus == 400 || responseStatus == 404

  @pet @delete @security
  Scenario: TC-PET-042 - Delete pet with API key header
    * def petId = generatePetId()
    Given path 'pet'
    And request { id: #(petId), name: 'ApiKeyDeletePet', photoUrls: ['https://example.com/apidelete.jpg'], status: 'available' }
    When method POST
    Then status 200
    
    Given path 'pet', petId
    And header api_key = 'special-key'
    When method DELETE
    Then status 200

  @pet @delete @idempotency
  Scenario: TC-PET-043 - Verify DELETE idempotency behavior
    * def petId = generatePetId()
    Given path 'pet'
    And request { id: #(petId), name: 'IdempotentDeletePet', photoUrls: ['https://example.com/idem.jpg'], status: 'available' }
    When method POST
    Then status 200
    
    # First delete
    Given path 'pet', petId
    And header api_key = apiKey
    When method DELETE
    Then status 200
    
    # Second delete (should be 404)
    Given path 'pet', petId
    And header api_key = apiKey
    When method DELETE
    Then status 404

  @pet @delete @boundary
  Scenario: TC-PET-DELETE-001 - Handle delete with negative ID
    Given path 'pet', -1
    And header api_key = apiKey
    When method DELETE
    Then assert responseStatus == 400 || responseStatus == 404

  @pet @delete @boundary
  Scenario: TC-PET-DELETE-002 - Handle delete with zero ID
    Given path 'pet', 0
    And header api_key = apiKey
    When method DELETE
    Then assert responseStatus == 400 || responseStatus == 404

  @pet @delete @cascade
  Scenario: TC-PET-DELETE-003 - Verify pet removal from search results after delete
    * def petId = generatePetId()
    Given path 'pet'
    And request { id: #(petId), name: 'SearchDeletePet', photoUrls: ['https://example.com/searchdel.jpg'], status: 'available' }
    When method POST
    Then status 200
    
    # Verify pet appears in search
    Given path 'pet', 'findByStatus'
    And param status = 'available'
    When method GET
    Then status 200
    * def foundBefore = karate.filter(response, function(x){ return x.id == petId })
    And match foundBefore == '#[1]'
    
    # Delete the pet
    Given path 'pet', petId
    And header api_key = apiKey
    When method DELETE
    Then status 200
    
    # Verify pet no longer appears in search
    Given path 'pet', 'findByStatus'
    And param status = 'available'
    When method GET
    Then status 200
    * def foundAfter = karate.filter(response, function(x){ return x.id == petId })
    And match foundAfter == '#[0]'
