Feature: Pet lifecycle management (critical E2E flows for high-impact functionality)
Background:
* def baseUrl = '[https://petstore.swagger.io/v2](https://petstore.swagger.io/v2)'
* url baseUrl
* configure headers = { Accept: 'application/json' }
* def petSchema =
"""
{
id: '##number',
category: '##object',
name: '#string',
photoUrls: '#[] string',
tags: '##[] object',
status: '#string'
}
"""
* def apiResponseSchema =
"""
{
code: '##number',
type: '##string',
message: '##string'
}
"""

@critical @pet @create @schema
Scenario: Create a new pet with full payload and verify persistence
* configure headers = { Accept: 'application/json', Content-Type: 'application/json' }
* def payload =
"""
{
"id": 9223372036854710001,
"category": { "id": 10, "name": "dogs" },
"name": "Kona",
"photoUrls": ["[https://img.example/pets/kona.png](https://img.example/pets/kona.png)"],
"tags": [{ "id": 201, "name": "friendly" }],
"status": "available"
}
"""
Given path 'pet'
And request payload
When method post
Then status 200
And match response == petSchema
And match response.name == 'Kona'
And match response.status == 'available'
Given path 'pet', 9223372036854710001
When method get
Then status 200
And match response.id == 9223372036854710001
And match response == petSchema

@high @pet @update @schema
Scenario: Update an existing pet via PUT and verify fields changed
* configure headers = { Accept: 'application/json', Content-Type: 'application/json' }
* def create =
"""
{
"id": 9223372036854710002,
"category": { "id": 99, "name": "temp" },
"name": "Mochi",
"photoUrls": ["[https://img.example/pets/mochi.png](https://img.example/pets/mochi.png)"],
"tags": [{ "id": 202, "name": "adoptable" }],
"status": "pending"
}
"""
Given path 'pet'
And request create
When method post
Then status 200
* def payload =
"""
{
"id": 9223372036854710002,
"category": { "id": 11, "name": "cats" },
"name": "Mochi-Upd",
"photoUrls": ["[https://img.example/pets/mochi.png](https://img.example/pets/mochi.png)"],
"tags": [{ "id": 202, "name": "adoptable" }],
"status": "sold"
}
"""
Given path 'pet'
And request payload
When method put
Then status 200
And match response == petSchema
And match response.name == 'Mochi-Upd'
And match response.status == 'sold'
Given path 'pet', 9223372036854710002
When method get
Then status 200
And match response.name == 'Mochi-Upd'
And match response.category.name == 'cats'

@critical @pet @read @query
Scenario Outline: Find pets by status returns only requested statuses
* configure headers = { Accept: 'application/json' }
Given path 'pet', 'findByStatus'
And param status = '<status>'
When method get
Then status 200
And match response == '#[]'
And match each response == petSchema
And match each response[*].status == '<status>'
Examples:
| status    |
| available |
| pending   |
| sold      |

@medium @pet @read @query
Scenario: Find pets by multiple statuses
* configure headers = { Accept: 'application/json' }
Given path 'pet', 'findByStatus'
And param status = 'available,pending'
When method get
Then status 200
And match response == '#[]'
And match each response == petSchema
And match each response[*].status == '#? ["available","pending"].includes(_ )'

@medium @pet @negative @validation
Scenario: Create a pet with missing required fields should be rejected
* configure headers = { Accept: 'application/json', Content-Type: 'application/json' }
* def bad =
"""
{
"id": 9223372036854710003,
"category": { "id": 12, "name": "birds" }
}
"""
Given path 'pet'
And request bad
When method post
Then status 405

@critical @pet @read @negative
Scenario: Get pet by non-existing id returns 404
* configure headers = { Accept: 'application/json' }
Given path 'pet', 999999999999999999
When method get
Then status 404

@high @pet @read @negative @validation
Scenario Outline: Get pet by invalid id format returns client error
* configure headers = { Accept: 'application/json' }
Given path 'pet', <petId>
When method get
Then status 400
Examples:
| petId |
| -1    |
| 0     |
| 'abc' |

@high @pet @form
Scenario: Update a pet using form data (name and status)
* configure headers = { Accept: 'application/json', Content-Type: 'application/json' }
* def pet =
"""
{
"id": 9223372036854710004,
"name": "Pixel",
"photoUrls": ["[https://img.example/pets/pixel.png](https://img.example/pets/pixel.png)"],
"status": "available"
}
"""
Given path 'pet'
And request pet
When method post
Then status 200
* configure headers = { Accept: 'application/json', Content-Type: 'application/x-www-form-urlencoded' }
Given path 'pet', 9223372036854710004
And form field name = 'PixelRenamed'
And form field status = 'pending'
When method post
Then status 200
* configure headers = { Accept: 'application/json' }
Given path 'pet', 9223372036854710004
When method get
Then status 200
And match response.name == 'PixelRenamed'
And match response.status == 'pending'

