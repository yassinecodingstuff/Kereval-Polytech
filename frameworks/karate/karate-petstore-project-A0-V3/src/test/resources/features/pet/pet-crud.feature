Feature: Pet API — CRUD and Search (High-Risk Coverage)

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

Scenario: Create pet with minimum required fields (JSON)
  * def petId = '1101'
  * def payload =
  """
  {
    id: 1101,
    name: "Fido",
    photoUrls: ["http://example.com/fido.jpg"],
    status: "available"
  }
  """
  Given path 'pet'
  And request payload
  When method post
  Then status 200
  And match response == petSchema
  And match response.id == 1101
  And match response.name == 'Fido'
  And match response.status == 'available'

Scenario: Retrieve newly created pet by ID (seed-before-read)
  * def petId = '1102'
  * def create =
  """
  {
    id: 1102,
    name: "Seed-Read",
    photoUrls: ["http://example.com/seed.jpg"],
    status: "available"
  }
  """
  Given path 'pet'
  And request create
  When method post
  Then status 200
  Given path 'pet', petId
  When method get
  Then status 200
  And match response == petSchema
  And match response.id == 1102

Scenario: Update entire pet via PUT with valid ID (seed-before-read)
  * def petId = '1103'
  * def base =
  """
  {
    id: 1103,
    name: "BeforeUpdate",
    photoUrls: ["http://example.com/one.jpg"],
    status: "available"
  }
  """
  Given path 'pet'
  And request base
  When method post
  Then status 200
  * def updated =
  """
  {
    id: 1103,
    name: "Fido-Updated",
    photoUrls: ["http://example.com/two.jpg"],
    status: "pending",
    tags: [{"id": 1, "name": "friendly"}],
    category: {"id": 100, "name": "dogs"}
  }
  """
  Given path 'pet'
  And request updated
  When method put
  Then status 200
  And match response.name == 'Fido-Updated'
  And match response.status == 'pending'
  And match response == petSchema

Scenario: Update pet name and status via form-encoded endpoint (seed-before-read)
  * def petId = '1104'
  * def base =
  """
  {
    id: 1104,
    name: "FormBefore",
    photoUrls: ["http://example.com/form.jpg"],
    status: "available"
  }
  """
  Given path 'pet'
  And request base
  When method post
  Then status 200
  Given path 'pet', petId
  And form field name = 'Fido-Form'
  And form field status = 'sold'
  When method post
  Then match [200,204] contains responseStatus
  Given path 'pet', petId
  When method get
  Then status 200
  And match response.name == 'Fido-Form'
  And match response.status == 'sold'

Scenario: Upload pet image (multipart/form-data) (seed-before-read)
  * def petId = '1105'
  * def base =
  """
  {
    id: 1105,
    name: "ImgPet",
    photoUrls: ["http://example.com/img.jpg"],
    status: "available"
  }
  """
  Given path 'pet'
  And request base
  When method post
  Then status 200
  Given path 'pet', petId, 'uploadImage'
  And multipart field additionalMetadata = 'cute'
  And multipart file file = { read: 'classpath:img/pet.jpg', filename: 'pet.jpg', contentType: 'image/jpeg' }
  When method post
  Then status 200
  * def t = karate.typeOf(response)
  * if (t == 'map') match response contains { code: '#number', type: '##string', message: '#string' }
  * else match response == '#string'

Scenario: Delete pet by ID and verify it no longer exists (seed-before-read)
  * def petId = '1106'
  * def base =
  """
  {
    id: 1106,
    name: "DelMe",
    photoUrls: ["http://example.com/del.jpg"],
    status: "available"
  }
  """
  Given path 'pet'
  And request base
  When method post
  Then status 200
  Given path 'pet', petId
  When method delete
  Then match [200,204] contains responseStatus
  Given path 'pet', petId
  When method get
  Then status 404

Scenario Outline: Find pets by valid status returns only requested statuses (seed-one)
  * def petId = '1201'
  * def seed =
  """
  {
    id: 1201,
    name: "Finder",
    photoUrls: ["http://example.com/find.jpg"],
    status: "<status>"
  }
  """
  Given path 'pet'
  And request seed
  When method post
  Then status 200
  Given path 'pet', 'findByStatus'
  And param status = '<status>'
  When method get
  Then status 200
  And match response == '#[] #object'
  * def valid = response.every(x => !x.status || x.status == '<status>')
  * assert valid
  Examples:
    | status    |
    | available |
    | pending   |
    | sold      |

Scenario: Find pets by tags with invalid tag value yields 400 or empty
  Given path 'pet', 'findByTags'
  And param tags = '@@@invalid@@@'
  When method get
  Then match [200,400] contains responseStatus
  * if (responseStatus == 200) match response == '#[] #object'

Scenario Outline: Get pet by ID with invalid identifiers
  Given path 'pet', '<id>'
  When method get
  Then status <status>
  * def t = karate.typeOf(response)
  * if (t == 'map') match response contains { message: '#string' }
  * else match response == '#string'
  Examples:
    | id     | status |
    | '-1'   | 400    |
    | '0'    | 404    |
    | 'abc'  | 400    |
    | '9999' | 404    |

Scenario: Idempotent PUT update yields stable representation (seed-before-read)
  * def petId = '1301'
  * def base =
  """
  {
    id: 1301,
    name: "Stable",
    photoUrls: ["http://example.com/s1.jpg"],
    status: "pending"
  }
  """
  Given path 'pet'
  And request base
  When method post
  Then status 200
  Given path 'pet'
  And request base
  When method put
  Then status 200
  * def first = response
  Given path 'pet'
  And request base
  When method put
  Then status 200
  And match response == first

Scenario: Delete non-existing pet returns 404
  Given path 'pet', '19999'
  When method delete
  Then status 404
