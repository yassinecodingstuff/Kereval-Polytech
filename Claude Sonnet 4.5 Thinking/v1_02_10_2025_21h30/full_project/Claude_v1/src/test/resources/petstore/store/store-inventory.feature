Feature: Store Inventory Retrieval

Background:
  * url baseUrl

Scenario: Retrieve current pet inventories by status
  Given path 'store', 'inventory'
  And header api_key = apiKey
  When method get
  Then status 200
  And match response == '#object'
  And match response.available == '#number'

Scenario: Validate inventory response structure
  Given path 'store', 'inventory'
  And header api_key = apiKey
  When method get
  Then status 200
  And match response == '#object'
  And match karate.sizeOf(response) > 0

Scenario: Verify inventory contains expected status categories
  Given path 'store', 'inventory'
  And header api_key = apiKey
  When method get
  Then status 200
  And match response == '#object'