@high @pet @upload
Scenario: Upload an image for a pet
* configure headers = { Accept: 'application/json' }
* def ensure =
"""
{
"id": 9223372036854710005,
"name": "Roxy",
"photoUrls": ["[https://img.example/pets/roxy.png](https://img.example/pets/roxy.png)"],
"status": "available"
}
"""
Given path 'pet'
And request ensure
When method post
Then status 200
* def temp = karate.write('pet image', 'pet.txt')
* configure headers = { Accept: 'application/json', Content-Type: 'multipart/form-data' }
Given path 'pet', 9223372036854710005, 'uploadImage'
And multipart field additionalMetadata = 'show profile'
And multipart file file = { read: 'file:' + temp, filename: 'pet.txt', contentType: 'text/plain' }
When method post
Then status 200
And match response == apiResponseSchema
And match response.message contains '9223372036854710005'

@critical @pet @delete @security
Scenario: Delete a pet with api_key authentication
* configure headers = { Accept: 'application/json', Content-Type: 'application/json' }
* def pet =
"""
{
"id": 9223372036854710006,
"name": "Bolt",
"photoUrls": ["[https://img.example/pets/bolt.png](https://img.example/pets/bolt.png)"],
"status": "available"
}
"""
Given path 'pet'
And request pet
When method post
Then status 200
* configure headers = { Accept: 'application/json', api_key: 'special-key' }
Given path 'pet', 9223372036854710006
When method delete
Then status 200
* configure headers = { Accept: 'application/json' }
Given path 'pet', 9223372036854710006
When method get
Then status 404

@high @pet @delete @negative @security
Scenario: Deleting a pet without api_key should be rejected
* configure headers = { Accept: 'application/json', Content-Type: 'application/json' }
* def pet =
"""
{
"id": 9223372036854710007,
"name": "Nala",
"photoUrls": ["[https://img.example/pets/nala.png](https://img.example/pets/nala.png)"],
"status": "available"
}
"""
Given path 'pet'
And request pet
When method post
Then status 200
* configure headers = { Accept: 'application/json' }
Given path 'pet', 9223372036854710007
When method delete
* assert responseStatus == 400 || responseStatus == 401 || responseStatus == 403

Feature: Store order management (inventory, order placement, and fulfillment)
Background:
* def baseUrl = '[https://petstore.swagger.io/v2](https://petstore.swagger.io/v2)'
* url baseUrl
* configure headers = { Accept: 'application/json' }
* def orderSchema =
"""
{
id: '##number',
petId: '#number',
quantity: '#number',
shipDate: '##string',
status: '##string',
complete: '##boolean'
}
"""
* def apiResponseSchema =
"""
{
code: '##number',
type: '##string',
message: '##string'
}
"""

@critical @store @inventory @security
Scenario: Get inventory by status with api_key and validate structure
* configure headers = { Accept: 'application/json', api_key: 'special-key' }
Given path 'store', 'inventory'
When method get
Then status 200
And match response == '#object'
* def keys = karate.keysOf(response)
* match each keys contains '#? ["available","pending","sold"].includes(_ )'
* match each response[*] == '#? _ >= 0'

@critical @store @order @schema
Scenario: Place an order for a pet and verify retrieval
* configure headers = { Accept: 'application/json', Content-Type: 'application/json' }
* def order =
"""
{
"id": 7001,
"petId": 9223372036854710001,
"quantity": 2,
"shipDate": "2025-10-01T09:00:00.000Z",
"status": "placed",
"complete": true
}
"""
Given path 'store', 'order'
And request order
When method post
Then status 200
And match response == orderSchema
And match response.status == 'placed'
Given path 'store', 'order', 7001
When method get
Then status 200
And match response == orderSchema
And match response.quantity == 2

@high @store @order @negative
Scenario: Get order by non-existing id returns 404
* configure headers = { Accept: 'application/json' }
Given path 'store', 'order', 9999999
When method get
Then status 404

