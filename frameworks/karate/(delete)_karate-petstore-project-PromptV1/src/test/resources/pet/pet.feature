Feature: Pet API v2 - Risk-based CRUD, query, media, and ID validation

  Background:
    * url 'https://petstore.swagger.io/v2'
    * configure headers = { Accept: 'application/json' }
    * def randId = function(){ return Math.floor(Math.random()*900000000) + 1 }
    * def petSchema =
    """
    {
      id: '#number',
      name: '#string',
      photoUrls: '#[ #string ]',
      category: '#? _ == null || typeof _ == "object"',
      tags: '#? _ == null || Array.isArray(_)',
      status: '#? _ == null || _ in ["available","pending","sold"]'
    }
    """

  @pet @positive @critical @schema
  Scenario: Create pet and retrieve it by id
    * def petId = randId()
    Given path 'pet'
    And request
    """
    {
      "id": #(petId),
      "name": "neo-dog",
      "photoUrls": ["https://pics.example/p1.jpg"],
      "status": "available",
      "category": {"id": 1, "name": "dogs"},
      "tags": [{"id": 10, "name": "cute"}]
    }
    """
    When method post
    Then status 200
    And match response == petSchema
    And match response.name == 'neo-dog'
    And match response.status == 'available'

    Given path 'pet', petId
    When method get
    Then status 200
    And match response == petSchema
    And match response.id == petId

  @pet @positive @high @schema
  Scenario: Update pet via PUT and verify persisted fields
    * def petId = randId()
    Given path 'pet'
    And request { id: #(petId), name: 'milo', photoUrls: ['u1'], status: 'pending', tags: [ { id: 1, name: 'blue' } ] }
    When method post
    Then status 200

    Given path 'pet'
    And request { id: #(petId), name: 'milo-upd', photoUrls: ['u1','u2'], status: 'sold', category: { id: 2, name: 'rare' } }
    When method put
    Then status 200
    And match response == petSchema
    And match response.id == petId
    And match response.name == 'milo-upd'
    And match response.status == 'sold'
    And match response.category.name == 'rare'

    Given path 'pet', petId
    When method get
    Then status 200
    And match response.name == 'milo-upd'
    And match response.status == 'sold'

  @pet @negative @validation
  Scenario: Create pet with missing required field (name) -> 405
    Given path 'pet'
    And request { id: #(randId()), photoUrls: ['u1'], status: 'available' }
    When method post
    Then status 405

  @pet @negative @validation
  Scenario Outline: Get pet by id with invalid id format -> 400
    Given path 'pet', <badId>
    When method get
    Then status 400
    Examples:
      | badId |
      | 'abc' |
      | -5    |

  @pet @negative
  Scenario: Get pet by id that does not exist -> 404
    Given path 'pet', 999999999999
    When method get
    Then status 404

  @pet @positive @validation
  Scenario: Update pet with form data (name & status)
    * def petId = randId()
    Given path 'pet'
    And request { id: #(petId), name: 'formy', photoUrls: ['u1'], status: 'available' }
    When method post
    Then status 200

    Given path 'pet', petId
    And header Content-Type = 'application/x-www-form-urlencoded'
    And request 'name=formy-upd&status=pending'
    When method post
    Then status 200

    Given path 'pet', petId
    When method get
    Then status 200
    And match response.name == 'formy-upd'
    And match response.status == 'pending'

  @pet @positive @medium
  Scenario: Upload image for a pet
    * def petId = randId()
    Given path 'pet'
    And request { id: #(petId), name: 'snappy', photoUrls: ['u1'], status: 'available' }
    When method post
    Then status 200

    Given path 'pet', petId, 'uploadImage'
    And header Content-Type = 'multipart/form-data'
    And multipart field additionalMetadata = 'first image'
    And multipart file file = { read: 'classpath:files/pet.png', filename: 'pet.png', contentType: 'image/png' }
    When method post
    Then status 200
    And match response.message contains 'uploaded'

  @pet @positive @schema
  Scenario: Find pets by status returns only requested statuses
    * def petA = randId()
    * def petB = randId()
    Given path 'pet'
    And request { id: #(petA), name: 'a1', photoUrls: ['u'], status: 'available' }
    When method post
    Then status 200

    Given path 'pet'
    And request { id: #(petB), name: 'b1', photoUrls: ['u'], status: 'sold' }
    When method post
    Then status 200

    Given path 'pet/findByStatus'
    And param status = 'available'
    When method get
    Then status 200
    And match each response == petSchema
    And match response[*].status contains only ['available']
    And match response[*].id contains petA
    And match response[*].id !contains petB

  @pet @negative @validation
  Scenario: Find pets by status with invalid value -> 400
    Given path 'pet/findByStatus'
    And param status = 'unknown'
    When method get
    Then status 400

  @pet @positive @schema
  Scenario: Find pets by tags
    * def petId = randId()
    Given path 'pet'
    And request { id: #(petId), name: 'taggo', photoUrls: ['u'], tags: [ { id: 1, name: 'blue' } ] }
    When method post
    Then status 200

    Given path 'pet/findByTags'
    And param tags = 'blue'
    When method get
    Then status 200
    And match each response == petSchema
    And match response[*].id contains petId

  @pet @negative @validation
  Scenario: Find pets by tags with invalid tag value -> 400
    Given path 'pet/findByTags'
    And param tags = ''
    When method get
    Then status 400

  @pet @positive @cleanup
  Scenario: Delete pet by id
    * def petId = randId()
    Given path 'pet'
    And request { id: #(petId), name: 'to-delete', photoUrls: ['u'], status: 'available' }
    When method post
    Then status 200

    Given path 'pet', petId
    When method delete
    Then status 200

    Given path 'pet', petId
    When method get
    Then status 404

  @pet @negative
  Scenario Outline: Delete pet with invalid or non-existing id
    Given path 'pet', <pid>
    When method delete
    Then status <code>
    Examples:
      | pid             | code |
      | 'abc'           | 400  |
      | 99999999999999  | 404  |
