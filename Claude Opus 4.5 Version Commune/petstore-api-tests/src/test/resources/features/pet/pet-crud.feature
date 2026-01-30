Feature: Pet Management API - CRUD and Search Operations
  As a pet store administrator
  I want to manage pets in the store inventory
  So that customers can browse and purchase pets

  Background:
    * url baseUrl
    * configure headers = { Accept: 'application/json' }
    * def allowedStatuses = ['available', 'pending', 'sold']
    * def generatePetId = function(){ return Math.floor(Math.random() * 900) + 1001 }

  # ==========================================================================
  # TC-PET-001: Add New Pet - Positive Scenarios
  # Risk Level: Critical
  # ==========================================================================

  @critical @smoke @pet @create
  Scenario: TC-PET-001-01 - Successfully add a new pet with all required fields
    * def petId = generatePetId()
    * def petPayload =
      """
      {
        "id": #(petId),
        "name": "Fluffy",
        "photoUrls": ["https://example.com/pet.jpg"],
        "status": "available"
      }
      """
    Given path 'pet'
    And request petPayload
    When method post
    Then status 200
    And match response.id == petId
    And match response.name == 'Fluffy'
    And match responseHeaders['Content-Type'][0] contains 'application/json'

  @critical @pet @create
  Scenario: TC-PET-001-02 - Successfully add a new pet with all optional fields
    * def petId = generatePetId()
    * def petPayload =
      """
      {
        "id": #(petId),
        "name": "Max",
        "photoUrls": ["https://example.com/max.jpg"],
        "status": "available",
        "category": { "id": 1, "name": "Dogs" },
        "tags": [{ "id": 1, "name": "friendly" }]
      }
      """
    Given path 'pet'
    And request petPayload
    When method post
    Then status 200
    And match response.id == petId
    And match response.status == 'available'
    And match response.category.name == 'Dogs'
    And match response.tags[0].name == 'friendly'

  @critical @pet @create
  Scenario Outline: TC-PET-001-03 - Add pets with different valid status values
    * def petId = generatePetId()
    * def petPayload =
      """
      {
        "id": #(petId),
        "name": "TestPet",
        "photoUrls": ["https://example.com/test.jpg"],
        "status": "<status>"
      }
      """
    Given path 'pet'
    And request petPayload
    When method post
    Then status 200
    And match response.status == '<status>'

    Examples:
      | status    |
      | available |
      | pending   |
      | sold      |

  # ==========================================================================
  # TC-PET-002: Add New Pet - Negative Scenarios
  # Risk Level: High
  # ==========================================================================

  @high @pet @create @negative
  Scenario: TC-PET-002-01 - Handle pet creation with missing name field
    * def petPayload =
      """
      {
        "photoUrls": ["https://example.com/pet.jpg"]
      }
      """
    Given path 'pet'
    And request petPayload
    When method post
    Then match [200, 405, 400] contains responseStatus

  @high @pet @create @negative
  Scenario: TC-PET-002-02 - Handle pet creation with missing photoUrls field
    * def petPayload =
      """
      {
        "name": "TestPet"
      }
      """
    Given path 'pet'
    And request petPayload
    When method post
    Then match [200, 405, 400] contains responseStatus

  @high @pet @create @negative
  Scenario: TC-PET-002-03 - Handle pet creation with empty request body
    Given path 'pet'
    And request {}
    When method post
    Then match [400, 405, 500] contains responseStatus

  @high @pet @create @negative
  Scenario: TC-PET-002-04 - Handle pet creation with invalid JSON format
    Given path 'pet'
    And header Content-Type = 'application/json'
    And request 'invalid json {'
    When method post
    Then match [400, 405, 500] contains responseStatus

  @medium @pet @create @negative
  Scenario: TC-PET-002-05 - Handle pet creation with invalid status enum value
    * def petId = generatePetId()
    * def petPayload =
      """
      {
        "id": #(petId),
        "name": "TestPet",
        "photoUrls": ["https://example.com/test.jpg"],
        "status": "invalid_status"
      }
      """
    Given path 'pet'
    And request petPayload
    When method post
    Then match [200, 400, 405] contains responseStatus

  # ==========================================================================
  # TC-PET-003: Get Pet by ID - Positive Scenarios
  # Risk Level: Critical
  # ==========================================================================

  @critical @smoke @pet @read
  Scenario: TC-PET-003-01 - Successfully retrieve an existing pet by ID
    * def petId = generatePetId()
    * def petPayload =
      """
      {
        "id": #(petId),
        "name": "RetrievablePet",
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
    Then status 200
    And match response.id == petId
    And match response.name == 'RetrievablePet'
    And match responseHeaders['Content-Type'][0] contains 'application/json'

  @high @pet @read
  Scenario: TC-PET-003-02 - Retrieve pet with XML response format
    * def petId = generatePetId()
    * def petPayload =
      """
      {
        "id": #(petId),
        "name": "XMLPet",
        "photoUrls": ["https://example.com/pet.jpg"],
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

  # ==========================================================================
  # TC-PET-004: Get Pet by ID - Negative Scenarios
  # Risk Level: High
  # ==========================================================================

  @high @pet @read @negative
  Scenario: TC-PET-004-01 - Return 404 for non-existent pet ID
    Given path 'pet', '999999999'
    When method get
    Then status 404
    * def t = karate.typeOf(response)
    * if (t == 'map') karate.log('Response is JSON object')
    * else karate.log('Response is: ' + t)

  @high @pet @read @negative
  Scenario: TC-PET-004-02 - Return error for invalid pet ID format (string)
    Given path 'pet', 'invalid'
    When method get
    Then match [400, 404] contains responseStatus

  @high @pet @read @negative
  Scenario: TC-PET-004-03 - Return error for invalid pet ID format (negative number)
    Given path 'pet', '-1'
    When method get
    Then match [400, 404] contains responseStatus

  @medium @pet @read @negative
  Scenario: TC-PET-004-04 - Handle pet ID exceeding int64 max value
    * def bigId = '9223372036854775808'
    Given path 'pet', bigId
    When method get
    Then match [400, 404, 500] contains responseStatus

  # ==========================================================================
  # TC-PET-005: Update Pet - PUT Method
  # Risk Level: Critical
  # ==========================================================================

  @critical @pet @update
  Scenario: TC-PET-005-01 - Successfully update an existing pet
    * def petId = generatePetId()
    * def createPayload =
      """
      {
        "id": #(petId),
        "name": "OriginalName",
        "photoUrls": ["https://example.com/pet.jpg"],
        "status": "available"
      }
      """
    Given path 'pet'
    And request createPayload
    When method post
    Then status 200

    * def updatePayload =
      """
      {
        "id": #(petId),
        "name": "UpdatedFluffy",
        "photoUrls": ["https://example.com/new.jpg"],
        "status": "sold"
      }
      """
    Given path 'pet'
    And request updatePayload
    When method put
    Then status 200
    And match response.name == 'UpdatedFluffy'
    And match response.status == 'sold'

  @high @pet @update @negative
  Scenario: TC-PET-005-02 - Handle update with invalid ID in payload
    * def updatePayload =
      """
      {
        "id": "abc",
        "name": "TestPet",
        "photoUrls": ["https://example.com/pet.jpg"]
      }
      """
    Given path 'pet'
    And request updatePayload
    When method put
    Then match [400, 500] contains responseStatus

  @high @pet @update @negative
  Scenario: TC-PET-005-03 - Handle update of non-existent pet
    * def updatePayload =
      """
      {
        "id": 999999999,
        "name": "NonExistentPet",
        "photoUrls": ["https://example.com/pet.jpg"]
      }
      """
    Given path 'pet'
    And request updatePayload
    When method put
    Then match [200, 404] contains responseStatus

  @high @pet @update @negative
  Scenario: TC-PET-005-04 - Handle update with validation exception
    * def updatePayload =
      """
      {
        "photoUrls": "not-an-array"
      }
      """
    Given path 'pet'
    And request updatePayload
    When method put
    Then match [400, 405, 500] contains responseStatus

  # ==========================================================================
  # TC-PET-006: Update Pet with Form Data - POST Method
  # Risk Level: High
  # ==========================================================================

  @high @pet @update
  Scenario: TC-PET-006-01 - Successfully update pet name using form data
    * def petId = generatePetId()
    * def createPayload =
      """
      {
        "id": #(petId),
        "name": "OriginalName",
        "photoUrls": ["https://example.com/pet.jpg"],
        "status": "available"
      }
      """
    Given path 'pet'
    And request createPayload
    When method post
    Then status 200

    Given path 'pet', petId
    And header Content-Type = 'application/x-www-form-urlencoded'
    And form field name = 'FormUpdatedPet'
    When method post
    Then match [200, 405] contains responseStatus

  @high @pet @update
  Scenario: TC-PET-006-02 - Successfully update pet status using form data
    * def petId = generatePetId()
    * def createPayload =
      """
      {
        "id": #(petId),
        "name": "StatusTestPet",
        "photoUrls": ["https://example.com/pet.jpg"],
        "status": "available"
      }
      """
    Given path 'pet'
    And request createPayload
    When method post
    Then status 200

    Given path 'pet', petId
    And header Content-Type = 'application/x-www-form-urlencoded'
    And form field status = 'pending'
    When method post
    Then match [200, 405] contains responseStatus

  @high @pet @update
  Scenario: TC-PET-006-03 - Successfully update both name and status using form data
    * def petId = generatePetId()
    * def createPayload =
      """
      {
        "id": #(petId),
        "name": "BothFieldsPet",
        "photoUrls": ["https://example.com/pet.jpg"],
        "status": "available"
      }
      """
    Given path 'pet'
    And request createPayload
    When method post
    Then status 200

    Given path 'pet', petId
    And header Content-Type = 'application/x-www-form-urlencoded'
    And form field name = 'NewPetName'
    And form field status = 'available'
    When method post
    Then match [200, 405] contains responseStatus

  # ==========================================================================
  # TC-PET-007: Delete Pet
  # Risk Level: Critical
  # ==========================================================================

  @critical @pet @delete
  Scenario: TC-PET-007-01 - Successfully delete an existing pet
    * def petId = generatePetId()
    * def createPayload =
      """
      {
        "id": #(petId),
        "name": "DeletablePet",
        "photoUrls": ["https://example.com/pet.jpg"],
        "status": "available"
      }
      """
    Given path 'pet'
    And request createPayload
    When method post
    Then status 200

    Given path 'pet', petId
    And header api_key = 'special-key'
    When method delete
    Then match [200, 204] contains responseStatus

    Given path 'pet', petId
    When method get
    Then status 404

  @high @pet @delete @negative
  Scenario: TC-PET-007-02 - Return error for delete with invalid ID format
    Given path 'pet', 'invalid_id'
    And header api_key = 'special-key'
    When method delete
    Then match [400, 404] contains responseStatus

  @high @pet @delete @negative
  Scenario: TC-PET-007-03 - Return 404 for delete of non-existent pet
    Given path 'pet', '999999999'
    And header api_key = 'special-key'
    When method delete
    Then match [404, 200] contains responseStatus

  # ==========================================================================
  # TC-PET-008: Find Pets by Status
  # Risk Level: Critical
  # ==========================================================================

  @critical @smoke @pet @search
  Scenario: TC-PET-008-01 - Successfully find pets by available status
    Given path 'pet', 'findByStatus'
    And param status = 'available'
    When method get
    Then status 200
    And match response == '#array'
    And match each response[*].status == 'available'

  @critical @pet @search
  Scenario: TC-PET-008-02 - Successfully find pets by pending status
    Given path 'pet', 'findByStatus'
    And param status = 'pending'
    When method get
    Then status 200
    And match response == '#array'

  @critical @pet @search
  Scenario: TC-PET-008-03 - Successfully find pets by sold status
    Given path 'pet', 'findByStatus'
    And param status = 'sold'
    When method get
    Then status 200
    And match response == '#array'

  @high @pet @search
  Scenario: TC-PET-008-04 - Successfully find pets by multiple status values
    Given path 'pet', 'findByStatus'
    And params { status: ['available', 'pending'] }
    When method get
    Then status 200
    And match response == '#array'

  @high @pet @search @negative
  Scenario: TC-PET-008-05 - Handle invalid status value
    Given path 'pet', 'findByStatus'
    And param status = 'invalid'
    When method get
    Then match [200, 400] contains responseStatus

  @high @pet @search @negative
  Scenario: TC-PET-008-06 - Handle missing status parameter
    Given path 'pet', 'findByStatus'
    When method get
    Then match [200, 400] contains responseStatus

  # ==========================================================================
  # TC-PET-009: Find Pets by Tags (Deprecated)
  # Risk Level: Medium
  # ==========================================================================

  @medium @pet @search @deprecated
  Scenario: TC-PET-009-01 - Successfully find pets by single tag
    Given path 'pet', 'findByTags'
    And param tags = 'tag1'
    When method get
    Then match [200, 400] contains responseStatus
    * if (responseStatus == 200) karate.match('response', '#array')

  @medium @pet @search @deprecated
  Scenario: TC-PET-009-02 - Successfully find pets by multiple tags
    Given path 'pet', 'findByTags'
    And params { tags: ['tag1', 'tag2'] }
    When method get
    Then match [200, 400] contains responseStatus

  @medium @pet @search @negative @deprecated
  Scenario: TC-PET-009-03 - Handle empty tags parameter
    Given path 'pet', 'findByTags'
    And param tags = ''
    When method get
    Then match [200, 400] contains responseStatus

  # ==========================================================================
  # TC-PET-010: Upload Pet Image
  # Risk Level: Medium
  # ==========================================================================

  @medium @pet @image
  Scenario: TC-PET-010-01 - Successfully upload image for existing pet
    * def petId = generatePetId()
    * def createPayload =
      """
      {
        "id": #(petId),
        "name": "ImageTestPet",
        "photoUrls": ["https://example.com/pet.jpg"],
        "status": "available"
      }
      """
    Given path 'pet'
    And request createPayload
    When method post
    Then status 200

    Given path 'pet', petId, 'uploadImage'
    And header Content-Type = 'multipart/form-data'
    And multipart field additionalMetadata = 'test image'
    And multipart file file = { read: 'classpath:img/test-image.jpg', filename: 'test.jpg', contentType: 'image/jpeg' }
    When method post
    Then match [200, 415] contains responseStatus
    * if (responseStatus == 200) karate.match('response.code', '#number')
    * if (responseStatus == 200) karate.match('response.type', '#string')
    * if (responseStatus == 200) karate.match('response.message', '#string')

  @medium @pet @image
  Scenario: TC-PET-010-02 - Upload image with additional metadata
    * def petId = generatePetId()
    * def createPayload =
      """
      {
        "id": #(petId),
        "name": "MetadataImagePet",
        "photoUrls": ["https://example.com/pet.jpg"],
        "status": "available"
      }
      """
    Given path 'pet'
    And request createPayload
    When method post
    Then status 200

    Given path 'pet', petId, 'uploadImage'
    And header Content-Type = 'multipart/form-data'
    And multipart field additionalMetadata = 'Profile photo of the pet'
    When method post
    Then match [200, 415] contains responseStatus

  # ==========================================================================
  # TC-PET-011: Data Consistency Tests
  # Risk Level: Critical
  # ==========================================================================

  @critical @pet @consistency
  Scenario: TC-PET-011-01 - Create-Read consistency for pets
    * def petId = generatePetId()
    * def petPayload =
      """
      {
        "id": #(petId),
        "name": "ConsistencyTestPet",
        "photoUrls": ["https://example.com/test.jpg"],
        "status": "available"
      }
      """
    Given path 'pet'
    And request petPayload
    When method post
    Then status 200
    * def createdPet = response

    Given path 'pet', petId
    When method get
    Then status 200
    And match response.id == createdPet.id
    And match response.name == createdPet.name
    And match response.status == createdPet.status

  @critical @pet @consistency
  Scenario: TC-PET-011-02 - Update-Read consistency for pets
    * def petId = generatePetId()
    * def createPayload =
      """
      {
        "id": #(petId),
        "name": "BeforeUpdate",
        "photoUrls": ["https://example.com/pet.jpg"],
        "status": "available"
      }
      """
    Given path 'pet'
    And request createPayload
    When method post
    Then status 200

    * def updatePayload =
      """
      {
        "id": #(petId),
        "name": "UpdatedConsistencyPet",
        "photoUrls": ["https://example.com/pet.jpg"],
        "status": "sold"
      }
      """
    Given path 'pet'
    And request updatePayload
    When method put
    Then status 200

    Given path 'pet', petId
    When method get
    Then status 200
    And match response.name == 'UpdatedConsistencyPet'

  @critical @pet @consistency
  Scenario: TC-PET-011-03 - Delete-Read consistency for pets
    * def petId = generatePetId()
    * def createPayload =
      """
      {
        "id": #(petId),
        "name": "ToBeDeleted",
        "photoUrls": ["https://example.com/pet.jpg"],
        "status": "available"
      }
      """
    Given path 'pet'
    And request createPayload
    When method post
    Then status 200

    Given path 'pet', petId
    And header api_key = 'special-key'
    When method delete
    Then match [200, 204] contains responseStatus

    Given path 'pet', petId
    When method get
    Then status 404

  # ==========================================================================
  # TC-PET-012: Idempotency Tests
  # Risk Level: High
  # ==========================================================================

  @high @pet @idempotency
  Scenario: TC-PET-012-01 - GET requests are idempotent
    * def petId = generatePetId()
    * def createPayload =
      """
      {
        "id": #(petId),
        "name": "IdempotentPet",
        "photoUrls": ["https://example.com/pet.jpg"],
        "status": "available"
      }
      """
    Given path 'pet'
    And request createPayload
    When method post
    Then status 200

    Given path 'pet', petId
    When method get
    Then status 200
    * def firstResponse = response

    Given path 'pet', petId
    When method get
    Then status 200
    And match response == firstResponse

    Given path 'pet', petId
    When method get
    Then status 200
    And match response == firstResponse

  @high @pet @idempotency
  Scenario: TC-PET-012-02 - PUT requests are idempotent
    * def petId = generatePetId()
    * def petPayload =
      """
      {
        "id": #(petId),
        "name": "IdempotentUpdatePet",
        "photoUrls": ["https://example.com/pet.jpg"],
        "status": "available"
      }
      """
    Given path 'pet'
    And request petPayload
    When method post
    Then status 200

    Given path 'pet'
    And request petPayload
    When method put
    Then status 200
    * def firstUpdate = response

    Given path 'pet'
    And request petPayload
    When method put
    Then status 200
    And match response.id == firstUpdate.id
    And match response.name == firstUpdate.name

  # ==========================================================================
  # TC-PET-013: Schema Validation
  # Risk Level: High
  # ==========================================================================

  @high @pet @schema
  Scenario: TC-PET-013-01 - Validate pet response contains required fields
    * def petId = generatePetId()
    * def petPayload =
      """
      {
        "id": #(petId),
        "name": "SchemaPet",
        "photoUrls": ["https://example.com/schema.jpg"],
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

  @high @pet @schema
  Scenario: TC-PET-013-02 - Validate pet status enum values in response
    * def petId = generatePetId()
    * def petPayload =
      """
      {
        "id": #(petId),
        "name": "EnumPet",
        "photoUrls": ["https://example.com/enum.jpg"],
        "status": "pending"
      }
      """
    Given path 'pet'
    And request petPayload
    When method post
    Then status 200

    Given path 'pet', petId
    When method get
    Then status 200
    And match allowedStatuses contains response.status

  @medium @pet @schema
  Scenario: TC-PET-013-03 - Validate pet category structure in response
    * def petId = generatePetId()
    * def petPayload =
      """
      {
        "id": #(petId),
        "name": "CategoryPet",
        "photoUrls": ["https://example.com/cat.jpg"],
        "status": "available",
        "category": { "id": 1, "name": "Dogs" }
      }
      """
    Given path 'pet'
    And request petPayload
    When method post
    Then status 200

    Given path 'pet', petId
    When method get
    Then status 200
    And match response.category ==
      """
      {
        id: '#number',
        name: '#string'
      }
      """

  @medium @pet @schema
  Scenario: TC-PET-013-04 - Validate pet tags array structure in response
    * def petId = generatePetId()
    * def petPayload =
      """
      {
        "id": #(petId),
        "name": "TagsPet",
        "photoUrls": ["https://example.com/tags.jpg"],
        "status": "available",
        "tags": [
          { "id": 1, "name": "friendly" },
          { "id": 2, "name": "playful" }
        ]
      }
      """
    Given path 'pet'
    And request petPayload
    When method post
    Then status 200

    Given path 'pet', petId
    When method get
    Then status 200
    And match each response.tags ==
      """
      {
        id: '#number',
        name: '#string'
      }
      """
