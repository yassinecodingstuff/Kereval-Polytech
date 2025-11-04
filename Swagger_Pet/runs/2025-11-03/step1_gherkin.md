Feature: Pet Store API - Pet Management
    As a Pet Store user or administrator,
    I want to manage pet records via the API,
    So that I can add, update, retrieve, and delete pet information efficiently.

    Background:
        Given the base URL is "https://petstore.swagger.io/v2"
        And the "Content-Type" header is set to "application/json"

    @smoke @high-priority
    Scenario: Add a new pet with valid data
        Given I have a valid pet payload with:
            | id       | 1001 |
            | name     | "Max" |
            | category | { "id": 1, "name": "Dogs" } |
            | photoUrls| ["https://example.com/max.jpg"] |
            | tags     | [{ "id": 1, "name": "friendly" }] |
            | status   | "available" |
        When I send a POST request to "/pet" with the payload
        Then the response status code should be 200
        And the response body should match the pet payload

    @regression @medium-priority
    Scenario: Add a new pet with missing required fields
        Given I have an invalid pet payload with missing "name":
            | id       | 1002 |
            | category | { "id": 1, "name": "Cats" } |
            | photoUrls| ["https://example.com/whiskers.jpg"] |
            | tags     | [{ "id": 1, "name": "playful" }] |
            | status   | "available" |
        When I send a POST request to "/pet" with the payload
        Then the response status code should be 400
        And the response body should contain an error message indicating missing required field

    @regression @high-priority
    Scenario: Retrieve a pet by valid ID
        Given a pet with ID "1001" exists in the system
        When I send a GET request to "/pet/1001"
        Then the response status code should be 200
        And the response body should contain the pet details with ID "1001"

    @regression @high-priority
    Scenario: Retrieve a pet by invalid ID
        Given no pet with ID "9999" exists in the system
        When I send a GET request to "/pet/9999"
        Then the response status code should be 404
        And the response body should contain an error message indicating pet not found

    @regression @high-priority
    Scenario: Update an existing pet with valid data
        Given a pet with ID "1001" exists in the system
        And I have an updated pet payload with:
            | id       | 1001 |
            | name     | "Max Updated" |
            | category | { "id": 1, "name": "Dogs" } |
            | photoUrls| ["https://example.com/max_updated.jpg"] |
            | tags     | [{ "id": 1, "name": "friendly" }] |
            | status   | "sold" |
        When I send a PUT request to "/pet" with the payload
        Then the response status code should be 200
        And the response body should match the updated pet payload

    @regression @medium-priority
    Scenario: Update a pet with invalid data
        Given a pet with ID "1001" exists in the system
        And I have an invalid pet payload with:
            | id       | 1001 |
            | name     | "" |
            | category | { "id": 1, "name": "Dogs" } |
            | photoUrls| ["https://example.com/max_updated.jpg"] |
            | tags     | [{ "id": 1, "name": "friendly" }] |
            | status   | "sold" |
        When I send a PUT request to "/pet" with the payload
        Then the response status code should be 400
        And the response body should contain an error message indicating invalid data

    @regression @high-priority
    Scenario: Delete a pet by valid ID
        Given a pet with ID "1001" exists in the system
        When I send a DELETE request to "/pet/1001"
        Then the response status code should be 200
        And the response body should contain a success message

    @regression @high-priority
    Scenario: Delete a pet by invalid ID
        Given no pet with ID "9999" exists in the system
        When I send a DELETE request to "/pet/9999"
        Then the response status code should be 404
        And the response body should contain an error message indicating pet not found

    @regression @medium-priority
    Scenario: Find pets by status
        Given there are pets with status "available" in the system
        When I send a GET request to "/pet/findByStatus?status=available"
        Then the response status code should be 200
        And the response body should contain a list of pets with status "available"

    @regression @medium-priority
    Scenario: Find pets by invalid status
        Given there are no pets with status "invalid_status" in the system
        When I send a GET request to "/pet/findByStatus?status=invalid_status"
        Then the response status code should be 200
        And the response body should be an empty list

