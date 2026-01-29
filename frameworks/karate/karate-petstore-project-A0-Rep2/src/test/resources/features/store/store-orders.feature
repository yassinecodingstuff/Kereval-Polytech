Feature: Store API — Orders and Inventory (Financial and Fulfillment Risk)

Background:
  * url baseUrl
  * configure headers = { Accept: 'application/json' }
  * def OrderSchema =
    """
    {
      id: '##number',
      petId: '##number',
      quantity: '##number',
      shipDate: '##string',
      status: '#? ["placed","approved","delivered"].includes(_) ',
      complete: '#boolean'
    }
    """

@smoke @high
Scenario: Get inventory by status returns non-negative integer counts
  Given path 'store', 'inventory'
  When method get
  Then status 200
  And match response == '#object'
  * def keys = Object.keys(response)
  * def values = karate.map(keys, function(k){ return response[k]; })
  And match each values == '#? _ >= 0'

@smoke @high
Scenario Outline: Place an order for a Pet and retrieve it
  Given path 'pet'
  And request { id: <petId>, name: 'orderable', photoUrls: ['http://img/p'] }
  When method post
  Then status 200
  Given path 'store', 'order'
  And request
    """
    {
      "id": <orderId>,
      "petId": <petId>,
      "quantity": <qty>,
      "shipDate": "<shipDate>",
      "status": "<status>",
      "complete": <complete>
    }
    """
  When method post
  Then status 200
  And match response == OrderSchema
  And match response.id == <orderId>
  Given path 'store', 'order', <orderId>
  When method get
  Then status 200
  And match response.petId == <petId>
Examples:
  | orderId | petId | qty | shipDate               | status    | complete |
  | 7001    | 1001  | 1   | 2024-06-10T10:00:00Z   | placed    | true     |
  | 7002    | 1002  | 3   | 2025-01-05T00:00:00Z   | approved  | false    |

@regression @medium
Scenario Outline: Delete order by ID and verify it is removed
  Given path 'pet'
  And request { id: 11001, name: 'seed-for-order', photoUrls: ['http://img/p'] }
  When method post
  Then status 200
  Given path 'store', 'order'
  And request { id: <orderId>, petId: 11001, quantity: 1, shipDate: '2024-06-10T10:00:00Z', status: 'placed', complete: true }
  When method post
  Then status 200
  Given path 'store', 'order', <orderId>
  When method delete
  Then status 200
  Given path 'store', 'order', <orderId>
  When method get
  Then status 404
Examples:
  | orderId |
  | 7001    |
  | 7002    |

@regression @medium @negative
Scenario Outline: Get order by ID boundary and error handling
  Given path 'store', 'order', <orderId>
  When method get
  Then match responseStatus in [400,404]
Examples:
  | orderId |
  | -1      |
  | 0       |
  | 999999  |
