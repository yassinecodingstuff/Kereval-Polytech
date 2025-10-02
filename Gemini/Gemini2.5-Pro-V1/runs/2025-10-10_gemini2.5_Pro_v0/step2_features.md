Feature: Pet Management

Background:
* url 'https://petstore.swagger.io/v2'

Scenario: Successfully add a new pet to the store
Given path 'pet'
And request { id: 0, name: 'doggie', photoUrls: [], status: 'available' }
When method post
Then status 200
And match response.name == 'doggie'
And match response.status == 'available'

Scenario Outline: Find pets by status
Given path 'pet', 'findByStatus'
And param status = '<status>'
When method get
Then status 200
And match each response[*].status == '<status>'

text
Examples:
  | status    |
  | available |
  | pending   |
  | sold      |

Scenario: Attempt to find pets with an invalid status
Given path 'pet', 'findByStatus'
And param status = 'invalid_status'
When method get
Then status 400

Scenario: Successfully find an existing pet by its ID
* def pet_id = 1
Given path 'pet', pet_id
When method get
Then status 200
And match response.id == pet_id

Scenario: Attempt to find a pet with a non-existent ID
Given path 'pet', 999999
When method get
Then status 404
And match response.message == 'Pet not found'

Scenario: Successfully update an existing pet's name and status
* def pet_id = 1
Given path 'pet'
And request { id: '#(pet_id)', name: 'Snoopy', photoUrls: [], status: 'sold' }
When method put
Then status 200
And match response.name == 'Snoopy'
And match response.status == 'sold'

Scenario: Successfully delete an existing pet
* def pet_id = 1
Given path 'pet', pet_id
And header api_key = 'special-key'
When method delete
Then status 200

text
# Verification Step
Given path 'pet', pet_id
When method get
Then status 404

Feature: Store Management

Background:
* url 'https://petstore.swagger.io/v2'

Scenario: Successfully place an order for a pet and verify it
* def order =
"""
{
"id": 10,
"petId": 1,
"quantity": 1,
"shipDate": "2025-10-01T18:00:00.000Z",
"status": "placed",
"complete": true
}
"""
Given path 'store', 'order'
And request order
When method post
Then status 200
And match response.id == order.id
And match response.status == 'placed'

Scenario: Find an existing purchase order by ID
Given path 'store', 'order', 5
When method get
Then status 200
And match response.id == 5

Scenario: Attempt to find a purchase order with a non-existent ID
Given path 'store', 'order', 999999
When method get
Then status 404
And match response.message == 'Order not found'

Scenario: Successfully delete an existing purchase order
* def order_id = 8
Given path 'store', 'order', order_id
When method delete
Then status 200

text
# Verification Step
Given path 'store', 'order', order_id
When method get
Then status 404

Scenario: Retrieve pet inventories by status
Given path 'store', 'inventory'
When method get
Then status 200
And match response.sold != null
And match response.available != null
And match response.pending != null

Feature: User Management

Background:
* url 'https://petstore.swagger.io/v2'
* def newUser =
"""
{
"id": 12345,
"username": "testuser123",
"firstName": "Test",
"lastName": "User",
"email": "testuser123@example.com",
"password": "password123",
"phone": "123-456-7890",
"userStatus": 1
}
"""

Scenario: Create a new user and verify creation
Given path 'user'
And request newUser
When method post
Then status 200
And match response.message == 'ok'

Scenario: Successfully log in with valid credentials
Given path 'user', 'login'
And param username = newUser.username
And param password = newUser.password
When method get
Then status 200
And match response.message contains 'logged in user session:'

Scenario: Attempt to log in with invalid credentials
Given path 'user', 'login'
And param username = newUser.username
And param password = 'wrongpassword'
When method get
Then status 400
And match response.message == 'Invalid username/password supplied'

Scenario: Retrieve user details by username
Given path 'user', newUser.username
When method get
Then status 200
And match response.username == newUser.username
And match response.email == newUser.email

Scenario: Attempt to retrieve a user with a non-existent username
Given path 'user', 'nonexistentuser99'
When method get
Then status 404
And match response.message == 'User not found'

Scenario: Update an existing user's information and verify
* def updatedEmail = 'updated.user@example.com'
* def updatedUser = karate.set(newUser, 'email', updatedEmail)

text
Given path 'user', newUser.username
And request updatedUser
When method put
Then status 200

# Verification Step
Given path 'user', newUser.username
When method get
Then status 200
And match response.email == updatedEmail

Scenario: Successfully log out and end the current session
# First, log in to establish a session
Given path 'user', 'login'
And param username = newUser.username
And param password = newUser.password
When method get
Then status 200

text
# Then, log out
Given path 'user', 'logout'
When method get
Then status 200
And match response.message == 'ok'