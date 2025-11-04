Feature: Comprehensive Store Management API Tests
  Background:
    * url baseUrl = 'https://petstore.swagger.io/v2'
    * configure headers = { 'Content-Type': 'application/json' }

  # Positive Scenarios
  Scenario: Place a new order
    Given path '/store/order'
    And request { id: 5001, petId: 1001, quantity: 2, shipDate: '2025-11-04T10:00:00Z', status: 'placed', complete: true }
    When method post
    Then status 200
    And match response.status == 'placed'

  Scenario: Retrieve an existing order
    Given path '/store/order/5001'
    When method get
    Then status 200
    And match response.id == 5001

  Scenario: Get store inventory
    Given path '/store/inventory'
    When method get
    Then status 200
    And match response contains { available: '#number' }

  Scenario: Delete an existing order
    Given path '/store/order/5001'
    When method delete
    Then status 200
    And match response.message == '5001'

  # Negative Scenarios
  Scenario: Retrieve non-existent order
    Given path '/store/order/9999'
    When method get
    Then status 404

  Scenario: Place order with invalid data
    Given path '/store/order'
    And request { petId: 'abc', quantity: 'x' }
    When method post
    Then status 400

  Scenario: Delete order with invalid ID
    Given path '/store/order/xyz'
    When method delete
    Then status 400
