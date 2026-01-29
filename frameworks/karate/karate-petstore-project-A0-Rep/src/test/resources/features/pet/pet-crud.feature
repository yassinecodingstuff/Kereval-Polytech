Feature: Pet API — CRUD & Search (Swagger Petstore v2)
  Background:
    * def baseUrl = karate.get('baseUrl')
    * url baseUrl
    * configure headers = { Accept: 'application/json' }
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

  @high @smoke @pet @create
  Scenario: Create Pet with Required Fields Only (Happy Path)
    * def payload =
      """
      { name: 'doggo', photoUrls: ['https://example.test/img/dog.png'] }
      """
    * header Authorization = 'Bearer ' + oauthToken
    Given path 'pet'
    And request payload
    When method post
    Then status 200
    And match response == petSchema
    And match response.name == 'doggo'
    And match response.id == '#number'

  @high @negative @pet @create
  Scenario Outline: Create Pet fails when required fields are missing
    * def basePayload = { name: 'doggo-missing', photoUrls: ['https://example.test/img/dog.png'] }
    * def payload =
    """
    function(bp, missing){
      var p = karate.clone(bp);
      delete p[missing];
      return p;
    }
    """
    * header Authorization = 'Bearer ' + oauthToken
    Given path 'pet'
    And request payload(basePayload, '<missingField>')
    When method post
    Then status 405
    And match response == { code: '#number', type: '#string?', message: '#string' }
    Examples:
      | missingField |
      | name         |
      | photoUrls    |

  @high @pet @update
  Scenario: Update Existing Pet (Full Object)
    * header Authorization = 'Bearer ' + oauthToken
    * def create =
      """
      function(){
        var p = { name: 'doggo', photoUrls: ['https://example.test/img/dog.png'], status: 'pending' };
        return p;
      }
      """
    Given path 'pet'
    And request create()
    When method post
    Then status 200
    * def petId = response.id
    * def updatePayload = { id: petId, name: 'doggo2', photoUrls: ['https://example.test/img/dog.png'], status: 'available' }
    Given path 'pet'
    And request updatePayload
    When method put
    Then status 200
    And match response == petSchema
    And match response.name == 'doggo2'
    And match response.status == 'available'

  @medium @negative @pet @update
  Scenario: Update Pet with Unknown ID returns 404
    * header Authorization = 'Bearer ' + oauthToken
    Given path 'pet'
    And request { id: 999999999999, name: 'ghost', photoUrls: ['https://example.test/img/ghost.png'], status: 'available' }
    When method put
    Then status 404
    And match response == { code: '#number', type: '#string?', message: '#string' }

  @high @pet @search
  Scenario Outline: Find Pets by Status returns only allowed statuses
    * header Authorization = 'Bearer ' + oauthToken
    * def allowed = ["available","pending","sold"]
    Given path 'pet', 'findByStatus'
    And param status = <statuses>
    When method get
    Then status 200
    And match each response == petSchema
    And match each response[*].status == '#? allowed.includes(_)'
    Examples:
      | statuses                     |
      | ['available','pending']      |
      | ['sold']                     |

  @medium @negative @pet @search
  Scenario Outline: Find Pets by Status with invalid value returns 400
    * header Authorization = 'Bearer ' + oauthToken
    Given path 'pet', 'findByStatus'
    And param status = '<bad>'
    When method get
    Then status 400
    And match response == { code: '#number', type: '#string?', message: '#string' }
    Examples:
      | bad     |
      | unknown |
      | INVALID |

  @high @smoke @pet @read
  Scenario: Get Pet by ID (Happy Path)
    * header Authorization = 'Bearer ' + oauthToken
    * def newPet = { name: 'reader', photoUrls: ['https://example.test/img/p.png'], status: 'available' }
    Given path 'pet'
    And request newPet
    When method post
    Then status 200
    * def petId = response.id
    * header api_key = apiKey
    Given path 'pet', petId
    When method get
    Then status 200
    And match response == petSchema
    And match response.id == petId

  @medium @negative @pet @read
  Scenario Outline: Get Pet by ID with invalid path parameter returns 400
    * header api_key = apiKey
    Given path 'pet', '<path>'
    When method get
    Then status 400
    And match response == { code: '#number', type: '#string?', message: '#string' }
    Examples:
      | path |
      | -1   |
      | abc  |

  @medium @negative @pet @read
  Scenario: Get Pet by ID not found returns 404
    * header api_key = apiKey
    Given path 'pet', 999999999999
    When method get
    Then status 404
    And match response == { code: '#number', type: '#string?', message: '#string' }

  @medium @pet @partialUpdate
  Scenario: Update Pet with Form Data (Name and Status)
    * header Authorization = 'Bearer ' + oauthToken
    * def create = { name: 'formy', photoUrls: ['https://example.test/img/p.png'], status: 'pending' }
    Given path 'pet'
    And request create
    When method post
    Then status 200
    * def petId = response.id
    Given path 'pet', petId
    And header Content-Type = 'application/x-www-form-urlencoded'
    And form field name = 'Bobbie'
    And form field status = 'sold'
    When method post
    Then status 200
    And match responseHeaders['Content-Type'][0] contains 'application/'

  @medium @pet @upload
  Scenario: Upload Image for Pet
    * header Authorization = 'Bearer ' + oauthToken
    * def create = { name: 'upl', photoUrls: ['https://example.test/img/p.png'], status: 'available' }
    Given path 'pet'
    And request create
    When method post
    Then status 200
    * def petId = response.id
    Given path 'pet', petId, 'uploadImage'
    And multipart field additionalMetadata = 'cute dog'
    And multipart file file = { read: 'classpath:files/dog.png', filename: 'dog.png', contentType: 'image/png' }
    When method post
    Then status 200
    And match response == { code: '#number', type: '#string?', message: '#string' }
    And match response.message contains 'uploaded'

  @high @pet @delete
  Scenario Outline: Delete Pet by ID — success and error handling
    * header Authorization = 'Bearer ' + oauthToken
    * def base = { name: 'todelete', photoUrls: ['https://example.test/img/p.png'], status: 'available' }
    Given path 'pet'
    And request base
    When method post
    Then status 200
    * def petId = response.id
    * header api_key = apiKey
    * def idToDelete = <target> == 'created' ? petId : <target>
    Given path 'pet', idToDelete
    When method delete
    * if (idToDelete == petId) assert responseStatus == 200 || responseStatus == 204
    * else if (idToDelete == -1) assert responseStatus == 400
    * else if (idToDelete == 999999999999) assert responseStatus == 404
    Examples:
      | target        |
      | 'created'     |
      | -1            |
      | 999999999999  |
