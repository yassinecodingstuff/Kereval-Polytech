Feature: Store Management API

  Background:
    * url 'https://petstore.swagger.io/v2'

  @store @smoke @high
  Scenario: Place a new order with valid data
    Given path '/store/order'
    And request { "petId": 1, "quantity": 1, "shipDate": "2025-12-01T10:00:00Z", "status": "placed", "complete": false }
    And header Content-Type = 'application/json'
    When method POST
    Then status 200
    And match response.status == 'placed'

  @store @negative @high
  Scenario: Place a new order with invalid data
    Given path '/store/order'
    And request { "petId": -1, "quantity": 0, "status": "invalid_status" }
    And header Content-Type = 'application/json'
    When method POST
    Then status 400
    And match response contains { "code": 400, "type": "unknown", "message": "Invalid Order" }

  @store @smoke @high
  Scenario: Find purchase order by valid ID
    Given path '/store/order/1'
    When method GET
    Then status 200
    And match response.id == 1

  @store @negative @high
  Scenario: Find purchase order by invalid ID
    Given path '/store/order/-1'
    When method GET
    Then status 400
    And match response contains { "code": 400, "type": "unknown", "message": "Invalid ID supplied" }

  @store @smoke @high
  Scenario: Delete purchase order by valid ID
    Given path '/store/order/1'
    When method DELETE
    Then status 200
    And match response contains { "code": 200, "type": "unknown", "message": "1" }

  @store @negative @high
  Scenario: Delete purchase order by invalid ID
    Given path '/store/order/-1'
    When method DELETE
    Then status 400
    And match response contains { "code": 400, "type": "unknown", "message": "Invalid ID supplied" }

  @store @medium
  Scenario: Get inventory status
    Given path '/store/inventory'
    When method GET
    Then status 200
    And match response contains { "available": "#number", "pending": "#number", "sold": "#number" }