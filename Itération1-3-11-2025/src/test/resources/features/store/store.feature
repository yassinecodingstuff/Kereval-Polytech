Feature: Store Inventory Management API

  Background:
    * url 'https://petstore.swagger.io/v2'

  @smoke @high-priority
  Scenario: Get inventory by valid status
    When method GET
    And path '/store/inventory'
    Then status 200
    And match response == "#map"

  @regression @medium-priority
  Scenario: Place a new order with valid data
    Given request { "petId": 123, "quantity": 1, "shipDate": "2025-12-01T00:00:00.000Z", "status": "placed" }
    When method POST
    And path '/store/order'
    Then status 200
    And match response == { "petId": 123, "quantity": 1, "status": "placed" }

  @regression @medium-priority
  Scenario: Place a new order with missing required fields
    Given request { "quantity": 1, "shipDate": "2025-12-01T00:00:00.000Z", "status": "placed" }
    When method POST
    And path '/store/order'
    Then status 400
    And match response contains { "message": "#string" }

  @regression @medium-priority
  Scenario: Get order by valid ID
    When method GET
    And path '/store/order/123'
    Then status 200
    And match response == { "id": 123, "petId": "#number", "quantity": "#number", "status": "#string" }

  @regression @medium-priority
  Scenario: Get order by invalid ID
    When method GET
    And path '/store/order/9999'
    Then status 404
    And match response contains { "message": "#string" }

  @regression @medium-priority
  Scenario: Delete an existing order
    When method DELETE
    And path '/store/order/123'
    Then status 200
    And match response contains { "message": "#string" }
