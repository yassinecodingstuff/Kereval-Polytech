Feature: Petstore API - Contract, Performance, and Security Validation
  Background:
    * url baseUrl
    * header api_key = apiKey
    * configure headers = { 'Content-Type': 'application/json' }

  @contract @schema
  Scenario: Validate response schema for core endpoints
    Given path 'pet'
    And request { id: 9001, name: 'TestPet', status: 'available' }
    When method post
    Then status 200
    And match response contains { id: '#number', name: '#string', status: '#string' }
    Given path 'store/inventory'
    When method get
    Then status 200

  @robustness @malformed
  Scenario: Send malformed JSON
    Given path 'pet'
    And header Content-Type = 'application/json'
    And request '{"id":1004,"name":"invalidJson}'
    When method post
    Then status 400

  @security @content-type
  Scenario: Invalid Content-Type
    Given path 'pet'
    And header Content-Type = 'text/plain'
    And request 'plain text'
    When method post
    Then status 415
