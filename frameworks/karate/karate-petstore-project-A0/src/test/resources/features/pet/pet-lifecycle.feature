Feature: Pet lifecycle management (critical E2E flows for high-impact functionality)
  Background:
    * def baseUrl = 'https://petstore.swagger.io/v2'
    * url baseUrl
    * configure headers = { Accept: 'application/json' }
    * def petSchema =
    """
    {
      id: '##number',
      category: '##object',
      name: '#string',
      photoUrls: '#[] string',
      tags: '##[] object',
      status: '#string'
    }
    """
    * def apiResponseSchema =
    """
    {
      code: '##number',
      type: '##string',
      message: '##string'
    }
    """

  @critical @pet @create @schema
  Scenario: Create a new pet with full payload and verify persistence
    * configure headers = { Accept: 'application/json', Content-Type: 'application/json' }
    * def payload =
    """
    {
      "id": 9223372036854710001,
      "category": { "id": 10, "name": "dogs" },
      "name": "Kona",
      "photoUrls": ["https://img.example/pets/kona.png"],
      "tags": [{ "id": 201, "name": "friendly" }],
      "status": "available"
    }
    """
    Given path 'pet'
    And request payload
    When method post
    Then status 200
    And match response == petSchema
    And match response.name == 'Kona'
    And match response.status == 'available'
    Given path 'pet', 9223372036854710001
    When method get
    Then status 200
    And match response.id == 9223372036854710001
    And match response == petSchema

  @high @pet @update @schema
  Scenario: Update an existing pet via PUT and verify fields changed
    * configure headers = { Accept: 'application/json', Content-Type: 'application/json' }
    * def create =
    """
    {
      "id": 9223372036854710002,
      "category": { "id": 99, "name": "temp" },
      "name": "Mochi",
      "photoUrls": ["https://img.example/pets/mochi.png"],
      "tags": [{ "id": 202, "name": "adoptable" }],
      "status": "pending"
    }
    """
    Given path 'pet'
    And request create
    When method post
    Then status 200
    * def payload =
    """
    {
      "id": 9223372036854710002,
      "category": { "id": 11, "name": "cats" },
      "name": "Mochi-Upd",
      "photoUrls": ["https://img.example/pets/mochi.png"],
      "tags": [{ "id": 202, "name": "adoptable" }],
      "status": "sold"
    }
    """
    Given path 'pet'
    And request payload
    When method put
    Then status 200
    And match response == petSchema
    And match response.name == 'Mochi-Upd'
    And match response.status == 'sold'
    Given path 'pet', 9223372036854710002
    When method get
    Then status 200
    And match response.name == 'Mochi-Upd'
    And match response.category.name == 'cats'

  @critical @pet @read @query
  Scenario Outline: Find pets by status returns only requested statuses
    * configure headers = { Accept: 'application/json' }
    Given path 'pet', 'findByStatus'
    And param status = '<status>'
    When method get
    Then status 200
    And match response == '#[]'
    And match each response == petSchema
    And match each response[*].status == '<status>'
    Examples:
      | status    |
      | available |
      | pending   |
      | sold      |

  @medium @pet @read @query
  Scenario: Find pets by multiple statuses
    * configure headers = { Accept: 'application/json' }
    Given path 'pet', 'findByStatus'
    And param status = 'available,pending'
    When method get
    Then status 200
    And match response == '#[]'
    And match each response == petSchema
    And match each response[*].status == '#? ["available","pending"].includes(_ )'

  @medium @pet @negative @validation
  Scenario: Create a pet with missing required fields should be rejected
    * configure headers = { Accept: 'application/json', Content-Type: 'application/json' }
    * def bad =
    """
    {
      "id": 9223372036854710003,
      "category": { "id": 12, "name": "birds" }
    }
    """
    Given path 'pet'
    And request bad
    When method post
    Then status 405

  @critical @pet @read @negative
  Scenario: Get pet by non-existing id returns 404
    * configure headers = { Accept: 'application/json' }
    Given path 'pet', 999999999999999999
    When method get
    Then status 404

  @high @pet @read @negative @validation
  Scenario Outline: Get pet by invalid id format returns client error
    * configure headers = { Accept: 'application/json' }
    Given path 'pet', <petId>
    When method get
    Then status 400
    Examples:
      | petId |
      | -1    |
      | 0     |
      | 'abc' |

  @high @pet @form
  Scenario: Update a pet using form data (name and status)
    * configure headers = { Accept: 'application/json', Content-Type: 'application/json' }
    * def pet =
    """
    {
      "id": 9223372036854710004,
      "name": "Pixel",
      "photoUrls": ["https://img.example/pets/pixel.png"],
      "status": "available"
    }
    """
    Given path 'pet'
    And request pet
    When method post
    Then status 200
    * configure headers = { Accept: 'application/json', Content-Type: 'application/x-www-form-urlencoded' }
    Given path 'pet', 9223372036854710004
    And form field name = 'PixelRenamed'
    And form field status = 'pending'
    When method post
    Then status 200
    * configure headers = { Accept: 'application/json' }
    Given path 'pet', 9223372036854710004
    When method get
    Then status 200
    And match response.name == 'PixelRenamed'
    And match response.status == 'pending'

  @high @pet @upload
  Scenario: Upload an image for a pet
    * configure headers = { Accept: 'application/json' }
    * def ensure =
    """
    {
      "id": 9223372036854710005,
      "name": "Roxy",
      "photoUrls": ["https://img.example/pets/roxy.png"],
      "status": "available"
    }
    """
    Given path 'pet'
    And request ensure
    When method post
    Then status 200
    * def temp = karate.write('pet image', 'pet.txt')
    * configure headers = { Accept: 'application/json', Content-Type: 'multipart/form-data' }
    Given path 'pet', 9223372036854710005, 'uploadImage'
    And multipart field additionalMetadata = 'show profile'
    And multipart file file = { read: 'file:' + temp, filename: 'pet.txt', contentType: 'text/plain' }
    When method post
    Then status 200
    And match response == apiResponseSchema
    And match response.message contains '9223372036854710005'

  @critical @pet @delete @security
  Scenario: Delete a pet with api_key authentication
    * configure headers = { Accept: 'application/json', Content-Type: 'application/json' }
    * def pet =
    """
    {
      "id": 9223372036854710006,
      "name": "Bolt",
      "photoUrls": ["https://img.example/pets/bolt.png"],
      "status": "available"
    }
    """
    Given path 'pet'
    And request pet
    When method post
    Then status 200
    * configure headers = { Accept: 'application/json', api_key: 'special-key' }
    Given path 'pet', 9223372036854710006
    When method delete
    Then status 200
    * configure headers = { Accept: 'application/json' }
    Given path 'pet', 9223372036854710006
    When method get
    Then status 404

  @high @pet @delete @negative @security
  Scenario: Deleting a pet without api_key should be rejected
    * configure headers = { Accept: 'application/json', Content-Type: 'application/json' }
    * def pet =
    """
    {
      "id": 9223372036854710007,
      "name": "Nala",
      "photoUrls": ["https://img.example/pets/nala.png"],
      "status": "available"
    }
    """
    Given path 'pet'
    And request pet
    When method post
    Then status 200
    * configure headers = { Accept: 'application/json' }
    Given path 'pet', 9223372036854710007
    When method delete
    * assert responseStatus == 400 || responseStatus == 401 || responseStatus == 403