---

Feature: Pet Store API - Pet Image Management
    As a Pet Store user or administrator,
    I want to manage pet images via the API,
    So that I can upload and retrieve pet images efficiently.

    Background:
        Given the base URL is "https://petstore.swagger.io/v2"
        And the "Content-Type" header is set to "multipart/form-data"

    @regression @medium-priority
    Scenario: Upload an image for a pet with valid ID
        Given a pet with ID "1001" exists in the system
        And I have a valid image file "max.jpg"
        When I send a POST request to "/pet/1001/uploadImage" with the image file
        Then the response status code should be 200
        And the response body should contain a success message

    @regression @medium-priority
    Scenario: Upload an image for a pet with invalid ID
        Given no pet with ID "9999" exists in the system
        And I have a valid image file "max.jpg"
        When I send a POST request to "/pet/9999/uploadImage" with the image file
        Then the response status code should be 404
        And the response body should contain an error message indicating pet not found

    @regression @medium-priority
    Scenario: Upload an invalid image file for a pet
        Given a pet with ID "1001" exists in the system
        And I have an invalid image file "max.txt"
        When I send a POST request to "/pet/1001/uploadImage" with the file
        Then the response status code should be 400
        And the response body should contain an error message indicating invalid file type

---

Feature: Pet Store API - Store Inventory Management
    As a Pet Store administrator,
    I want to manage store inventory via the API,
    So that I can retrieve and update inventory information efficiently.

    Background:
        Given the base URL is "https://petstore.swagger.io/v2"
        And the "Content-Type" header is set to "application/json"

    @smoke @high-priority
    Scenario: Retrieve store inventory
        When I send a GET request to "/store/inventory"
        Then the response status code should be 200
        And the response body should contain inventory data

---

Feature: Pet Store API - Store Order Management
    As a Pet Store user or administrator,
    I want to manage store orders via the API,
    So that I can place, retrieve, and delete orders efficiently.

    Background:
        Given the base URL is "https://petstore.swagger.io/v2"
        And the "Content-Type" header is set to "application/json"

    @regression @high-priority
    Scenario: Place a new order with valid data
        Given I have a valid order payload with:
            | id     | 1001 |
            | petId  | 1001 |
            | quantity | 1 |
            | shipDate | "2025-11-04T00:00:00.000Z" |
            | status | "placed" |
            | complete | true |
        When I send a POST request to "/store/order" with the payload
        Then the response status code should be 200
        And the response body should match the order payload

    @regression @medium-priority
    Scenario: Place a new order with invalid data
        Given I have an invalid order payload with missing "petId":
            | id     | 1002 |
            | quantity | 1 |
            | shipDate | "2025-11-04T00:00:00.000Z" |
            | status | "placed" |
            | complete | true |
        When I send a POST request to "/store/order" with the payload
        Then the response status code should be 400
        And the response body should contain an error message indicating missing required field

    @regression @high-priority
    Scenario: Retrieve an order by valid ID
        Given an order with ID "1001" exists in the system
        When I send a GET request to "/store/order/1001"
        Then the response status code should be 200
        And the response body should contain the order details with ID "1001"

    @regression @high-priority
    Scenario: Retrieve an order by invalid ID
        Given no order with ID "9999" exists in the system
        When I send a GET request to "/store/order/9999"
        Then the response status code should be 404
        And the response body should contain an error message indicating order not found

    @regression @high-priority
    Scenario: Delete an order by valid ID
        Given an order with ID "1001" exists in the system
        When I send a DELETE request to "/store/order/1001"
        Then the response status code should be 200
        And the response body should contain a success message

    @regression @high-priority
    Scenario: Delete an order by invalid ID
        Given no order with ID "9999" exists in the system
        When I send a DELETE request to "/store/order/9999"
        Then the response status code should be 404
        And the response body should contain an error message indicating order not found

---

