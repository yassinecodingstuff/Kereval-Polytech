Feature: Store Order Processing
  As a test automation engineer
  I want to verify the Store ordering system
  So that I can ensure pet orders are processed correctly

  Background:
    * url 'https://petstore.swagger.io/v2'
    * def getRandomId = function(){ return Math.floor(Math.random() * 100000000) + 1 }
    * def orderId = getRandomId()
    * def petId = getRandomId()
    * def shipDate = '2025-12-01T12:00:00.000+0000'

  Scenario: Successfully place an order for a pet
    Given path 'store', 'order'
    And request
    """
    {
      "id": #(orderId),
      "petId": #(petId),
      "quantity": 1,
      "shipDate": "#(shipDate)",
      "status": "placed",
      "complete": true
    }
    """
    When method post
    Then status 200
    And match response.id == orderId

  Scenario: Retrieve a valid order by ID
    Given path 'store', 'order'
    And request { "id": #(orderId), "petId": #(petId), "quantity": 5, "status": "approved", "complete": false }
    When method post
    Then status 200

    Given path 'store', 'order', orderId
    When method get
    Then status 200
    And match response.id == orderId

  Scenario: Reject order deletion with non-numeric ID
    Given path 'store', 'order', 'abc-not-a-number'
    When method delete
    Then status 400

  Scenario: Verify Store Inventory returns correct data structure
    Given path 'store', 'inventory'
    When method get
    Then status 200
    And match response == '#object'
    And match response['sold'] == '#number'