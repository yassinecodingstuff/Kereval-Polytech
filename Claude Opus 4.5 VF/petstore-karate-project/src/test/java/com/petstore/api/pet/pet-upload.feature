Feature: Pet API - Image Upload Operations
  As a pet store operator
  I need to upload pet images
  So that customers can see pet photos

  Background:
    * url baseUrl
    * def generatePetId = function(){ return Math.floor(Math.random() * 900000) + 100000 }

  @pet @upload
  Scenario: TC-PET-044 - Successfully upload image for existing pet
    * def petId = generatePetId()
    Given path 'pet'
    And request { id: #(petId), name: 'UploadPet', photoUrls: ['https://example.com/upload.jpg'], status: 'available' }
    When method POST
    Then status 200
    
    Given path 'pet', petId, 'uploadImage'
    And header Content-Type = 'multipart/form-data'
    And multipart field additionalMetadata = 'Test image upload'
    When method POST
    Then status 200
    And match response contains { code: '#number', message: '#string' }

  @pet @upload
  Scenario: TC-PET-045 - Upload image with additional metadata
    * def petId = generatePetId()
    Given path 'pet'
    And request { id: #(petId), name: 'MetadataPet', photoUrls: ['https://example.com/meta.jpg'], status: 'available' }
    When method POST
    Then status 200
    
    Given path 'pet', petId, 'uploadImage'
    And header Content-Type = 'multipart/form-data'
    And multipart field additionalMetadata = 'Profile picture of Buddy - High resolution photo'
    When method POST
    Then status 200
    And match response.message contains 'additionalMetadata'

  @pet @upload @metadata
  Scenario: TC-PET-UPLOAD-001 - Upload with special characters in metadata
    * def petId = generatePetId()
    Given path 'pet'
    And request { id: #(petId), name: 'SpecialCharPet', photoUrls: ['https://example.com/special.jpg'], status: 'available' }
    When method POST
    Then status 200
    
    Given path 'pet', petId, 'uploadImage'
    And header Content-Type = 'multipart/form-data'
    And multipart field additionalMetadata = 'Photo with special chars: @#$%^&*()!'
    When method POST
    Then status 200

  @pet @upload @metadata
  Scenario: TC-PET-UPLOAD-002 - Upload with unicode metadata
    * def petId = generatePetId()
    Given path 'pet'
    And request { id: #(petId), name: 'UnicodePet', photoUrls: ['https://example.com/unicode.jpg'], status: 'available' }
    When method POST
    Then status 200
    
    Given path 'pet', petId, 'uploadImage'
    And header Content-Type = 'multipart/form-data'
    And multipart field additionalMetadata = 'Photo with unicode: 日本語 中文 한국어'
    When method POST
    Then status 200

  @negative @pet @upload
  Scenario: TC-PET-UPLOAD-003 - Handle upload for non-existent pet
    Given path 'pet', 999999999999, 'uploadImage'
    And header Content-Type = 'multipart/form-data'
    And multipart field additionalMetadata = 'Test'
    When method POST
    Then assert responseStatus == 200 || responseStatus == 404

  @pet @upload @boundary
  Scenario: TC-PET-UPLOAD-004 - Upload with empty metadata
    * def petId = generatePetId()
    Given path 'pet'
    And request { id: #(petId), name: 'EmptyMetaPet', photoUrls: ['https://example.com/empty.jpg'], status: 'available' }
    When method POST
    Then status 200
    
    Given path 'pet', petId, 'uploadImage'
    And header Content-Type = 'multipart/form-data'
    And multipart field additionalMetadata = ''
    When method POST
    Then status 200

  @pet @upload @boundary
  Scenario: TC-PET-UPLOAD-005 - Upload with long metadata
    * def petId = generatePetId()
    * def longMetadata = ''
    * eval for(var i = 0; i < 500; i++) longMetadata += 'A'
    Given path 'pet'
    And request { id: #(petId), name: 'LongMetaPet', photoUrls: ['https://example.com/long.jpg'], status: 'available' }
    When method POST
    Then status 200
    
    Given path 'pet', petId, 'uploadImage'
    And header Content-Type = 'multipart/form-data'
    And multipart field additionalMetadata = longMetadata
    When method POST
    Then status 200
