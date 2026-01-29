Feature: Store API — Orders & Inventory (Swagger Petstore v2)
  Background:
    * def baseUrl = karate.get('baseUrl')
    * url baseUrl
    * configure headers = { Accept: 'application/json' }
    * configure logPrettyRequest = true
    * configure logPrettyResponse = true
    * def apiKey = karate.get('apiKey', 'special-key')
    * def orderSchema =
      """
      {
        id: '#? _ == null || typeof _ == "number"',
        petId: '#number',
        quantity: '#number',
        shipDate: '#? _ == null || karate.match(_, "#string").pass',
        status: '#string',
        complete: '#boolean'
      }
      """

  @high @smoke @store @order
  Scenario: Place Order for Pet (Happy Path)
    Given path 'store', 'order'
    And request { petId: 1, quantity: 2, status: 'placed', complete: true }
    When method post
    Then status 200
    And match response == orderSchema
    And match response.quantity == 2

  @medium @negative @store @order
  Scenario Outline: Place Order with invalid payload returns 400
    Given path 'store', 'order'
    And request <payload>
    When method post
    Then status 400
    And match response == { code: '#number', type: '#string?', message: '#string' }
    Examples:
      | payload                                                              |
      | { petId: 1, quantity: -1, status: 'placed', complete: true }         |
      | { petId: 'X', quantity: 2, status: 'placed', complete: true }        |
      | { quantity: 2, status: 'placed', complete: true }                    |

  @high @store @order @boundary
  Scenario Outline: Get Order by ID at documented boundaries returns 200
    Given path 'store', 'order', <id>
    When method get
    Then status 200
    And match response == orderSchema
    Examples:
      | id |
      | 1  |
      | 10 |

  @medium @negative @store @order
  Scenario Outline: Get Order by ID with invalid values returns 400
    Given path 'store', 'order', '<badId>'
    When method get
    Then status 400
    And match response == { code: '#number', type: '#string?', message: '#string' }
    Examples:
      | badId |
      | 0     |
      | -1    |
      | abc   |

  @medium @negative @store @order
  Scenario: Get Order by ID not found returns 404
    Given path 'store', 'order', 5
    When method get
    Then status 404
    And match response == { code: '#number', type: '#string?', message: '#string' }

  @high @store @order @delete
  Scenario Outline: Delete Order by ID — success and error handling
    * def order = { petId: 1, quantity: 1, status: 'placed', complete: false }
    Given path 'store', 'order'
    And request order
    When method post
    Then status 200
    * def orderId = response.id
    * def idToDelete = <target> == 'created' ? orderId : <target>
    Given path 'store', 'order', idToDelete
    When method delete
    * if (idToDelete == orderId) assert responseStatus == 200 || responseStatus == 204
    * else if (idToDelete == 0) assert responseStatus == 400
    * else if (idToDelete == 999999999999) assert responseStatus == 404
    Examples:
      | target        |
      | 'created'     |
      | 0             |
      | 999999999999  |

  @medium @smoke @store @inventory
  Scenario: Get Inventory by Status with API Key
    * header api_key = apiKey
    Given path 'store', 'inventory'
    When method get
    Then status 200
    * def allNumbers =
      """
      function(o){ for (var k in o){ if (typeof o[k] !== 'number') return false; } return true; }
      """
    And match allNumbers(response) == true

  @medium @security @store @inventory
  Scenario: Get Inventory without API Key is unauthorized
    Given path 'store', 'inventory'
    When method get
    * assert responseStatus == 401 || responseStatus == 403
