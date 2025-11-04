Feature: Pet Management API - Core CRUD Operations
  Background:
    * url 'https://petstore.swagger.io/v2'
    * configure headers = { 'api_key': 'special-key', 'Content-Type': 'application/json' }

  @critical @create
  Scenario: Create a new pet (happy path)
    * def pet = { id: 1001, name: 'Fluffy', category: { name: 'cat' }, photoUrls: ['url1'], tags: [{ name: 'cute' }], status: 'available' }
    Given path 'pet'
    And request pet
    When method post
    Then status 200
    And match response == pet
    Given path 'pet', pet.id
    When method get
    Then status 200
    And match response == pet

  @negative @create
  Scenario: Create a pet with missing required field
    * def pet = { id: 1002, status: 'available' }
    Given path 'pet'
    And request pet
    When method post
    Then status 400

  @high @read
  Scenario: Retrieve existing pet by id
    * def id = 1001
    Given path 'pet', id
    When method get
    Then status 200
    And match response.id == id
    And match response.name == 'Fluffy'

  @high @read-negative
  Scenario: Retrieve non-existent pet by id
    * def id = 999999
    Given path 'pet', id
    When method get
    Then status 404
    And match response.message contains 'Pet not found'

  @critical @update
  Scenario: Update existing pet
    * def pet = { id: 1001, name: 'FluffyUpdated', category: { name: 'cat' }, photoUrls: ['url1'], tags: [{ name: 'cute' }], status: 'sold' }
    Given path 'pet'
    And request pet
    When method put
    Then status 200
    Given path 'pet', pet.id
    When method get
    Then status 200
    And match response.name == 'FluffyUpdated'
    And match response.status == 'sold'

  @high @delete
  Scenario: Delete pet and verify removal
    * def id = 1001
    Given path 'pet', id
    When method delete
    Then status 200
    Given path 'pet', id
    When method get
    Then status 404
