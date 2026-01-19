Feature: Pet Management API

  Background:
    * url 'https://petstore.swagger.io/v2'

  @smoke @high-priority
  Scenario: Add a new pet with valid data
    Given request { "id": 123, "name": "Max", "status": "available" }
    When method POST
    And path '/pet'
    Then status 200
    And match response == { "id": 123, "name": "Max", "status": "available" }

  @regression @medium-priority
  Scenario: Add a new pet with missing required fields
    Given request { "id": 123, "status": "available" }
    When method POST
    And path '/pet'
    Then status 400
    And match response contains { "message": "#string" }

  @regression @medium-priority
  Scenario: Add a new pet with invalid data type
    Given request { "id": "123", "name": "Max", "status": "available" }
    When method POST
    And path '/pet'
    Then status 400
    And match response contains { "message": "#string" }

  @smoke @high-priority
  Scenario: Update an existing pet with valid data
    Given request { "id": 123, "name": "Max Updated", "status": "sold" }
    When method PUT
    And path '/pet'
    Then status 200
    And match response == { "id": 123, "name": "Max Updated", "status": "sold" }

  @regression @medium-priority
  Scenario: Update a non-existent pet
    Given request { "id": 9999, "name": "Non-existent Pet", "status": "available" }
    When method PUT
    And path '/pet'
    Then status 404
    And match response contains { "message": "#string" }

  @smoke @high-priority
  Scenario: Find pet by valid ID
    When method GET
    And path '/pet/123'
    Then status 200
    And match response == { "id": 123, "name": "#string", "status": "#string" }

  @regression @medium-priority
  Scenario: Find pet by invalid ID
    When method GET
    And path '/pet/9999'
    Then status 404
    And match response contains { "message": "#string" }

  @regression @medium-priority
  Scenario: Find pet by invalid ID format
    When method GET
    And path '/pet/abc'
    Then status 400
    And match response contains { "message": "#string" }

  @smoke @high-priority
  Scenario: Find pets by valid status
    When method GET
    And path '/pet/findByStatus'
    And param status = 'available'
    Then status 200
    And match response[0].status == 'available'

  @regression @medium-priority
  Scenario: Find pets by invalid status
    When method GET
    And path '/pet/findByStatus'
    And param status = 'unknown'
    Then status 200
    And match response == []

  @smoke @high-priority
  Scenario: Delete an existing pet
    When method DELETE
    And path '/pet/123'
    Then status 200
    And match response contains { "message": "#string" }

  @regression @medium-priority
  Scenario: Delete a non-existent pet
    When method DELETE
    And path '/pet/9999'
    Then status 404
    And match response contains { "message": "#string" }
