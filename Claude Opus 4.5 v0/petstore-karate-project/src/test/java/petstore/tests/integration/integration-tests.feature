Feature: Data Integrity and Cross-Endpoint Integration
  As a Petstore API consumer
  I want to verify data integrity across operations and integration between endpoints
  So that business workflows function correctly and data remains consistent
  
  Priority: MEDIUM - Integration Testing
  ISO/IEC/IEEE 29119 Alignment: Integration testing with end-to-end workflow coverage

  Background:
    * url baseUrl
    * def generateUniqueId = function(){ return Math.floor(Math.random() * 900000000) + 100000000 }
    * def generateUniqueUsername = function(prefix){ return prefix + '_' + Math.floor(Math.random() * 100000) + '_' + Date.now() }

  @high @integrity @crud @pet
  Scenario: TC-INT-001 - Verify pet data consistency through CRUD cycle
    * def petId = generateUniqueId()
    
    * def createPayload = { id: #(petId), name: 'IntegrityTestPet', category: { id: 1, name: 'Dogs' }, photoUrls: ['https://example.com/pet.jpg'], tags: [{ id: 1, name: 'friendly' }], status: 'available' }
    Given path 'pet'
    And header Content-Type = 'application/json'
    And request createPayload
    When method post
    Then status 200
    
    Given path 'pet', petId
    And header api_key = apiKey
    When method get
    Then status 200
    And match response.id == petId
    And match response.name == 'IntegrityTestPet'
    And match response.status == 'available'
    
    * def updatePayload = { id: #(petId), name: 'UpdatedIntegrityPet', category: { id: 1, name: 'Dogs' }, photoUrls: ['https://example.com/updated.jpg'], tags: [{ id: 1, name: 'friendly' }], status: 'sold' }
    Given path 'pet'
    And header Content-Type = 'application/json'
    And request updatePayload
    When method put
    Then status 200
    
    Given path 'pet', petId
    And header api_key = apiKey
    When method get
    Then status 200
    And match response.name == 'UpdatedIntegrityPet'
    And match response.status == 'sold'
    
    Given path 'pet', petId
    And header api_key = apiKey
    When method delete
    Then status 200
    
    Given path 'pet', petId
    And header api_key = apiKey
    When method get
    Then status 404

  @high @integrity @crud @order
  Scenario: TC-INT-002 - Verify order data consistency through CRUD cycle
    * def orderId = generateUniqueId()
    
    * def createPayload = { id: #(orderId), petId: 1, quantity: 2, status: 'placed', complete: false }
    Given path 'store', 'order'
    And header Content-Type = 'application/json'
    And request createPayload
    When method post
    Then status 200
    
    Given path 'store', 'order', orderId
    When method get
    Then status 200
    And match response.id == orderId
    And match response.petId == 1
    And match response.quantity == 2
    And match response.status == 'placed'
    And match response.complete == false
    
    Given path 'store', 'order', orderId
    When method delete
    Then status 200
    
    Given path 'store', 'order', orderId
    When method get
    Then status 404

  @high @integrity @crud @user
  Scenario: TC-INT-003 - Verify user data consistency through CRUD cycle
    * def username = generateUniqueUsername('integrity')
    * def userId = generateUniqueId()
    
    * def createPayload = { id: #(userId), username: '#(username)', firstName: 'Integrity', lastName: 'Test', email: '#(username + "@test.com")', password: 'Password123', phone: '1234567890', userStatus: 1 }
    Given path 'user'
    And header Content-Type = 'application/json'
    And request createPayload
    When method post
    Then status 200
    
    Given path 'user', username
    When method get
    Then status 200
    And match response.username == username
    And match response.firstName == 'Integrity'
    And match response.lastName == 'Test'
    
    * def updatePayload = { id: #(userId), username: '#(username)', firstName: 'UpdatedIntegrity', lastName: 'UpdatedTest', email: '#(username + "@updated.com")', password: 'NewPassword123', phone: '0987654321', userStatus: 2 }
    Given path 'user', username
    And header Content-Type = 'application/json'
    And request updatePayload
    When method put
    Then status 200
    
    Given path 'user', username
    When method get
    Then status 200
    And match response.firstName == 'UpdatedIntegrity'
    And match response.lastName == 'UpdatedTest'
    
    Given path 'user', username
    When method delete
    Then status 200
    
    Given path 'user', username
    When method get
    Then status 404

  @medium @integration @e2e
  Scenario: TC-E2E-001 - Complete pet purchase workflow
    * def username = generateUniqueUsername('buyer')
    * def petId = generateUniqueId()
    * def orderId = generateUniqueId()
    
    * def userPayload = { username: '#(username)', firstName: 'Pet', lastName: 'Buyer', email: '#(username + "@buyer.com")', password: 'BuyerPass123' }
    Given path 'user'
    And header Content-Type = 'application/json'
    And request userPayload
    When method post
    Then status 200
    
    Given path 'user', 'login'
    And param username = username
    And param password = 'BuyerPass123'
    When method get
    Then status 200
    
    * def petPayload = { id: #(petId), name: 'SaleablePet', photoUrls: ['https://example.com/pet.jpg'], status: 'available' }
    Given path 'pet'
    And header Content-Type = 'application/json'
    And request petPayload
    When method post
    Then status 200
    
    * def orderPayload = { id: #(orderId), petId: #(petId), quantity: 1, status: 'placed', complete: false }
    Given path 'store', 'order'
    And header Content-Type = 'application/json'
    And request orderPayload
    When method post
    Then status 200
    And match response.petId == petId
    
    Given path 'store', 'order', orderId
    When method get
    Then status 200
    And match response.petId == petId
    
    Given path 'user', 'logout'
    When method get
    Then status 200
    
    Given path 'store', 'order', orderId
    When method delete
    Then status 200
    
    Given path 'pet', petId
    And header api_key = apiKey
    When method delete
    Then status 200
    
    Given path 'user', username
    When method delete
    Then status 200

  @medium @integration @e2e
  Scenario: TC-E2E-002 - Pet status update reflects in findByStatus
    * def petId = generateUniqueId()
    
    * def petPayload = { id: #(petId), name: 'StatusTrackingPet', photoUrls: ['https://example.com/pet.jpg'], status: 'available' }
    Given path 'pet'
    And header Content-Type = 'application/json'
    And request petPayload
    When method post
    Then status 200
    
    Given path 'pet', 'findByStatus'
    And param status = 'available'
    When method get
    Then status 200
    * def availablePets = response
    * def foundInAvailable = karate.filter(availablePets, function(x){ return x.id == petId }).length > 0
    And assert foundInAvailable == true
    
    * def updatePayload = { id: #(petId), name: 'StatusTrackingPet', photoUrls: ['https://example.com/pet.jpg'], status: 'sold' }
    Given path 'pet'
    And header Content-Type = 'application/json'
    And request updatePayload
    When method put
    Then status 200
    
    Given path 'pet', 'findByStatus'
    And param status = 'available'
    When method get
    Then status 200
    * def availablePetsAfter = response
    * def stillInAvailable = karate.filter(availablePetsAfter, function(x){ return x.id == petId }).length > 0
    And assert stillInAvailable == false
    
    Given path 'pet', 'findByStatus'
    And param status = 'sold'
    When method get
    Then status 200
    * def soldPets = response
    * def foundInSold = karate.filter(soldPets, function(x){ return x.id == petId }).length > 0
    And assert foundInSold == true
    
    Given path 'pet', petId
    And header api_key = apiKey
    When method delete
    Then status 200

  @medium @integrity @referential
  Scenario: TC-INT-004 - Verify order maintains pet reference integrity
    * def petId = generateUniqueId()
    * def orderId = generateUniqueId()
    
    * def petPayload = { id: #(petId), name: 'ReferencedPet', photoUrls: ['https://example.com/pet.jpg'], status: 'available' }
    Given path 'pet'
    And header Content-Type = 'application/json'
    And request petPayload
    When method post
    Then status 200
    
    * def orderPayload = { id: #(orderId), petId: #(petId), quantity: 1, status: 'placed', complete: false }
    Given path 'store', 'order'
    And header Content-Type = 'application/json'
    And request orderPayload
    When method post
    Then status 200
    And match response.petId == petId
    
    Given path 'store', 'order', orderId
    When method get
    Then status 200
    And match response.petId == petId
    
    Given path 'store', 'order', orderId
    When method delete
    Then status 200
    
    Given path 'pet', petId
    And header api_key = apiKey
    When method delete
    Then status 200

  @medium @integration @inventory
  Scenario: TC-E2E-003 - Verify inventory reflects pet status distribution
    Given path 'store', 'inventory'
    And header api_key = apiKey
    When method get
    Then status 200
    * def initialInventory = response
    
    * def pet1 = generateUniqueId()
    Given path 'pet'
    And header Content-Type = 'application/json'
    And request { id: #(pet1), name: 'InventoryPet1', photoUrls: ['https://example.com/pet.jpg'], status: 'available' }
    When method post
    Then status 200
    
    * def pet2 = generateUniqueId()
    Given path 'pet'
    And header Content-Type = 'application/json'
    And request { id: #(pet2), name: 'InventoryPet2', photoUrls: ['https://example.com/pet.jpg'], status: 'available' }
    When method post
    Then status 200
    
    Given path 'store', 'inventory'
    And header api_key = apiKey
    When method get
    Then status 200
    * def updatedInventory = response
    
    Given path 'pet'
    And header Content-Type = 'application/json'
    And request { id: #(pet1), name: 'InventoryPet1', photoUrls: ['https://example.com/pet.jpg'], status: 'sold' }
    When method put
    Then status 200
    
    Given path 'store', 'inventory'
    And header api_key = apiKey
    When method get
    Then status 200
    * def finalInventory = response
    
    Given path 'pet', pet1
    And header api_key = apiKey
    When method delete
    Then status 200
    
    Given path 'pet', pet2
    And header api_key = apiKey
    When method delete
    Then status 200
