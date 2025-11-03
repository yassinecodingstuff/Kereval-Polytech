Feature: Pet Management API Tests

Scenario: Add a New Pet - Success Path
Given url 'https://petstore.swagger.io/v2/pet'
And request { id: 123, name: 'Rex', category: {id: 1, name: 'Dogs'}, photoUrls: ['http://example.com/dog.jpg'], tags: [], status: 'available' }
When method post
Then status 200
And match response.id == 123
And match response.name == 'Rex'
And match response.status == 'available'

Scenario: Add a New Pet - Missing Required Fields
Given url 'https://petstore.swagger.io/v2/pet'
And request { id: 124 }
When method post
Then status 400

Scenario: Update an Existing Pet - Success Path
Given url 'https://petstore.swagger.io/v2/pet'
And request { id: 123, name: 'Rex Updated', category: {id: 1, name: 'Dogs'}, photoUrls: ['http://example.com/dog_updated.jpg'], tags: [], status: 'sold' }
When method put
Then status 200
And match response.name == 'Rex Updated'
And match response.status == 'sold'

Scenario: Update a Non-Existent Pet
Given url 'https://petstore.swagger.io/v2/pet'
And request { id: 999999, name: 'NonExistent' }
When method put
Then status 404

Scenario: Delete a Pet
Given pathParams petId = 123
Given url 'https://petstore.swagger.io/v2/pet/' + petId
When method delete
Then status 200

Scenario: Delete a Non-Existent Pet
Given pathParams petId = 999999
Given url 'https://petstore.swagger.io/v2/pet/' + petId
When method delete
Then status 404

Feature: Order Management API Tests

Scenario: Place an Order - Success Path
Given url 'https://petstore.swagger.io/v2/store/order'
And request { id: 12345, petId: 123, quantity: 1, shipDate: '2025-10-02T10:00:00.000Z', status: 'placed', complete: false }
When method post
Then status 200
And match response.id == 12345
And match response.petId == 123

Scenario: Place an Order for a Non-Existent Pet
Given url 'https://petstore.swagger.io/v2/store/order'
And request { petId: 9999999, quantity: 1, status: 'placed' }
When method post
Then status 400

Scenario: Retrieve Order by ID
Given pathParams orderId = 12345
Given url 'https://petstore.swagger.io/v2/store/order/' + orderId
When method get
Then status 200
And match response.id == orderId

Feature: User Management API Tests

Scenario: Create a User - Success Path
Given url 'https://petstore.swagger.io/v2/user'
And request { id: 1, username: 'testuser', firstName: 'Test', lastName: 'User', email: 'test@example.com', password: 'password123', phone: '1234567890', userStatus: 1 }
When method post
Then status 200
And match response.code == 200

Scenario: Create a User with Invalid Data
Given url 'https://petstore.swagger.io/v2/user'
And request { username: '' }
When method post
Then status 400

Feature: Security and Availability API Tests

Scenario: Unauthenticated Access to Sensitive Endpoints
Given url 'https://petstore.swagger.io/v2/user/testuser'
When method get
Then status 401

Scenario: Excessive Data Exposure Prevention
Given pathParams petId = 123
Given url 'https://petstore.swagger.io/v2/pet/' + petId
When method get
Then status 200
And match response contains { id: '#number', name: '#string', status: '#string' }
And match !response contains 'internalField'

Scenario: Rate Limiting Enforcement
* def calls = function(count){
for(var i=0; i < count; i++){
karate.callSingle('classpath:tests/RateLimitTest.feature')
}
}
* eval calls(20)
Then status 429
