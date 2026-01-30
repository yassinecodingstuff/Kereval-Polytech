Feature: Store API - Order Operations
  As a pet store customer
  I need to place and manage orders
  So that I can purchase pets from the store

  Background:
    * url baseUrl
    * def generatePetId = function(){ return Math.floor(Math.random() * 900000) + 100000 }
    * def currentDateTime = function(){ return new Date().toISOString() }

  @critical @smoke @store @order @create
  Scenario: TC-STORE-004 - Successfully place a new order
    * def petId = generatePetId()
    * def shipDate = currentDateTime()
    Given path 'store', 'order'
    And header Content-Type = 'application/json'
    And request
      """
      {
        "petId": #(petId),
        "quantity": 1,
        "shipDate": "#(shipDate)",
        "status": "placed",
        "complete": false
      }
      """
    When method POST
    Then status 200
    And match response.id == '#number'
    And match response.petId == petId
    And match response.quantity == 1
    And match response.status == 'placed'
    And match response.complete == false

  @store @order @create
  Scenario: TC-STORE-005 - Place order with approved status
    * def petId = generatePetId()
    Given path 'store', 'order'
    And header Content-Type = 'application/json'
    And request
      """
      {
        "petId": #(petId),
        "quantity": 2,
        "status": "approved",
        "complete": false
      }
      """
    When method POST
    Then status 200
    And match response.status == 'approved'

  @store @order @create
  Scenario: TC-STORE-006 - Place order with delivered status
    * def petId = generatePetId()
    Given path 'store', 'order'
    And header Content-Type = 'application/json'
    And request
      """
      {
        "petId": #(petId),
        "quantity": 1,
        "status": "delivered",
        "complete": true
      }
      """
    When method POST
    Then status 200
    And match response.status == 'delivered'

  @store @order @create
  Scenario: TC-STORE-007 - Place order marked as complete
    * def petId = generatePetId()
    Given path 'store', 'order'
    And header Content-Type = 'application/json'
    And request
      """
      {
        "petId": #(petId),
        "quantity": 1,
        "status": "delivered",
        "complete": true
      }
      """
    When method POST
    Then status 200
    And match response.complete == true

  @negative @store @order @create @validation
  Scenario: TC-STORE-008 - Handle order with invalid payload
    Given path 'store', 'order'
    And header Content-Type = 'application/json'
    And request
      """
      {
        "invalid": "payload"
      }
      """
    When method POST
    Then assert responseStatus == 200 || responseStatus == 400

  @store @order @create @boundary
  Scenario: TC-STORE-009 - Place order with maximum quantity
    * def petId = generatePetId()
    Given path 'store', 'order'
    And header Content-Type = 'application/json'
    And request
      """
      {
        "petId": #(petId),
        "quantity": 2147483647,
        "status": "placed",
        "complete": false
      }
      """
    When method POST
    Then status 200
    And match response.quantity == 2147483647

  @negative @store @order @create @boundary
  Scenario: TC-STORE-010 - Handle order with negative quantity
    * def petId = generatePetId()
    Given path 'store', 'order'
    And header Content-Type = 'application/json'
    And request
      """
      {
        "petId": #(petId),
        "quantity": -1,
        "status": "placed",
        "complete": false
      }
      """
    When method POST
    Then assert responseStatus == 200 || responseStatus == 400

  @store @order @create @datatype
  Scenario: TC-STORE-011 - Verify order ID is returned as int64 format
    * def petId = generatePetId()
    Given path 'store', 'order'
    And header Content-Type = 'application/json'
    And request
      """
      {
        "petId": #(petId),
        "quantity": 1,
        "status": "placed",
        "complete": false
      }
      """
    When method POST
    Then status 200
    And match response.id == '#number'

  @store @order @create @content-type
  Scenario: TC-STORE-012 - Place order and receive XML response
    * def petId = generatePetId()
    Given path 'store', 'order'
    And header Content-Type = 'application/json'
    And header Accept = 'application/xml'
    And request
      """
      {
        "petId": #(petId),
        "quantity": 1,
        "status": "placed",
        "complete": false
      }
      """
    When method POST
    Then status 200
    And match header Content-Type contains 'application/xml'

  @critical @smoke @store @order @read
  Scenario: TC-STORE-013 - Successfully retrieve order by valid ID
    * def petId = generatePetId()
    # Create an order first
    Given path 'store', 'order'
    And request { petId: #(petId), quantity: 1, status: 'placed', complete: false }
    When method POST
    Then status 200
    * def orderId = response.id
    
    # Retrieve the order
    Given path 'store', 'order', orderId
    When method GET
    Then status 200
    And match response contains { id: '#number', petId: '#number', quantity: '#number' }

  @store @order @read @boundary
  Scenario: TC-STORE-014 - Retrieve order with minimum valid ID
    Given path 'store', 'order', 1
    When method GET
    Then assert responseStatus == 200 || responseStatus == 404

  @store @order @read @boundary
  Scenario: TC-STORE-015 - Retrieve order with maximum valid ID
    Given path 'store', 'order', 10
    When method GET
    Then assert responseStatus == 200 || responseStatus == 404

  @negative @store @order @read @boundary
  Scenario: TC-STORE-016 - Reject request for order ID below minimum
    Given path 'store', 'order', 0
    When method GET
    Then assert responseStatus == 400 || responseStatus == 404

  @negative @store @order @read @boundary
  Scenario: TC-STORE-017 - Return 404 for order ID above maximum valid range
    Given path 'store', 'order', 11
    When method GET
    Then status 404

  @negative @store @order @read @validation
  Scenario: TC-STORE-018 - Return error for invalid order ID format
    Given path 'store', 'order', 'invalid_id'
    When method GET
    Then assert responseStatus == 400 || responseStatus == 404

  @negative @store @order @read @validation
  Scenario: TC-STORE-019 - Return 404 for non-existent order
    Given path 'store', 'order', 999999999
    When method GET
    Then status 404

  @store @order @read @content-negotiation
  Scenario: TC-STORE-020 - Retrieve order in XML format
    * def petId = generatePetId()
    Given path 'store', 'order'
    And request { petId: #(petId), quantity: 1, status: 'placed', complete: false }
    When method POST
    Then status 200
    * def orderId = response.id
    
    Given path 'store', 'order', orderId
    And header Accept = 'application/xml'
    When method GET
    Then status 200
    And match header Content-Type contains 'application/xml'

  @critical @store @order @delete
  Scenario: TC-STORE-021 - Successfully delete an existing order
    * def petId = generatePetId()
    # Create order
    Given path 'store', 'order'
    And request { petId: #(petId), quantity: 1, status: 'placed', complete: false }
    When method POST
    Then status 200
    * def orderId = response.id
    
    # Delete order
    Given path 'store', 'order', orderId
    When method DELETE
    Then status 200
    
    # Verify deletion
    Given path 'store', 'order', orderId
    When method GET
    Then status 404

  @negative @store @order @delete @validation
  Scenario: TC-STORE-022 - Return 404 when deleting non-existent order
    Given path 'store', 'order', 999999999
    When method DELETE
    Then status 404

  @negative @store @order @delete @validation
  Scenario: TC-STORE-023 - Handle invalid order ID on delete
    Given path 'store', 'order', 'invalid_id'
    When method DELETE
    Then assert responseStatus == 400 || responseStatus == 404

  @negative @store @order @delete @boundary
  Scenario: TC-STORE-024 - Handle delete with negative order ID
    Given path 'store', 'order', -5
    When method DELETE
    Then assert responseStatus == 400 || responseStatus == 404

  @store @order @delete @idempotency
  Scenario: TC-STORE-025 - Verify DELETE idempotency behavior
    * def petId = generatePetId()
    # Create order
    Given path 'store', 'order'
    And request { petId: #(petId), quantity: 1, status: 'placed', complete: false }
    When method POST
    Then status 200
    * def orderId = response.id
    
    # First delete
    Given path 'store', 'order', orderId
    When method DELETE
    Then status 200
    
    # Second delete (should be 404)
    Given path 'store', 'order', orderId
    When method DELETE
    Then status 404

  @store @order @status-enum
  Scenario Outline: TC-STORE-ENUM-001 - Order status accepts valid enum values
    * def petId = generatePetId()
    Given path 'store', 'order'
    And header Content-Type = 'application/json'
    And request
      """
      {
        "petId": #(petId),
        "quantity": 1,
        "status": "<status>",
        "complete": false
      }
      """
    When method POST
    Then status <expected_status>

    Examples:
      | status    | expected_status |
      | placed    | 200             |
      | approved  | 200             |
      | delivered | 200             |

  @store @order @performance
  Scenario: TC-STORE-PERF-001 - Order creation responds within acceptable time
    * def petId = generatePetId()
    Given path 'store', 'order'
    And request { petId: #(petId), quantity: 1, status: 'placed', complete: false }
    When method POST
    Then status 200
    And assert responseTime < 3000
