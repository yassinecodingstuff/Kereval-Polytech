Feature: Pet API — P0/P1 risk-based lifecycle, search, form update, deletion, and image upload

  Background:
    * url baseUrl
    * configure headers = { Accept: 'application/json' }

  @P0 @HighRisk @Positive @Auth
  Scenario: Add Pet — Create a new pet with required fields (JSON)
    * def petId = karate.time()
    * def create = call read('classpath:features/common/keywords.feature@CreatePetJson') { petId: petId, name: 'automation-doggie', status: 'available', photoUrl: 'https://example.invalid/pets/' + petId + '/1.jpg', withAuth: true }
    * match create.createdPet.id == petId
    * match create.createdPet.name == 'automation-doggie'
    * match create.createdPet.photoUrls == '#[]'
    * match create.createdPet.status == 'available'

  @P0 @HighRisk @Negative @Validation @Auth
  Scenario: Add Pet — Reject when required field "name" is missing
    * def petId = karate.time()
    * header Content-Type = 'application/json'
    * header Authorization = 'Bearer ' + writePetsToken
    * def petMissingName =
      """
      {
        "id": #(petId),
        "photoUrls": ["https://example.invalid/pets/#(petId)/1.jpg"],
        "status": "available"
      }
      """
    Given path 'pet'
    And request petMissingName
    When method post
    Then status 405

  @P0 @HighRisk @Negative @Validation @Auth
  Scenario: Add Pet — Reject when required field "photoUrls" is missing
    * def petId = karate.time()
    * header Content-Type = 'application/json'
    * header Authorization = 'Bearer ' + writePetsToken
    * def petMissingPhotoUrls =
      """
      {
        "id": #(petId),
        "name": "automation-doggie",
        "status": "available"
      }
      """
    Given path 'pet'
    And request petMissingPhotoUrls
    When method post
    Then status 405

  @P1 @MediumRisk @Positive @ContentNegotiation @Auth
  Scenario: Add Pet — Create a new pet using XML payload
    * def petId = karate.time()
    * header Content-Type = 'application/xml'
    * header Authorization = 'Bearer ' + writePetsToken
    * def petXml =
      """
      <Pet>
        <id>#(petId)</id>
        <name>automation-doggie</name>
        <photoUrls>
          <photoUrl>https://example.invalid/pets/#(petId)/1.jpg</photoUrl>
        </photoUrls>
        <status>available</status>
      </Pet>
      """
    Given path 'pet'
    And request petXml
    When method post
    Then status 200

  @P0 @HighRisk @Positive @Auth
  Scenario: Update Pet — Update an existing pet (PUT /pet)
    * def petId = karate.time()
    * def _ = call read('classpath:features/common/keywords.feature@CreatePetJson') { petId: petId, name: 'automation-doggie', status: 'available', photoUrl: 'https://example.invalid/pets/' + petId + '/1.jpg', withAuth: true }

    * header Content-Type = 'application/json'
    * header Authorization = 'Bearer ' + writePetsToken
    * def petUpdate =
      """
      {
        "id": #(petId),
        "name": "automation-doggie-updated",
        "photoUrls": ["https://example.invalid/pets/#(petId)/1.jpg"],
        "status": "pending"
      }
      """
    Given path 'pet'
    And request petUpdate
    When method put
    Then status 200
    And match response.id == petId
    And match response.name == 'automation-doggie-updated'
    And match response.status == 'pending'

  @P0 @HighRisk @Negative @Boundary @Auth
  Scenario: Update Pet — Reject invalid ID supplied (negative int64)
    * header Content-Type = 'application/json'
    * header Authorization = 'Bearer ' + writePetsToken
    * def petInvalidId =
      """
      {
        "id": -1,
        "name": "automation-invalid",
        "photoUrls": ["https://example.invalid/pets/-1/1.jpg"],
        "status": "available"
      }
      """
    Given path 'pet'
    And request petInvalidId
    When method put
    Then status 400

  @P0 @HighRisk @Negative @NotFound @Auth
  Scenario: Update Pet — Return 404 when pet does not exist
    * header Content-Type = 'application/json'
    * header Authorization = 'Bearer ' + writePetsToken
    * def petNonexistent =
      """
      {
        "id": 9223372036854775000,
        "name": "automation-nonexistent",
        "photoUrls": ["https://example.invalid/pets/9223372036854775000/1.jpg"],
        "status": "available"
      }
      """
    Given path 'pet'
    And request petNonexistent
    When method put
    Then status 404

  @P0 @HighRisk @Positive @Auth
  Scenario: Get Pet By ID — Retrieve an existing pet (GET /pet/{petId})
    * def petId = karate.time()
    * def _ = call read('classpath:features/common/keywords.feature@CreatePetJson') { petId: petId, name: 'automation-doggie', status: 'available', photoUrl: 'https://example.invalid/pets/' + petId + '/1.jpg', withAuth: true }

    * header api_key = apiKey
    Given path 'pet', petId
    When method get
    Then status 200
    And match response.id == petId
    And match response.name == '#string'
    And match response.photoUrls == '#[]'
    And match response.status == '#? ["available","pending","sold"].includes(_)'
    And match response.status == 'available'

  @P0 @HighRisk @Negative @AuthZ
  Scenario: Get Pet By ID — Reject request without required api_key header
    * def petId = karate.time()
    Given path 'pet', petId
    When method get
    Then assert responseStatus == 401 || responseStatus == 403

  @P0 @HighRisk @Negative @Validation
  Scenario: Get Pet By ID — Return 400 for non-integer petId
    * header api_key = apiKey
    Given path 'pet', 'not-an-integer'
    When method get
    Then status 400

  @P0 @HighRisk @Negative @Boundary
  Scenario: Get Pet By ID — Return 400 for invalid ID supplied (petId = 0)
    * header api_key = apiKey
    Given path 'pet', 0
    When method get
    Then status 400

  @P0 @HighRisk @Negative @NotFound
  Scenario: Get Pet By ID — Return 404 when pet is not found
    * header api_key = apiKey
    Given path 'pet', 9223372036854775000
    When method get
    Then status 404

  @P1 @MediumRisk @Positive @Search @Auth
  Scenario Outline: Find Pets By Status — Filter using one or more allowed status values
    * header Authorization = 'Bearer ' + readPetsToken
    * def statusList = status2 == '' ? [status1] : [status1, status2]
    Given path 'pet', 'findByStatus'
    And param status = statusList
    When method get
    Then status 200
    And match response == '#[]'
    And match each response[*].status == '#? ["available","pending","sold"].includes(_)'
    Examples:
      | status1   | status2 |
      | available |         |
      | pending   | sold    |

  @P1 @MediumRisk @Negative @Validation @Auth
  Scenario: Find Pets By Status — Return 400 for invalid status value
    * header Authorization = 'Bearer ' + readPetsToken
    Given path 'pet', 'findByStatus'
    And param status = 'broken'
    When method get
    Then status 400

  @P2 @LowRisk @Positive @Search @Deprecated @Auth
  Scenario: Find Pets By Tags — Return pets filtered by tags (deprecated endpoint)
    * header Authorization = 'Bearer ' + readPetsToken
    Given path 'pet', 'findByTags'
    And param tags = ['tag1', 'tag2']
    When method get
    Then status 200
    And match response == '#[]'

  @P0 @HighRisk @Positive @Auth
  Scenario: Update Pet With Form — Update pet name and status via x-www-form-urlencoded
    * def petId = karate.time()
    * def _ = call read('classpath:features/common/keywords.feature@CreatePetJson') { petId: petId, name: 'automation-doggie', status: 'available', photoUrl: 'https://example.invalid/pets/' + petId + '/1.jpg', withAuth: true }

    * header Authorization = 'Bearer ' + writePetsToken
    Given path 'pet', petId
    And form field name = 'automation-doggie-form'
    And form field status = 'sold'
    When method post
    Then status 200

  @P0 @HighRisk @Negative @Validation @Auth
  Scenario: Update Pet With Form — Reject invalid input (no fields provided)
    * header Authorization = 'Bearer ' + writePetsToken
    Given path 'pet', 1
    When method post
    Then status 405

  @P0 @HighRisk @Positive @Auth
  Scenario: Delete Pet — Delete an existing pet and verify it is no longer retrievable
    * def petId = karate.time()
    * def _ = call read('classpath:features/common/keywords.feature@CreatePetJson') { petId: petId, name: 'automation-delete-me', status: 'available', photoUrl: 'https://example.invalid/pets/' + petId + '/1.jpg', withAuth: true }

    * header Authorization = 'Bearer ' + writePetsToken
    * header api_key = apiKey
    Given path 'pet', petId
    When method delete
    Then status 200

    * header api_key = apiKey
    Given path 'pet', petId
    When method get
    Then status 404

  @P0 @HighRisk @Negative @NotFound @Auth
  Scenario: Delete Pet — Return 404 when pet is not found
    * header Authorization = 'Bearer ' + writePetsToken
    Given path 'pet', 9223372036854775000
    When method delete
    Then status 404

  @P0 @HighRisk @Negative @Validation @Auth
  Scenario: Delete Pet — Return 400 for invalid ID supplied (non-integer)
    * header Authorization = 'Bearer ' + writePetsToken
    Given path 'pet', 'not-an-integer'
    When method delete
    Then status 400

  @P1 @MediumRisk @Positive @FileUpload @Auth
  Scenario: Upload Pet Image — Upload an image for an existing pet (multipart/form-data)
    * def petId = karate.time()
    * def _ = call read('classpath:features/common/keywords.feature@CreatePetJson') { petId: petId, name: 'automation-image-pet', status: 'available', photoUrl: 'https://example.invalid/pets/' + petId + '/1.jpg', withAuth: true }

    * header Authorization = 'Bearer ' + writePetsToken
    Given path 'pet', petId, 'uploadImage'
    And multipart field additionalMetadata = 'automation upload'
    And multipart file file = { read: 'classpath:fixtures/pet.jpg', filename: 'pet.jpg', contentType: 'image/jpeg' }
    When method post
    Then status 200
    And match response.code == '#number'
    And match response.message == '#string'

  @P1 @MediumRisk @Positive @FileUpload @Auth
  Scenario: Upload Pet Image — Succeed when optional file part is omitted
    * header Authorization = 'Bearer ' + writePetsToken
    Given path 'pet', 1, 'uploadImage'
    And multipart field additionalMetadata = 'no file provided'
    When method post
    Then status 200
    And match response.code == '#number'
