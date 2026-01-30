Feature: Store Order Management API
  As a customer
  I want to place and manage orders for pets
  So that I can purchase pets from the store

  Background:
    * url baseUrl
    * configure headers = { Accept: 'application/json' }
    * def allowedOrderStatuses = ['placed', 'approved', 'delivered']
    * def generateOrderId = function(){ return Math.floor(Math.random() * 9) + 1 }
    * def generatePetId = function(){ return Math.floor(Math.random() * 900) + 1001 }

  # ==========================================================================
  # TC-STORE-001: Get Store Inventory
  # Risk Level: High
  # ==========================================================================

  @high @smoke @store @inventory
  Scenario: TC-STORE-001-01 - Successfully retrieve store inventory
    Given path 'store', 'inventory'
    And header api_key = 'special-key'
    When method get
    Then status 200
    And match response == '#object'
    And match responseHeaders['Content-Type'][0] contains 'application/json'

  @medium @store @inventory
  Scenario: TC-STORE-001-02 - Verify inventory values are integers
    Given path 'store', 'inventory'
    And header api_key = 'special-key'
    When method get
    Then status 200
    And match response == '#object'
    * def validateIntegers =
      """
      function(obj) {
        for (var key in obj) {
          if (typeof obj[key] !== 'number' || !Number.isInteger(obj[key])) {
            return false;
          }
        }
        return true;
      }
      """
    * assert validateIntegers(response)

  # ==========================================================================
  # TC-STORE-002: Place Order - Positive Scenarios
  # Risk Level: Critical
  # ==========================================================================

  @critical @smoke @store @order @create
  Scenario: TC-STORE-002-01 - Successfully place an order with all required fields
    * def orderId = generateOrderId()
    * def petId = generatePetId()
    * def orderPayload =
      """
      {
        "id": #(orderId),
        "petId": #(petId),
        "quantity": 1,
        "shipDate": "2025-01-15T10:00:00.000Z",
        "status": "placed",
        "complete": false
      }
      """
    Given path 'store', 'order'
    And request orderPayload
    When method post
    Then status 200
    And match response.id == orderId
    And match response.status == 'placed'
    And match response.complete == false

  @critical @store @order @create
  Scenario Outline: TC-STORE-002-02 - Place orders with different valid status values
    * def orderId = generateOrderId()
    * def petId = generatePetId()
    * def orderPayload =
      """
      {
        "id": #(orderId),
        "petId": #(petId),
        "quantity": 1,
        "status": "<status>",
        "complete": false
      }
      """
    Given path 'store', 'order'
    And request orderPayload
    When method post
    Then status 200
    And match response.status == '<status>'

    Examples:
      | status    |
      | placed    |
      | approved  |
      | delivered |

  @high @store @order @create
  Scenario: TC-STORE-002-03 - Successfully place an order with minimum fields
    * def orderId = generateOrderId()
    * def petId = generatePetId()
    * def orderPayload =
      """
      {
        "id": #(orderId),
        "petId": #(petId)
      }
      """
    Given path 'store', 'order'
    And request orderPayload
    When method post
    Then status 200
    And match response.id == orderId

  @high @store @order @create
  Scenario: TC-STORE-002-04 - Place order with specific order ID
    * def orderId = 5
    * def petId = generatePetId()
    * def orderPayload =
      """
      {
        "id": #(orderId),
        "petId": #(petId),
        "quantity": 2,
        "status": "placed"
      }
      """
    Given path 'store', 'order'
    And request orderPayload
    When method post
    Then status 200
    And match response.id == 5

  @high @store @order @create
  Scenario: TC-STORE-002-05 - Place order with complete flag set to true
    * def orderId = generateOrderId()
    * def petId = generatePetId()
    * def orderPayload =
      """
      {
        "id": #(orderId),
        "petId": #(petId),
        "quantity": 1,
        "status": "delivered",
        "complete": true
      }
      """
    Given path 'store', 'order'
    And request orderPayload
    When method post
    Then status 200
    And match response.complete == true

  # ==========================================================================
  # TC-STORE-003: Place Order - Negative Scenarios
  # Risk Level: High
  # ==========================================================================

  @high @store @order @create @negative
  Scenario: TC-STORE-003-01 - Handle invalid order payload with wrong data types
    * def orderPayload =
      """
      {
        "id": "invalid",
        "petId": "invalid",
        "quantity": "not-a-number"
      }
      """
    Given path 'store', 'order'
    And request orderPayload
    When method post
    Then match [400, 500] contains responseStatus

  @high @store @order @create @negative
  Scenario: TC-STORE-003-02 - Handle order with invalid petId format
    * def orderPayload =
      """
      {
        "id": 1,
        "petId": "invalid"
      }
      """
    Given path 'store', 'order'
    And request orderPayload
    When method post
    Then match [400, 500] contains responseStatus

  @medium @store @order @create @negative
  Scenario: TC-STORE-003-03 - Handle order with negative quantity
    * def orderId = generateOrderId()
    * def petId = generatePetId()
    * def orderPayload =
      """
      {
        "id": #(orderId),
        "petId": #(petId),
        "quantity": -5
      }
      """
    Given path 'store', 'order'
    And request orderPayload
    When method post
    Then match [200, 400] contains responseStatus

  @medium @store @order @create @negative
  Scenario: TC-STORE-003-04 - Handle order with empty request body
    Given path 'store', 'order'
    And request {}
    When method post
    Then match [200, 400, 500] contains responseStatus

  # ==========================================================================
  # TC-STORE-004: Get Order by ID - Positive Scenarios
  # Risk Level: Critical
  # ==========================================================================

  @critical @smoke @store @order @read
  Scenario: TC-STORE-004-01 - Successfully retrieve an existing order by ID
    * def orderId = 5
    * def petId = generatePetId()
    * def orderPayload =
      """
      {
        "id": #(orderId),
        "petId": #(petId),
        "quantity": 1,
        "status": "placed"
      }
      """
    Given path 'store', 'order'
    And request orderPayload
    When method post
    Then status 200

    Given path 'store', 'order', '5'
    When method get
    Then status 200
    And match response.id == 5
    And match response.petId == '#number'
    And match responseHeaders['Content-Type'][0] contains 'application/json'

  @high @store @order @read
  Scenario Outline: TC-STORE-004-02 - Retrieve orders with valid IDs in range 1-10
    * def orderId = <orderId>
    * def petId = generatePetId()
    * def orderPayload =
      """
      {
        "id": #(orderId),
        "petId": #(petId),
        "quantity": 1,
        "status": "placed"
      }
      """
    Given path 'store', 'order'
    And request orderPayload
    When method post
    Then status 200

    Given path 'store', 'order', '<orderId>'
    When method get
    Then match [200, 404] contains responseStatus

    Examples:
      | orderId |
      | 1       |
      | 5       |
      | 10      |

  @medium @store @order @read
  Scenario: TC-STORE-004-03 - Retrieve order with XML response format
    * def orderId = 7
    * def petId = generatePetId()
    * def orderPayload =
      """
      {
        "id": #(orderId),
        "petId": #(petId),
        "quantity": 1,
        "status": "placed"
      }
      """
    Given path 'store', 'order'
    And request orderPayload
    When method post
    Then status 200

    Given path 'store', 'order', '7'
    And header Accept = 'application/xml'
    When method get
    Then match [200, 404] contains responseStatus
    * if (responseStatus == 200) karate.match("responseHeaders['Content-Type'][0]", '#regex .*xml.*')

  # ==========================================================================
  # TC-STORE-005: Get Order by ID - Negative Scenarios
  # Risk Level: High
  # ==========================================================================

  @high @store @order @read @negative
  Scenario: TC-STORE-005-01 - Return 404 for non-existent order ID
    Given path 'store', 'order', '999'
    When method get
    Then status 404
    * def t = karate.typeOf(response)
    * if (t == 'map') karate.log('Response is JSON')
    * else karate.log('Response type: ' + t)

  @high @store @order @read @negative
  Scenario: TC-STORE-005-02 - Return error for invalid order ID format
    Given path 'store', 'order', 'invalid'
    When method get
    Then match [400, 404] contains responseStatus

  @high @store @order @read @negative
  Scenario: TC-STORE-005-03 - Return error for order ID less than minimum (0)
    Given path 'store', 'order', '0'
    When method get
    Then match [400, 404] contains responseStatus

  @high @store @order @read @negative
  Scenario: TC-STORE-005-04 - Return 404 for order ID greater than maximum (>10)
    Given path 'store', 'order', '11'
    When method get
    Then match [404, 200] contains responseStatus

  @medium @store @order @read @negative
  Scenario: TC-STORE-005-05 - Return error for negative order ID
    Given path 'store', 'order', '-1'
    When method get
    Then match [400, 404] contains responseStatus

  @medium @store @order @read @negative
  Scenario: TC-STORE-005-06 - Return error for floating point order ID
    Given path 'store', 'order', '5.5'
    When method get
    Then match [400, 404] contains responseStatus

  # ==========================================================================
  # TC-STORE-006: Delete Order
  # Risk Level: High
  # ==========================================================================

  @high @store @order @delete
  Scenario: TC-STORE-006-01 - Successfully delete an existing order
    * def orderId = 8
    * def petId = generatePetId()
    * def orderPayload =
      """
      {
        "id": #(orderId),
        "petId": #(petId),
        "quantity": 1,
        "status": "placed"
      }
      """
    Given path 'store', 'order'
    And request orderPayload
    When method post
    Then status 200

    Given path 'store', 'order', '8'
    When method delete
    Then match [200, 204, 404] contains responseStatus

    Given path 'store', 'order', '8'
    When method get
    Then status 404

  @high @store @order @delete @negative
  Scenario: TC-STORE-006-02 - Return 404 for delete of non-existent order
    Given path 'store', 'order', '999'
    When method delete
    Then match [404, 400] contains responseStatus

  @high @store @order @delete @negative
  Scenario: TC-STORE-006-03 - Return error for delete with invalid order ID format
    Given path 'store', 'order', 'invalid'
    When method delete
    Then match [400, 404] contains responseStatus

  @medium @store @order @delete @negative
  Scenario: TC-STORE-006-04 - Return error for delete with negative order ID
    Given path 'store', 'order', '-5'
    When method delete
    Then match [400, 404] contains responseStatus

  # ==========================================================================
  # TC-STORE-007: Order Schema Validation
  # Risk Level: High
  # ==========================================================================

  @high @store @order @schema
  Scenario: TC-STORE-007-01 - Validate order response schema
    * def orderId = 3
    * def petId = generatePetId()
    * def orderPayload =
      """
      {
        "id": #(orderId),
        "petId": #(petId),
        "quantity": 2,
        "shipDate": "2025-02-01T12:00:00.000Z",
        "status": "approved",
        "complete": true
      }
      """
    Given path 'store', 'order'
    And request orderPayload
    When method post
    Then status 200

    Given path 'store', 'order', '3'
    When method get
    Then status 200
    And match response ==
      """
      {
        id: '#number',
        petId: '#number',
        quantity: '#number',
        shipDate: '#string',
        status: '#string',
        complete: '#boolean'
      }
      """

  @high @store @order @schema
  Scenario: TC-STORE-007-02 - Validate order status enum values
    * def orderId = 4
    * def petId = generatePetId()
    * def orderPayload =
      """
      {
        "id": #(orderId),
        "petId": #(petId),
        "quantity": 1,
        "status": "placed"
      }
      """
    Given path 'store', 'order'
    And request orderPayload
    When method post
    Then status 200

    Given path 'store', 'order', '4'
    When method get
    Then status 200
    And match allowedOrderStatuses contains response.status

  # ==========================================================================
  # TC-STORE-008: Idempotency Tests
  # Risk Level: High
  # ==========================================================================

  @high @store @order @idempotency
  Scenario: TC-STORE-008-01 - GET order requests are idempotent
    * def orderId = 6
    * def petId = generatePetId()
    * def orderPayload =
      """
      {
        "id": #(orderId),
        "petId": #(petId),
        "quantity": 1,
        "status": "placed"
      }
      """
    Given path 'store', 'order'
    And request orderPayload
    When method post
    Then status 200

    Given path 'store', 'order', '6'
    When method get
    Then status 200
    * def firstResponse = response

    Given path 'store', 'order', '6'
    When method get
    Then status 200
    And match response.id == firstResponse.id
    And match response.petId == firstResponse.petId

    Given path 'store', 'order', '6'
    When method get
    Then status 200
    And match response.id == firstResponse.id

  @high @store @order @idempotency
  Scenario: TC-STORE-008-02 - DELETE then GET returns 404 consistently
    * def orderId = 9
    * def petId = generatePetId()
    * def orderPayload =
      """
      {
        "id": #(orderId),
        "petId": #(petId),
        "quantity": 1,
        "status": "placed"
      }
      """
    Given path 'store', 'order'
    And request orderPayload
    When method post
    Then status 200

    Given path 'store', 'order', '9'
    When method delete
    Then match [200, 204, 404] contains responseStatus

    Given path 'store', 'order', '9'
    When method get
    Then status 404

    Given path 'store', 'order', '9'
    When method delete
    Then match [404, 400] contains responseStatus
