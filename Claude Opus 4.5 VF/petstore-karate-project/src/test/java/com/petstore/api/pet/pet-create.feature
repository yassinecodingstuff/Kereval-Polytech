Feature: Pet API - Create Operations
  As a pet store operator
  I need to add new pets to the store inventory
  So that customers can browse and purchase pets

  Background:
    * url baseUrl
    * def generatePetId = function(){ return Math.floor(Math.random() * 900000) + 100000 }

  @critical @smoke @pet @create
  Scenario: TC-PET-001 - Successfully add a new pet with all required fields
    * def petId = generatePetId()
    Given path 'pet'
    And header Content-Type = 'application/json'
    And request
      """
      {
        "id": #(petId),
        "name": "Buddy",
        "photoUrls": ["https://example.com/buddy.jpg"],
        "status": "available"
      }
      """
    When method POST
    Then status 200
    And match response.id == '#number'
    And match response.name == 'Buddy'
    And match response.photoUrls == '#array'
    And match response.status == 'available'

  @critical @pet @create
  Scenario: TC-PET-002 - Successfully add a new pet with all optional fields
    * def petId = generatePetId()
    Given path 'pet'
    And header Content-Type = 'application/json'
    And request
      """
      {
        "id": #(petId),
        "name": "MaxTheDog",
        "photoUrls": ["https://example.com/max.jpg"],
        "status": "available",
        "category": {
          "id": 1,
          "name": "Dogs"
        },
        "tags": [
          {
            "id": 1,
            "name": "friendly"
          },
          {
            "id": 2,
            "name": "vaccinated"
          }
        ]
      }
      """
    When method POST
    Then status 200
    And match response.name == 'MaxTheDog'
    And match response.category.name == 'Dogs'
    And match response.tags[0].name == 'friendly'
    And match response.tags == '#[2]'

  @negative @pet @create @validation
  Scenario: TC-PET-003 - Reject pet creation with missing required field name
    Given path 'pet'
    And header Content-Type = 'application/json'
    And request
      """
      {
        "photoUrls": ["https://example.com/pet.jpg"],
        "status": "available"
      }
      """
    When method POST
    Then status 405

  @negative @pet @create @validation
  Scenario: TC-PET-004 - Reject pet creation with missing required field photoUrls
    Given path 'pet'
    And header Content-Type = 'application/json'
    And request
      """
      {
        "name": "TestPet",
        "status": "available"
      }
      """
    When method POST
    Then status 405

  @negative @pet @create @validation
  Scenario: TC-PET-005 - Reject pet creation with empty request body
    Given path 'pet'
    And header Content-Type = 'application/json'
    And request {}
    When method POST
    Then status 405

  @pet @create @datatype
  Scenario: TC-PET-006 - Verify pet ID is returned as int64 format
    * def petId = generatePetId()
    Given path 'pet'
    And header Content-Type = 'application/json'
    And request
      """
      {
        "id": #(petId),
        "name": "TypeTestPet",
        "photoUrls": ["https://example.com/type.jpg"],
        "status": "available"
      }
      """
    When method POST
    Then status 200
    And match response.id == '#number'
    And assert response.id >= -9223372036854775808 && response.id <= 9223372036854775807

  @pet @create @boundary
  Scenario: TC-PET-009 - Add pet with maximum length name
    * def petId = generatePetId()
    * def longName = ''
    * eval for(var i = 0; i < 255; i++) longName += 'A'
    Given path 'pet'
    And header Content-Type = 'application/json'
    And request
      """
      {
        "id": #(petId),
        "name": "#(longName)",
        "photoUrls": ["https://example.com/long.jpg"],
        "status": "available"
      }
      """
    When method POST
    Then status 200
    And match response.name == longName

  @pet @create @boundary
  Scenario: TC-PET-010 - Add pet with multiple photo URLs
    * def petId = generatePetId()
    Given path 'pet'
    And header Content-Type = 'application/json'
    And request
      """
      {
        "id": #(petId),
        "name": "MultiPhotoPet",
        "photoUrls": ["url1.jpg", "url2.jpg", "url3.jpg", "url4.jpg", "url5.jpg"],
        "status": "available"
      }
      """
    When method POST
    Then status 200
    And match response.photoUrls == '#[5]'

  @pet @create @content-type
  Scenario: TC-PET-011 - Successfully add pet using XML content type
    * def petId = generatePetId()
    Given path 'pet'
    And header Content-Type = 'application/xml'
    And header Accept = 'application/xml'
    And request
      """
      <Pet>
        <id>#(petId)</id>
        <name>XMLPet</name>
        <photoUrls>
          <photoUrl>https://example.com/xml.jpg</photoUrl>
        </photoUrls>
        <status>available</status>
      </Pet>
      """
    When method POST
    Then status 200

  @pet @create @status-enum
  Scenario Outline: TC-PET-ENUM-001 - Pet status accepts valid enum values
    * def petId = generatePetId()
    Given path 'pet'
    And header Content-Type = 'application/json'
    And request
      """
      {
        "id": #(petId),
        "name": "EnumTestPet",
        "photoUrls": ["https://example.com/enum.jpg"],
        "status": "<status>"
      }
      """
    When method POST
    Then status <expected_status>

    Examples:
      | status    | expected_status |
      | available | 200             |
      | pending   | 200             |
      | sold      | 200             |
