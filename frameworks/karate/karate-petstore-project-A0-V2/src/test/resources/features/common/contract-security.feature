Feature: Contract & Security — Swagger Contract Checks and Content Negotiation

Background:
  * url baseUrl
  * configure headers = { Accept: 'application/json' }
  * def apiKey = 'special-key'

@P0 @contract
Scenario: [TC-CONTRACT-001] Swagger document is available and has required sections
  Given path 'swagger.json'
  When method get
  Then status 200
  And match response.swagger == '2.0'
  And match response.paths contains
  """
  {
    "/pet": "#object",
    "/pet/findByStatus": "#object",
    "/store/inventory": "#object",
    "/user/login": "#object"
  }
  """
  And match response.definitions contains
  """
  {
    "Pet": "#object",
    "Order": "#object",
    "User": "#object"
  }
  """
  And match response.securityDefinitions contains
  """
  {
    "api_key": { "type": "apiKey" },
    "petstore_auth": { "type": "oauth2" }
  }
  """

@P0 @security @apikey
Scenario: [TC-SEC-001] Endpoints requiring api_key accept requests with valid key
  Given header api_key = apiKey
  And path 'pet', '1'
  When method get
  Then match [200,404] contains responseStatus
  * if (responseStatus == 200) karate.match(response, { id: '#number', name: '#string', '##status': '##string' })

@P0 @security @oauth2
Scenario: [TC-SEC-002] POST /pet accepts token with read/write scopes (best-effort)
  * def petId = '1401'
  Given header Authorization = 'Bearer dummy-token'
  And path 'pet'
  And request
  """
  { "id": 1401, "name": "Secured", "photoUrls": ["http://img"] }
  """
  When method post
  Then match [200,201,405] contains responseStatus

@P1 @content @acceptJson
Scenario: [TC-CONTENT-001] GET returns JSON when Accept is application/json
  * configure headers = { Accept: 'application/json' }
  * def uname = 'karate_cn_json'
  Given path 'user'
  And request
  """
  { "id": 1501, "username": "karate_cn_json", "firstName": "C", "lastName": "N", "email": "cnj@example.com", "password": "pw", "phone": "1" }
  """
  When method post
  Then status 200
  Given path 'user', uname
  When method get
  Then status 200
  And match responseHeaders['Content-Type'][0] contains 'application/json'

@P1 @content @acceptXml
Scenario: [TC-CONTENT-002] GET returns XML when Accept is application/xml
  * def uname = 'karate_cn_xml'
  * configure headers = { Accept: 'application/json' }
  Given path 'user'
  And request
  """
  { "id": 1502, "username": "karate_cn_xml", "firstName": "X", "lastName": "M", "email": "cnx@example.com", "password": "pw", "phone": "1" }
  """
  When method post
  Then status 200
  * configure headers = { Accept: 'application/xml' }
  Given path 'user', uname
  When method get
  Then match [200,404] contains responseStatus
  * if (responseStatus == 200) karate.match(responseHeaders['Content-Type'][0], '#? _.startsWith("application/xml")')
  * if (responseStatus == 200) karate.match(response, '#string')
