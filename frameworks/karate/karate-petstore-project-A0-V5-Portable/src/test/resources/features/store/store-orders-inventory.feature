Feature: Store API — Orders & Inventory — Swagger Petstore v2
  Background:
    * url baseUrl
    * configure headers = { Accept: 'application/json' }

  Scenario: Place Order for a Pet and retrieve it by ID
    * def oid = '1101'
    Given path 'store', 'order'
    And header Content-Type = 'application/json'
    And request { "id": 1101, "petId": 1007, "quantity": 2, "shipDate": "2026-01-30T12:00:00Z", "status": "placed", "complete": false }
    When method post
    Then status 200
    And match response contains { id: '#number', petId: '#number', quantity: '#number', status: '#string', complete: '#boolean' }

    Given path 'store', 'order', oid
    When method get
    Then status 200
    And match response contains { id: '#number', petId: '#number', quantity: '#number', status: '#string', complete: '#boolean' }

  Scenario Outline: Get Order by ID within inclusive bounds (seed-before-read)
    * def oid = '<id>'
    Given path 'store', 'order'
    And header Content-Type = 'application/json'
    And request { "id": <id>, "petId": 1008, "quantity": 1, "shipDate": "2026-01-30T10:00:00Z", "status": "placed", "complete": true }
    When method post
    Then status 200

    Given path 'store', 'order', oid
    When method get
    Then status 200
    And match response contains { id: '#number', petId: '#number', quantity: '#number', status: '#string', complete: '#boolean' }
    Examples:
      | id  |
      | 1   |
      | 5   |
      | 10  |

  Scenario Outline: Get Order by ID out of bounds returns error (typed body safe)
    Given path 'store', 'order', '<id>'
    When method get
    Then match [400,404] contains responseStatus
    * def t = karate.typeOf(response)
    * if (t == 'map') match response contains { message: '#string' }
    * else match response == '#string'
    Examples:
      | id   |
      | '0'  |
      | '11' |
      | '-1' |
      | 'abc'|

  Scenario: Delete Order and verify it is not retrievable
    * def oid = '1102'
    Given path 'store', 'order'
    And header Content-Type = 'application/json'
    And request { "id": 1102, "petId": 1009, "quantity": 3, "shipDate": "2026-01-30T11:00:00Z", "status": "placed", "complete": false }
    When method post
    Then status 200

    Given path 'store', 'order', oid
    When method delete
    Then match [200,204,404] contains responseStatus

    Given path 'store', 'order', oid
    When method get
    Then match [404] contains responseStatus

  Scenario: Get Inventory requires API key and returns integer quantities
    Given path 'store', 'inventory'
    And header api_key = 'special-key'
    When method get
    Then status 200
    And match response == '#object'
    * def keys = karate.keysOf(response)
    * if (keys != null && karate.sizeOf(keys) > 0)
      """
      * def vals = keys.map(function(k){ return response[k] })
      * match each vals == '#number'
      """

  Scenario Outline: Create orders with allowed status values
    Given path 'store', 'order'
    And header Content-Type = 'application/json'
    And request { "id": <id>, "petId": 1010, "quantity": 1, "status": "<status>" }
    When method post
    Then status 200
    And match response contains { status: '#? ["placed","approved","delivered"].includes(_)' }
    Examples:
      | id   | status    |
      | 1110 | placed    |
      | 1111 | approved  |
      | 1112 | delivered |

  Scenario: Create order with missing required fields results in client error or server handling
    Given path 'store', 'order'
    And header Content-Type = 'application/json'
    And request { "status": "placed" }
    When method post
    Then match [200,400,405] contains responseStatus
    * def t = karate.typeOf(response)
    * if (t == 'map') match response contains { message: '#string' }
    * else match response == '#string'

  Scenario: Delete non-existing order returns tolerant status
    Given path 'store', 'order', '1998'
    When method delete
    Then match [404,200,204] contains responseStatus

  Scenario: Retrieve order after deletion returns 404
    * def oid = '1113'
    Given path 'store', 'order'
    And header Content-Type = 'application/json'
    And request { "id": 1113, "petId": 1011, "quantity": 1, "status": "placed" }
    When method post
    Then status 200

    Given path 'store', 'order', oid
    When method delete
    Then match [200,204,404] contains responseStatus

    Given path 'store', 'order', oid
    When method get
    Then match [404] contains responseStatus

  Scenario: Content-type defaults to JSON on order create
    Given path 'store', 'order'
    And header Content-Type = 'application/json'
    And request { "id": 1114, "petId": 1012, "quantity": 2, "status": "placed" }
    When method post
    Then status 200
    * match responseHeaders['Content-Type'][0] contains 'application/json'
