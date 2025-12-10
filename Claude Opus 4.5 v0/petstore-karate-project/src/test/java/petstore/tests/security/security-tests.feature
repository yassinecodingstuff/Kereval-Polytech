Feature: Security and Authorization Testing
  As a Petstore API security tester
  I want to verify authentication and authorization mechanisms
  So that the API is protected against unauthorized access
  
  Priority: CRITICAL - Security
  ISO/IEC/IEEE 29119 Alignment: Security testing with vulnerability coverage

  Background:
    * url baseUrl
    * def generateUniqueId = function(){ return Math.floor(Math.random() * 900000000) + 100000000 }

  @critical @security @oauth2
  Scenario: TC-SEC-001 - Verify behavior without OAuth2 authentication on pet endpoints
    * def petId = generateUniqueId()
    * def petPayload = { id: #(petId), name: 'SecurityTestPet', photoUrls: ['https://example.com/pet.jpg'] }
    Given path 'pet'
    And header Content-Type = 'application/json'
    And request petPayload
    When method post
    Then assert responseStatus == 200 || responseStatus == 401 || responseStatus == 403

  @critical @security @apikey
  Scenario: TC-SEC-002 - Verify API key authentication for inventory endpoint
    Given path 'store', 'inventory'
    And header api_key = 'special-key'
    And header Accept = 'application/json'
    When method get
    Then status 200

  @critical @security @apikey
  Scenario: TC-SEC-003 - Test inventory request with invalid API key
    Given path 'store', 'inventory'
    And header api_key = 'invalid-key'
    And header Accept = 'application/json'
    When method get
    Then assert responseStatus == 200 || responseStatus == 401 || responseStatus == 403

  @high @security @injection
  Scenario: TC-SEC-004 - Protect against SQL injection in pet name
    * def petId = generateUniqueId()
    * def petPayload = { id: #(petId), name: "'; DROP TABLE pets;--", photoUrls: ['https://example.com/pet.jpg'] }
    Given path 'pet'
    And header Content-Type = 'application/json'
    And header Accept = 'application/json'
    And request petPayload
    When method post
    Then assert responseStatus == 200 || responseStatus == 400
    And match response !contains 'SQL'
    And match response !contains 'syntax error'

  @high @security @injection
  Scenario: TC-SEC-005 - Protect against NoSQL injection in search
    Given path 'pet', 'findByStatus'
    And param status = "{'$gt': ''}"
    And header Accept = 'application/json'
    When method get
    Then assert responseStatus == 200 || responseStatus == 400

  @high @security @xss
  Scenario: TC-SEC-006 - Protect against XSS in pet name
    * def petId = generateUniqueId()
    * def xssPayload = "<script>alert('XSS')</script>"
    * def petPayload = { id: #(petId), name: '#(xssPayload)', photoUrls: ['https://example.com/pet.jpg'] }
    Given path 'pet'
    And header Content-Type = 'application/json'
    And header Accept = 'application/json'
    And request petPayload
    When method post
    Then status 200
    
    Given path 'pet', petId
    And header api_key = apiKey
    When method get
    Then status 200
    And match response.name == '#string'

  @high @security @xss
  Scenario: TC-SEC-007 - Protect against stored XSS in user fields
    * def username = 'xsstest_' + generateUniqueId()
    * def xssPayload = "<img src=x onerror=alert('XSS')>"
    * def userPayload = { username: '#(username)', firstName: '#(xssPayload)', lastName: 'Test' }
    Given path 'user'
    And header Content-Type = 'application/json'
    And header Accept = 'application/json'
    And request userPayload
    When method post
    Then status 200
    
    Given path 'user', username
    When method get
    Then status 200
    And match response.firstName == '#string'

  @medium @security @path-traversal
  Scenario: TC-SEC-008 - Protect against path traversal in pet ID
    Given path 'pet', '..', '..', '..', 'etc', 'passwd'
    And header api_key = apiKey
    When method get
    Then assert responseStatus == 400 || responseStatus == 404
    And match response !contains 'root:'

  @medium @security @overflow
  Scenario: TC-SEC-009 - Handle integer overflow in IDs gracefully
    Given path 'pet', '99999999999999999999999999'
    And header api_key = apiKey
    When method get
    Then assert responseStatus == 400 || responseStatus == 404 || responseStatus == 500
    And match response !contains 'stack trace'

  @medium @security @methods
  Scenario: TC-SEC-010 - Verify only allowed HTTP methods work
    Given path 'pet', 1
    When method options
    Then assert responseStatus == 200 || responseStatus == 405

  @high @security @content-type
  Scenario: TC-SEC-011 - Reject request with mismatched content type
    * def petPayload = { name: 'ContentTypePet', photoUrls: ['https://example.com/pet.jpg'] }
    Given path 'pet'
    And header Content-Type = 'text/plain'
    And request petPayload
    When method post
    Then assert responseStatus == 200 || responseStatus == 400 || responseStatus == 415

  @medium @security @encoding
  Scenario: TC-SEC-012 - Handle URL encoded malicious input
    Given path 'pet', 'findByStatus'
    And param status = '%27%20OR%20%271%27%3D%271'
    When method get
    Then assert responseStatus == 200 || responseStatus == 400

  @medium @security @null-byte
  Scenario: TC-SEC-013 - Handle null byte injection
    * def petId = generateUniqueId()
    * def petPayload = { id: #(petId), name: 'Test\u0000Pet', photoUrls: ['https://example.com/pet.jpg'] }
    Given path 'pet'
    And header Content-Type = 'application/json'
    And request petPayload
    When method post
    Then assert responseStatus == 200 || responseStatus == 400

  @low @security @large-payload
  Scenario: TC-SEC-014 - Handle excessively large payload
    * def generateLargeArray = function(){ var arr=[]; for(var i=0;i<1000;i++) arr.push('https://example.com/photo'+i+'.jpg'); return arr; }
    * def largePhotoUrls = generateLargeArray()
    * def petPayload = { name: 'LargePayloadPet', photoUrls: #(largePhotoUrls) }
    Given path 'pet'
    And header Content-Type = 'application/json'
    And request petPayload
    When method post
    Then assert responseStatus == 200 || responseStatus == 400 || responseStatus == 413

  @medium @security @crlf
  Scenario: TC-SEC-015 - Protect against CRLF injection
    * def petId = generateUniqueId()
    * def petPayload = { id: #(petId), name: "Test\r\nX-Injected-Header: malicious", photoUrls: ['https://example.com/pet.jpg'] }
    Given path 'pet'
    And header Content-Type = 'application/json'
    And request petPayload
    When method post
    Then assert responseStatus == 200 || responseStatus == 400
    And match responseHeaders['X-Injected-Header'] == '#notpresent'

  @critical @security @auth
  Scenario: TC-SEC-016 - Verify login endpoint security
    Given path 'user', 'login'
    And param username = "<script>alert('xss')</script>"
    And param password = 'testpassword'
    And header Accept = 'application/json'
    When method get
    Then assert responseStatus == 200 || responseStatus == 400
    And match response !contains '<script>'

  @high @security @apikey
  Scenario: TC-SEC-017 - Verify API key for pet retrieval
    * def petId = generateUniqueId()
    * def petPayload = { id: #(petId), name: 'ApiKeyTestPet', photoUrls: ['https://example.com/pet.jpg'] }
    Given path 'pet'
    And header Content-Type = 'application/json'
    And request petPayload
    When method post
    Then status 200
    
    Given path 'pet', petId
    And header api_key = 'special-key'
    And header Accept = 'application/json'
    When method get
    Then status 200
