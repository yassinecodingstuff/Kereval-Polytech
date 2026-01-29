Feature: Pet — Lifecycle, Search, and Media (Swagger Petstore v2)

Background:
  * url baseUrl
  * configure headers = { Accept: 'application/json' }
  * def allowedStatuses = ['available','pending','sold']
  * def apiKey = 'special-key'

@P0 @create @schema
Scenario: [TC-PET-001] Create pet with required fields only returns 200/201 and conforms to schema
  * def petId = '1101'
  Given path 'pet'
  And request
  """
  {
    "id": 1101,
    "name": "doggie",
    "photoUrls": ["http://example.com/img1.jpg"]
  }
  """
  When method post
  Then match [200,201] contains responseStatus
  And match response ==
  """
  {
    "id": "#number",
    "name": "doggie",
    "photoUrls": "#[] #string",
    "##tags": "#[] #object",
    "##category": "#object",
    "##status": "##? allowedStatuses.includes(_)"
  }
  """

@P0 @create @read @persistence
Scenario: [TC-PET-002] Create pet with full payload persists all fields on retrieval
  * def petId = '1102'
  * def payload =
  """
  {
    "id": 1102,
    "name": "Mochi",
    "status": "pending",
    "category": { "id": 10, "name": "Cat" },
    "tags": [ { "id": 7, "name": "cute" } ],
    "photoUrls": ["http://img/1","/img/2"]
  }
  """
  Given path 'pet'
  And request payload
  When method post
  Then match [200,201] contains responseStatus
  And match response ==
  """
  {
    "id": 1102,
    "name": "Mochi",
    "status": "pending",
    "category": { "id": "#number", "name": "#string" },
    "tags": "#[] #object",
    "photoUrls": "#[] #string"
  }
  """
  Given header api_key = apiKey
  And path 'pet', petId
  When method get
  Then status 200
  And match response ==
  """
  {
    "id": 1102,
    "name": "Mochi",
    "status": "pending",
    "category": { "id": 10, "name": "Cat" },
    "tags": [ { "id": 7, "name": "cute" } ],
    "photoUrls": ["http://img/1","/img/2"]
  }
  """

@P0 @update @idempotent
Scenario: [TC-PET-003] Update existing pet via PUT overwrites fields and is idempotent
  * def petId = '1103'
  * def original =
  """
  { "id": 1103, "name": "Mochi v1", "status": "available", "photoUrls": ["http://img"] }
  """
  Given path 'pet'
  And request original
  When method post
  Then match [200,201] contains responseStatus
  * def update =
  """
  { "id": 1103, "name": "Mochi v2", "status": "sold", "photoUrls": ["http://img"] }
  """
  Given path 'pet'
  And request update
  When method put
  Then status 200
  Given path 'pet'
  And request update
  When method put
  Then status 200
  Given header api_key = apiKey
  And path 'pet', petId
  When method get
  Then status 200
  And match response.name == 'Mochi v2'
  And match response.status == 'sold'

@P0 @read
Scenario: [TC-PET-004] Get pet by ID returns Pet when ID exists
  * def petId = '1104'
  Given path 'pet'
  And request
  """
  { "id": 1104, "name": "Buddy", "photoUrls": ["http://img/1"] }
  """
  When method post
  Then match [200,201] contains responseStatus
  Given header api_key = apiKey
  And path 'pet', petId
  When method get
  Then status 200
  And match response ==
  """
  {
    "id": 1104,
    "name": "#string",
    "photoUrls": "#[] #string",
    "##tags": "#[] #object",
    "##category": "#object",
    "##status": "##? allowedStatuses.includes(_)"
  }
  """

@P0 @delete @notFound
Scenario: [TC-PET-005] Delete pet makes subsequent GET return 404
  * def petId = '1105'
  Given path 'pet'
  And request
  """
  { "id": 1105, "name": "Temp", "photoUrls": ["http://img"] }
  """
  When method post
  Then match [200,201] contains responseStatus
  Given header api_key = apiKey
  And path 'pet', petId
  When method delete
  Then match [200,204] contains responseStatus
  Given header api_key = apiKey
  And path 'pet', petId
  When method get
  Then status 404
  And match response.message contains 'Pet not found'

@P0 @search @status
Scenario Outline: [TC-PET-006] Find pets by single status returns only requested status
  Given path 'pet', 'findByStatus'
  And param status = '<status>'
  When method get
  Then status 200
  And match response == '#[] #object'
  And match each response ==
  """
  {
    "id": "#number",
    "name": "#string",
    "photoUrls": "##[] #string",
    "##status": "#? _ == '<status>'"
  }
  """

  Examples:
    | status     |
    | available  |
    | pending    |
    | sold       |

@P1 @search @deprecated
Scenario: [TC-PET-007] Find pets by tags returns pets containing at least one requested tag
  Given path 'pet', 'findByTags'
  And param tags = 'tag1'
  And param tags = 'tag2'
  When method get
  Then status 200
  And match response == '#[] #object'
  * def hasAny = function(x){ return x && x.length && x.map(t => t.name).some(n => ['tag1','tag2'].includes(n)); }
  And match each response.tags == '#? hasAny(_)'

@P0 @partialUpdate @form
Scenario: [TC-PET-008] Update pet with form data changes name and status
  * def petId = '1106'
  Given path 'pet'
  And request
  """
  { "id": 1106, "name": "Buddy v1", "status": "pending", "photoUrls": ["http://img"] }
  """
  When method post
  Then match [200,201] contains responseStatus
  Given path 'pet', petId
  And header Content-Type = 'application/x-www-form-urlencoded'
  And form field name = 'Buddy v3'
  And form field status = 'available'
  When method post
  Then match [200,204] contains responseStatus
  Given header api_key = apiKey
  And path 'pet', petId
  When method get
  Then status 200
  And match response.name == 'Buddy v3'
  And match response.status == 'available'

@P1 @media @upload
Scenario: [TC-PET-009] Uploading an image returns ApiResponse with message
  * def petId = '1107'
  Given path 'pet'
  And request
  """
  { "id": 1107, "name": "PicPet", "photoUrls": ["http://img"] }
  """
  When method post
  Then match [200,201] contains responseStatus
  Given path 'pet', petId, 'uploadImage'
  And multipart field additionalMetadata = 'profile photo'
  And multipart file file = { read: 'classpath:img/pet.png', filename: 'pet.png', contentType: 'image/png' }
  When method post
  Then status 200
  And match response ==
  """
  {
    "code": "#number",
    "type": "#string",
    "message": "#string"
  }
  """
  And match response.message contains 'uploaded'

@P0 @validation @negative
Scenario: [TC-PET-010] Creating pet without required fields is rejected with 405 Invalid input
  Given path 'pet'
  And request
  """
  { "id": 1108 }
  """
  When method post
  Then status 405
  And match response.message contains 'Invalid input'

@P0 @validation @negative
Scenario Outline: [TC-PET-011] Get pet by invalid ID returns 400 or 404
  * def badId = '<bad>'
  Given header api_key = apiKey
  And path 'pet', badId
  When method get
  Then match [400,404] contains responseStatus
  And match response.message == '#string'

  Examples:
    | bad           |
    | 'abc'         |
    | '0'           |
    | '-1'          |
    | '999999999999'|

@P1 @search
Scenario: [TC-PET-012] Find by multiple statuses returns only allowed statuses
  Given path 'pet', 'findByStatus'
  And param status = 'available'
  And param status = 'pending'
  When method get
  Then status 200
  And match response == '#[] #object'
  And match each response.status == '#? ["available","pending"].includes(_)'
