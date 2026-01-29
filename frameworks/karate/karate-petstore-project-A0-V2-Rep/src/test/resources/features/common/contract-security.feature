Feature: Contract & Security — Schema, Methods, and Content Negotiation

Background:
  * url baseUrl
  * configure headers = { Accept: 'application/json' }
  * def allowedStatuses = ['available','pending','sold']
  * def petSchema =
  """
  {
    id: '##number',
    category: '##object',
    name: '#string',
    photoUrls: '#[] #string',
    tags: '##[] #object',
    status: '##? allowedStatuses.includes(_)'
  }
  """
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

Scenario: Security — Inventory endpoint without API key
  * header api_key = null
  Given path 'store', 'inventory'
  When method get
  Then match [200,401,403] contains responseStatus

Scenario: Contract — Find Pets by status matches Pet schema
  Given path 'pet', 'findByStatus'
  And param status = 'available'
  When method get
  Then status 200
  And match response == '#[] #object'
  And match each response == petSchema

Scenario: Contract — Place Order matches Order schema
  Given path 'store', 'order'
  And request { id: 2199, petId: 1102, quantity: 1, shipDate: '2025-11-11T11:11:11Z', status: 'placed', complete: true }
  When method post
  Then status 200
  And match response == orderSchema

Scenario: Contract — Inventory is object map
  * header api_key = 'special-key'
  Given path 'store', 'inventory'
  When method get
  Then status 200
  And match response == '#object'
  And match each response == '#number'
  * header api_key = null

Scenario: Contract — Login returns string token
  Given path 'user', 'login'
  And param username = 'demo'
  And param password = 'demo'
  When method get
  Then status 200
  And match response == '#string'

Scenario: Content — Unsupported Media Type rejected for JSON-only endpoint
  Given path 'store', 'order'
  * header Content-Type = 'text/plain'
  And request 'hello'
  When method post
  Then match [415,400] contains responseStatus
  * header Content-Type = null

Scenario: Reliability — GET inventory is safe (no state change)
  * header api_key = 'special-key'
  Given path 'store', 'inventory'
  When method get
  Then status 200
  * def inv1 = response
  Given path 'store', 'inventory'
  When method get
  Then status 200
  * def inv2 = response
  And match inv2 == inv1
  * header api_key = null

Scenario: Performance — Login returns rate limit header within bounds
  Given path 'user', 'login'
  And param username = 'demo'
  And param password = 'demo'
  When method get
  Then status 200
  * def rate = +responseHeaders['X-Rate-Limit'][0]
  * match rate == '#? _ >= 1'

Scenario: Robustness — PATCH /pet yields 405
  Given path 'pet'
  When method patch
  Then status 405

Scenario: Robustness — PATCH /user/login yields 405
  Given path 'user', 'login'
  When method patch
  Then status 405

Scenario: Robustness — PUT /store/inventory yields 405
  Given path 'store', 'inventory'
  When method put
  Then status 405

Scenario: Observability — 400 error has structured response or null
  Given path 'pet', 'abc'
  When method get
  Then status 400
  And match response == '#? _ == null || (typeof _ == "object" && (_.code == null || typeof _.code == "number"))'
