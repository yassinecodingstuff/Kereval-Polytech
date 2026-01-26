Feature: Store order management (inventory, order placement, and fulfillment)
  Background:
    * def baseUrl = 'https://petstore.swagger.io/v2'
    * url baseUrl
    * configure headers = { Accept: 'application/json' }
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
    * def apiResponseSchema =
    """
    {
      code: '##number',
      type: '##string',
      message: '##string'
    }
    """

  @critical @store @inventory @security
  Scenario: Get inventory by status with api_key and validate structure
    * configure headers = { Accept: 'application/json', api_key: 'special-key' }
    Given path 'store', 'inventory'
    When method get
    Then status 200
    And match response == '#object'
    * def keys = karate.keysOf(response)
    * match each keys contains '#? ["available","pending","sold"].includes(_ )'
    * match each response[*] == '#? _ >= 0'

  @critical @store @order @schema
  Scenario: Place an order for a pet and verify retrieval
    * configure headers = { Accept: 'application/json', Content-Type: 'application/json' }
    * def order =
    """
    {
      "id": 7001,
      "petId": 9223372036854710001,
      "quantity": 2,
      "shipDate": "2025-10-01T09:00:00.000Z",
      "status": "placed",
      "complete": true
    }
    """
    Given path 'store', 'order'
    And request order
    When method post
    Then status 200
    And match response == orderSchema
    And match response.status == 'placed'
    Given path 'store', 'order', 7001
    When method get
    Then status 200
    And match response == orderSchema
    And match response.quantity == 2

  @high @store @order @negative
  Scenario: Get order by non-existing id returns 404
    * configure headers = { Accept: 'application/json' }
    Given path 'store', 'order', 9999999
    When method get
    Then status 404

  @high @store @order @negative @validation
  Scenario Outline: Place an order with invalid payload should be rejected
    * configure headers = { Accept: 'application/json', Content-Type: 'application/json' }
    * def badOrder =
    """
    {
      id: <id>,
      petId: <petId>,
      quantity: <quantity>,
      shipDate: <shipDate>,
      status: <status>,
      complete: <complete>
    }
    """
    Given path 'store', 'order'
    And request badOrder
    When method post
    Then status 400
    Examples:
      | id   | petId | quantity | shipDate                   | status    | complete |
      | 7002 | null  | 1        | "2025-10-01T09:00:00.000Z" | "placed"  | true     |
      | 7003 | 1     | -1       | "2025-10-01T09:00:00.000Z" | "placed"  | false    |
      | 7004 | 1     | 1        | "invalid"                  | "placed"  | false    |
      | 7005 | 1     | 1        | "2025-10-01T09:00:00.000Z" | "bad"     | false    |

  @high @store @order @delete
  Scenario: Delete an existing order
    * configure headers = { Accept: 'application/json', Content-Type: 'application/json' }
    * def order =
    """
    {
      "id": 7006,
      "petId": 9223372036854710001,
      "quantity": 1,
      "shipDate": "2025-10-01T09:00:00.000Z",
      "status": "placed",
      "complete": false
    }
    """
    Given path 'store', 'order'
    And request order
    When method post
    Then status 200
    Given path 'store', 'order', 7006
    When method delete
    Then status 200
    Given path 'store', 'order', 7006
    When method get
    Then status 404

  @medium @store @order @negative
  Scenario Outline: Delete order with invalid id returns client error
    * configure headers = { Accept: 'application/json' }
    Given path 'store', 'order', <orderId>
    When method delete
    Then status 400
    Examples:
      | orderId |
      | -1      |
      | 0       |
      | 'abc'   |
