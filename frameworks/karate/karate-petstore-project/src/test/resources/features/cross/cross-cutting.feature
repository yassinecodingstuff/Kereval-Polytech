Feature: Cross-cutting quality attributes and robustness (security, limits, and schema conformance)
  Background:
    * def baseUrl = 'https://petstore.swagger.io/v2'
    * url baseUrl
    * configure headers = { Accept: 'application/json' }
    * def apiResponseSchema =
    """
    {
      code: '##number',
      type: '##string',
      message: '##string'
    }
    """
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
    * def orderSchema =
    """
    {
      id: '##number',
      petId: '#number',
      quantity: '#number',
      shipDate: '##string',
      status: '##string',
      complete: '##boolean'
    }
    """

  @security @headers @negative
  Scenario: Reject requests with unsupported media type
    * configure headers = { Accept: 'application/json', Content-Type: 'text/plain' }
    Given path 'pet'
    And request 'plain text is not allowed'
    When method post
    Then status 415

  @limits @negative
  Scenario: Reject oversized request body for pet creation
    * configure headers = { Accept: 'application/json', Content-Type: 'application/json' }
    * def photoUrls = []
    * def i = 0
    * while(i < 10000) karate.appendTo(photoUrls, 'https://img.example/pets/big-' + i++ + '.png')
    * def big =
    """
    {
      id: 9223372036854710010,
      name: "BigPayload",
      photoUrls: __PHOTO__,
      status: "available"
    }
    """
    * big.photoUrls = photoUrls
    Given path 'pet'
    And request big
    When method post
    Then status 413

  @schema @contract
  Scenario: Pet by id conforms to schema
    * configure headers = { Accept: 'application/json' }
    Given path 'pet', 9223372036854710001
    When method get
    Then status 200
    And match response == petSchema

  @schema @contract
  Scenario: Find pets by status returns array of Pet
    * configure headers = { Accept: 'application/json' }
    Given path 'pet', 'findByStatus'
    And param status = 'available'
    When method get
    Then status 200
    And match response == '#[]'
    And match each response == petSchema

  @schema @contract
  Scenario: Get order by id conforms to schema
    * configure headers = { Accept: 'application/json' }
    Given path 'store', 'order', 7001
    When method get
    Then status 200
    And match response == orderSchema

  @schema @contract
  Scenario: Inventory is a map of string to int
    * configure headers = { Accept: 'application/json' }
    Given path 'store', 'inventory'
    When method get
    Then status 200
    And match response == '#object'
    * match each response[*] == '#number'

  @schema @contract
  Scenario: Get user by username conforms to schema
    * configure headers = { Accept: 'application/json' }
    Given path 'user', 'qa_user_501'
    When method get
    Then status 200
    And match response == userSchema

  @schema @contract
  Scenario: Place order conforms to schema
    * configure headers = { Accept: 'application/json', Content-Type: 'application/json' }
    * def order =
    """
    {
      "id": 7200,
      "petId": 9223372036854710001,
      "quantity": 1,
      "shipDate": "2025-10-01T10:00:00.000Z",
      "status": "placed",
      "complete": false
    }
    """
    Given path 'store', 'order'
    And request order
    When method post
    Then status 200
    And match response == orderSchema

  @id-boundaries @pet
  Scenario Outline: Boundary testing for 64-bit ids on pet resource
    * configure headers = { Accept: 'application/json', Content-Type: 'application/json' }
    * def payload =
    """
    {
      "id": <id>,
      "name": "BoundaryPet",
      "photoUrls": ["https://img.example/pets/boundary.png"],
      "status": "available"
    }
    """
    Given path 'pet'
    And request payload
    When method post
    Then status 200
    * configure headers = { Accept: 'application/json' }
    Given path 'pet', <id>
    When method get
    Then status 200
    Examples:
      | id                  |
      | 1                   |
      | 9223372036854775806 |
      | 9223372036854775807 |

  @negative @id-boundaries @pet
  Scenario Outline: Invalid id boundaries are rejected for pet resource
    * configure headers = { Accept: 'application/json' }
    Given path 'pet', <id>
    When method get
    Then status 400
    Examples:
      | id                   |
      | -9223372036854775808 |
      | 9223372036854775808  |
      | 'NaN'                |

  @security @api-key @pet
  Scenario: Requests requiring api_key are authorized when header present
    * configure headers = { Accept: 'application/json', api_key: 'special-key' }
    Given path 'pet', 9223372036854710001
    When method get
    Then status 200

  @security @api-key @negative @pet
  Scenario: Requests requiring api_key are rejected when header missing
    * configure headers = { Accept: 'application/json' }
    Given path 'pet', 9223372036854710001
    When method get
    * assert responseStatus == 400 || responseStatus == 401 || responseStatus == 403

  @resilience @method-override @negative
  Scenario: Method not allowed returns 405
    * configure headers = { Accept: 'application/json' }
    Given path 'store', 'inventory'
    And request {}
    When method put
    Then status 405

  @performance @headers
  Scenario: Rate limit headers present on user login response
    * configure headers = { Accept: 'application/json' }
    Given path 'user', 'login'
    And param username = 'qa_user_501'
    And param password = 'Secret#123'
    When method get
    Then status 200
    * match responseHeaders['X-Rate-Limit'][0] == '#present'
    * match responseHeaders['X-Expires-After'][0] == '#present'

  @compat @deprecation
  Scenario: Find pets by tags remains available but flagged as deprecated in API definition
    * configure headers = { Accept: 'application/json' }
    Given path 'pet', 'findByTags'
    And param tags = 'tag1,tag2'
    When method get
    Then status 200
    And match response == '#[]'
    * configure headers = { Accept: 'application/json' }
    Given path 'swagger.json'
    When method get
    Then status 200
    * def deprecatedFlag = response.paths['/pet/findByTags'].get.deprecated
    * match deprecatedFlag == true

  @observability @errors
  Scenario Outline: Error responses return machine-readable bodies
    * configure headers = { Accept: 'application/json' }
    Given path <p1>, <p2>, <p3>
    When method <method>
    Then status <status>
    And match response == apiResponseSchema
    Examples:
      | method   | p1      | p2                 | p3    | status |
      | 'get'    | 'pet'   | 0                  | null  | 400    |
      | 'get'    | 'pet'   | 999999999          | null  | 404    |
      | 'delete' | 'store' | 'order'            | 0     | 400    |
      | 'get'    | 'user'  | 'nonexistent_user' | null  | 404    |
