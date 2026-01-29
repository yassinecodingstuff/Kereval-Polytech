Feature: Pet API — High-Impact CRUD, Search, and Media (Swagger Petstore v2)

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
  * def apiRespSchema =
  """
  {
    code: '##number',
    type: '##string',
    message: '##string'
  }
  """
  * def petId = '1101'
  * def otherPetId = '1102'

Scenario: Create Pet with minimal valid JSON (required fields only)
  Given path 'pet'
  And request { id: 1101, name: 'Rex', photoUrls: ['http://example.com/rex.jpg'] }
  When method post
  Then status 200
  And match response == petSchema
  And match response.id == 1101
  And match response.name == 'Rex'

Scenario: Create Pet with XML and negotiate XML response
  * header Accept = 'application/xml'
  * header Content-Type = 'application/xml'
  Given path 'pet'
  And request <Pet><id>1102</id><name>Whiskers</name><photoUrls><photoUrl>http://example.com/w.jpg</photoUrl></photoUrls><status>available</status></Pet>
  When method post
  Then status 200
  And match responseType == 'xml'
  * header Accept = 'application/json'
  * header Content-Type = null

Scenario: Create Pet missing required field yields Invalid input
  Given path 'pet'
  And request { id: 1103, photoUrls: ['http://example.com/no-name.jpg'] }
  When method post
  Then match [400,405] contains responseStatus
  And match response == apiRespSchema

Scenario: Update existing Pet (full object) succeeds
  Given path 'pet'
  And request { id: 1101, name: 'Rex II', photoUrls: ['http://example.com/rex2.jpg'], status: 'pending' }
  When method put
  Then status 200
  And match response == petSchema
  And match response.name == 'Rex II'
  And match response.status == 'pending'

Scenario: Update Pet with invalid enum status yields Validation exception
  Given path 'pet'
  And request { id: 1101, name: 'Bad Enum', photoUrls: ['http://example.com/x.jpg'], status: 'archived' }
  When method put
  Then match [400,405] contains responseStatus
  And match response == apiRespSchema

Scenario: Update Pet for non-existent id yields Pet not found
  Given path 'pet'
  And request { id: 9999, name: 'Ghost', photoUrls: ['http://example.com/ghost.jpg'] }
  When method put
  Then match [404,400] contains responseStatus
  And match response == '#? _ == null || (typeof _ == "object")'

Scenario Outline: Find Pets by status returns array of Pet
  Given path 'pet', 'findByStatus'
  And param status = <status>
  When method get
  Then status 200
  And match response == '#[] #object'
  And match each response == petSchema
  Examples:
    | status    |
    | available |
    | pending   |
    | sold      |

Scenario: Find Pets by status with invalid value yields 400
  Given path 'pet', 'findByStatus'
  And param status = 'unknown'
  When method get
  Then status 400
  And match response == apiRespSchema

Scenario: Find Pets by tags returns array (deprecated endpoint)
  Given path 'pet', 'findByTags'
  And param tags = 'cute'
  And param tags = 'fluffy'
  When method get
  Then status 200
  And match response == '#[] #object'
  And match each response == petSchema

Scenario: Get Pet by ID with API key
  * header api_key = 'special-key'
  Given path 'pet', petId
  When method get
  Then status 200
  And match response == petSchema
  And match response.id == 1101
  * header api_key = null

Scenario: Get Pet by ID without API key
  * header api_key = null
  Given path 'pet', '1'
  When method get
  Then match [200,401,403] contains responseStatus

Scenario: Get Pet by ID with invalid format yields 400
  Given path 'pet', 'abc'
  When method get
  Then status 400
  And match response == apiRespSchema

Scenario: Update Pet with form data (partial update)
  * header Content-Type = 'application/x-www-form-urlencoded'
  Given path 'pet', petId
  And form field name = 'Buddy'
  And form field status = 'sold'
  When method post
  Then match [200,202,204] contains responseStatus
  * header Content-Type = null
  Given path 'pet', petId
  When method get
  Then status 200
  And match response.name == 'Buddy'
  And match response.status == 'sold'

Scenario: Upload Pet image (multipart)
  * header Content-Type = null
  * header Accept = 'application/json'
  Given path 'pet', petId, 'uploadImage'
  And multipart field additionalMetadata = 'Glam shot'
  And multipart file file = { read: 'classpath:img/photo.png', filename: 'photo.png', contentType: 'image/png' }
  When method post
  Then status 200
  And match response == apiRespSchema

Scenario: Delete Pet by ID
  * header api_key = 'special-key'
  Given path 'pet', petId
  When method delete
  Then match [200,204] contains responseStatus
  * header api_key = null
  Given path 'pet', petId
  When method get
  Then status 404

Scenario: Delete Pet with invalid id yields 400
  Given path 'pet', 'abc'
  When method delete
  Then status 400
  And match response == apiRespSchema

Scenario: Accept JSON by default for Pet endpoints
  * header Accept = 'application/json'
  Given path 'pet', 'findByStatus'
  And param status = 'available'
  When method get
  Then status 200
  And match responseHeaders['Content-Type'][0] contains 'application/json'

Scenario: Pet lifecycle e2e — create, update, delete, verify not found
  * def lifeId = '1199'
  Given path 'pet'
  And request { id: 1199, name: 'Lifecycle', photoUrls: ['http://example.com/life.jpg'], status: 'available' }
  When method post
  Then status 200
  Given path 'pet'
  And request { id: 1199, name: 'Lifecycle+', photoUrls: ['http://example.com/life2.jpg'], status: 'pending' }
  When method put
  Then status 200
  Given path 'pet', lifeId
  When method delete
  Then match [200,204] contains responseStatus
  Given path 'pet', lifeId
  When method get
  Then status 404

Scenario: Interoperability — Pet endpoints support XML round-trip
  * header Accept = 'application/xml'
  * header Content-Type = 'application/xml'
  * def xmlRoundId = '1201'
  Given path 'pet'
  And request <Pet><id>1201</id><name>XMLCat</name><photoUrls><photoUrl>http://example.com/c.jpg</photoUrl></photoUrls><status>available</status></Pet>
  When method post
  Then status 200
  Given path 'pet', 'findByStatus'
  And param status = 'available'
  When method get
  Then status 200
  And match responseType == 'xml'
  * def names = get response //name
  * match names contains 'XMLCat'
  * header Accept = 'application/json'
  * header Content-Type = null
