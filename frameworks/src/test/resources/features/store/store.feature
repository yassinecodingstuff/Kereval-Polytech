Feature: Store API - Order and Inventory Management
  Background:
    * url 'https://petstore.swagger.io/v2'
    * configure headers = { 'api_key': 'special-key', 'Content-Type': 'application/json' }

  @critical @inventory
  Scenario: Get store inventory
    Given path 'store/inventory'
    When method get
    Then status 200
    And match each response contains '#number'
    And match response.available >= 0

  @high @order-create
  Scenario: Place an order for a pet
    * def order = { id: 3001, petId: 1003, quantity: 1, shipDate: '2025-11-04T10:00:00Z', status: 'placed', complete: true }
    Given path 'store/order'
    And request order
    When method post
    Then status 200
    And match response.petId == order.petId
    * def orderId = response.id
    Given path 'store/order', orderId
    When method get
    Then status 200
    And match response.id == orderId

  @high @order-invalid
  Scenario: Place an order with invalid quantity
    * def order = { id: 3002, petId: 1003, quantity: -2 }
    Given path 'store/order'
    And request order
    When method post
    Then status 400

  @medium @order-delete
  Scenario: Delete an order and verify retrieval fails
    * def id = 3001
    Given path 'store/order', id
    When method delete
    Then status 200
    Given path 'store/order', id
    When method get
    Then status 404
