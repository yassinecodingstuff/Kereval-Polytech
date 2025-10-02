Pet Management API Test Cases

Feature: Pet Management
As an API user, I want to manage pets in the pet store so that I can add, find, update, and delete pet information.

Scenario: Successfully add a new pet to the store
Given I have a valid payload for a new pet named "doggie" with status "available"
When I send a POST request to the /pet endpoint
Then the response status code should be 200
And the response body should contain the details of the newly created pet

Scenario: Find pets by 'available' status
Given the pet store contains pets with the status "available"
When I send a GET request to /pet/findByStatus with the query parameter status=available
Then the response status code should be 200
And the response body should contain a list of pets where each pet's status is "available"

Scenario: Find pets by 'pending' status
Given the pet store contains pets with the status "pending"
When I send a GET request to /pet/findByStatus with the query parameter status=pending
Then the response status code should be 200
And the response body should contain a list of pets where each pet's status is "pending"

Scenario: Find pets by 'sold' status
Given the pet store contains pets with the status "sold"
When I send a GET request to /pet/findByStatus with the query parameter status=sold
Then the response status code should be 200
And the response body should contain a list of pets where each pet's status is "sold"

Scenario: Attempt to find pets with an invalid status
Given I want to find pets using an unsupported status
When I send a GET request to /pet/findByStatus with the query parameter status=invalid_status
Then the response status code should be 400
And the response body should contain an error message indicating an invalid status was provided

Scenario: Successfully find an existing pet by its ID
Given a pet with a specific ID exists in the store
When I send a GET request to /pet/{petId} with the existing pet's ID
Then the response status code should be 200
And the response body should contain the correct details for that pet

Scenario: Attempt to find a pet with a non-existent ID
Given no pet exists in the store with ID 999999
When I send a GET request to /pet/999999
Then the response status code should be 404
And the response body should contain a "Pet not found" error message

Scenario: Successfully update an existing pet's name and status
Given a pet with a specific ID exists
And I have a valid payload to update its name to "Snoopy" and status to "sold"
When I send a PUT request to the /pet endpoint with the updated payload
Then the response status code should be 200
And the response body should reflect the updated pet name and status

Scenario: Successfully delete an existing pet
Given a pet with a specific ID exists
When I send a DELETE request to /pet/{petId} with that pet's ID
Then the response status code should be 200
And a subsequent GET request to /pet/{petId} for that ID should return a 404 status
Store Management API Test Cases

Feature: Store Management
As an API user, I want to manage pet store orders and inventory.

Scenario: Successfully place an order for a pet
Given I have a valid payload for a new order for an existing pet
When I send a POST request to the /store/order endpoint
Then the response status code should be 200
And the response body should contain the details of the newly created order with status "placed"

Scenario: Successfully find an existing purchase order by ID
Given a purchase order with ID 5 exists
When I send a GET request to /store/order/5
Then the response status code should be 200
And the response body should contain the correct details for order ID 5

Scenario: Attempt to find a purchase order with a non-existent ID
Given no purchase order exists with ID 999999
When I send a GET request to /store/order/999999
Then the response status code should be 404
And the response body should contain an "Order not found" error message

Scenario: Successfully delete an existing purchase order
Given a purchase order with ID 8 exists
When I send a DELETE request to /store/order/8
Then the response status code should be 200
And a subsequent GET request for order ID 8 should return a 404 status

Scenario: Retrieve pet inventories by status
Given the store has pets with statuses including "available", "pending", and "sold"
When I send a GET request to the /store/inventory endpoint
Then the response status code should be 200
And the response body should contain a map of pet statuses to their respective quantities
User Management API Test Cases

Feature: User Management
As an API user, I want to manage user accounts and sessions.

Scenario: Successfully create a new user
Given I have a valid payload for a new user with a unique username
When I send a POST request to the /user endpoint
Then the response status code should be 200
And the response body should indicate successful creation of the user account

Scenario: Successfully log in with valid credentials
Given a user account with username "testuser" and password "password123" exists
When I send a GET request to /user/login with valid query parameters for username and password
Then the response status code should be 200
And the response headers should include session information

Scenario: Attempt to log in with invalid credentials
Given a user account with username "testuser" exists
When I send a GET request to /user/login with the correct username but an incorrect password
Then the response status code should be 400
And the response body should indicate an "Invalid username/password supplied" error

Scenario: Successfully retrieve a user's details by username
Given a user with the username "testuser" exists
When I send a GET request to /user/testuser
Then the response status code should be 200
And the response body should contain the correct details for "testuser"

Scenario: Attempt to retrieve a user with a non-existent username
Given no user exists with the username "nonexistentuser"
When I send a GET request to /user/nonexistentuser
Then the response status code should be 404
And the response body should contain a "User not found" error message

Scenario: Successfully update an existing user's information
Given a user with the username "testuser" exists
And I am logged in as "testuser"
When I send a PUT request to /user/testuser with a valid payload to update the user's email
Then the response status code should be 200
And a subsequent GET request for "testuser" should show the updated email

Scenario: Successfully log out and end the current session
Given a user is currently logged in
When I send a GET request to the /user/logout endpoint
Then the response status code should be 200
And the user's session should be invalidated