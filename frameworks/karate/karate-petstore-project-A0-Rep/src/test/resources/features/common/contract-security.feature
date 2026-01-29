Feature: Content Negotiation & Security (Swagger Petstore v2)
  Background:
    * def baseUrl = karate.get('baseUrl')
    * url baseUrl
    * configure logPrettyRequest = true
    * configure logPrettyResponse = true
    * def apiKey = karate.get('apiKey', 'special-key')
    * def oauthToken = karate.get('oauthToken', '')
    * def petSchema =
      """
      {
        id: '#number',
        name: '#string',
        category: { id: '#? _ == null || typeof _ == "number"', name: '#? _ == null || typeof _ == "string"' },
        photoUrls: '#[]',
        tags: '#? _ == null || karate.typeOf(_) == "list"',
        status: '#? _ == null || ["available","pending","sold"].includes(_)'
      }
      """
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
    * def apiResponseSchema = { code: '#number', type: '#string?', message: '#string' }
    * def userSchema =
      """
      {
        id: '#? _ == null || typeof _ == "number"',
        username: '#string',
        firstName: '#? _ == null || typeof _ == "string"',
        lastName: '#? _ == null || typeof _ == "string"',
        email: '#? _ == null || typeof _ == "string"',
        password: '#? _ == null || typeof _ == "string"',
        phone: '#? _ == null || typeof _ == "string"',
        userStatus: '#? _ == null || typeof _ == "number"'
      }
      """

  @medium @contract @pet
  Scenario: Get Pet by ID returns XML when requested
    * header Authorization = 'Bearer ' + oauthToken
    * def create = { name: 'xml-cat', photoUrls: ['https://example.test/img/cat.png'], status: 'available' }
    Given path 'pet'
    And request create
    When method post
    Then status 200
    * def petId = response.id
    * header api_key = apiKey
    * header Accept = 'application/xml'
    Given path 'pet', petId
    When method get
    Then status 200
    And match responseHeaders['Content-Type'][0] contains 'application/xml'

  @medium @contract @store
  Scenario: Place Order rejects unsupported Content-Type
    Given path 'store', 'order'
    And header Content-Type = 'application/xml'
    And request '<order></order>'
    When method post
    * assert responseStatus == 400 || responseStatus == 415

  @medium @contract @schema
  Scenario: GET /pet/{petId} conforms to Pet schema
    * header Authorization = 'Bearer ' + oauthToken
    * def create = { name: 'schema-dog', photoUrls: ['https://example.test/img/dog.png'], status: 'sold' }
    Given path 'pet'
    And request create
    When method post
    Then status 200
    * def petId = response.id
    * header api_key = apiKey
    Given path 'pet', petId
    When method get
    Then status 200
    And match response == petSchema

  @medium @contract @schema
  Scenario: GET /pet/findByStatus (sold) returns array of Pet schema
    Given path 'pet', 'findByStatus'
    And param status = 'sold'
    When method get
    Then status 200
    And match each response == petSchema

  @medium @contract @schema
  Scenario: POST /store/order conforms to Order schema
    Given path 'store', 'order'
    And request { petId: 1, quantity: 1, status: 'placed', complete: true }
    When method post
    Then status 200
    And match response == orderSchema

  @medium @contract @schema
  Scenario: POST /pet/{petId}/uploadImage returns ApiResponse schema
    * header Authorization = 'Bearer ' + oauthToken
    * def create = { name: 'schema-upl', photoUrls: ['https://example.test/img/p.png'] }
    Given path 'pet'
    And request create
    When method post
    Then status 200
    * def petId = response.id
    Given path 'pet', petId, 'uploadImage'
    And multipart field additionalMetadata = 'meta'
    And multipart file file = { read: 'classpath:files/dog.png', filename: 'dog.png', contentType: 'image/png' }
    When method post
    Then status 200
    And match response == apiResponseSchema

  @medium @contract @schema
  Scenario: GET /user/{username} conforms to User schema
    * def uname = 'schema-user-' + java.lang.System.currentTimeMillis()
    Given path 'user'
    And request { username: #(uname) }
    When method post
    Then status 200
    Given path 'user', uname
    When method get
    Then status 200
    And match response == userSchema

  @high @security @pet
  Scenario: Add Pet without OAuth token is denied
    Given path 'pet'
    And request { name: 'secured', photoUrls: ['https://example.test/img/p.png'] }
    When method post
    * assert responseStatus == 401 || responseStatus == 403

  @high @security @pet
  Scenario: Update Pet without OAuth token is denied
    Given path 'pet'
    And request { id: 1, name: 'noauth', photoUrls: ['https://example.test/img/p.png'] }
    When method put
    * assert responseStatus == 401 || responseStatus == 403

  @high @security @pet
  Scenario: Delete Pet without OAuth token is denied
    * header api_key = apiKey
    Given path 'pet', 1
    When method delete
    * assert responseStatus == 401 || responseStatus == 403

  @high @security @read
  Scenario: Get Pet by ID without API key is denied
    Given path 'pet', 1
    When method get
    * assert responseStatus == 401 || responseStatus == 403

  @medium @security @scope
  Scenario: OAuth token without write:pets scope cannot modify pets
    * header Authorization = 'Bearer READ_ONLY_TOKEN'
    Given path 'pet'
    And request { name: 'secured', photoUrls: ['https://example.test/img/p.png'] }
    When method post
    * assert responseStatus == 403

  @medium @security @headers
  Scenario: Login response headers enforce rate limiting and expiry formats
    Given path 'user', 'login'
    And param username = 'user1'
    And param password = 'password1'
    When method get
    Then status 200
    * def rate = responseHeaders['X-Rate-Limit'][0]
    * def expires = responseHeaders['X-Expires-After'][0]
    * match rate == '#number'
    * def rfc3339 = /^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(?:\.\d+)?Z$/
    * match expires == '#regex ' + rfc3339
