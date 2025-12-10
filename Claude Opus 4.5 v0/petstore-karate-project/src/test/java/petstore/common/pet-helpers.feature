@ignore
Feature: Pet API Reusable Scenarios
  Reusable background scenarios for Pet API testing
  ISO/IEC/IEEE 29119-5 Keyword-Driven Testing Support

  Background:
    * url baseUrl
    * def utils = call read('classpath:petstore/common/common-utils.feature')

  @ignore @reusable
  Scenario: Create a pet helper
    * def petId = __arg.petId || utils.generateUniqueId()
    * def petName = __arg.name || 'TestPet'
    * def petStatus = __arg.status || 'available'
    * def photoUrls = __arg.photoUrls || ['https://example.com/pet.jpg']
    * def category = __arg.category || null
    * def tags = __arg.tags || null
    
    * def petPayload = { id: #(petId), name: '#(petName)', photoUrls: #(photoUrls), status: '#(petStatus)' }
    * if (category != null) petPayload.category = category
    * if (tags != null) petPayload.tags = tags
    
    Given path 'pet'
    And header Content-Type = 'application/json'
    And header Accept = 'application/json'
    And request petPayload
    When method post
    Then status 200
    * def createdPet = response

  @ignore @reusable
  Scenario: Get pet by ID helper
    * def petId = __arg.petId
    Given path 'pet', petId
    And header Accept = 'application/json'
    And header api_key = apiKey
    When method get

  @ignore @reusable
  Scenario: Update pet helper
    * def petPayload = __arg.petPayload
    Given path 'pet'
    And header Content-Type = 'application/json'
    And header Accept = 'application/json'
    And request petPayload
    When method put

  @ignore @reusable
  Scenario: Delete pet helper
    * def petId = __arg.petId
    Given path 'pet', petId
    And header api_key = apiKey
    When method delete

  @ignore @reusable
  Scenario: Find pets by status helper
    * def status = __arg.status
    Given path 'pet', 'findByStatus'
    And param status = status
    And header Accept = 'application/json'
    When method get

  @ignore @reusable
  Scenario: Find pets by tags helper
    * def tags = __arg.tags
    Given path 'pet', 'findByTags'
    And param tags = tags
    And header Accept = 'application/json'
    When method get

  @ignore @reusable
  Scenario: Update pet with form data helper
    * def petId = __arg.petId
    * def name = __arg.name || null
    * def status = __arg.status || null
    Given path 'pet', petId
    And header Content-Type = 'application/x-www-form-urlencoded'
    And form field name = name
    And form field status = status
    When method post

  @ignore @reusable
  Scenario: Upload pet image helper
    * def petId = __arg.petId
    * def additionalMetadata = __arg.metadata || ''
    * def file = __arg.file
    Given path 'pet', petId, 'uploadImage'
    And header Content-Type = 'multipart/form-data'
    And multipart field additionalMetadata = additionalMetadata
    And multipart file file = { read: '#(file)', filename: 'test.jpg', contentType: 'image/jpeg' }
    When method post
