Feature: Pet Management API

  Background:
    * url 'https://petstore.swagger.io/v2'

  @pet @smoke @high
  Scenario: Add a new pet to the store with valid data
    Given path '/pet'
    And request { "name": "Max", "photoUrls": ["https://example.com/max.jpg"], "status": "available" }
    And header Content-Type = 'application/json'
    When method POST
    Then status 200
    And match response.name == 'Max'
    And match response.photoUrls[0] == 'https://example.com/max.jpg'
    And match response.status == 'available'

  @pet @negative @high
  Scenario: Add a new pet to the store with invalid data
    Given path '/pet'
    And request { "name": "", "photoUrls": [] }
    And header Content-Type = 'application/json'
    When method POST
    Then status 405
    And match response contains { "code": 405, "type": "unknown", "message": "Invalid input" }

  @pet @smoke @high
  Scenario: Update an existing pet with valid data
    Given path '/pet'
    And request { "id": 1, "name": "Buddy", "photoUrls": ["https://example.com/buddy.jpg"], "status": "pending" }
    And header Content-Type = 'application/json'
    When method PUT
    Then status 200
    And match response.name == 'Buddy'
    And match response.status == 'pending'

  @pet @negative @high
  Scenario: Update an existing pet with invalid ID
    Given path '/pet'
    And request { "id": -1, "name": "Buddy", "photoUrls": ["https://example.com/buddy.jpg"], "status": "pending" }
    And header Content-Type = 'application/json'
    When method PUT
    Then status 400
    And match response contains { "code": 400, "type": "unknown", "message": "Invalid ID supplied" }

  @pet @smoke @high
  Scenario: Find pets by status
    Given path '/pet/findByStatus'
    And param status = 'available'
    When method GET
    Then status 200
    And match each response[*] == { "status": "available" }

  @pet @negative @high
  Scenario: Find pets by invalid status
    Given path '/pet/findByStatus'
    And param status = 'invalid_status'
    When method GET
    Then status 400
    And match response contains { "code": 400, "type": "unknown", "message": "Invalid status value" }

  @pet @smoke @high
  Scenario: Find pet by valid ID
    Given path '/pet/1'
    When method GET
    Then status 200
    And match response.id == 1

  @pet @negative @high
  Scenario: Find pet by invalid ID
    Given path '/pet/-1'
    When method GET
    Then status 400
    And match response contains { "code": 400, "type": "unknown", "message": "Invalid ID supplied" }

  @pet @smoke @high
  Scenario: Delete a pet with valid ID
    Given path '/pet/1'
    And header api_key = 'special-key'
    When method DELETE
    Then status 200
    And match response contains { "code": 200, "type": "unknown", "message": "1" }

  @pet @negative @high
  Scenario: Delete a pet with invalid ID
    Given path '/pet/-1'	
    And header api_key = 'special-key'
    When method DELETE
    Then status 400
    And match response contains { "code": 400, "type": "unknown", "message": "Invalid ID supplied" }

  @pet @medium
  Scenario: Upload an image for a pet
    Given path '/pet/1/uploadImage'
    And header Content-Type = 'multipart/form-data'
    And multipart file = { read: 'classpath:pet_image.jpg', filename: 'pet_image.jpg', contentType: 'image/jpeg' }
    And multipart field additionalMetadata = 'sample metadata'
    When method POST
    Then status 200
    And match response.code == 200