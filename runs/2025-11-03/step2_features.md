Feature: Pet Store API - Pet Management

  Background:
    * url 'https://petstore.swagger.io/v2'
    * header Content-Type = 'application/json'

  @smoke @high-priority
  Scenario: Add a new pet with valid data
    Given request
      """
      {
        "id": 1001,
        "name": "Max",
        "category": {
          "id": 1,
          "name": "Dogs"
        },
        "photoUrls": [
          "https://example.com/max.jpg"
        ],
        "tags": [
          {
            "id": 1,
            "name": "friendly"
          }
        ],
        "status": "available"
      }
    """
    When method POST
    And path '/pet'
    Then status 200
    And match response ==
      """
      {
        "id": 1001,
        "name": "Max",
        "category": {
          "id": 1,
          "name": "Dogs"
        },
        "photoUrls": [
          "https://example.com/max.jpg"
        ],
        "tags": [
          {
            "id": 1,
            "name": "friendly"
          }
        ],
        "status": "available"
      }
      """

  @regression @medium-priority
  Scenario: Add a new pet with missing required fields
    Given request
      """
      {
        "id": 1002,
        "category": {
          "id": 1,
          "name": "Cats"
        },
        "photoUrls": [
          "https://example.com/whiskers.jpg"
        ],
        "tags": [
          {
            "id": 1,
            "name": "playful"
          }
        ],
        "status": "available"
      }
      """
    When method POST
    And path '/pet'
    Then status 400
    And match response.error contains 'missing required field'

  @regression @high-priority
  Scenario: Retrieve a pet by valid ID
    Given path '/pet/1001'
    When method GET
    Then status 200
    And match response.id == 1001
    And match response.name == 'Max'

  @regression @high-priority
  Scenario: Retrieve a pet by invalid ID
    Given path '/pet/9999'
    When method GET
    Then status 404
    And match response.message contains 'Pet not found'

  @regression @high-priority
  Scenario: Update an existing pet with valid data
    Given request
      """
      {
        "id": 1001,
        "name": "Max Updated",
        "category": {
          "id": 1,
          "name": "Dogs"
        },
        "photoUrls": [
          "https://example.com/max_updated.jpg"
        ],
        "tags": [
          {
            "id": 1,
            "name": "friendly"
          }
        ],
        "status": "sold"
      }
      """
    When method PUT
    And path '/pet'
    Then status 200
    And match response.name == 'Max Updated'
    And match response.status == 'sold'

  @regression @medium-priority
  Scenario: Update a pet with invalid data
    Given request
      """
      {
        "id": 1001,
        "name": "",
        "category": {
          "id": 1,
          "name": "Dogs"
        },
        "photoUrls": [
          "https://example.com/max_updated.jpg"
        ],
        "tags": [
          {
            "id": 1,
            "name": "friendly"
          }
        ],
        "status": "sold"
      }
      """
    When method PUT
    And path '/pet'
    Then status 400
    And match response.error contains 'invalid data'

  @regression @high-priority
  Scenario: Delete a pet by valid ID
    Given path '/pet/1001'
    When method DELETE
    Then status 200
    And match response.message contains 'Pet deleted'

  @regression @high-priority
  Scenario: Delete a pet by invalid ID
    Given path '/pet/9999'
    When method DELETE
    Then status 404
    And match response.message contains 'Pet not found'

  @regression @medium-priority
  Scenario: Find pets by status
    Given path '/pet/findByStatus', { status: 'available' }
    When method GET
    Then status 200
    And match each response[*] == { status: 'available' }

  @regression @medium-priority
  Scenario: Find pets by invalid status
    Given path '/pet/findByStatus', { status: 'invalid_status' }
    When method GET
    Then status 200
    And match response == []
Feature: Pet Store API - Pet Image Management

  Background:
    * url 'https://petstore.swagger.io/v2'

  @regression @medium-priority
  Scenario: Upload an image for a pet with valid ID
    Given path '/pet/1001/uploadImage'
    And multipart file image = { read: 'max.jpg', filename: 'max.jpg', contentType: 'image/jpeg' }
    When method POST
    Then status 200
    And match response.message contains 'successfully uploaded'

  @regression @medium-priority
  Scenario: Upload an image for a pet with invalid ID
    Given path '/pet/9999/uploadImage'
    And multipart file image = { read: 'max.jpg', filename: 'max.jpg', contentType: 'image/jpeg' }
    When method POST
    Then status 404
    And match response.message contains 'Pet not found'

  @regression @medium-priority
  Scenario: Upload an invalid image file for a pet
    Given path '/pet/1001/uploadImage'
    And multipart file image = { read: 'max.txt', filename: 'max.txt', contentType: 'text/plain' }
    When method POST
    Then status 400
    And match response.error contains 'invalid file type'
Feature: Pet Store API - Store Inventory Management

  Background:
    * url 'https://petstore.swagger.io/v2'
    * header Content-Type = 'application/json'

  @smoke @high-priority
  Scenario: Retrieve store inventory
    Given path '/store/inventory'
    When method GET
    Then status 200
    And match response == '#object'
