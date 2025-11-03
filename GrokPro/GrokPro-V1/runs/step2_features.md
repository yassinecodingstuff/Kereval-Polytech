Feature: Pet Resource Management
As a user of the Petstore API, I want to perform comprehensive CRUD operations on pet data.

Background:
* url 'https://petstore.swagger.io/v2'
* def petPayload =
"""
{
"id": 0,
"category": { "id": 1, "name": "Dogs" },
"name": "doggie",
"photoUrls": [ "string" ],
"tags": [ { "id": 0, "name": "string" } ],
"status": "available"
}
"""

Scenario: Create, retrieve, update, and delete a pet
# Create a new pet
Given path '/pet'
And request petPayload
When method post
Then status 200
And match response.id == '#number'
And match response.name == 'doggie'
* def petId = response.id

text
# Retrieve the created pet by ID
Given path '/pet', petId
When method get
Then status 200
And match response.id == petId

# Update the pet's status to 'sold'
* set petPayload.id = petId
* set petPayload.status = 'sold'
Given path '/pet'
And request petPayload
When method put
Then status 200
And match response.status == 'sold'

# Delete the pet
Given path '/pet', petId
And header api_key = 'special-key'
When method delete
Then status 200

# Verify the pet has been deleted
Given path '/pet', petId
When method get
Then status 404
And match response.message == 'Pet not found'
Scenario Outline: Find pets by various statuses
Given path '/pet/findByStatus'
And param status = '<status>'
When method get
Then status 200
And match each response contains { id: '#number', status: '<status>' }

text
Examples:
  | status    |
  | available |
  | pending   |
  | sold      |
Scenario: Attempt to find a pet with an invalid status
Given path '/pet/findByStatus'
And param status = 'invalid-status'
When method get
Then status 400
And match response.message contains 'Invalid status value'

Feature: Pet Store Order and Inventory Management
As a store manager, I want to manage pet orders and inventory.

Background:
* url 'https://petstore.swagger.io/v2/store'
* def orderPayload =
"""
{
"id": 0,
"petId": 1,
"quantity": 1,
"shipDate": "2025-10-02T10:23:00.000Z",
"status": "placed",
"complete": true
}
"""

Scenario: Retrieve store inventory
Given path 'inventory'
When method get
Then status 200
And match response.sold == '#number'
And match response.available == '#number'
And match response.pending == '#number'

Scenario: Place, retrieve, and delete a pet order
# Place an order for a pet
* set orderPayload.id = Math.floor(Math.random() * 1000) + 1
Given path 'order'
And request orderPayload
When method post
Then status 200
And match response.id == orderPayload.id
* def orderId = response.id

text
# Retrieve the created order by ID
Given path 'order', orderId
When method get
Then status 200
And match response.id == orderId
And match response.petId == orderPayload.petId

# Delete the order
Given path 'order', orderId
When method delete
Then status 200

# Verify the order has been deleted
Given path 'order', orderId
When method get
Then status 404
And match response.message == 'Order not found'
Scenario: Attempt to retrieve a non-existent order
Given path 'order', -1
When method get
Then status 404
And match response.message == 'Order not found'

Feature: User Account Management
As a user, I want to manage my account through the API.

Background:
* url 'https://petstore.swagger.io/v2/user'
* def random_suffix = java.util.UUID.randomUUID().toString().substring(0, 8)
* def username = 'testuser_' + random_suffix
* def userPayload =
"""
{
"id": 0,
"username": "#(username)",
"firstName": "Test",
"lastName": "User",
"email": "test.user@example.com",
"password": "password123",
"phone": "1234567890",
"userStatus": 1
}
"""

Scenario: Create, log in, update, and delete a user
# Create a new user
Given path '/'
And request userPayload
When method post
Then status 200
And match response.message == '#string'

text
# Log in with the created user
Given path 'login'
And params { username: '#(username)', password: 'password123' }
When method get
Then status 200
And match response.message contains 'logged in user session:'
* def sessionToken = response.message

# Retrieve user information by username
Given path username
When method get
Then status 200
And match response.username == username
And match response.firstName == 'Test'

# Update user's first name
* set userPayload.firstName = 'Updated'
Given path username
And request userPayload
When method put
Then status 200

# Verify the update
Given path username
When method get
Then status 200
And match response.firstName == 'Updated'

# Log out
Given path 'logout'
When method get
Then status 200
And match response.message == 'ok'

# Delete the user
Given path username
When method delete
Then status 200

# Verify the user is deleted
Given path username
When method get
Then status 404
And match response.message == 'User not found'
