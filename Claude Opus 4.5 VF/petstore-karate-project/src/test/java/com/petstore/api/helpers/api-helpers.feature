@ignore
Feature: Common Helper Functions
  Reusable helper scenarios for API operations

  Background:
    * url baseUrl

  @ignore
  Scenario: createPet
    * def petId = __arg.petId || karate.call('classpath:com/petstore/api/helpers/generators.feature@generatePetId').result
    * def petName = __arg.name || 'TestPet'
    * def petStatus = __arg.status || 'available'
    * def photoUrls = __arg.photoUrls || ['https://example.com/pet.jpg']
    * def category = __arg.category || { id: 1, name: 'Dogs' }
    * def tags = __arg.tags || [{ id: 1, name: 'test' }]
    Given path 'pet'
    And header Content-Type = 'application/json'
    And request
      """
      {
        "id": #(petId),
        "name": "#(petName)",
        "category": #(category),
        "photoUrls": #(photoUrls),
        "tags": #(tags),
        "status": "#(petStatus)"
      }
      """
    When method POST
    Then status 200
    * def createdPet = response

  @ignore
  Scenario: getPet
    * def petId = __arg.petId
    Given path 'pet', petId
    And header api_key = apiKey
    When method GET

  @ignore
  Scenario: updatePet
    * def pet = __arg.pet
    Given path 'pet'
    And header Content-Type = 'application/json'
    And request pet
    When method PUT

  @ignore
  Scenario: deletePet
    * def petId = __arg.petId
    Given path 'pet', petId
    And header api_key = apiKey
    When method DELETE

  @ignore
  Scenario: findPetsByStatus
    * def status = __arg.status || 'available'
    Given path 'pet', 'findByStatus'
    And param status = status
    When method GET

  @ignore
  Scenario: createOrder
    * def petId = __arg.petId
    * def quantity = __arg.quantity || 1
    * def status = __arg.status || 'placed'
    * def complete = __arg.complete || false
    * def shipDate = __arg.shipDate || new Date().toISOString()
    Given path 'store', 'order'
    And header Content-Type = 'application/json'
    And request
      """
      {
        "petId": #(petId),
        "quantity": #(quantity),
        "shipDate": "#(shipDate)",
        "status": "#(status)",
        "complete": #(complete)
      }
      """
    When method POST
    Then status 200
    * def createdOrder = response

  @ignore
  Scenario: getOrder
    * def orderId = __arg.orderId
    Given path 'store', 'order', orderId
    When method GET

  @ignore
  Scenario: deleteOrder
    * def orderId = __arg.orderId
    Given path 'store', 'order', orderId
    When method DELETE

  @ignore
  Scenario: getInventory
    Given path 'store', 'inventory'
    And header api_key = apiKey
    When method GET
    Then status 200
    * def inventory = response

  @ignore
  Scenario: createUser
    * def username = __arg.username || karate.call('classpath:com/petstore/api/helpers/generators.feature@generateUsername').result
    * def firstName = __arg.firstName || 'Test'
    * def lastName = __arg.lastName || 'User'
    * def email = __arg.email || username + '@test.com'
    * def password = __arg.password || 'TestPassword123!'
    * def phone = __arg.phone || '555-1234'
    * def userStatus = __arg.userStatus || 1
    Given path 'user'
    And header Content-Type = 'application/json'
    And request
      """
      {
        "username": "#(username)",
        "firstName": "#(firstName)",
        "lastName": "#(lastName)",
        "email": "#(email)",
        "password": "#(password)",
        "phone": "#(phone)",
        "userStatus": #(userStatus)
      }
      """
    When method POST
    Then status 200
    * def createdUser = { username: '#(username)', password: '#(password)' }

  @ignore
  Scenario: getUser
    * def username = __arg.username
    Given path 'user', username
    When method GET

  @ignore
  Scenario: updateUser
    * def username = __arg.username
    * def userData = __arg.userData
    Given path 'user', username
    And header Content-Type = 'application/json'
    And request userData
    When method PUT

  @ignore
  Scenario: deleteUser
    * def username = __arg.username
    Given path 'user', username
    When method DELETE

  @ignore
  Scenario: loginUser
    * def username = __arg.username
    * def password = __arg.password
    Given path 'user', 'login'
    And param username = username
    And param password = password
    When method GET
    Then status 200
    * def sessionToken = response

  @ignore
  Scenario: logoutUser
    Given path 'user', 'logout'
    When method GET
    Then status 200
