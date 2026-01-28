Feature: Store API - Orders and Inventory

  Background:
    * url baseUrl
    * header Accept = 'application/json'
    * def uuid = function(){ return java.util.UUID.randomUUID() + '' }
    * def newId = function(){ return Math.floor( (java.lang.System.currentTimeMillis() % 1000000000) + (Math.random()*100000) ) }

  # --- CRITICAL / HAPPY PATHS ---

  Scenario: Place an order for a pet via POST /store/order
    * def petId = newId()
    Given path 'pet'
    And request { id: #(petId), name: 'Pet-For-Order', photoUrls: ['https://example.com/p.png'], status: 'available' }
    When method post
    Then status 200
    Given path 'store', 'order'
    And request
    """
    {
      "id": 1,
      "petId": #(petId),
      "quantity": 1,
      "shipDate": "2025-01-01T10:00:00Z",
      "status": "placed",
      "complete": false
    }
    """
    When method post
    Then status 200
    And match response.petId == petId
    And match response.status == 'placed'

  Scenario Outline: Retrieve order by ID within documented bounds via GET /store/order/{orderId}
    Given path 'store', 'order', <orderId>
    When method get
    Then status 200
    And match response.id == <orderId>
    Examples:
      | orderId |
      | 1       |
      | 10      |

  Scenario Outline: Reject order retrieval with invalid IDs via GET /store/order/{orderId}
    Given path 'store', 'order', <orderId>
    When method get
    Then status 400
    Examples:
      | orderId |
      | 0       |
      | -1      |
      | 11      |
      | 'abc'   |

  Scenario: Delete an existing order via DELETE /store/order/{orderId}
    * def petId = newId()
    Given path 'pet'
    And request { id: #(petId), name: 'Pet-For-Delete-Order', photoUrls: ['https://example.com/p2.png'], status: 'available' }
    When method post
    Then status 200
    Given path 'store', 'order'
    And request { id: 2, petId: #(petId), quantity: 1, shipDate: '2025-01-01T10:00:00Z', status: 'placed', complete: false }
    When method post
    Then status 200
    Given path 'store', 'order', 2
    When method delete
    Then status 200
    Given path 'store', 'order', 2
    When method get
    Then status 404

  Scenario Outline: Reject order deletion with invalid IDs via DELETE /store/order/{orderId}
    Given path 'store', 'order', <orderId>
    When method delete
    Then status 400
    Examples:
      | orderId |
      | 0       |
      | -5      |
      | 'abc'   |

  Scenario: Get pet inventories by status via GET /store/inventory
    * header api_key = 'special-key'
    Given path 'store', 'inventory'
    When method get
    Then status 200
    And match response == '#object'
    And match each response.* == '#number'

  # --- ADDITIONAL VALIDATION / BOUNDARIES ---

  Scenario Outline: Place order with boundary and allowed statuses via POST /store/order
    * def petId = newId()
    Given path 'pet'
    And request { id: #(petId), name: 'Pet-For-Boundary', photoUrls: ['https://example.com/p3.png'], status: 'available' }
    When method post
    Then status 200
    Given path 'store', 'order'
    And request
    """
    {
      "id": 3,
      "petId": #(petId),
      "quantity": <qty>,
      "shipDate": "2025-01-01T10:00:00Z",
      "status": "<status>",
      "complete": false
    }
    """
    When method post
    Then status 200
    Examples:
      | qty | status    |
      | 1   | placed    |
      | 0   | placed    |
      | 1   | approved  |
      | 1   | delivered |
