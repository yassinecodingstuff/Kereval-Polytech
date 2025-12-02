Feature: Pet Lifecycle Management
  As a test automation engineer
  I want to verify the Pet resource capabilities
  So that I can ensure pets are correctly managed in the system

  Background:
    * url 'https://petstore.swagger.io/v2'
    * def getRandomId = function(){ return Math.floor(Math.random() * 100000000) + 1 }

  Scenario: Successfully create a new pet with all fields
    * def randomId = getRandomId()
    * def petName = 'AutoPet-' + randomId
    Given path 'pet'
    And request
    """
    {
      "id": #(randomId),
      "category": { "id": 1, "name": "Dogs" },
      "name": "#(petName)",
      "photoUrls": [ "http://example.com/photo1.jpg" ],
      "tags": [ { "id": 0, "name": "fuzzy" } ],
      "status": "available"
    }
    """
    When method post
    Then status 200
    And match response.id == randomId
    And match response.name == petName

  Scenario: Successfully create a pet with only required fields
    * def newId = getRandomId()
    Given path 'pet'
    And request { "id": #(newId), "name": "MinimalPet", "photoUrls": [] }
    When method post
    Then status 200
    And match response.id == newId

  Scenario: Verify full lifecycle of a pet
    # Create
    * def lifecycleId = getRandomId()
    * def initialName = 'LifeCyclePet-' + lifecycleId
    Given path 'pet'
    And request { "id": #(lifecycleId), "name": "#(initialName)", "photoUrls": [], "status": "available" }
    When method post
    Then status 200

    # Read
    Given path 'pet', lifecycleId
    When method get
    Then status 200
    And match response.name == initialName

    # Update
    * def updatedName = initialName + '-Updated'
    Given path 'pet'
    And request { "id": #(lifecycleId), "name": "#(updatedName)", "photoUrls": [], "status": "sold" }
    When method put
    Then status 200
    And match response.status == 'sold'

    # Delete
    Given path 'pet', lifecycleId
    When method delete
    Then status 200

    # Verify Delete
    Given path 'pet', lifecycleId
    When method get
    Then status 404

  Scenario: Reject pet creation with invalid data type
    Given path 'pet'
    And request { "id": "invalid-id-string", "name": "BadDataPet", "photoUrls": [] }
    When method post
    Then status 400

  Scenario: Retrieve pets by status
    Given path 'pet', 'findByStatus'
    And param status = 'available'
    When method get
    Then status 200
    And match response == '#array'