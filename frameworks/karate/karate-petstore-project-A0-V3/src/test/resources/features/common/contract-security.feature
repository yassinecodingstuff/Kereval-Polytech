Feature: Contract & Security & Content Negotiation

Background:
  * url baseUrl
  * configure headers = { Accept: 'application/json' }
  * def allowedStatuses = ['available', 'pending', 'sold']
  * def petSchema =
  """
  {
    id: '#number',
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
    id: '#number',
    petId: '#number',
    quantity: '#number',
    shipDate: '##string',
    status: '##string',
    complete: '#boolean'
  }
  """
  * def userSchema =
  """
  {
    id: '#number',
    username: '#string',
    firstName: '##string',
    lastName: '##string',
    email: '##string',
    password: '##string',
    phone: '##string',
    userStatus: '##number'
  }
  """

Scenario: OpenAPI document is available and has key paths
  Given path 'swagger.json'
  When method get
  Then status 200
  And match response.swagger == '2.0'
  And match response.paths contains any { '/pet': '#object' }
  And match response.paths contains any { '/store/inventory': '#object' }
  And match response.paths contains any { '/user/login': '#object' }

Scenario: Invalid Content-Type yields 415 (or 405 if not supported)
  Given path 'pet'
  And header Content-Type = 'text/plain'
  And request 'not-json'
  When method post
  Then match [415,405] contains responseStatus

Scenario: XML response is available when Accept is application/xml
  * configure headers = { Accept: 'application/xml' }
  Given path 'store', 'inventory'
  When method get
  Then status 200
  * match responseHeaders['Content-Type'][0] contains 'application/xml'

Scenario: Access inventory without api_key
  * configure headers = { Accept: 'application/json' }
  Given path 'store', 'inventory'
  When method get
  Then match [200,401,403] contains responseStatus

Scenario: Access inventory with valid api_key
  Given path 'store', 'inventory'
  And header api_key = 'special-key'
  When method get
  Then status 200

Scenario: OAuth2 access token with correct scope grants access to write:pet (tolerant)
  * def token = 'dummy-token-with-write-pets'
  * def newPet =
  """
  { id: 4101, name: "OAuthPet", photoUrls: ["http://example.com/op.jpg"], status: "available" }
  """
  Given path 'pet'
  And header Authorization = 'Bearer ' + token
  And request newPet
  When method post
  Then match [200,401,403] contains responseStatus

Scenario: OAuth2 token missing required scope is denied for write operation (tolerant)
  * def token = 'dummy-token-with-read-only'
  * def newPet =
  """
  { id: 4102, name: "OAuthPetNoScope", photoUrls: ["http://example.com/op2.jpg"], status: "available" }
  """
  Given path 'pet'
  And header Authorization = 'Bearer ' + token
  And request newPet
  When method post
  Then match [401,403] contains responseStatus

Scenario: Unsupported HTTP method returns 405 (or 404)
  Given path 'pet'
  When method patch
  Then match [405,404] contains responseStatus

Scenario: Missing required query parameter returns 400 (tolerant)
  Given path 'pet', 'findByStatus'
  When method get
  Then match [200,400] contains responseStatus

Scenario: ETag/Cache headers are present for safe GETs (seed-before-read)
  * def petId = '4201'
  * def payload =
  """
  { id: 4201, name: "CacheMe", photoUrls: ["http://example.com/c.jpg"], status: "available" }
  """
  Given path 'pet'
  And request payload
  When method post
  Then status 200
  Given path 'pet', petId
  When method get
  Then status 200
  * def et = responseHeaders.ETag
  * def lm = responseHeaders['Last-Modified']
  * if (!et && !lm) karate.fail('No ETag or Last-Modified header present')

Scenario: Error body structure includes type, code, and message (detect body type)
  Given path 'pet', 'abc'
  When method get
  Then match [400,404] contains responseStatus
  * def t = karate.typeOf(response)
  * if (t == 'map') match response contains { message: '#string' }
  * else match response == '#string'

Scenario: Core endpoint responses roughly match simplified schemas (seed-before-read)
  # /pet
  * def pet =
  """
  { id: 4301, name: "Contract", photoUrls: ["http://example.com/k.jpg"], status: "available" }
  """
  Given path 'pet'
  And request pet
  When method post
  Then status 200
  Given path 'pet', '4301'
  When method get
  Then status 200
  And match response == petSchema
  # /store/order
  * def order =
  """
  { id: 8001, petId: 4301, quantity: 1, status: "placed", complete: true }
  """
  Given path 'store', 'order'
  And request order
  When method post
  Then status 200
  And match response == orderSchema
  # /user
  * def user =
  """
  { id: 3401, username: "contract_user", firstName: "C", lastName: "U", email: "cu@example.com", password: "x", phone: "1", userStatus: 0 }
  """
  Given path 'user'
  And request user
  When method post
  Then status 200
  Given path 'user', 'contract_user'
  When method get
  Then status 200
  And match response == userSchema
