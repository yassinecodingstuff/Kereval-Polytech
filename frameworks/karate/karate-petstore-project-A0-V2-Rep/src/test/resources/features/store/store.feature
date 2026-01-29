Feature: Store API — Orders & Inventory Controls

Background:
  * url baseUrl
  * configure headers = { Accept: 'application/json' }
  * def allowedStatuses = ['available','pending','sold']
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
  * def apiRespSchema =
  """
  {
    code: '##number',
    type: '##string',
    message: '##string'
  }
  """
  * def orderId = '2101'

Scenario: Get Inventory returns map of statuses to quantities
  * header api_key = 'special-key'
  Given path 'store', 'inventory'
  When method get
  Then status 200
  And match response == '#object'
  And match each response == '#number'
  * def keys = Object.keys(response)
  * def invalid = keys.filter(k => !allowedStatuses.includes(k))
  * match invalid == []
  * header api_key = null

Scenario: Place Order for a Pet (valid)
  Given path 'store', 'order'
  And request { id: 2101, petId: 1102, quantity: 2, shipDate: '2025-12-01T10:00:00Z', status: 'placed', complete: true }
  When method post
  Then status 200
  And match response == orderSchema
  And match response.status == 'placed'
  And match response.id == 2101

Scenario Outline: Get Order by ID within allowed range [1..10]
  Given path 'store', 'order', '<id>'
  When method get
  Then status 200
  And match response == orderSchema
  Examples:
    | id |
    | 1  |
    | 10 |

Scenario: Get Order by ID with 0 yields Invalid ID supplied
  Given path 'store', 'order', '0'
  When method get
  Then status 400
  And match response == apiRespSchema

Scenario: Get Order by ID with >10 yields Not found
  Given path 'store', 'order', '11'
  When method get
  Then status 404
  And match response == apiRespSchema

Scenario: Delete Order by ID and verify deletion
  Given path 'store', 'order', orderId
  When method delete
  Then match [200,204] contains responseStatus
  Given path 'store', 'order', orderId
  When method get
  Then status 404

Scenario: Delete Order with invalid id format yields 400
  Given path 'store', 'order', 'abc'
  When method delete
  Then status 400
  And match response == apiRespSchema
