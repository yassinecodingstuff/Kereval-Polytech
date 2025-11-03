
Feature: Store API Risk-Based Comprehensive Tests

  Background:
    * url baseUrl

  Scenario: Get store inventory successfully
    Given path 'store/inventory'
    When method get
    Then status 200
    And match response == '#object'

  Scenario: Place an order successfully
    Given path 'store/order'
    And request { id: 1, petId: 12345, quantity: 1, status: 'placed' }
    When method post
    Then status 200
    And match response.status == 'placed'

  Scenario: Fail to place order with invalid data
    Given path 'store/order'
    And request { quantity: 1 }
    When method post
    Then status 405

  Scenario: Get order by ID successfully
    Given path 'store/order', 1
    When method get
    Then status 200
    And match response.id == 1

  Scenario: Fail to get non-existent order
    Given path 'store/order', 999999
    When method get
    Then status 404

  Scenario: Delete order successfully
    Given path 'store/order', 1
    When method delete
    Then status 200

  Scenario: Fail to delete non-existent order
    Given path 'store/order', 999999
    When method delete
    Then status 404
