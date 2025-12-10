Feature: Pet Management API - DELETE and Form Update Operations
  As a Petstore API consumer
  I want to delete pets and update them with form data
  So that I can manage the pet lifecycle
  
  Priority: HIGH - Core Business Functionality
  ISO/IEC/IEEE 29119 Alignment: Risk-based test selection with deletion coverage

  Background:
    * url baseUrl
    * def generateUniqueId = function(){ return Math.floor(Math.random() * 900000000) + 100000000 }

  @high @positive @POST @pet @form
  Scenario: TC-PET-045 - Successfully update pet name using form data
    * def petId = generateUniqueId()
    * def petPayload = { id: #(petId), name: 'OldName', photoUrls: ['https://example.com/pet.jpg'], status: 'available' }
    Given path 'pet'
    And header Content-Type = 'application/json'
    And request petPayload
    When method post
    Then status 200
    
    Given path 'pet', petId
    And header Content-Type = 'application/x-www-form-urlencoded'
    And form field name = 'NewFormName'
    When method post
    Then status 200
    
    Given path 'pet', petId
    And header api_key = apiKey
    When method get
    Then status 200
    And match response.name == 'NewFormName'

  @high @positive @POST @pet @form
  Scenario: TC-PET-046 - Successfully update pet status using form data
    * def petId = generateUniqueId()
    * def petPayload = { id: #(petId), name: 'StatusFormPet', photoUrls: ['https://example.com/pet.jpg'], status: 'available' }
    Given path 'pet'
    And header Content-Type = 'application/json'
    And request petPayload
    When method post
    Then status 200
    
    Given path 'pet', petId
    And header Content-Type = 'application/x-www-form-urlencoded'
    And form field status = 'sold'
    When method post
    Then status 200
    
    Given path 'pet', petId
    And header api_key = apiKey
    When method get
    Then status 200
    And match response.status == 'sold'

  @high @positive @POST @pet @form
  Scenario: TC-PET-047 - Successfully update both name and status using form data
    * def petId = generateUniqueId()
    * def petPayload = { id: #(petId), name: 'DualFormPet', photoUrls: ['https://example.com/pet.jpg'], status: 'available' }
    Given path 'pet'
    And header Content-Type = 'application/json'
    And request petPayload
    When method post
    Then status 200
    
    Given path 'pet', petId
    And header Content-Type = 'application/x-www-form-urlencoded'
    And form field name = 'FormUpdatedPet'
    And form field status = 'pending'
    When method post
    Then status 200
    
    Given path 'pet', petId
    And header api_key = apiKey
    When method get
    Then status 200
    And match response.name == 'FormUpdatedPet'
    And match response.status == 'pending'

  @high @negative @POST @pet @form @validation
  Scenario: TC-PET-048 - Reject form update with invalid pet ID
    Given path 'pet', 'invalid_id'
    And header Content-Type = 'application/x-www-form-urlencoded'
    And form field name = 'InvalidTest'
    When method post
    Then assert responseStatus == 405 || responseStatus == 400 || responseStatus == 404

  @high @smoke @positive @DELETE @pet
  Scenario: TC-PET-049 - Successfully delete an existing pet
    * def petId = generateUniqueId()
    * def petPayload = { id: #(petId), name: 'DeleteablePet', photoUrls: ['https://example.com/pet.jpg'] }
    Given path 'pet'
    And header Content-Type = 'application/json'
    And request petPayload
    When method post
    Then status 200
    
    Given path 'pet', petId
    And header api_key = apiKey
    When method delete
    Then status 200
    
    Given path 'pet', petId
    And header api_key = apiKey
    When method get
    Then status 404

  @high @positive @DELETE @pet @security
  Scenario: TC-PET-050 - Successfully delete pet with api_key header
    * def petId = generateUniqueId()
    * def petPayload = { id: #(petId), name: 'ApiKeyDeletePet', photoUrls: ['https://example.com/pet.jpg'] }
    Given path 'pet'
    And header Content-Type = 'application/json'
    And request petPayload
    When method post
    Then status 200
    
    Given path 'pet', petId
    And header api_key = 'special-key'
    When method delete
    Then status 200

  @high @negative @DELETE @pet
  Scenario: TC-PET-051 - Return 404 when deleting non-existent pet
    * def nonExistentId = 999999999999
    Given path 'pet', nonExistentId
    And header api_key = apiKey
    When method delete
    Then status 404

  @high @negative @DELETE @pet @validation
  Scenario: TC-PET-052 - Return 400 for invalid pet ID format on delete
    Given path 'pet', 'invalid_format'
    And header api_key = apiKey
    When method delete
    Then assert responseStatus == 400 || responseStatus == 404

  @medium @negative @DELETE @pet @idempotency
  Scenario: TC-PET-053 - Verify delete is not idempotent (second call returns 404)
    * def petId = generateUniqueId()
    * def petPayload = { id: #(petId), name: 'IdempotencyDeletePet', photoUrls: ['https://example.com/pet.jpg'] }
    Given path 'pet'
    And header Content-Type = 'application/json'
    And request petPayload
    When method post
    Then status 200
    
    Given path 'pet', petId
    And header api_key = apiKey
    When method delete
    Then status 200
    
    Given path 'pet', petId
    And header api_key = apiKey
    When method delete
    Then status 404

  @medium @positive @POST @pet @upload
  Scenario: TC-PET-054 - Successfully upload image for existing pet (mock test)
    * def petId = generateUniqueId()
    * def petPayload = { id: #(petId), name: 'ImageUploadPet', photoUrls: ['https://example.com/pet.jpg'] }
    Given path 'pet'
    And header Content-Type = 'application/json'
    And request petPayload
    When method post
    Then status 200
    
    Given path 'pet', petId, 'uploadImage'
    And header Content-Type = 'multipart/form-data'
    And multipart field additionalMetadata = 'Test image upload'
    And multipart file file = { read: 'classpath:test-data/test-image.txt', filename: 'test.jpg', contentType: 'image/jpeg' }
    When method post
    Then status 200
    And match response.code == '#number'

  @low @negative @DELETE @pet @boundary
  Scenario: TC-PET-055 - Handle deletion with negative pet ID
    Given path 'pet', -12345
    And header api_key = apiKey
    When method delete
    Then assert responseStatus == 400 || responseStatus == 404

  @low @negative @DELETE @pet @boundary
  Scenario: TC-PET-056 - Handle deletion with zero pet ID
    Given path 'pet', 0
    And header api_key = apiKey
    When method delete
    Then assert responseStatus == 400 || responseStatus == 404
