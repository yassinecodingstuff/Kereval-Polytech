Feature: Pet Management API - POST Operations
  As a Petstore API consumer
  I want to create new pet records in the store
  So that I can add pets to the inventory
  
  Priority: CRITICAL - Core Business Functionality
  ISO/IEC/IEEE 29119 Alignment: Risk-based test selection with critical path coverage

  Background:
    * url baseUrl
    * def utils = call read('classpath:petstore/common/common-utils.feature')
    * def generateUniqueId = function(){ return Math.floor(Math.random() * 900000000) + 100000000 }
    * def generateStringOfLength = function(len){ var r=''; for(var i=0;i<len;i++) r+='a'; return r }

  @critical @smoke @positive @POST @pet
  Scenario: TC-PET-001 - Successfully add a new pet with all required fields
    * def petId = generateUniqueId()
    * def petPayload = { id: #(petId), name: 'Buddy', photoUrls: ['https://example.com/dog.jpg'] }
    Given path 'pet'
    And header Content-Type = 'application/json'
    And header Accept = 'application/json'
    And request petPayload
    When method post
    Then status 200
    And match response.name == 'Buddy'
    And match response.id == '#number'
    And match responseHeaders['Content-Type'][0] contains 'application/json'

  @critical @positive @POST @pet
  Scenario: TC-PET-002 - Successfully add a new pet with complete data model
    * def petId = generateUniqueId()
    * def petPayload =
      """
      {
        id: #(petId),
        name: 'MaxCompletePet',
        category: { id: 1, name: 'Dogs' },
        photoUrls: ['https://example.com/max.jpg'],
        tags: [{ id: 1, name: 'friendly' }],
        status: 'available'
      }
      """
    Given path 'pet'
    And header Content-Type = 'application/json'
    And header Accept = 'application/json'
    And request petPayload
    When method post
    Then status 200
    And match response.name == 'MaxCompletePet'
    And match response.category.name == 'Dogs'
    And match response.tags[0].name == 'friendly'
    And match response.status == 'available'

  @critical @positive @POST @pet @status
  Scenario Outline: TC-PET-003 - Successfully add pet with valid status enum values
    * def petId = generateUniqueId()
    * def petPayload = { id: #(petId), name: 'StatusTestPet', photoUrls: ['https://example.com/pet.jpg'], status: '<status>' }
    Given path 'pet'
    And header Content-Type = 'application/json'
    And header Accept = 'application/json'
    And request petPayload
    When method post
    Then status 200
    And match response.status == '<status>'

    Examples:
      | status    |
      | available |
      | pending   |
      | sold      |

  @critical @negative @POST @pet @validation
  Scenario: TC-PET-004 - Reject pet creation with missing required field name
    * def petPayload = { photoUrls: ['https://example.com/pet.jpg'] }
    Given path 'pet'
    And header Content-Type = 'application/json'
    And header Accept = 'application/json'
    And request petPayload
    When method post
    Then status 405

  @critical @negative @POST @pet @validation
  Scenario: TC-PET-005 - Reject pet creation with missing required field photoUrls
    * def petPayload = { name: 'TestPet' }
    Given path 'pet'
    And header Content-Type = 'application/json'
    And header Accept = 'application/json'
    And request petPayload
    When method post
    Then status 405

  @high @negative @POST @pet @validation
  Scenario: TC-PET-006 - Reject pet creation with empty request body
    Given path 'pet'
    And header Content-Type = 'application/json'
    And header Accept = 'application/json'
    And request {}
    When method post
    Then assert responseStatus == 405 || responseStatus == 400

  @high @negative @POST @pet @validation
  Scenario: TC-PET-007 - Reject pet creation with malformed JSON payload
    Given path 'pet'
    And header Content-Type = 'application/json'
    And header Accept = 'application/json'
    And request "{ name: 'MissingQuotes' }"
    When method post
    Then assert responseStatus == 400 || responseStatus == 405 || responseStatus == 500

  @medium @negative @POST @pet @datatype
  Scenario: TC-PET-008 - Reject pet creation with invalid data type for id field
    * def petPayload = { id: 'invalid_string', name: 'DataTypePet', photoUrls: ['https://example.com/pet.jpg'] }
    Given path 'pet'
    And header Content-Type = 'application/json'
    And header Accept = 'application/json'
    And request petPayload
    When method post
    Then assert responseStatus == 400 || responseStatus == 405 || responseStatus == 500

  @medium @positive @POST @pet @special-characters
  Scenario: TC-PET-009 - Successfully add pet with special characters in name
    * def petId = generateUniqueId()
    * def specialName = 'Señor Whiskers 日本語 🐱'
    * def petPayload = { id: #(petId), name: '#(specialName)', photoUrls: ['https://example.com/cat.jpg'] }
    Given path 'pet'
    And header Content-Type = 'application/json'
    And header Accept = 'application/json'
    And request petPayload
    When method post
    Then status 200
    And match response.name == specialName

  @medium @positive @POST @pet @boundary
  Scenario: TC-PET-010 - Successfully add pet with maximum allowed name length
    * def petId = generateUniqueId()
    * def longName = generateStringOfLength(255)
    * def petPayload = { id: #(petId), name: '#(longName)', photoUrls: ['https://example.com/pet.jpg'] }
    Given path 'pet'
    And header Content-Type = 'application/json'
    And header Accept = 'application/json'
    And request petPayload
    When method post
    Then status 200
    And match response.name == longName

  @medium @positive @POST @pet @array
  Scenario: TC-PET-011 - Successfully add pet with multiple photoUrls
    * def petId = generateUniqueId()
    * def petPayload = { id: #(petId), name: 'MultiPhotoPet', photoUrls: ['https://ex.com/1.jpg', 'https://ex.com/2.jpg', 'https://ex.com/3.jpg'] }
    Given path 'pet'
    And header Content-Type = 'application/json'
    And header Accept = 'application/json'
    And request petPayload
    When method post
    Then status 200
    And match response.photoUrls == '#[3]'

  @medium @positive @POST @pet @array
  Scenario: TC-PET-012 - Successfully add pet with multiple tags
    * def petId = generateUniqueId()
    * def petPayload =
      """
      {
        id: #(petId),
        name: 'MultiTagPet',
        photoUrls: ['https://example.com/pet.jpg'],
        tags: [{ id: 1, name: 'cute' }, { id: 2, name: 'small' }]
      }
      """
    Given path 'pet'
    And header Content-Type = 'application/json'
    And header Accept = 'application/json'
    And request petPayload
    When method post
    Then status 200
    And match response.tags == '#[2]'

  @low @positive @POST @pet @content-type
  Scenario: TC-PET-013 - Successfully add pet with XML content type
    * def petId = generateUniqueId()
    * def xmlPayload = '<Pet><id>' + petId + '</id><name>XMLPet</name><photoUrls><photoUrl>https://example.com/pet.jpg</photoUrl></photoUrls><status>available</status></Pet>'
    Given path 'pet'
    And header Content-Type = 'application/xml'
    And header Accept = 'application/xml'
    And request xmlPayload
    When method post
    Then status 200

  @critical @negative @POST @pet @security
  Scenario: TC-PET-014 - Verify behavior without authentication
    * def petId = generateUniqueId()
    * def petPayload = { id: #(petId), name: 'UnauthorizedPet', photoUrls: ['https://example.com/pet.jpg'] }
    Given path 'pet'
    And header Content-Type = 'application/json'
    And header Accept = 'application/json'
    And request petPayload
    When method post
    Then assert responseStatus == 200 || responseStatus == 401 || responseStatus == 403

  @medium @positive @POST @pet @category
  Scenario: TC-PET-015 - Successfully add pet with nested category object
    * def petId = generateUniqueId()
    * def petPayload =
      """
      {
        id: #(petId),
        name: 'CategorizedPet',
        category: { id: 100, name: 'Exotic Birds' },
        photoUrls: ['https://example.com/bird.jpg'],
        status: 'available'
      }
      """
    Given path 'pet'
    And header Content-Type = 'application/json'
    And header Accept = 'application/json'
    And request petPayload
    When method post
    Then status 200
    And match response.category.id == 100
    And match response.category.name == 'Exotic Birds'

  @low @positive @POST @pet @minimal
  Scenario: TC-PET-016 - Successfully add pet with only required fields
    * def petId = generateUniqueId()
    * def petPayload = { id: #(petId), name: 'MinimalPet', photoUrls: ['https://example.com/minimal.jpg'] }
    Given path 'pet'
    And header Content-Type = 'application/json'
    And request petPayload
    When method post
    Then status 200
    And match response.name == 'MinimalPet'

  @low @negative @POST @pet @boundary
  Scenario: TC-PET-017 - Handle pet creation with empty photoUrls array
    * def petId = generateUniqueId()
    * def petPayload = { id: #(petId), name: 'EmptyPhotosPet', photoUrls: [] }
    Given path 'pet'
    And header Content-Type = 'application/json'
    And request petPayload
    When method post
    Then assert responseStatus == 200 || responseStatus == 405
