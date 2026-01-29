Feature: Store API — Inventory and Orders (High-Risk Coverage)

Background:
  * url baseUrl
  * configure headers = { Accept: 'application/json' }
  * def orderSchema =
  """
  {
    id: '#number',
    petId: '#number',
    quantity: '#number',
    shipDate: '##string',
    status: '##string',
    complete: '#boolean'
  }
  """

Scenario: Get inventory returns status-to-quantity map (seed-some)
  * def availPet =
  """
  { id: 2101, name: "InvA", photoUrls: ["http://example.com/a.jpg"], status: "available" }
  """
  * def soldPet =
  """
  { id: 2102, name: "InvS", photoUrls: ["http://example.com/s.jpg"], status: "sold" }
  """
  Given path 'pet'
  And request availPet
  When method post
  Then status 200
  Given path 'pet'
  And request soldPet
  When method post
  Then status 200
  Given path 'store', 'inventory'
  And header api_key = 'special-key'
  When method get
  Then status 200
  * match response == '#object'
  * def entries = response
  * def ok = function(e){ for (var k in e) { if (typeof e[k] !== 'number' || e[k] < 0) return false; } return true; }
  * assert ok(entries)

Scenario: Place order for pet with valid payload (seed-before-read)
  * def seeded =
  """
  { id: 2201, name: "Orderable", photoUrls: ["http://example.com/o.jpg"], status: "available" }
  """
  Given path 'pet'
  And request seeded
  When method post
  Then status 200
  * def order =
  """
  {
    id: 7001,
    petId: 2201,
    quantity: 2,
    shipDate: "2025-12-01T10:00:00.000Z",
    status: "placed",
    complete: true
  }
  """
  Given path 'store', 'order'
  And request order
  When method post
  Then status 200
  And match response == orderSchema
  * def orderId = response.id

Scenario: Get order by ID returns created order (seed-before-read)
  * def seeded =
  """
  { id: 2202, name: "Orderable2", photoUrls: ["http://example.com/o2.jpg"], status: "available" }
  """
  Given path 'pet'
  And request seeded
  When method post
  Then status 200
  * def order =
  """
  { id: 7002, petId: 2202, quantity: 1, status: "approved", complete: false }
  """
  Given path 'store', 'order'
  And request order
  When method post
  Then status 200
  * def orderId = response.id
  Given path 'store', 'order', orderId + ''
  When method get
  Then status 200
  And match response.id == orderId

Scenario: Delete order by ID and verify it no longer exists (seed-before-read)
  * def seeded =
  """
  { id: 2203, name: "Orderable3", photoUrls: ["http://example.com/o3.jpg"], status: "available" }
  """
  Given path 'pet'
  And request seeded
  When method post
  Then status 200
  * def order =
  """
  { id: 7003, petId: 2203, quantity: 3, status: "approved", complete: true }
  """
  Given path 'store', 'order'
  And request order
  When method post
  Then status 200
  * def orderId = response.id + ''
  Given path 'store', 'order', orderId
  When method delete
  Then match [200,204] contains responseStatus
  Given path 'store', 'order', orderId
  When method get
  Then status 404
  * def t = karate.typeOf(response)
  * if (t == 'map') match response contains { message: '#string' }
  * else match response == '#string'

Scenario Outline: Get order with invalid or non-existent ID
  Given path 'store', 'order', '<id>'
  When method get
  Then status <status>
  * def t = karate.typeOf(response)
  * if (t == 'map') match response contains { message: '#string' }
  * else match response == '#string'
  Examples:
    | id     | status |
    | '-1'   | 400    |
    | 'abc'  | 400    |
    | '9999' | 404    |

Scenario: Place order with invalid payload is rejected
  * def invalid =
  """
  { quantity: -5, status: "unknown" }
  """
  Given path 'store', 'order'
  And request invalid
  When method post
  Then status 400

Scenario: Inventory endpoint responds within acceptable time
  Given path 'store', 'inventory'
  And header api_key = 'special-key'
  When method get
  Then status 200
  * assert responseTime < 1000

Scenario: Find by status returns within acceptable time for large results
  Given path 'pet', 'findByStatus'
  And param status = 'available'
  When method get
  Then status 200
  * assert responseTime < 2000
  And match response == '#[] #object'