Feature: Pet Store API - Store Order Management

  Background:
    * url 'https://petstore.swagger.io/v2'
    * header Content-Type = 'application/json'

  @regression @high-priority
  Scenario: Place a new order with valid data
    Given request
      """
      {
        "id": 1001,
        "petId": 1001,
        "quantity": 1,
        "shipDate": "2025-11-04T00:00:00.000Z",
        "status": "placed",
        "complete": true
      }
      """
    When method POST
    And path '/store/order'
    Then status 200
    And match response.id == 1001
    And match response.status == 'placed'

  @regression @medium-priority
  Scenario: Place a new order with invalid data
    Given request
      """
      {
        "id": 1002,
        "quantity": 1,
        "shipDate": "2025-11-04T00:00:00.000Z",
        "status": "placed",
        "complete": true
      }
      """
    When method POST
    And path '/store/order'
    Then status 400
    And match response.error contains 'missing required field'

  @regression @high-priority
  Scenario: Retrieve an order by valid ID
    Given path '/store/order/1001'
    When method GET
    Then status 200
    And match response.id == 1001

  @regression @high-priority
  Scenario: Retrieve an order by invalid ID
    Given path '/store/order/9999'
    When method GET
    Then status 404
    And match response.message contains 'Order not found'

  @regression @high-priority
  Scenario: Delete an order by valid ID
    Given path '/store/order/1001'
    When method DELETE
    Then status 200
    And match response.message contains 'Order deleted'

  @regression @high-priority
  Scenario: Delete an order by invalid ID
    Given path '/store/order/9999'
    When method DELETE
    Then status 404
    And match response.message contains 'Order not found'
Feature: Pet Store API - User Management

  Background:
    * url 'https://petstore.swagger.io/v2'
    * header Content-Type = 'application/json'

  @regression @high-priority
  Scenario: Create a new user with valid data
    Given request
      """
      {
        "id": 1001,
        "username": "testuser1",
        "firstName": "John",
        "lastName": "Doe",
        "email": "john.doe@example.com",
        "password": "password123",
        "phone": "1234567890",
        "userStatus": 1
      }
      """
    When method POST
    And path '/user'
    Then status 200
    And match response.message contains 'successful'

  @regression @medium-priority
  Scenario: Create a new user with missing required fields
    Given request
      """
      {
        "id": 1002,
        "firstName": "Jane",
        "lastName": "Doe",
        "email": "jane.doe@example.com",
        "password": "password123",
        "phone": "1234567890",
        "userStatus": 1
      }
      """
    When method POST
    And path '/user'
    Then status 400
    And match response.error contains 'missing required field'

  @regression @high-priority
  Scenario: Retrieve a user by valid username
    Given path '/user/testuser1'
    When method GET
    Then status 200
    And match response.username == 'testuser1'

  @regression @high-priority
  Scenario: Retrieve a user by invalid username
    Given path '/user/nonexistentuser'
    When method GET
    Then status 404
    And match response.message contains 'User not found'

  @regression @high-priority
  Scenario: Update a user with valid data
    Given request
      """
      {
        "id": 1001,
        "username": "testuser1",
        "firstName": "John Updated",
        "lastName": "Doe",
        "email": "john.updated@example.com",
        "password": "password123",
        "phone": "1234567890",
        "userStatus": 1
      }
      """
    When method PUT
    And path '/user/testuser1'
    Then status 200
    And match response.message contains 'successful'

  @regression @medium-priority
  Scenario: Update a user with invalid data
    Given request
      """
      {
        "id": 1001,
        "username": "testuser1",
        "firstName": "",
        "lastName": "Doe",
        "email": "john.updated@example.com",
        "password": "password123",
        "phone": "1234567890",
        "userStatus": 1
      }
      """
    When method PUT
    And path '/user/testuser1'
    Then status 400
    And match response.error contains 'invalid data'

  @regression @high-priority
  Scenario: Delete a user by valid username
    Given path '/user/testuser1'
    When method DELETE
    Then status 200
    And match response.message contains 'User deleted'

  @regression @high-priority
  Scenario: Delete a user by invalid username
    Given path '/user/nonexistentuser'
    When method DELETE
    Then status 404
    And match response.message contains 'User not found'

  @regression @medium-priority
  Scenario: Log in a user with valid credentials
    Given path '/user/login', { username: 'testuser1', password: 'password123' }
    When method GET
    Then status 200
    And match response.message contains 'logged in user session'

  @regression @medium-priority
  Scenario: Log in a user with invalid credentials
    Given path '/user/login', { username: 'testuser1', password: 'wrongpassword' }
    When method GET
    Then status 400
    And match response.message contains 'Invalid username/password'

  @regression @medium-priority
  Scenario: Log out a user
    Given path '/user/logout'
    When method GET
    Then status 200
    And match response.message contains 'ok'

