Feature: Error Handling and Edge Cases
  As a Petstore API consumer
  I want to verify proper error handling
  So that I can handle failures gracefully
  
  Priority: MEDIUM - Robustness Testing
  ISO/IEC/IEEE 29119 Alignment: Exception handling and boundary testing

  Background:
    * url baseUrl
    * def generateUniqueId = function(){ return Math.floor(Math.random() * 900000000) + 100000000 }

  @medium @error @method
  Scenario: TC-ERR-001 - Reject unsupported HTTP method PATCH on pet endpoint
    * def petPayload = { name: 'PatchPet', photoUrls: ['https://example.com/pet.jpg'] }
    Given path 'pet', 1
    And header Content-Type = 'application/json'
    And request petPayload
    When method patch
    Then assert responseStatus == 405 || responseStatus == 404

  @medium @error @method
  Scenario: TC-ERR-002 - Reject unsupported HTTP method PUT on store inventory
    Given path 'store', 'inventory'
    And header Content-Type = 'application/json'
    And request { available: 100 }
    When method put
    Then status 405

  @medium @error @method
  Scenario: TC-ERR-003 - Reject unsupported HTTP method DELETE on user login
    Given path 'user', 'login'
    When method delete
    Then status 405

  @medium @error @content-type
  Scenario: TC-ERR-004 - Handle request with unsupported content type
    * def petPayload = { name: 'ContentTypePet', photoUrls: ['https://example.com/pet.jpg'] }
    Given path 'pet'
    And header Content-Type = 'text/plain'
    And request petPayload
    When method post
    Then assert responseStatus == 200 || responseStatus == 400 || responseStatus == 415

  @medium @error @content-type
  Scenario: TC-ERR-005 - Handle request with text/html content type
    Given path 'pet'
    And header Content-Type = 'text/html'
    And request '<html><body>Not JSON</body></html>'
    When method post
    Then assert responseStatus == 400 || responseStatus == 415 || responseStatus == 500

  @medium @error @404
  Scenario: TC-ERR-006 - Return 404 for undefined endpoint
    Given path 'undefined', 'endpoint'
    When method get
    Then status 404

  @medium @error @404
  Scenario: TC-ERR-007 - Return 404 for misspelled resource path
    Given path 'pets'
    When method get
    Then status 404

  @medium @error @malformed
  Scenario: TC-ERR-008 - Handle malformed JSON with missing closing brace
    Given path 'pet'
    And header Content-Type = 'application/json'
    And request '{ "name": "MalformedPet", "photoUrls": ["https://example.com/pet.jpg"]'
    When method post
    Then assert responseStatus == 400 || responseStatus == 500

  @medium @error @malformed
  Scenario: TC-ERR-009 - Handle JSON with trailing comma
    Given path 'pet'
    And header Content-Type = 'application/json'
    And request '{ "name": "TrailingCommaPet", "photoUrls": ["https://example.com/pet.jpg"], }'
    When method post
    Then assert responseStatus == 400 || responseStatus == 500

  @medium @error @malformed
  Scenario: TC-ERR-010 - Handle completely invalid JSON
    Given path 'pet'
    And header Content-Type = 'application/json'
    And request 'This is not JSON at all'
    When method post
    Then assert responseStatus == 400 || responseStatus == 500

  @medium @error @malformed
  Scenario: TC-ERR-011 - Handle empty request body
    Given path 'pet'
    And header Content-Type = 'application/json'
    And request ''
    When method post
    Then assert responseStatus == 400 || responseStatus == 405 || responseStatus == 500

  @medium @error @datatype
  Scenario: TC-ERR-012 - Handle string where integer expected for pet ID
    * def petPayload = { id: 'not-an-integer', name: 'DataTypePet', photoUrls: ['https://example.com/pet.jpg'] }
    Given path 'pet'
    And header Content-Type = 'application/json'
    And request petPayload
    When method post
    Then assert responseStatus == 400 || responseStatus == 500

  @medium @error @datatype
  Scenario: TC-ERR-013 - Handle boolean where string expected
    * def petPayload = { name: true, photoUrls: ['https://example.com/pet.jpg'] }
    Given path 'pet'
    And header Content-Type = 'application/json'
    And request petPayload
    When method post
    Then assert responseStatus == 200 || responseStatus == 400

  @medium @error @datatype
  Scenario: TC-ERR-014 - Handle object where array expected for photoUrls
    * def petPayload = { name: 'ObjectPhotoUrlsPet', photoUrls: { url: 'https://example.com/pet.jpg' } }
    Given path 'pet'
    And header Content-Type = 'application/json'
    And request petPayload
    When method post
    Then assert responseStatus == 400 || responseStatus == 405 || responseStatus == 500

  @low @error @null
  Scenario: TC-ERR-015 - Handle null value for required field
    * def petPayload = { name: null, photoUrls: ['https://example.com/pet.jpg'] }
    Given path 'pet'
    And header Content-Type = 'application/json'
    And request petPayload
    When method post
    Then assert responseStatus == 200 || responseStatus == 400 || responseStatus == 405

  @low @error @null
  Scenario: TC-ERR-016 - Handle null value for optional field
    * def petPayload = { name: 'NullOptionalPet', photoUrls: ['https://example.com/pet.jpg'], status: null }
    Given path 'pet'
    And header Content-Type = 'application/json'
    And request petPayload
    When method post
    Then status 200

  @low @error @empty
  Scenario: TC-ERR-017 - Handle empty string for required field
    * def petPayload = { name: '', photoUrls: ['https://example.com/pet.jpg'] }
    Given path 'pet'
    And header Content-Type = 'application/json'
    And request petPayload
    When method post
    Then assert responseStatus == 200 || responseStatus == 405

  @low @error @unicode
  Scenario: TC-ERR-018 - Handle Unicode characters in pet name
    * def petPayload = { name: '猫の名前はミケです 🐱', photoUrls: ['https://example.com/pet.jpg'] }
    Given path 'pet'
    And header Content-Type = 'application/json; charset=utf-8'
    And request petPayload
    When method post
    Then status 200
    And match response.name == '猫の名前はミケです 🐱'

  @low @error @unicode
  Scenario: TC-ERR-019 - Handle RTL characters in pet name
    * def petPayload = { name: 'قط عربي', photoUrls: ['https://example.com/pet.jpg'] }
    Given path 'pet'
    And header Content-Type = 'application/json; charset=utf-8'
    And request petPayload
    When method post
    Then status 200

  @low @error @boundary
  Scenario: TC-ERR-020 - Handle oversized request payload
    * def generateUrls = function(count){ var urls=[]; for(var i=0;i<count;i++) urls.push('https://example.com/photo'+i+'.jpg'); return urls; }
    * def manyUrls = generateUrls(1000)
    * def petPayload = { name: 'ManyPhotosPet', photoUrls: #(manyUrls) }
    Given path 'pet'
    And header Content-Type = 'application/json'
    And request petPayload
    When method post
    Then assert responseStatus == 200 || responseStatus == 400 || responseStatus == 413
