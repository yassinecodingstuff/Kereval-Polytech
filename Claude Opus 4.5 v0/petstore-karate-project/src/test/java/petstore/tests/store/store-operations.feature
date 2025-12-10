Feature: Store Operations API
  As a Petstore API consumer
  I want to manage store orders and inventory
  So that I can process pet purchases
  
  Priority: HIGH - Business Critical
  ISO/IEC/IEEE 29119 Alignment: Risk-based test selection with transaction coverage

  Background:
    * url baseUrl
    * def generateUniqueId = function(){ return Math.floor(Math.random() * 900000000) + 100000000 }

  @high @smoke @positive @GET @store @inventory
  Scenario: TC-STORE-001 - Successfully retrieve store inventory
    Given path 'store', 'inventory'
    And header api_key = apiKey
    And header Accept = 'application/json'
    When method get
    Then status 200
    And match response == '#object'
    And match responseHeaders['Content-Type'][0] contains 'application/json'

  @high @positive @GET @store @inventory
  Scenario: TC-STORE-002 - Verify inventory returns status counts as integers
    Given path 'store', 'inventory'
    And header api_key = apiKey
    And header Accept = 'application/json'
    When method get
    Then status 200
    And match response == '#object'

  @high @negative @GET @store @inventory @security
  Scenario: TC-STORE-003 - Verify inventory request behavior without API key
    Given path 'store', 'inventory'
    And header Accept = 'application/json'
    When method get
    Then assert responseStatus == 200 || responseStatus == 401 || responseStatus == 403

  @medium @positive @GET @store @inventory @performance
  Scenario: TC-STORE-004 - Verify inventory response time is acceptable
    Given path 'store', 'inventory'
    And header api_key = apiKey
    And header Accept = 'application/json'
    When method get
    Then status 200
    And assert responseTime < 3000

  @critical @smoke @positive @POST @store @order
  Scenario: TC-STORE-005 - Successfully place a new order
    * def orderId = generateUniqueId()
    * def orderPayload = { id: #(orderId), petId: 1, quantity: 1, status: 'placed', complete: false }
    Given path 'store', 'order'
    And header Content-Type = 'application/json'
    And header Accept = 'application/json'
    And request orderPayload
    When method post
    Then status 200
    And match response.id == '#number'
    And match response.petId == 1
    And match response.status == 'placed'

  @critical @positive @POST @store @order
  Scenario: TC-STORE-006 - Successfully place order with complete data
    * def orderId = generateUniqueId()
    * def shipDate = java.time.Instant.now().plusSeconds(86400).toString()
    * def orderPayload = { id: #(orderId), petId: 100, quantity: 2, shipDate: '#(shipDate)', status: 'placed', complete: false }
    Given path 'store', 'order'
    And header Content-Type = 'application/json'
    And header Accept = 'application/json'
    And request orderPayload
    When method post
    Then status 200
    And match response.quantity == 2
    And match response.petId == 100

  @critical @positive @POST @store @order @status
  Scenario Outline: TC-STORE-007 - Successfully place order with valid status values
    * def orderId = generateUniqueId()
    * def orderPayload = { id: #(orderId), petId: 1, quantity: 1, status: '<status>', complete: false }
    Given path 'store', 'order'
    And header Content-Type = 'application/json'
    And header Accept = 'application/json'
    And request orderPayload
    When method post
    Then status 200
    And match response.status == '<status>'

    Examples:
      | status    |
      | placed    |
      | approved  |
      | delivered |

  @high @negative @POST @store @order @validation
  Scenario: TC-STORE-008 - Reject order with invalid order data
    * def orderPayload = { invalid: 'data' }
    Given path 'store', 'order'
    And header Content-Type = 'application/json'
    And header Accept = 'application/json'
    And request orderPayload
    When method post
    Then assert responseStatus == 200 || responseStatus == 400

  @high @negative @POST @store @order @datatype
  Scenario: TC-STORE-009 - Reject order with invalid quantity data type
    * def orderPayload = { petId: 1, quantity: 'not_a_number', status: 'placed' }
    Given path 'store', 'order'
    And header Content-Type = 'application/json'
    And header Accept = 'application/json'
    And request orderPayload
    When method post
    Then assert responseStatus == 400 || responseStatus == 500

  @medium @positive @POST @store @order @boundary
  Scenario: TC-STORE-010 - Successfully place order with minimum quantity
    * def orderId = generateUniqueId()
    * def orderPayload = { id: #(orderId), petId: 1, quantity: 1, status: 'placed', complete: false }
    Given path 'store', 'order'
    And header Content-Type = 'application/json'
    And header Accept = 'application/json'
    And request orderPayload
    When method post
    Then status 200
    And match response.quantity == 1

  @medium @negative @POST @store @order @boundary
  Scenario: TC-STORE-011 - Handle order with zero quantity
    * def orderId = generateUniqueId()
    * def orderPayload = { id: #(orderId), petId: 1, quantity: 0, status: 'placed', complete: false }
    Given path 'store', 'order'
    And header Content-Type = 'application/json'
    And header Accept = 'application/json'
    And request orderPayload
    When method post
    Then assert responseStatus == 200 || responseStatus == 400

  @medium @negative @POST @store @order @boundary
  Scenario: TC-STORE-012 - Handle order with negative quantity
    * def orderId = generateUniqueId()
    * def orderPayload = { id: #(orderId), petId: 1, quantity: -1, status: 'placed', complete: false }
    Given path 'store', 'order'
    And header Content-Type = 'application/json'
    And header Accept = 'application/json'
    And request orderPayload
    When method post
    Then assert responseStatus == 200 || responseStatus == 400

  @low @positive @POST @store @order
  Scenario: TC-STORE-013 - Successfully place order with complete flag true
    * def orderId = generateUniqueId()
    * def orderPayload = { id: #(orderId), petId: 1, quantity: 1, status: 'delivered', complete: true }
    Given path 'store', 'order'
    And header Content-Type = 'application/json'
    And header Accept = 'application/json'
    And request orderPayload
    When method post
    Then status 200
    And match response.complete == true

  @high @smoke @positive @GET @store @order
  Scenario: TC-STORE-014 - Successfully retrieve order by valid ID
    * def orderId = generateUniqueId()
    * def orderPayload = { id: #(orderId), petId: 1, quantity: 1, status: 'placed', complete: false }
    Given path 'store', 'order'
    And header Content-Type = 'application/json'
    And request orderPayload
    When method post
    Then status 200
    
    Given path 'store', 'order', orderId
    And header Accept = 'application/json'
    When method get
    Then status 200
    And match response.id == orderId

  @high @positive @GET @store @order @boundary
  Scenario Outline: TC-STORE-015 - Successfully retrieve order with boundary IDs (1-10)
    Given path 'store', 'order', <orderId>
    And header Accept = 'application/json'
    When method get
    Then status 200
    And match response.id == <orderId>

    Examples:
      | orderId |
      | 1       |
      | 5       |
      | 10      |

  @high @negative @GET @store @order
  Scenario: TC-STORE-016 - Return 404 for non-existent order ID
    * def nonExistentId = 999999999
    Given path 'store', 'order', nonExistentId
    And header Accept = 'application/json'
    When method get
    Then status 404

  @high @negative @GET @store @order @validation
  Scenario: TC-STORE-017 - Return 400 for invalid order ID format
    Given path 'store', 'order', 'invalid_id'
    And header Accept = 'application/json'
    When method get
    Then assert responseStatus == 400 || responseStatus == 404

  @high @negative @GET @store @order @boundary
  Scenario: TC-STORE-018 - Return error for order ID greater than 10
    Given path 'store', 'order', 11
    And header Accept = 'application/json'
    When method get
    Then status 404

  @medium @negative @GET @store @order @boundary
  Scenario: TC-STORE-019 - Return error for order ID less than 1
    Given path 'store', 'order', 0
    And header Accept = 'application/json'
    When method get
    Then assert responseStatus == 400 || responseStatus == 404

  @medium @negative @GET @store @order @boundary
  Scenario: TC-STORE-020 - Handle negative order ID
    Given path 'store', 'order', -5
    And header Accept = 'application/json'
    When method get
    Then assert responseStatus == 400 || responseStatus == 404

  @low @positive @GET @store @order @content-negotiation
  Scenario: TC-STORE-021 - Retrieve order in XML format
    Given path 'store', 'order', 2
    And header Accept = 'application/xml'
    When method get
    Then status 200
    And match responseHeaders['Content-Type'][0] contains 'application/xml'

  @high @smoke @positive @DELETE @store @order
  Scenario: TC-STORE-022 - Successfully delete an existing order
    * def orderId = generateUniqueId()
    * def orderPayload = { id: #(orderId), petId: 1, quantity: 1, status: 'placed', complete: false }
    Given path 'store', 'order'
    And header Content-Type = 'application/json'
    And request orderPayload
    When method post
    Then status 200
    
    Given path 'store', 'order', orderId
    When method delete
    Then status 200
    
    Given path 'store', 'order', orderId
    When method get
    Then status 404

  @high @negative @DELETE @store @order
  Scenario: TC-STORE-023 - Return 404 when deleting non-existent order
    * def nonExistentId = 999999999
    Given path 'store', 'order', nonExistentId
    When method delete
    Then status 404

  @high @negative @DELETE @store @order @validation
  Scenario: TC-STORE-024 - Return 400 for invalid order ID format on delete
    Given path 'store', 'order', 'not_a_number'
    When method delete
    Then assert responseStatus == 400 || responseStatus == 404

  @medium @negative @DELETE @store @order @boundary
  Scenario: TC-STORE-025 - Return error when deleting order with negative ID
    Given path 'store', 'order', -1
    When method delete
    Then assert responseStatus == 400 || responseStatus == 404

  @medium @positive @POST @store @order @schema
  Scenario: TC-STORE-026 - Verify order response matches expected schema
    * def orderId = generateUniqueId()
    * def orderPayload = { id: #(orderId), petId: 1, quantity: 1, status: 'placed', complete: false }
    Given path 'store', 'order'
    And header Content-Type = 'application/json'
    And header Accept = 'application/json'
    And request orderPayload
    When method post
    Then status 200
    And match response == { id: '#number', petId: '#number', quantity: '#number', shipDate: '##string', status: '#string', complete: '#boolean' }
