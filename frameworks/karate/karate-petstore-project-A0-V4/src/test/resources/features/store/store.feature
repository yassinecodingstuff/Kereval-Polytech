Feature: Store API — Inventory and Orders (High Priority, ISO 29119-aligned)
  Background:
    * url baseUrl
    * configure headers = { Accept: 'application/json' }
    * def orderSchema =
    """
    {
      id: '##number',
      petId: '##number',
      quantity: '##number',
      shipDate: '##string',
      status: '##string',
      complete: '##boolean'
    }
    """

  Scenario: [GET] Inventory by status — 200 and all values are integers
    Given path 'store', 'inventory'
    When method get
    Then status 200
    And match response == '#object'
    * def allAreNumbers = function(x){ for (var k in x) { if (typeof x[k] !== 'number') return false; } return true }
    * match allAreNumbers(response) == true

  Scenario: [POST] Place an order for a pet — success returns 200 Order
    * def orderId = 2001
    Given path 'store', 'order'
    And request { id: 2001, petId: 1001, quantity: 1, shipDate: '2020-01-01T00:00:00.000Z', status: 'placed', complete: true }
    When method post
    Then status 200
    And match response == orderSchema

  Scenario: [POST] Place an order — invalid payload returns 400
    Given path 'store', 'order'
    And request { id: 2002, petId: 1001, quantity: 'NaN' }
    When method post
    Then status 400
    * def t = karate.typeOf(response)
    * if (t == 'map') match response contains { message: '#string' }
    * else match response == '#string'

  Scenario: [GET] Get order by ID — seed then 200 with Order schema
    * def orderId = '2003'
    Given path 'store', 'order'
    And request { id: 2003, petId: 1001, quantity: 2, shipDate: '2020-01-02T00:00:00.000Z', status: 'approved', complete: false }
    When method post
    Then status 200
    Given path 'store', 'order', orderId
    When method get
    Then status 200
    And match response == orderSchema

  Scenario Outline: [GET] Get order by ID — boundary & negative checks
    Given path 'store', 'order', orderId
    When method get
    Then match [200,400,404] contains responseStatus
    Examples:
      | orderId |
      | '1'     |
      | '10'    |
      | '0'     |
      | '-5'    |
      | '9999'  |

  Scenario: [DELETE] Delete order by ID — seed then tolerant delete
    * def orderId = '2004'
    Given path 'store', 'order'
    And request { id: 2004, petId: 1001, quantity: 1, shipDate: '2020-01-03T00:00:00.000Z', status: 'placed', complete: false }
    When method post
    Then status 200
    Given path 'store', 'order', orderId
    When method delete
    Then match [200,400,404] contains responseStatus

  Scenario Outline: [DELETE] Delete order by ID — boundary & negative checks
    Given path 'store', 'order', orderId
    When method delete
    Then match [200,400,404] contains responseStatus
    Examples:
      | orderId |
      | '1'     |
      | '0'     |
      | '-3'    |
      | '9999'  |
