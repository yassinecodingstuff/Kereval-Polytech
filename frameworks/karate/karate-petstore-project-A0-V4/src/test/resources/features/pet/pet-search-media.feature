Feature: Pet API — Search & Media — Swagger Petstore v2
  Background:
    * url baseUrl
    * configure headers = { Accept: 'application/json' }

  Scenario Outline: Find Pets by valid statuses (single and comma-separated)
    Given path 'pet', 'findByStatus'
    And param status = '<statuses>'
    When method get
    Then status 200
    * def arr = response
    * if (karate.typeOf(arr) == 'list' && karate.sizeOf(arr) > 0)
    """
    match each arr contains
    { id: '#number',
      name: '##string',
      photoUrls: '##[] #string',
      status: '#? ["available","pending","sold"].includes(_)' }
    """
    Examples:
      | statuses                   |
      | available                  |
      | pending                    |
      | sold                       |
      | available, pending         |
      | pending, sold              |
      | available, sold            |
      | available, pending, sold   |

  Scenario: Find Pets by invalid status returns 400 with error body typed safely
    Given path 'pet', 'findByStatus'
    And param status = 'INVALID'
    When method get
    Then status 400
    * def t = karate.typeOf(response)
    * if (t == 'map') match response contains { message: '#string' }
    * else match response == '#string'

  Scenario: Upload image for Pet (multipart/form-data)
    * def pid = '1010'
    Given path 'pet'
    And header Content-Type = 'application/json'
    And request { id: 1010, name: 'PicPet', photoUrls: ['u'], status: 'available' }
    When method post
    Then status 200

    Given path 'pet', pid, 'uploadImage'
    And multipart field additionalMetadata = 'cute photo'
    And multipart file file = { read: 'classpath:img/pet.jpg', filename: 'pet.jpg', contentType: 'image/jpeg' }
    When method post
    Then status 200
    And match response contains { code: '#number', message: '#string' }

  Scenario: Upload image with missing file returns client error or success message
    * def pid = '1011'
    Given path 'pet'
    And header Content-Type = 'application/json'
    And request { id: 1011, name: 'NoFilePet', photoUrls: ['u'], status: 'available' }
    When method post
    Then status 200

    Given path 'pet', pid, 'uploadImage'
    And multipart field additionalMetadata = 'no file attached'
    When method post
    Then match [200,400] contains responseStatus
    * def t = karate.typeOf(response)
    * if (t == 'map') match response contains { message: '#string' }
    * else match response == '#string'

  Scenario: Deprecated findByTags remains functional
    Given path 'pet', 'findByTags'
    And param tags = 'tag1'
    And param tags = 'tag2'
    When method get
    Then status 200
    * def arr = response
    * if (karate.typeOf(arr) == 'list' && karate.sizeOf(arr) > 0)
    """
    match each arr contains
    { id: '#number',
      name: '##string',
      photoUrls: '##[] #string',
      status: '#? ["available","pending","sold"].includes(_)' }
    """

  Scenario: GET Pet by ID with API key after seeding
    * def pid = '1012'
    Given path 'pet'
    And header Content-Type = 'application/json'
    And request { id: 1012, name: 'ApiKeyPet', photoUrls: ['u'], status: 'available' }
    When method post
    Then status 200

    Given path 'pet', pid
    And header api_key = 'special-key'
    When method get
    Then match [200,404] contains responseStatus
    * if (responseStatus == 200) match response contains { id: '#number', name: '##string', photoUrls: '##[] #string' }

  Scenario: Content negotiation for Pet create — JSON
    * def pid = '1013'
    Given path 'pet'
    And header Content-Type = 'application/json'
    And header Accept = 'application/json'
    And request { "id": 1013, "name": "CN-JSON", "photoUrls": ["u"] }
    When method post
    Then status 200
    * if (responseType == 'json') match response contains { id: '#number', name: 'CN-JSON', photoUrls: '##[] #string' }

  Scenario: Content negotiation for Pet create — XML
    * def pid = '1014'
    Given path 'pet'
    And header Content-Type = 'application/xml'
    And header Accept = 'application/xml'
    And request <Pet><id>1014</id><name>CN-XML</name><photoUrls><photoUrls>u</photoUrls></photoUrls><status>available</status></Pet>
    When method post
    Then status 200
    * match responseHeaders['Content-Type'][0] contains 'xml'
