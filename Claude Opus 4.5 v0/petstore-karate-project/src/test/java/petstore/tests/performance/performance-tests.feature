Feature: Performance and Reliability Testing
  As a Petstore API consumer
  I want to verify API performance characteristics
  So that the API meets service level expectations
  
  Priority: MEDIUM - Non-Functional Testing
  ISO/IEC/IEEE 29119 Alignment: Performance testing and reliability verification

  Background:
    * url baseUrl
    * def generateUniqueId = function(){ return Math.floor(Math.random() * 900000000) + 100000000 }

  @medium @performance @response-time
  Scenario: TC-PERF-001 - Verify GET pet by ID response time
    * def petId = generateUniqueId()
    * def petPayload = { id: #(petId), name: 'ResponseTimePet', photoUrls: ['https://example.com/pet.jpg'] }
    Given path 'pet'
    And header Content-Type = 'application/json'
    And request petPayload
    When method post
    Then status 200
    
    Given path 'pet', petId
    And header api_key = apiKey
    When method get
    Then status 200
    And assert responseTime < 1000

  @medium @performance @response-time
  Scenario: TC-PERF-002 - Verify POST pet response time
    * def petId = generateUniqueId()
    * def petPayload = { id: #(petId), name: 'PostTimePet', photoUrls: ['https://example.com/pet.jpg'] }
    Given path 'pet'
    And header Content-Type = 'application/json'
    And request petPayload
    When method post
    Then status 200
    And assert responseTime < 2000

  @medium @performance @response-time
  Scenario: TC-PERF-003 - Verify inventory retrieval response time
    Given path 'store', 'inventory'
    And header api_key = apiKey
    When method get
    Then status 200
    And assert responseTime < 2000

  @medium @performance @response-time
  Scenario: TC-PERF-004 - Verify findByStatus response time with large result set
    Given path 'pet', 'findByStatus'
    And param status = 'available'
    When method get
    Then status 200
    And assert responseTime < 5000

  @medium @performance @response-time
  Scenario: TC-PERF-005 - Verify user login response time
    Given path 'user', 'login'
    And param username = 'user1'
    And param password = 'password123'
    When method get
    Then status 200
    And assert responseTime < 1500

  @medium @performance @response-time
  Scenario: TC-PERF-006 - Verify order creation response time
    * def orderId = generateUniqueId()
    * def orderPayload = { id: #(orderId), petId: 1, quantity: 1, status: 'placed', complete: false }
    Given path 'store', 'order'
    And header Content-Type = 'application/json'
    And request orderPayload
    When method post
    Then status 200
    And assert responseTime < 2000

  @low @performance @sequential
  Scenario: TC-PERF-007 - Execute sequential pet operations
    * def petId = generateUniqueId()
    * def petPayload = { id: #(petId), name: 'SequentialPet', photoUrls: ['https://example.com/pet.jpg'], status: 'available' }
    
    Given path 'pet'
    And header Content-Type = 'application/json'
    And request petPayload
    When method post
    Then status 200
    * def createTime = responseTime
    
    Given path 'pet', petId
    And header api_key = apiKey
    When method get
    Then status 200
    * def readTime = responseTime
    
    * def updatePayload = { id: #(petId), name: 'UpdatedSequentialPet', photoUrls: ['https://example.com/pet.jpg'], status: 'sold' }
    Given path 'pet'
    And header Content-Type = 'application/json'
    And request updatePayload
    When method put
    Then status 200
    * def updateTime = responseTime
    
    Given path 'pet', petId
    And header api_key = apiKey
    When method delete
    Then status 200
    * def deleteTime = responseTime
    
    And assert createTime + readTime + updateTime + deleteTime < 8000

  @low @performance @reliability
  Scenario: TC-PERF-008 - Verify consistent response structure across multiple requests
    Given path 'pet', 'findByStatus'
    And param status = 'available'
    When method get
    Then status 200
    * def firstResponse = response
    
    Given path 'pet', 'findByStatus'
    And param status = 'available'
    When method get
    Then status 200
    * def secondResponse = response
    
    And match firstResponse == '#array'
    And match secondResponse == '#array'

  @low @performance @reliability
  Scenario: TC-PERF-009 - Verify idempotent GET operations
    * def petId = generateUniqueId()
    * def petPayload = { id: #(petId), name: 'IdempotentGetPet', photoUrls: ['https://example.com/pet.jpg'] }
    Given path 'pet'
    And header Content-Type = 'application/json'
    And request petPayload
    When method post
    Then status 200
    
    Given path 'pet', petId
    And header api_key = apiKey
    When method get
    Then status 200
    * def firstGet = response
    
    Given path 'pet', petId
    And header api_key = apiKey
    When method get
    Then status 200
    * def secondGet = response
    
    Given path 'pet', petId
    And header api_key = apiKey
    When method get
    Then status 200
    * def thirdGet = response
    
    And match firstGet == secondGet
    And match secondGet == thirdGet

  @low @performance @rate-limit
  Scenario: TC-PERF-010 - Verify rate limit header in login response
    Given path 'user', 'login'
    And param username = 'user1'
    And param password = 'password123'
    When method get
    Then status 200
    And match responseHeaders['X-Rate-Limit'][0] == '#regex \\d+'

  @low @performance @rate-limit
  Scenario: TC-PERF-011 - Verify expiration header in login response
    Given path 'user', 'login'
    And param username = 'user1'
    And param password = 'password123'
    When method get
    Then status 200
    And match responseHeaders['X-Expires-After'][0] == '#string'

  @low @performance @load
  Scenario: TC-PERF-012 - Execute burst of create operations
    * def results = []
    
    * def pet1 = generateUniqueId()
    Given path 'pet'
    And header Content-Type = 'application/json'
    And request { id: #(pet1), name: 'BurstPet1', photoUrls: ['https://example.com/pet.jpg'] }
    When method post
    Then status 200
    * karate.appendTo(results, responseTime)
    
    * def pet2 = generateUniqueId()
    Given path 'pet'
    And header Content-Type = 'application/json'
    And request { id: #(pet2), name: 'BurstPet2', photoUrls: ['https://example.com/pet.jpg'] }
    When method post
    Then status 200
    * karate.appendTo(results, responseTime)
    
    * def pet3 = generateUniqueId()
    Given path 'pet'
    And header Content-Type = 'application/json'
    And request { id: #(pet3), name: 'BurstPet3', photoUrls: ['https://example.com/pet.jpg'] }
    When method post
    Then status 200
    * karate.appendTo(results, responseTime)
    
    * def pet4 = generateUniqueId()
    Given path 'pet'
    And header Content-Type = 'application/json'
    And request { id: #(pet4), name: 'BurstPet4', photoUrls: ['https://example.com/pet.jpg'] }
    When method post
    Then status 200
    * karate.appendTo(results, responseTime)
    
    * def pet5 = generateUniqueId()
    Given path 'pet'
    And header Content-Type = 'application/json'
    And request { id: #(pet5), name: 'BurstPet5', photoUrls: ['https://example.com/pet.jpg'] }
    When method post
    Then status 200
    * karate.appendTo(results, responseTime)

  @low @performance @response-size
  Scenario: TC-PERF-013 - Handle large response from findByStatus
    Given path 'pet', 'findByStatus'
    And param status = 'available'
    When method get
    Then status 200
    And match response == '#array'

  @low @performance @timeout
  Scenario: TC-PERF-014 - Verify requests complete within timeout
    * configure readTimeout = 30000
    Given path 'pet', 'findByStatus'
    And param status = 'available'
    When method get
    Then status 200
    And assert responseTime < 30000
