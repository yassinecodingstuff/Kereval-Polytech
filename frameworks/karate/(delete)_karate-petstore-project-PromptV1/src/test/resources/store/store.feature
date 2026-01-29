Feature: Store API v2 - Order lifecycle, inventory, and ID bounds

  Background:
    * url 'https://petstore.swagger.io/v2'
    * configure headers = { Accept: 'application/json' }
    * def randId = function(){ return Math.floor(Math.random()*900000000) + 1 }
    * def orderSchema =
    """
    {
      id: '#number',
      petId: '#number',
      quantity: '#number',
      shipDate: '#? _ == null || typeof _ == "string"',
      status: '#string',
      complete: '#? _ == null || typeof _ == "boolean"'
    }
    """

  @store @positive @critical @schema
  Scenario: Place order, retrieve it, and delete it
    * def oid = Math.floor(Math.random()*10) + 1
    * def petId = randId()
    Given path 'pet'
    And request { id: #(petId), name: 'for-order', photoUrls: ['u'] }
    When method post
    Then status 200

    Given path 'store/order'
    And request { id: #(oid), petId: #(petId), quantity: 2, status: 'placed', complete: true }
    When method post
    Then status 200
    And match response == orderSchema
    And match response.id == oid

    Given path 'store/order', oid
    When method get
    Then status 200
    And match response == orderSchema
    And match response.petId == petId

    Given path 'store/order', oid
    When method delete
    Then status 200

    Given path 'store/order', oid
    When method get
    Then status 404

  @store @positive @security
  Scenario: Get inventory with API key
    Given path 'store/inventory'
    And header api_key = 'special-key'
    When method get
    Then status 200
    And match response == '#object'

  @store @negative @security
  Scenario: Get inventory without API key -> 401
    Given path 'store/inventory'
    When method get
    Then status 401

  @store @negative @validation
  Scenario Outline: Get order by id with invalid id -> 400
    Given path 'store/order', <bad>
    When method get
    Then status 400
    Examples:
      | bad  |
      | 'abc'|
      | -1   |
      | 0    |

  @store @negative
  Scenario Outline: Get order by id out of allowed range -> 404
    Given path 'store/order', <oid>
    When method get
    Then status 404
    Examples:
      | oid |
      | 11  |
      | 999 |

  @store @positive
  Scenario: Delete non-existing order id returns 404 after prior deletion
    * def oid = Math.floor(Math.random()*10) + 1
    Given path 'store/order'
    And request { id: #(oid), petId: 100, quantity: 1, status: 'placed' }
    When method post
    Then status 200

    Given path 'store/order', oid
    When method delete
    Then status 200

    Given path 'store/order', oid
    When method delete
    Then status 404

  @store @negative @validation
  Scenario: Delete order with invalid id format -> 400
    Given path 'store/order', 'abc'
    When method delete
    Then status 400

  @store @negative
  Scenario: Place order with invalid payload -> 400
    Given path 'store/order'
    And request { quantity: 'two', status: 'placed' }
    When method post
    Then status 400