Feature: Pet Store API - User Management
    As a Pet Store user or administrator,
    I want to manage user accounts via the API,
    So that I can create, update, retrieve, and delete user information efficiently.

    Background:
        Given the base URL is "https://petstore.swagger.io/v2"
        And the "Content-Type" header is set to "application/json"

    @regression @high-priority
    Scenario: Create a new user with valid data
        Given I have a valid user payload with:
            | id       | 1001 |
            | username | "testuser1" |
            | firstName| "John" |
            | lastName | "Doe" |
            | email    | "john.doe@example.com" |
            | password | "password123" |
            | phone    | "1234567890" |
            | userStatus | 1 |
        When I send a POST request to "/user" with the payload
        Then the response status code should be 200
        And the response body should contain a success message

    @regression @medium-priority
    Scenario: Create a new user with missing required fields
        Given I have an invalid user payload with missing "username":
            | id       | 1002 |
            | firstName| "Jane" |
            | lastName | "Doe" |
            | email    | "jane.doe@example.com" |
            | password | "password123" |
            | phone    | "1234567890" |
            | userStatus | 1 |
        When I send a POST request to "/user" with the payload
        Then the response status code should be 400
        And the response body should contain an error message indicating missing required field

    @regression @high-priority
    Scenario: Retrieve a user by valid username
        Given a user with username "testuser1" exists in the system
        When I send a GET request to "/user/testuser1"
        Then the response status code should be 200
        And the response body should contain the user details with username "testuser1"

    @regression @high-priority
    Scenario: Retrieve a user by invalid username
        Given no user with username "nonexistentuser" exists in the system
        When I send a GET request to "/user/nonexistentuser"
        Then the response status code should be 404
        And the response body should contain an error message indicating user not found

    @regression @high-priority
    Scenario: Update a user with valid data
        Given a user with username "testuser1" exists in the system
        And I have an updated user payload with:
            | id       | 1001 |
            | username | "testuser1" |
            | firstName| "John Updated" |
            | lastName | "Doe" |
            | email    | "john.updated@example.com" |
            | password | "password123" |
            | phone    | "1234567890" |
            | userStatus | 1 |
        When I send a PUT request to "/user/testuser1" with the payload
        Then the response status code should be 200
        And the response body should contain a success message

    @regression @medium-priority
    Scenario: Update a user with invalid data
        Given a user with username "testuser1" exists in the system
        And I have an invalid user payload with:
            | id       | 1001 |
            | username | "testuser1" |
            | firstName| "" |
            | lastName | "Doe" |
            | email    | "john.updated@example.com" |
            | password | "password123" |
            | phone    | "1234567890" |
            | userStatus | 1 |
        When I send a PUT request to "/user/testuser1" with the payload
        Then the response status code should be 400
        And the response body should contain an error message indicating invalid data

    @regression @high-priority
    Scenario: Delete a user by valid username
        Given a user with username "testuser1" exists in the system
        When I send a DELETE request to "/user/testuser1"
        Then the response status code should be 200
        And the response body should contain a success message

    @regression @high-priority
    Scenario: Delete a user by invalid username
        Given no user with username "nonexistentuser" exists in the system
        When I send a DELETE request to "/user/nonexistentuser"
        Then the response status code should be 404
        And the response body should contain an error message indicating user not found

    @regression @medium-priority
    Scenario: Log in a user with valid credentials
        Given a user with username "testuser1" and password "password123" exists in the system
        When I send a GET request to "/user/login?username=testuser1&password=password123"
        Then the response status code should be 200
        And the response body should contain a success message

    @regression @medium-priority
    Scenario: Log in a user with invalid credentials
        Given a user with username "testuser1" and password "password123" exists in the system
        When I send a GET request to "/user/login?username=testuser1&password=wrongpassword"
        Then the response status code should be 400
        And the response body should contain an error message indicating invalid credentials

    @regression @medium-priority
    Scenario: Log out a user
        When I send a GET request to "/user/logout"
        Then the response status code should be 200
        And the response body should contain a success message