@high @store @order @negative @validation
Scenario Outline: Place an order with invalid payload should be rejected
* configure headers = { Accept: 'application/json', Content-Type: 'application/json' }
* def badOrder =
"""
{
id: <id>,
petId: <petId>,
quantity: <quantity>,
shipDate: <shipDate>,
status: <status>,
complete: <complete>
}
"""
Given path 'store', 'order'
And request badOrder
When method post
Then status 400
Examples:
| id   | petId | quantity | shipDate                   | status    | complete |
| 7002 | null  | 1        | "2025-10-01T09:00:00.000Z" | "placed"  | true     |
| 7003 | 1     | -1       | "2025-10-01T09:00:00.000Z" | "placed"  | false    |
| 7004 | 1     | 1        | "invalid"                  | "placed"  | false    |
| 7005 | 1     | 1        | "2025-10-01T09:00:00.000Z" | "bad"     | false    |

@high @store @order @delete
Scenario: Delete an existing order
* configure headers = { Accept: 'application/json', Content-Type: 'application/json' }
* def order =
"""
{
"id": 7006,
"petId": 9223372036854710001,
"quantity": 1,
"shipDate": "2025-10-01T09:00:00.000Z",
"status": "placed",
"complete": false
}
"""
Given path 'store', 'order'
And request order
When method post
Then status 200
Given path 'store', 'order', 7006
When method delete
Then status 200
Given path 'store', 'order', 7006
When method get
Then status 404

@medium @store @order @negative
Scenario Outline: Delete order with invalid id returns client error
* configure headers = { Accept: 'application/json' }
Given path 'store', 'order', <orderId>
When method delete
Then status 400
Examples:
| orderId |
| -1      |
| 0       |
| 'abc'   |

Feature: User account management (authentication and CRUD)
Background:
* def baseUrl = '[https://petstore.swagger.io/v2](https://petstore.swagger.io/v2)'
* url baseUrl
* configure headers = { Accept: 'application/json' }
* def userSchema =
"""
{
id: '##number',
username: '#string',
firstName: '##string',
lastName: '##string',
email: '##string',
password: '##string',
phone: '##string',
userStatus: '##number'
}
"""

@critical @user @create @schema
Scenario: Create a user and verify retrieval by username
* configure headers = { Accept: 'application/json', Content-Type: 'application/json' }
* def u =
"""
{
"id": 501,
"username": "qa_user_501",
"firstName": "QA",
"lastName": "User",
"email": "[qa501@example.com](mailto:qa501@example.com)",
"password": "Secret#123",
"phone": "+33123456789",
"userStatus": 1
}
"""
Given path 'user'
And request u
When method post
Then status 200
* configure headers = { Accept: 'application/json' }
Given path 'user', 'qa_user_501'
When method get
Then status 200
And match response == userSchema
And match response.email == '[qa501@example.com](mailto:qa501@example.com)'

@critical @user @auth
Scenario: Login with valid credentials returns session info headers
* configure headers = { Accept: 'application/json' }
Given path 'user', 'login'
And param username = 'qa_user_501'
And param password = 'Secret#123'
When method get
Then status 200
And match response contains 'logged in user session'
* match responseHeaders['X-Rate-Limit'][0] == '#present'
* match responseHeaders['X-Expires-After'][0] == '#present'

@high @user @auth @negative
Scenario: Login with invalid credentials fails
* configure headers = { Accept: 'application/json' }
Given path 'user', 'login'
And param username = 'qa_user_501'
And param password = 'WrongPass!'
When method get
Then status 400

@medium @user @auth
Scenario: Logout current user session
* configure headers = { Accept: 'application/json' }
Given path 'user', 'logout'
When method get
Then status 200

@high @user @bulk
Scenario: Create multiple users with array input
* configure headers = { Accept: 'application/json', Content-Type: 'application/json' }
* def arr =
"""
[
{
"id": 601,
"username": "qa_user_601",
"firstName": "QA",
"lastName": "One",
"email": "[qa601@example.com](mailto:qa601@example.com)",
"password": "Secret#123",
"phone": "+33111111111",
"userStatus": 1
},
{
"id": 602,
"username": "qa_user_602",
"firstName": "QA",
"lastName": "Two",
"email": "[qa602@example.com](mailto:qa602@example.com)",
"password": "Secret#123",
"phone": "+33222222222",
"userStatus": 1
}
]
"""
Given path 'user', 'createWithArray'
And request arr
When method post
Then status 200
* configure headers = { Accept: 'application/json' }
Given path 'user', 'qa_user_601'
When method get
Then status 200
Given path 'user', 'qa_user_602'
When method get
Then status 200

