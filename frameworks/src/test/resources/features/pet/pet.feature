Feature: Comprehensive Pet Management API Tests
  Background:
    * url baseUrl = 'https://petstore.swagger.io/v2'
    * configure headers = { 'Content-Type': 'application/json' }

  # Positive Scenarios
  Scenario: Create a new pet successfully
    Given path '/pet'
    And request { id: 1001, name: 'Fluffy', photoUrls: ['img1.jpg'], status: 'available' }
    When method post
    Then status 200
    And match response.name == 'Fluffy'
    And match response.status == 'available'

  Scenario: Retrieve an existing pet by ID
    Given path '/pet/1001'
    When method get
    Then status 200
    And match response.id == 1001

  Scenario: Update an existing pet
    Given path '/pet'
    And request { id: 1001, name: 'FluffyUpdated', status: 'sold' }
    When method put
    Then status 200
    And match response.status == 'sold'

  Scenario: Find pets by status
    Given path '/pet/findByStatus'
    And param status = 'available'
    When method get
    Then status 200
    And match each response contains { status: 'available' }

  Scenario: Find pets by tags
    Given path '/pet/findByTags'
    And param tags = 'cute'
    When method get
    Then status 200

  Scenario: Upload an image for a pet
    * def filePath = karate.readAsString('classpath:files/dog.jpg')
    Given path '/pet/1001/uploadImage'
    And multipart file file = { read: 'classpath:files/dog.jpg', filename: 'dog.jpg', contentType: 'image/jpeg' }
    When method post
    Then status 200
    And match response.message contains 'dog.jpg'

  Scenario: Delete a pet
    Given path '/pet/1001'
    When method delete
    Then status 200
    And match response.message == '1001'

  # Negative Scenarios
  Scenario: Retrieve a non-existent pet
    Given path '/pet/999999'
    When method get
    Then status 404

  Scenario: Add pet with invalid JSON
    Given path '/pet'
    And request { invalid: }
    When method post
    Then status 400

  Scenario: Delete a pet with invalid ID
    Given path '/pet/abc'
    When method delete
    Then status 400
