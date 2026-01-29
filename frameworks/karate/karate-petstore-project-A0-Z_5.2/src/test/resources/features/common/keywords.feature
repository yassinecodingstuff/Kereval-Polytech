Feature: Common Keywords — reusable API actions

  Background:
    * url baseUrl
    * configure headers = { Accept: 'application/json' }

  @CreatePetJson
  Scenario: Create Pet (JSON)
    * def petId = __arg.petId
    * def name = __arg.name
    * def status = __arg.status
    * def photoUrl = __arg.photoUrl
    * def withAuth = __arg.withAuth == null ? true : __arg.withAuth
    * header Content-Type = 'application/json'
    * if (withAuth) header Authorization = 'Bearer ' + writePetsToken
    * def pet =
      """
      {
        "id": #(petId),
        "name": "#(name)",
        "photoUrls": ["#(photoUrl)"],
        "status": "#(status)"
      }
      """
    Given path 'pet'
    And request pet
    When method post
    Then status 200
    * def createdPet = response

  @CreateOrderJson
  Scenario: Create Order (JSON)
    * def orderId = __arg.orderId
    * def petId = __arg.petId
    * def quantity = __arg.quantity == null ? 1 : __arg.quantity
    * def shipDate = __arg.shipDate == null ? '2030-01-01T00:00:00Z' : __arg.shipDate
    * def status = __arg.status == null ? 'placed' : __arg.status
    * def complete = __arg.complete == null ? false : __arg.complete
    * header Content-Type = 'application/json'
    * def order =
      """
      {
        "id": #(orderId),
        "petId": #(petId),
        "quantity": #(quantity),
        "shipDate": "#(shipDate)",
        "status": "#(status)",
        "complete": #(complete)
      }
      """
    Given path 'store', 'order'
    And request order
    When method post
    Then status 200
    * def createdOrder = response

  @CreateUserJson
  Scenario: Create User (JSON)
    * def user = __arg.user
    * header Content-Type = 'application/json'
    Given path 'user'
    And request user
    When method post
    Then status 200
