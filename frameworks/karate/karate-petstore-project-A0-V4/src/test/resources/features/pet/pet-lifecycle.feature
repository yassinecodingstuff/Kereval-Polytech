Feature: Pet API — Lifecycle (Create, Update, Delete) — Swagger Petstore v2
  Background:
    * url baseUrl
    * configure headers = { Accept: 'application/json' }

  Scenario: Create Pet with minimal required fields and retrieve by ID
    Given path 'pet'
    And header Content-Type = 'application/json'
    And request
      """
      { "name": "Fido", "photoUrls": ["https://example.com/fido.jpg"], "status": "available" }
      """
    When method post
    Then status 200
    * def petId = response.id + ''
    And match response contains { id: '#number', name: 'Fido', status: 'available', photoUrls: '#[] #string' }

    Given path 'pet', petId
    When method get
    Then status 200
    And match response contains { id: '#number', name: 'Fido', status: 'available', photoUrls: '#[] #string' }

  Scenario: Update existing Pet via PUT and verify persistence
    * def pid = '1001'
    Given path 'pet'
    And header Content-Type = 'application/json'
    And request { id: 1001, name: 'Fido', photoUrls: ['https://example.com/fido.jpg'], status: 'available' }
    When method post
    Then status 200

    Given path 'pet'
    And header Content-Type = 'application/json'
    And request { id: 1001, name: 'Fido-Updated', photoUrls: ['https://example.com/fido.jpg'], status: 'pending' }
    When method put
    Then status 200

    Given path 'pet', pid
    When method get
    Then status 200
    And match response contains { id: '#number', name: 'Fido-Updated', status: 'pending', photoUrls: '#[] #string' }

  Scenario: Update Pet using form data (name and status)
    * def pid = '1002'
    Given path 'pet'
    And header Content-Type = 'application/json'
    And request { id: 1002, name: 'Formy', photoUrls: ['u'], status: 'available' }
    When method post
    Then status 200

    Given path 'pet', pid
    And header Content-Type = 'application/x-www-form-urlencoded'
    And form field name = 'Fido-Form'
    And form field status = 'sold'
    When method post
    Then status 200

    Given path 'pet', pid
    When method get
    Then status 200
    And match response contains { id: '#number', name: 'Fido-Form', status: 'sold' }

  Scenario: Delete Pet and verify it cannot be retrieved
    * def pid = '1003'
    Given path 'pet'
    And header Content-Type = 'application/json'
    And request { id: 1003, name: 'ToDelete', photoUrls: ['u'], status: 'available' }
    When method post
    Then status 200

    Given path 'pet', pid
    When method delete
    Then match [200,204,404] contains responseStatus

    Given path 'pet', pid
    When method get
    Then status 404

  Scenario: Idempotent delete — second delete should result in 404
    * def pid = '1004'
    Given path 'pet'
    And header Content-Type = 'application/json'
    And request { id: 1004, name: 'ToDelete2', photoUrls: ['u'], status: 'available' }
    When method post
    Then status 200

    Given path 'pet', pid
    When method delete
    Then match [200,204,404] contains responseStatus

    Given path 'pet', pid
    When method delete
    Then match [404,200,204] contains responseStatus

  Scenario: Create Pet with category and tags and verify nested schema
    * def pid = '1005'
    Given path 'pet'
    And header Content-Type = 'application/json'
    And request
      """
      {
        "id": 1005,
        "name": "Tagged",
        "category": { "id": 1, "name": "dogs" },
        "photoUrls": ["u"],
        "tags": [ { "id": 10, "name": "cute" }, { "id": 11, "name": "brown" } ],
        "status": "available"
      }
      """
    When method post
    Then status 200
    And match response contains
      """
      {
        id: '#number',
        name: 'Tagged',
        category: { id: '#number', name: '#string' },
        tags: '##[] #object',
        photoUrls: '#[] #string',
        status: '#? ["available","pending","sold"].includes(_)'
      }
      """

    Given path 'pet', pid
    When method get
    Then status 200
    And match response contains { id: '#number', name: 'Tagged' }

  Scenario: Get non-existing Pet returns 404 (typed body check)
    Given path 'pet', '1999'
    When method get
    Then status 404
    * def t = karate.typeOf(response)
    * if (t == 'map') match response contains { message: '#string' }
    * else match response == '#string'

  Scenario: Update Pet with invalid body returns client error (typed body)
    Given path 'pet'
    And header Content-Type = 'application/json'
    And request { "unexpected": "field-only" }
    When method put
    Then match [400,405] contains responseStatus
    * def t = karate.typeOf(response)
    * if (t == 'map') match response contains { message: '#string' }
    * else match response == '#string'

  Scenario: Get Pet by very large ID using string path variable
    * def bigId = '9223372036854710002'
    Given path 'pet', bigId
    When method get
    Then match [404,400] contains responseStatus
