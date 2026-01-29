Feature: Store — Orders and Inventory

Background:
  * url baseUrl
  * configure headers = { Accept: 'application/json' }

@P0 @order @create @schema
Scenario: [TC-STORE-001] Place a new order returns Order with correct fields
  * def orderId = '1201'
  Given path 'store', 'order'
  And request
  """
  {
    "id": 1201,
    "petId": 1102,
    "quantity": 2,
    "shipDate": "2025-01-01T00:00:00.000Z",
    "status": "placed",
    "complete": true
  }
  """
  When method post
  Then status 200
  And match response ==
  """
  {
    "id": 1201,
    "petId": "#number",
    "quantity": "#number",
    "##shipDate": "#string",
    "status": "#? ['placed','approved','delivered'].includes(_)",
    "complete": "#boolean"
  }
  """

@P0 @order @read @boundary
Scenario Outline: [TC-STORE-002] Get order by ID within allowed range (1..10) returns 200
  * def oid = '<orderId>'
  Given path 'store', 'order', oid
  When method get
  Then status 200
  And match response ==
  """
  {
    "id": "#number",
    "petId": "#number",
    "quantity": "#number",
    "##shipDate": "#string",
    "status": "#? ['placed','approved','delivered'].includes(_)",
    "complete": "#boolean"
  }
  """

  Examples:
    | orderId |
    | '1'     |
    | '5'     |
    | '10'    |

@P0 @order @negative @boundary
Scenario: [TC-STORE-003] Get order by ID below minimum returns 400 Invalid ID supplied
  Given path 'store', 'order', '0'
  When method get
  Then status 400
  And match response.message contains 'Invalid ID supplied'

@P0 @order @negative @boundary
Scenario: [TC-STORE-004] Get order by ID out of documented range returns 404 Order not found
  Given path 'store', 'order', '11'
  When method get
  Then status 404
  And match response.message contains 'Order not found'

@P0 @order @delete @notFound
Scenario: [TC-STORE-005] Delete order then verify it is not retrievable
  * def oid = '7'
  Given path 'store', 'order', oid
  When method delete
  Then match [200,204] contains responseStatus
  Given path 'store', 'order', oid
  When method get
  Then status 404

@P0 @inventory @schema
Scenario: [TC-STORE-006] Get inventory returns a map of status to integer quantities
  Given path 'store', 'inventory'
  When method get
  Then status 200
  And match response == '#object'
  * def values = Object.keys(response).map(k => response[k])
  And match values == '#[] #number'
  * def keys = Object.keys(response)
  And match keys == '#[] #string'

@P0 @validation @types
Scenario: [TC-STORE-007] Order type fields conform to schema
  Given path 'store', 'order', '1'
  When method get
  Then status 200
  And match response.quantity == '#number'
  And match response.complete == '#boolean'
  And match response.shipDate == '##string'
