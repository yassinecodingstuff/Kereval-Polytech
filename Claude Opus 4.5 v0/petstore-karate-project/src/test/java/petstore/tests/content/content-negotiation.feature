Feature: Content Negotiation Testing
  As a Petstore API consumer
  I want to receive responses in my preferred format
  So that I can process data appropriately
  
  Priority: LOW - Content Format Testing
  ISO/IEC/IEEE 29119 Alignment: Content negotiation and format validation

  Background:
    * url baseUrl
    * def generateUniqueId = function(){ return Math.floor(Math.random() * 900000000) + 100000000 }

  @low @content @accept @json
  Scenario: TC-CONTENT-001 - Receive JSON response with Accept application/json
    * def petId = generateUniqueId()
    * def petPayload = { id: #(petId), name: 'JsonAcceptPet', photoUrls: ['https://example.com/pet.jpg'] }
    Given path 'pet'
    And header Content-Type = 'application/json'
    And request petPayload
    When method post
    Then status 200
    
    Given path 'pet', petId
    And header Accept = 'application/json'
    And header api_key = apiKey
    When method get
    Then status 200
    And match responseHeaders['Content-Type'][0] contains 'application/json'
    And match response == '#object'
    And match response.name == 'JsonAcceptPet'
    
    Given path 'pet', petId
    And header api_key = apiKey
    When method delete
    Then status 200

  @low @content @accept @xml
  Scenario: TC-CONTENT-002 - Receive XML response with Accept application/xml
    * def petId = generateUniqueId()
    * def petPayload = { id: #(petId), name: 'XmlAcceptPet', photoUrls: ['https://example.com/pet.jpg'] }
    Given path 'pet'
    And header Content-Type = 'application/json'
    And request petPayload
    When method post
    Then status 200
    
    Given path 'pet', petId
    And header Accept = 'application/xml'
    And header api_key = apiKey
    When method get
    Then status 200
    And match responseHeaders['Content-Type'][0] contains 'application/xml'
    
    Given path 'pet', petId
    And header api_key = apiKey
    When method delete
    Then status 200

  @low @content @accept @xml
  Scenario: TC-CONTENT-003 - Receive XML response for order
    Given path 'store', 'order', 1
    And header Accept = 'application/xml'
    When method get
    Then status 200
    And match responseHeaders['Content-Type'][0] contains 'application/xml'

  @low @content @accept @default
  Scenario: TC-CONTENT-004 - Default to JSON when Accept header not specified
    * def petId = generateUniqueId()
    * def petPayload = { id: #(petId), name: 'DefaultAcceptPet', photoUrls: ['https://example.com/pet.jpg'] }
    Given path 'pet'
    And header Content-Type = 'application/json'
    And request petPayload
    When method post
    Then status 200
    
    Given path 'pet', petId
    And header api_key = apiKey
    When method get
    Then status 200
    And match responseHeaders['Content-Type'][0] contains 'application/json'
    
    Given path 'pet', petId
    And header api_key = apiKey
    When method delete
    Then status 200

  @low @content @accept @multiple
  Scenario: TC-CONTENT-005 - Handle Accept header with multiple types
    * def petId = generateUniqueId()
    * def petPayload = { id: #(petId), name: 'MultiAcceptPet', photoUrls: ['https://example.com/pet.jpg'] }
    Given path 'pet'
    And header Content-Type = 'application/json'
    And request petPayload
    When method post
    Then status 200
    
    Given path 'pet', petId
    And header Accept = 'application/xml, application/json;q=0.9'
    And header api_key = apiKey
    When method get
    Then status 200
    And match responseHeaders['Content-Type'][0] contains 'application'
    
    Given path 'pet', petId
    And header api_key = apiKey
    When method delete
    Then status 200

  @low @content @accept @wildcard
  Scenario: TC-CONTENT-006 - Handle wildcard Accept header
    Given path 'store', 'inventory'
    And header Accept = '*/*'
    And header api_key = apiKey
    When method get
    Then status 200
    And match responseHeaders['Content-Type'][0] contains 'application'

  @low @content @request @json
  Scenario: TC-CONTENT-007 - Accept JSON request body for pet creation
    * def petId = generateUniqueId()
    * def petPayload = { id: #(petId), name: 'JsonRequestPet', photoUrls: ['https://example.com/pet.jpg'] }
    Given path 'pet'
    And header Content-Type = 'application/json'
    And header Accept = 'application/json'
    And request petPayload
    When method post
    Then status 200
    And match response.name == 'JsonRequestPet'
    
    Given path 'pet', petId
    And header api_key = apiKey
    When method delete
    Then status 200

  @low @content @request @json
  Scenario: TC-CONTENT-008 - Accept JSON request body for order creation
    * def orderId = generateUniqueId()
    * def orderPayload = { id: #(orderId), petId: 1, quantity: 1, status: 'placed', complete: false }
    Given path 'store', 'order'
    And header Content-Type = 'application/json'
    And header Accept = 'application/json'
    And request orderPayload
    When method post
    Then status 200
    And match response.id == orderId
    
    Given path 'store', 'order', orderId
    When method delete
    Then status 200

  @low @content @request @form
  Scenario: TC-CONTENT-009 - Accept form data for pet update
    * def petId = generateUniqueId()
    * def petPayload = { id: #(petId), name: 'FormDataPet', photoUrls: ['https://example.com/pet.jpg'], status: 'available' }
    Given path 'pet'
    And header Content-Type = 'application/json'
    And request petPayload
    When method post
    Then status 200
    
    Given path 'pet', petId
    And header Content-Type = 'application/x-www-form-urlencoded'
    And form field name = 'UpdatedFormPet'
    And form field status = 'sold'
    When method post
    Then status 200
    
    Given path 'pet', petId
    And header api_key = apiKey
    When method get
    Then status 200
    And match response.name == 'UpdatedFormPet'
    And match response.status == 'sold'
    
    Given path 'pet', petId
    And header api_key = apiKey
    When method delete
    Then status 200

  @low @content @charset
  Scenario: TC-CONTENT-010 - Handle UTF-8 charset specification
    * def petId = generateUniqueId()
    * def petPayload = { id: #(petId), name: 'UTF8Pet 日本語 🐱', photoUrls: ['https://example.com/pet.jpg'] }
    Given path 'pet'
    And header Content-Type = 'application/json; charset=utf-8'
    And header Accept = 'application/json; charset=utf-8'
    And request petPayload
    When method post
    Then status 200
    And match response.name == 'UTF8Pet 日本語 🐱'
    
    Given path 'pet', petId
    And header api_key = apiKey
    When method delete
    Then status 200

  @low @content @array @json
  Scenario: TC-CONTENT-011 - Verify JSON array response for findByStatus
    Given path 'pet', 'findByStatus'
    And param status = 'available'
    And header Accept = 'application/json'
    When method get
    Then status 200
    And match responseHeaders['Content-Type'][0] contains 'application/json'
    And match response == '#array'

  @low @content @array @xml
  Scenario: TC-CONTENT-012 - Verify XML response for findByStatus
    Given path 'pet', 'findByStatus'
    And param status = 'available'
    And header Accept = 'application/xml'
    When method get
    Then status 200
    And match responseHeaders['Content-Type'][0] contains 'application/xml'

  @low @content @inventory
  Scenario: TC-CONTENT-013 - Verify inventory returns JSON object
    Given path 'store', 'inventory'
    And header Accept = 'application/json'
    And header api_key = apiKey
    When method get
    Then status 200
    And match responseHeaders['Content-Type'][0] contains 'application/json'
    And match response == '#object'

  @low @content @unsupported
  Scenario: TC-CONTENT-014 - Handle unsupported Accept header value
    Given path 'pet', 1
    And header Accept = 'application/pdf'
    And header api_key = apiKey
    When method get
    Then assert responseStatus == 200 || responseStatus == 406

  @low @content @unsupported
  Scenario: TC-CONTENT-015 - Handle text/plain content type for request
    * def petPayload = 'name=PlainTextPet&photoUrls=https://example.com/pet.jpg'
    Given path 'pet'
    And header Content-Type = 'text/plain'
    And request petPayload
    When method post
    Then assert responseStatus == 200 || responseStatus == 400 || responseStatus == 415
