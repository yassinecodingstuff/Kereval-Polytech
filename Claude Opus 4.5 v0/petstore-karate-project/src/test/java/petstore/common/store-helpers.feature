@ignore
Feature: Store API Reusable Scenarios
  Reusable background scenarios for Store API testing
  ISO/IEC/IEEE 29119-5 Keyword-Driven Testing Support

  Background:
    * url baseUrl
    * def utils = call read('classpath:petstore/common/common-utils.feature')

  @ignore @reusable
  Scenario: Get store inventory helper
    Given path 'store', 'inventory'
    And header api_key = apiKey
    And header Accept = 'application/json'
    When method get

  @ignore @reusable
  Scenario: Place order helper
    * def orderId = __arg.orderId || utils.generateUniqueId()
    * def petId = __arg.petId || 1
    * def quantity = __arg.quantity || 1
    * def orderStatus = __arg.status || 'placed'
    * def complete = __arg.complete || false
    * def shipDate = __arg.shipDate || null
    
    * def orderPayload = { id: #(orderId), petId: #(petId), quantity: #(quantity), status: '#(orderStatus)', complete: #(complete) }
    * if (shipDate != null) orderPayload.shipDate = shipDate
    
    Given path 'store', 'order'
    And header Content-Type = 'application/json'
    And header Accept = 'application/json'
    And request orderPayload
    When method post

  @ignore @reusable
  Scenario: Get order by ID helper
    * def orderId = __arg.orderId
    Given path 'store', 'order', orderId
    And header Accept = 'application/json'
    When method get

  @ignore @reusable
  Scenario: Delete order helper
    * def orderId = __arg.orderId
    Given path 'store', 'order', orderId
    When method delete