@medium @user @bulk
Scenario: Create multiple users with list input
* configure headers = { Accept: 'application/json', Content-Type: 'application/json' }
* def list =
"""
[
{
"id": 611,
"username": "qa_user_611",
"firstName": "QA",
"lastName": "List",
"email": "[qa611@example.com](mailto:qa611@example.com)",
"password": "Secret#123",
"phone": "+33333333333",
"userStatus": 1
}
]
"""
Given path 'user', 'createWithList'
And request list
When method post
Then status 200
* configure headers = { Accept: 'application/json' }
Given path 'user', 'qa_user_611'
When method get
Then status 200

@high @user @update
Scenario: Update existing user details
* configure headers = { Accept: 'application/json', Content-Type: 'application/json' }
* def ensure =
"""
{
"id": 501,
"username": "qa_user_501",
"firstName": "QA",
"lastName": "User",
"email": "[qa501@example.com](mailto:qa501@example.com)",
"password": "Secret#123",
"phone": "+33123456789",
"userStatus": 1
}
"""
Given path 'user'
And request ensure
When method post
Then status 200
* def update =
"""
{
"id": 501,
"username": "qa_user_501",
"firstName": "QA",
"lastName": "User-Updated",
"email": "[qa501.updated@example.com](mailto:qa501.updated@example.com)",
"password": "Secret#123",
"phone": "+33999999999",
"userStatus": 2
}
"""
Given path 'user', 'qa_user_501'
And request update
When method put
Then status 200
* configure headers = { Accept: 'application/json' }
Given path 'user', 'qa_user_501'
When method get
Then status 200
And match response.lastName == 'User-Updated'
And match response.userStatus == 2

@critical @user @delete
Scenario: Delete user and verify subsequent lookup returns 404
* configure headers = { Accept: 'application/json', Content-Type: 'application/json' }
* def toCreate =
"""
{
"id": 5120,
"username": "qa_user_to_delete",
"firstName": "QA",
"lastName": "Del",
"email": "[qa_delete@example.com](mailto:qa_delete@example.com)",
"password": "Secret#123",
"phone": "+33000000001",
"userStatus": 1
}
"""
Given path 'user'
And request toCreate
When method post
Then status 200
* configure headers = { Accept: 'application/json' }
Given path 'user', 'qa_user_to_delete'
When method delete
Then status 200
Given path 'user', 'qa_user_to_delete'
When method get
Then status 404

@medium @user @negative
Scenario Outline: User operations with invalid usernames return client error
* configure headers = { Accept: 'application/json' }
Given path 'user', <username>
When method get
Then status 400
Examples:
| username     |
| ''           |
| ' '          |
| '../../etc'  |

@medium @user @negative @validation
Scenario: Create a user with invalid email format should be rejected
* configure headers = { Accept: 'application/json', Content-Type: 'application/json' }
* def invalid =
"""
{
"id": 512,
"username": "qa_user_512",
"firstName": "QA",
"lastName": "User",
"email": "invalid-email",
"password": "Secret#123",
"phone": "+33000000000",
"userStatus": 1
}
"""
Given path 'user'
And request invalid
When method post
Then status 400

Feature: Cross-cutting quality attributes and robustness (security, limits, and schema conformance)
Background:
* def baseUrl = '[https://petstore.swagger.io/v2](https://petstore.swagger.io/v2)'
* url baseUrl
* configure headers = { Accept: 'application/json' }
* def apiResponseSchema =
"""
{
code: '##number',
type: '##string',
message: '##string'
}
"""
* def petSchema =
"""
{
id: '##number',
category: '##object',
name: '#string',
photoUrls: '#[] string',
tags: '##[] object',
status: '#string'
}
"""
* def orderSchema =
"""
{
id: '##number',
petId: '#number',
quantity: '#number',
shipDate: '##string',
status: '##string',
complete: '##boolean'
}
"""

@security @headers @negative
Scenario: Reject requests with unsupported media type
* configure headers = { Accept: 'application/json', Content-Type: 'text/plain' }
Given path 'pet'
And request 'plain text is not allowed'
When method post
Then status 415

@limits @negative
Scenario: Reject oversized request body for pet creation
* configure headers = { Accept: 'application/json', Content-Type: 'application/json' }
* def photoUrls = []
* def i = 0
* while(i < 10000) karate.appendTo(photoUrls, '[https://img.example/pets/big-](https://img.example/pets/big-)' + i++ + '.png')
* def big =
"""
{
id: 9223372036854710010,
name: "BigPayload",
photoUrls: **PHOTO**,
status: "available"
}
"""
* big.photoUrls = photoUrls
Given path 'pet'
And request big
When method post
Then status 413

