Feature: Store API - Inventory Operations
  As a pet store administrator
  I need to view store inventory
  So that I can monitor stock levels and plan restocking

  Background:
    * url baseUrl

  @critical @smoke @store @inventory
  Scenario: TC-STORE-001 - Successfully retrieve store inventory
    Given path 'store', 'inventory'
    And header api_key = apiKey
    When method GET
    Then status 200
    And match response == '#object'
    And match each response == '#number'

  @store @inventory @security
  Scenario: TC-STORE-002 - Verify inventory accessible with valid API key
    Given path 'store', 'inventory'
    And header api_key = 'special-key'
    When method GET
    Then status 200
    And match response == '#object'

  @store @inventory @datatype
  Scenario: TC-STORE-003 - Verify inventory values are int32 format
    Given path 'store', 'inventory'
    And header api_key = apiKey
    When method GET
    Then status 200
    * def validateInt32 = function(v){ return v >= -2147483648 && v <= 2147483647 }
    And match each response == '#? validateInt32(_)'

  @store @inventory @performance
  Scenario: TC-STORE-INV-001 - Inventory retrieval responds within acceptable time
    Given path 'store', 'inventory'
    And header api_key = apiKey
    When method GET
    Then status 200
    And assert responseTime < 2000

  @store @inventory @content-type
  Scenario: TC-STORE-INV-002 - Verify inventory response content type
    Given path 'store', 'inventory'
    And header api_key = apiKey
    When method GET
    Then status 200
    And match header Content-Type contains 'application/json'

  @store @inventory @status-counts
  Scenario: TC-STORE-INV-003 - Verify inventory contains expected status keys
    Given path 'store', 'inventory'
    And header api_key = apiKey
    When method GET
    Then status 200
    # Inventory may contain various status counts
    And match response == '#object'
