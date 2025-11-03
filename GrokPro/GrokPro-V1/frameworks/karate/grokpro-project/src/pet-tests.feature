
Feature: Pet API Risk-Based Comprehensive Tests

  Background:
    * url baseUrl

  Scenario: Add a new pet to the store successfully
    Given path 'pet'
    And request { id: 12345, name: 'Fluffy', status: 'available', category: { name: 'Dog' } }
    When method post
    Then status 200
    And match response.name == 'Fluffy'

  Scenario: Fail to add a pet with invalid data
    Given path 'pet'
    And request { id: 12346 }
    When method post
    Then status 405

  Scenario: Update an existing pet successfully
    Given path 'pet'
    And request { id: 12345, name: 'Fluffy Updated', status: 'available', category: { name: 'Dog' } }
    When method put
    Then status 200
    And match response.name == 'Fluffy Updated'

  Scenario: Fail to update a non-existent pet
    Given path 'pet'
    And request { id: 999999, name: 'Ghost Pet' }
    When method put
    Then status 404

  Scenario: Find pets by status successfully
    Given path 'pet/findByStatus'
    And param status = 'available'
    When method get
    Then status 200
    And match each response == '#object'
    And match each response.status == 'available'

  Scenario: Find pets by invalid status
    Given path 'pet/findByStatus'
    And param status = 'invalid'
    When method get
    Then status 200
    And match response == '#[]'

  Scenario: Get pet by ID successfully
    Given path 'pet', 12345
    When method get
    Then status 200
    And match response.id == 12345

  Scenario: Fail to get pet by non-existent ID
    Given path 'pet', 999999
    When method get
    Then status 404

  Scenario: Update pet with form data successfully
    Given path 'pet', 12345
    And multipart field name = 'Updated Name'
    And multipart field status = 'sold'
    When method post
    Then status 200

  Scenario: Delete a pet successfully
    Given path 'pet', 12345
    When method delete
    Then status 200

  Scenario: Fail to delete non-existent pet
    Given path 'pet', 999999
    When method delete
    Then status 404

  Scenario: Upload image for pet successfully
    Given path 'pet', 12345, 'uploadImage'
    And multipart file file = { read: 'classpath:sample.jpg', filename: 'sample.jpg', contentType: 'image/jpeg' }
    When method post
    Then status 200
