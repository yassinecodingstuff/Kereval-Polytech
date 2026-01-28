Feature: Pet API - Core CRUD and Search

  Background:
    * url baseUrl
    * header Accept = 'application/json'
    * def uuid = function(){ return java.util.UUID.randomUUID() + '' }
    * def newId = function(){ return Math.floor( (java.lang.System.currentTimeMillis() % 1000000000) + (Math.random()*100000) ) }

  # --- CRITICAL / HAPPY PATHS ---

  Scenario: Create a new pet successfully via POST /pet
    * def petId = newId()
    Given path 'pet'
    And request
    """
    {
      "id": #(petId),
      "name": "Rex",
      "photoUrls": ["https://example.com/rex.png"],
      "status": "available",
      "category": { "id": 1, "name": "dogs" },
      "tags": [ { "id": 100, "name": "friendly" } ]
    }
    """
    When method post
    Then status 200
    And match response.id == petId
    And match response.name == 'Rex'
    And match response.status == 'available'

  Scenario: Retrieve an existing pet by ID via GET /pet/{petId}
    * def petId = newId()
    * def petBody =
    """
    {
      "id": #(petId),
      "name": "Rex",
      "photoUrls": ["https://example.com/rex.png"],
      "status": "available"
    }
    """
    Given path 'pet'
    And request petBody
    When method post
    Then status 200
    And header api_key = 'special-key'
    Given path 'pet', petId
    When method get
    Then status 200
    And match response.id == petId
    And match response.name == 'Rex'

  Scenario: Update an existing pet via PUT /pet
    * def petId = newId()
    * def create =
    """
    {
      "id": #(petId),
      "name": "Rex",
      "photoUrls": ["https://example.com/rex.png"],
      "status": "available"
    }
    """
    Given path 'pet'
    And request create
    When method post
    Then status 200
    Given path 'pet'
    And request
    """
    {
      "id": #(petId),
      "name": "Rex-Updated",
      "photoUrls": ["https://example.com/rex2.png"],
      "status": "pending",
      "category": { "id": 1, "name": "dogs" },
      "tags": [ { "id": 101, "name": "updated" } ]
    }
    """
    When method put
    Then status 200
    And match response.name == 'Rex-Updated'
    And match response.status == 'pending'

  Scenario: Update a pet with form data via POST /pet/{petId}
    * def petId = newId()
    * def create =
    """
    {
      "id": #(petId),
      "name": "Rex-Updated",
      "photoUrls": ["https://example.com/rex.png"],
      "status": "pending"
    }
    """
    Given path 'pet'
    And request create
    When method post
    Then status 200
    Given path 'pet', petId
    And header Content-Type = 'application/x-www-form-urlencoded'
    And request { name: 'Rex-Form', status: 'sold' }
    When method post
    Then status 200
    Given path 'pet', petId
    When method get
    Then status 200
    And match response.name == 'Rex-Form'
    And match response.status == 'sold'

  Scenario: Upload an image for a pet via POST /pet/{petId}/uploadImage
    * def petId = newId()
    * def create =
    """
    {
      "id": #(petId),
      "name": "Rex-Form",
      "photoUrls": ["https://example.com/rex.png"],
      "status": "available"
    }
    """
    Given path 'pet'
    And request create
    When method post
    Then status 200
    Given path 'pet', petId, 'uploadImage'
    And multipart file file = { read: 'classpath:images/dog.png', filename: 'dog.png', contentType: 'image/png' }
    And multipart field additionalMetadata = 'cute'
    When method post
    Then status 200
    And match response.message != null

  Scenario: Delete an existing pet via DELETE /pet/{petId}
    * def petId = newId()
    * def create =
    """
    {
      "id": #(petId),
      "name": "DeleteMe",
      "photoUrls": ["https://example.com/x.png"],
      "status": "available"
    }
    """
    Given path 'pet'
    And request create
    When method post
    Then status 200
    And header api_key = 'special-key'
    Given path 'pet', petId
    When method delete
    Then status 200
    Given path 'pet', petId
    When method get
    Then status 404

  Scenario Outline: Find pets by status via GET /pet/findByStatus
    Given path 'pet', 'findByStatus'
    And param status = '<status>'
    When method get
    Then status 200
    And match response == '#[]'
    Examples:
      | status            |
      | available         |
      | pending           |
      | sold              |
      | available,pending |

  # --- VALIDATION & NEGATIVE ---

  Scenario Outline: Reject invalid pet creation (missing required fields) via POST /pet
    Given path 'pet'
    And request
    """
    { <json> }
    """
    When method post
    Then status 405
    Examples:
      | json                                                       |
      | "name": "NoPhotos"                                         |
      | "photoUrls": ["https://example.com/a.png"]                 |
      | "id": 12345                                                |

  Scenario Outline: Get pet by ID with invalid path values returns 400
    * header api_key = 'special-key'
    Given path 'pet', <badId>
    When method get
    Then status 400
    Examples:
      | badId |
      | -1    |
      | 0     |
      | 'abc' |

  Scenario: Delete pet that does not exist returns 404
    * header api_key = 'special-key'
    Given path 'pet', 999999999
    When method delete
    Then status 404

  Scenario: Find pets by tags via GET /pet/findByTags (deprecated)
    Given path 'pet', 'findByTags'
    And param tags = 'friendly,house'
    When method get
    Then status 200
    And match response == '#[]'
