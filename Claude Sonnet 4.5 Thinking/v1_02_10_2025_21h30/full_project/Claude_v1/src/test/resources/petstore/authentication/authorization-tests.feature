Feature: Authorization Tests

Background:
  * url baseUrl

Scenario: Access store inventory with valid API key
  Given path 'store', 'inventory'
  And header api_key = apiKey
  When method get
  Then status 200

Scenario: Verify API responds to requests without authorization
  Given path 'pet', 'findByStatus'
  And param status = 'available'
  When method get
  Then status 200
