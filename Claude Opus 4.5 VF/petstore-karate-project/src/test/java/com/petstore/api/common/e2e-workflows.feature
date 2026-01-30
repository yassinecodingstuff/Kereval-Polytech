Feature: End-to-End Business Workflows
  As a pet store system
  I need to support complete business workflows
  So that the entire customer journey functions correctly

  Background:
    * url baseUrl
    * def generatePetId = function(){ return Math.floor(Math.random() * 900000) + 100000 }
    * def generateUsername = function(){ return 'e2e_user_' + Math.floor(Math.random() * 1000000) }

  @e2e @critical @workflow
  Scenario: TC-E2E-001 - Complete pet purchase workflow
    # Step 1: Create a new user
    * def customerUsername = generateUsername()
    Given path 'user'
    And header Content-Type = 'application/json'
    And request
      """
      {
        "username": "#(customerUsername)",
        "firstName": "E2E",
        "lastName": "Customer",
        "email": "e2e.customer@test.com",
        "password": "e2ePassword123",
        "phone": "555-E2E1",
        "userStatus": 1
      }
      """
    When method POST
    Then status 200
    
    # Step 2: Login the user
    Given path 'user', 'login'
    And param username = customerUsername
    And param password = 'e2ePassword123'
    When method GET
    Then status 200
    * def sessionToken = response
    And match responseHeaders['X-Expires-After'] == '#present'
    
    # Step 3: Create a pet for purchase
    * def petId = generatePetId()
    Given path 'pet'
    And request { id: #(petId), name: 'E2EPurchasePet', photoUrls: ['https://example.com/e2e.jpg'], status: 'available' }
    When method POST
    Then status 200
    
    # Step 4: View pet details
    Given path 'pet', petId
    And header api_key = apiKey
    When method GET
    Then status 200
    And match response.status == 'available'
    
    # Step 5: Place order for the pet
    Given path 'store', 'order'
    And header Content-Type = 'application/json'
    And request
      """
      {
        "petId": #(petId),
        "quantity": 1,
        "status": "placed",
        "complete": false
      }
      """
    When method POST
    Then status 200
    * def orderId = response.id
    And match response.petId == petId
    And match response.status == 'placed'
    
    # Step 6: Verify order was created
    Given path 'store', 'order', orderId
    When method GET
    Then status 200
    And match response.id == orderId
    And match response.petId == petId
    
    # Step 7: Update pet status to sold
    Given path 'pet'
    And header Content-Type = 'application/json'
    And request
      """
      {
        "id": #(petId),
        "name": "E2EPurchasePet",
        "photoUrls": ["https://example.com/e2e.jpg"],
        "status": "sold"
      }
      """
    When method PUT
    Then status 200
    And match response.status == 'sold'
    
    # Step 8: Logout user
    Given path 'user', 'logout'
    When method GET
    Then status 200
    
    # Cleanup: Delete the test user
    Given path 'user', customerUsername
    When method DELETE
    Then status 200

  @e2e @workflow
  Scenario: TC-E2E-002 - Pet inventory management workflow
    # Step 1: Check current inventory
    Given path 'store', 'inventory'
    And header api_key = apiKey
    When method GET
    Then status 200
    * def initialInventory = response
    
    # Step 2: Add a new pet
    * def petId = generatePetId()
    Given path 'pet'
    And header Content-Type = 'application/json'
    And request
      """
      {
        "id": #(petId),
        "name": "InventoryPet",
        "photoUrls": ["https://example.com/inventory.jpg"],
        "status": "available"
      }
      """
    When method POST
    Then status 200
    
    # Step 3: Verify pet was added
    Given path 'pet', petId
    And header api_key = apiKey
    When method GET
    Then status 200
    And match response.status == 'available'
    
    # Step 4: Update pet to sold
    Given path 'pet'
    And header Content-Type = 'application/json'
    And request
      """
      {
        "id": #(petId),
        "name": "InventoryPet",
        "photoUrls": ["https://example.com/inventory.jpg"],
        "status": "sold"
      }
      """
    When method PUT
    Then status 200
    And match response.status == 'sold'
    
    # Step 5: Verify pet status changed
    Given path 'pet', petId
    And header api_key = apiKey
    When method GET
    Then status 200
    And match response.status == 'sold'
    
    # Step 6: Delete the pet
    Given path 'pet', petId
    And header api_key = apiKey
    When method DELETE
    Then status 200
    
    # Step 7: Verify pet is deleted
    Given path 'pet', petId
    And header api_key = apiKey
    When method GET
    Then status 404

  @e2e @workflow
  Scenario: TC-E2E-003 - User account lifecycle workflow
    * def username = generateUsername()
    
    # Step 1: Create user
    Given path 'user'
    And header Content-Type = 'application/json'
    And request
      """
      {
        "username": "#(username)",
        "firstName": "Lifecycle",
        "lastName": "User",
        "email": "lifecycle@test.com",
        "password": "lifecyclePass123",
        "phone": "555-LIFE",
        "userStatus": 1
      }
      """
    When method POST
    Then status 200
    
    # Step 2: Verify user was created
    Given path 'user', username
    When method GET
    Then status 200
    And match response.username == username
    And match response.firstName == 'Lifecycle'
    And match response.email == 'lifecycle@test.com'
    
    # Step 3: Login
    Given path 'user', 'login'
    And param username = username
    And param password = 'lifecyclePass123'
    When method GET
    Then status 200
    And match response == '#string'
    
    # Step 4: Update user information
    Given path 'user', username
    And header Content-Type = 'application/json'
    And request
      """
      {
        "username": "#(username)",
        "firstName": "Updated",
        "lastName": "UserName",
        "email": "updated.lifecycle@test.com",
        "password": "newLifecyclePass456",
        "phone": "555-UPDT",
        "userStatus": 1
      }
      """
    When method PUT
    Then status 200
    
    # Step 5: Verify update
    Given path 'user', username
    When method GET
    Then status 200
    And match response.firstName == 'Updated'
    And match response.email == 'updated.lifecycle@test.com'
    
    # Step 6: Logout
    Given path 'user', 'logout'
    When method GET
    Then status 200
    
    # Step 7: Delete user
    Given path 'user', username
    When method DELETE
    Then status 200
    
    # Step 8: Verify deletion
    Given path 'user', username
    When method GET
    Then status 404

  @e2e @workflow @order-lifecycle
  Scenario: TC-E2E-004 - Order status lifecycle workflow
    * def petId = generatePetId()
    
    # Create a pet first
    Given path 'pet'
    And request { id: #(petId), name: 'OrderLifecyclePet', photoUrls: ['https://example.com/order.jpg'], status: 'available' }
    When method POST
    Then status 200
    
    # Step 1: Place order with status 'placed'
    Given path 'store', 'order'
    And header Content-Type = 'application/json'
    And request
      """
      {
        "petId": #(petId),
        "quantity": 1,
        "status": "placed",
        "complete": false
      }
      """
    When method POST
    Then status 200
    * def orderId = response.id
    And match response.status == 'placed'
    And match response.complete == false
    
    # Step 2: Verify order status
    Given path 'store', 'order', orderId
    When method GET
    Then status 200
    And match response.status == 'placed'
    
    # Step 3: Check inventory
    Given path 'store', 'inventory'
    And header api_key = apiKey
    When method GET
    Then status 200
    
    # Step 4: Delete order
    Given path 'store', 'order', orderId
    When method DELETE
    Then status 200
    
    # Step 5: Verify order is deleted
    Given path 'store', 'order', orderId
    When method GET
    Then status 404
    
    # Cleanup pet
    Given path 'pet', petId
    And header api_key = apiKey
    When method DELETE
    Then status 200

  @e2e @workflow @data-consistency
  Scenario: TC-E2E-005 - Data consistency across operations
    * def petId = generatePetId()
    * def petName = 'ConsistencyPet_' + petId
    
    # Create pet
    Given path 'pet'
    And request 
      """
      { 
        id: #(petId), 
        name: '#(petName)', 
        photoUrls: ['https://example.com/consistency.jpg'], 
        status: 'available',
        category: { id: 100, name: 'TestCategory' },
        tags: [{ id: 200, name: 'TestTag' }]
      }
      """
    When method POST
    Then status 200
    * def createdPet = response
    
    # Verify GET returns same data
    Given path 'pet', petId
    And header api_key = apiKey
    When method GET
    Then status 200
    And match response.id == createdPet.id
    And match response.name == createdPet.name
    
    # Verify findByStatus includes the pet
    Given path 'pet', 'findByStatus'
    And param status = 'available'
    When method GET
    Then status 200
    * def foundPet = karate.filter(response, function(x){ return x.id == petId })
    And match foundPet == '#[1]'
    
    # Update and verify consistency
    Given path 'pet'
    And request { id: #(petId), name: '#(petName)', photoUrls: ['https://example.com/consistency.jpg'], status: 'sold' }
    When method PUT
    Then status 200
    
    # Verify update reflected in GET
    Given path 'pet', petId
    And header api_key = apiKey
    When method GET
    Then status 200
    And match response.status == 'sold'
    
    # Verify findByStatus reflects change
    Given path 'pet', 'findByStatus'
    And param status = 'sold'
    When method GET
    Then status 200
    * def foundSoldPet = karate.filter(response, function(x){ return x.id == petId })
    And match foundSoldPet == '#[1]'
    
    # Cleanup
    Given path 'pet', petId
    And header api_key = apiKey
    When method DELETE
    Then status 200