@schema @contract
Scenario: Pet by id conforms to schema
* configure headers = { Accept: 'application/json' }
Given path 'pet', 9223372036854710001
When method get
Then status 200
And match response == petSchema

@schema @contract
Scenario: Find pets by status returns array of Pet
* configure headers = { Accept: 'application/json' }
Given path 'pet', 'findByStatus'
And param status = 'available'
When method get
Then status 200
And match response == '#[]'
And match each response == petSchema

@schema @contract
Scenario: Get order by id conforms to schema
* configure headers = { Accept: 'application/json' }
Given path 'store', 'order', 7001
When method get
Then status 200
And match response == orderSchema

@schema @contract
Scenario: Inventory is a map of string to int
* configure headers = { Accept: 'application/json' }
Given path 'store', 'inventory'
When method get
Then status 200
And match response == '#object'
* match each response[*] == '#number'

@schema @contract
Scenario: Get user by username conforms to schema
* configure headers = { Accept: 'application/json' }
Given path 'user', 'qa_user_501'
When method get
Then status 200
And match response == userSchema

@schema @contract
Scenario: Place order conforms to schema
* configure headers = { Accept: 'application/json', Content-Type: 'application/json' }
* def order =
"""
{
"id": 7200,
"petId": 9223372036854710001,
"quantity": 1,
"shipDate": "2025-10-01T10:00:00.000Z",
"status": "placed",
"complete": false
}
"""
Given path 'store', 'order'
And request order
When method post
Then status 200
And match response == orderSchema

@id-boundaries @pet
Scenario Outline: Boundary testing for 64-bit ids on pet resource
* configure headers = { Accept: 'application/json', Content-Type: 'application/json' }
* def payload =
"""
{
"id": <id>,
"name": "BoundaryPet",
"photoUrls": ["[https://img.example/pets/boundary.png](https://img.example/pets/boundary.png)"],
"status": "available"
}
"""
Given path 'pet'
And request payload
When method post
Then status 200
* configure headers = { Accept: 'application/json' }
Given path 'pet', <id>
When method get
Then status 200
Examples:
| id                  |
| 1                   |
| 9223372036854775806 |
| 9223372036854775807 |

@negative @id-boundaries @pet
Scenario Outline: Invalid id boundaries are rejected for pet resource
* configure headers = { Accept: 'application/json' }
Given path 'pet', <id>
When method get
Then status 400
Examples:
| id                    |
| -9223372036854775808  |
| 9223372036854775808   |
| 'NaN'                 |

@security @api-key @pet
Scenario: Requests requiring api_key are authorized when header present
* configure headers = { Accept: 'application/json', api_key: 'special-key' }
Given path 'pet', 9223372036854710001
When method get
Then status 200

@security @api-key @negative @pet
Scenario: Requests requiring api_key are rejected when header missing
* configure headers = { Accept: 'application/json' }
Given path 'pet', 9223372036854710001
When method get
* assert responseStatus == 400 || responseStatus == 401 || responseStatus == 403

@resilience @method-override @negative
Scenario: Method not allowed returns 405
* configure headers = { Accept: 'application/json' }
Given path 'store', 'inventory'
And request {}
When method put
Then status 405

@performance @headers
Scenario: Rate limit headers present on user login response
* configure headers = { Accept: 'application/json' }
Given path 'user', 'login'
And param username = 'qa_user_501'
And param password = 'Secret#123'
When method get
Then status 200
* match responseHeaders['X-Rate-Limit'][0] == '#present'
* match responseHeaders['X-Expires-After'][0] == '#present'

@compat @deprecation
Scenario: Find pets by tags remains available but flagged as deprecated in API definition
* configure headers = { Accept: 'application/json' }
Given path 'pet', 'findByTags'
And param tags = 'tag1,tag2'
When method get
Then status 200
And match response == '#[]'
* configure headers = { Accept: 'application/json' }
Given path 'swagger.json'
When method get
Then status 200
* def deprecatedFlag = response.paths['/pet/findByTags'].get.deprecated
* match deprecatedFlag == true

@observability @errors
Scenario Outline: Error responses return machine-readable bodies
* configure headers = { Accept: 'application/json' }
Given path <p1>, <p2>, <p3>
When method <method>
Then status <status>
And match response == apiResponseSchema
Examples:
| method | p1     | p2        | p3                 | status |
| 'get'  | 'pet'  | 0         | null               | 400    |
| 'get'  | 'pet'  | 999999999 | null               | 404    |
| 'delete' | 'store' | 'order'   | 0                  | 400    |
| 'get'  | 'user' | 'nonexistent_user' | null | 404    |
