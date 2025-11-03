Pet Management API Tests
Feature: Pet Resource Management
As a user of the Petstore API, I want to perform comprehensive CRUD (Create, Read, Update, Delete) operations on pet data to ensure data integrity and system reliability.

Scenario: Successfully add a new pet to the store
Given a valid pet payload is prepared
When a POST request is sent to the /pet endpoint
Then the response status code should be 200
And the response body should contain the newly created pet's details

Scenario: Find pets by 'available' status
Given the API is available
When a GET request is sent to the /pet/findByStatus endpoint with the status "available"
Then the response status code should be 200
And the response body should contain a list of pets with the status "available"

Scenario: Find pets by 'sold' status
Given the API is available
When a GET request is sent to the /pet/findByStatus endpoint with the status "sold"
Then the response status code should be 200
And the response body should contain a list of pets with the status "sold"

Scenario: Attempt to find pets using an invalid status
Given the API is available
When a GET request is sent to the /pet/findByStatus endpoint with an invalid status like "unknown"
Then the response status code should be 400
And the response body should indicate an error due to the invalid status value​

Scenario: Successfully retrieve a pet by its ID
Given a pet exists in the system with a known ID
When a GET request is sent to the /pet/{petId} endpoint with that ID
Then the response status code should be 200
And the response body should contain the correct pet's details

Scenario: Attempt to retrieve a pet with a non-existent ID
Given the API is available
When a GET request is sent to the /pet/{petId} endpoint with a non-existent pet ID
Then the response status code should be 404​
And the response body should contain a "Pet not found" error message​

Scenario: Successfully update an existing pet's information
Given a pet exists and a valid update payload is prepared
When a PUT request is sent to the /pet endpoint with the updated data​
Then the response status code should be 200
And the pet's information should be updated in the system

Scenario: Attempt to update a pet with an invalid ID
Given a valid update payload is prepared
And the payload contains a non-existent pet ID
When a PUT request is sent to the /pet endpoint
Then the response status code should be 400​
And the response body should indicate an "Invalid ID supplied" error​

Scenario: Successfully delete a pet
Given a pet exists in the system with a known ID
When a DELETE request is sent to the /pet/{petId} endpoint with that ID
Then the response status code should be 200
And the pet should be removed from the system

Scenario: Attempt to delete a pet with a non-existent ID
Given the API is available
When a DELETE request is sent to the /pet/{petId} endpoint with a non-existent pet ID
Then the response status code should be 404

Store Operations API Tests
Feature: Pet Store Order and Inventory Management
As a store manager, I want to manage pet orders and inventory to ensure efficient store operations and accurate stock levels.

Scenario: Successfully place an order for a pet
Given a valid order payload for an available pet is prepared
When a POST request is sent to the /store/order endpoint​
Then the response status code should be 200
And the response body should contain the complete order details

Scenario: Attempt to place an order with invalid data
Given an order payload with invalid data is prepared
When a POST request is sent to the /store/order endpoint​
Then the response status code should be 400
And the response body should indicate an error due to invalid input

Scenario: Successfully retrieve a purchase order by its ID
Given a purchase order exists with a known ID
When a GET request is sent to the /store/order/{orderId} endpoint with that ID
Then the response status code should be 200
And the response body should contain the correct order details

Scenario: Attempt to retrieve an order with a non-existent ID
Given the API is available
When a GET request is sent to the /store/order/{orderId} endpoint with a non-existent order ID
Then the response status code should be 404
And the response body should contain an "Order not found" message

Scenario: Successfully delete a purchase order
Given a purchase order exists with a known ID
When a DELETE request is sent to the /store/order/{orderId} endpoint with that ID
Then the response status code should be 200
And the order should be removed from the system

Scenario: Retrieve pet inventories by status
Given the API is available
When a GET request is sent to the /store/inventory endpoint​
Then the response status code should be 200
And the response body should return a map of status codes to quantities​

User Account API Tests
Feature: User Account Management
As a user, I want to manage my account through the API, including creation, login, logout, and data updates, to ensure secure and personalized access.

Scenario: Successfully create a new user
Given a valid user payload is prepared
When a POST request is sent to the /user endpoint
Then the response status code should be 200
And the response should indicate a successful user creation

Scenario: Successfully log in a user with valid credentials
Given a user exists with valid credentials
When a GET request is sent to the /user/login endpoint with the user's credentials
Then the response status code should be 200
And the response should include a session token

Scenario: Attempt to log in with invalid credentials
Given a user provides incorrect credentials
When a GET request is sent to the /user/login endpoint
Then the response status code should be 400
And the response should indicate an "Invalid username/password supplied" error

Scenario: Successfully log out a user
Given a user is currently logged in
When a GET request is sent to the /user/logout endpoint
Then the response status code should be 200
And the user session should be terminated

Scenario: Successfully retrieve a user's information by username
Given a user exists with a known username
When a GET request is sent to the /user/{username} endpoint with that username
Then the response status code should be 200
And the response body should contain the user's details

Scenario: Attempt to retrieve information for a non-existent user
Given the API is available
When a GET request is sent to the /user/{username} endpoint with a non-existent username
Then the response status code should be 404
And the response should indicate that the user was not found

Scenario: Successfully update a user's information
Given a user exists and a valid update payload is prepared
When a PUT request is sent to the /user/{username} endpoint
Then the response status code should be 200
And the user's information should be updated

Scenario: Successfully delete a user
Given a user exists with a known username
When a DELETE request is sent to the /user/{username} endpoint with that username
Then the response status code should be 200
And the user account should be removed from the system
