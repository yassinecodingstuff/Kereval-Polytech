Feature: Pet lifecycle management (critical E2E flows for high-impact functionality)
Background:
Given the API base URL is "[https://petstore.swagger.io/v2](https://petstore.swagger.io/v2)"
And I set header "Accept" to "application/json"
And I set header "Content-Type" to "application/json"

@critical @pet @create @schema
Scenario: Create a new pet with full payload and verify persistence
When I POST "/pet" with JSON body:
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
Then the response status should be 200
And the response matches schema "Pet"
And the response body at "$.name" equals "Kona"
And the response body at "$.status" equals "available"
When I GET "/pet/9223372036854710001"
Then the response status should be 200
And the response body at "$.id" equals 9223372036854710001
And the response matches schema "Pet"

@high @pet @update @schema
Scenario: Update an existing pet via PUT and verify fields changed
Given a pet exists with id 9223372036854710002 and name "Mochi" and status "pending"
When I PUT "/pet" with JSON body:
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
Then the response status should be 200
And the response matches schema "Pet"
And the response body at "$.name" equals "Mochi-Upd"
And the response body at "$.status" equals "sold"
When I GET "/pet/9223372036854710002"
Then the response status should be 200
And the response body at "$.name" equals "Mochi-Upd"
And the response body at "$.category.name" equals "cats"

@critical @pet @read @query
Scenario Outline: Find pets by status returns only requested statuses
When I GET "/pet/findByStatus?status=<status>"
Then the response status should be 200
And the response body is an array
And for each item in "$":
| path         | rule                 | expected     |
| $.status     | equals               | <status>     |
| $.id         | is-integer           |              |
| $.name       | is-non-empty-string  |              |
And each item matches schema "Pet"
Examples:
| status     |
| available  |
| pending    |
| sold       |

@medium @pet @read @query
Scenario: Find pets by multiple statuses
When I GET "/pet/findByStatus?status=available,pending"
Then the response status should be 200
And the response body is an array
And for each item in "$":
| path     | rule            | expected                 |
| $.status | is-one-of       | available,pending        |
And each item matches schema "Pet"

@medium @pet @negative @validation
Scenario: Create a pet with missing required fields should be rejected
When I POST "/pet" with JSON body:
"""
{
"id": 9223372036854710003,
"category": { "id": 12, "name": "birds" }
}
"""
Then the response status should be 405

@critical @pet @read @negative
Scenario: Get pet by non-existing id returns 404
When I GET "/pet/999999999999999999"
Then the response status should be 404

@high @pet @read @negative @validation
Scenario Outline: Get pet by invalid id format returns client error
When I GET "/pet/<petId>"
Then the response status should be 400
Examples:
| petId     |
| -1        |
| 0         |
| abc       |

@high @pet @form
Scenario: Update a pet using form data (name and status)
Given a pet exists with id 9223372036854710004 and name "Pixel" and status "available"
And I set header "Content-Type" to "application/x-www-form-urlencoded"
When I POST "/pet/9223372036854710004" with form fields:
| name   | PixelRenamed |
| status | pending      |
Then the response status should be 200
When I GET "/pet/9223372036854710004"
Then the response status should be 200
And the response body at "$.name" equals "PixelRenamed"
And the response body at "$.status" equals "pending"

@high @pet @upload
Scenario: Upload an image for a pet
Given a pet exists with id 9223372036854710005 and name "Roxy" and status "available"
And I set header "Content-Type" to "multipart/form-data"
When I POST "/pet/9223372036854710005/uploadImage" with multipart fields:
| additionalMetadata | show profile |
| file               | @/tmp/pet.jpg |
Then the response status should be 200
And the response matches schema "ApiResponse"
And the response body at "$.message" contains "9223372036854710005"

@critical @pet @delete @security
Scenario: Delete a pet with api_key authentication
Given a pet exists with id 9223372036854710006 and name "Bolt" and status "available"
And I set header "api_key" to "special-key"
When I DELETE "/pet/9223372036854710006"
Then the response status should be 200
When I GET "/pet/9223372036854710006"
Then the response status should be 404

@high @pet @delete @negative @security
Scenario: Deleting a pet without api_key should be rejected
Given a pet exists with id 9223372036854710007 and name "Nala" and status "available"
And I remove header "api_key" if present
When I DELETE "/pet/9223372036854710007"
Then the response status should be one of 400,401,403

Feature: Store order management (inventory, order placement, and fulfillment)
Background:
Given the API base URL is "[https://petstore.swagger.io/v2](https://petstore.swagger.io/v2)"
And I set header "Accept" to "application/json"
And I set header "Content-Type" to "application/json"

@critical @store @inventory @security
Scenario: Get inventory by status with api_key and validate structure
And I set header "api_key" to "special-key"
When I GET "/store/inventory"
Then the response status should be 200
And the response body is an object
And for each key in "$":
| rule              |
| is-one-of: available,pending,sold |
And for each value in "$.*":
| rule         |
| is-non-negative-integer |

@critical @store @order @schema
Scenario: Place an order for a pet and verify retrieval
When I POST "/store/order" with JSON body:
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
Then the response status should be 200
And the response matches schema "Order"
And the response body at "$.status" equals "placed"
When I GET "/store/order/7001"
Then the response status should be 200
And the response matches schema "Order"
And the response body at "$.quantity" equals 2

@high @store @order @negative
Scenario: Get order by non-existing id returns 404
When I GET "/store/order/9999999"
Then the response status should be 404

@high @store @order @negative @validation
Scenario Outline: Place an order with invalid payload should be rejected
When I POST "/store/order" with JSON body:
"""
{
"id": <id>,
"petId": <petId>,
"quantity": <quantity>,
"shipDate": <shipDate>,
"status": <status>,
"complete": <complete>
}
"""
Then the response status should be 400
Examples:
| id    | petId | quantity | shipDate                     | status   | complete |
| 7002  | null  | 1        | "2025-10-01T09:00:00.000Z"   | "placed" | true     |
| 7003  | 1     | -1       | "2025-10-01T09:00:00.000Z"   | "placed" | false    |
| 7004  | 1     | 1        | "invalid"                    | "placed" | false    |
| 7005  | 1     | 1        | "2025-10-01T09:00:00.000Z"   | "bad"    | false    |

@high @store @order @delete
Scenario: Delete an existing order
Given an order exists with id 7006 for petId 9223372036854710001
When I DELETE "/store/order/7006"
Then the response status should be 200
When I GET "/store/order/7006"
Then the response status should be 404

@medium @store @order @negative
Scenario Outline: Delete order with invalid id returns client error
When I DELETE "/store/order/<orderId>"
Then the response status should be 400
Examples:
| orderId |
| -1      |
| 0       |
| abc     |

Feature: User account management (authentication and CRUD)
Background:
Given the API base URL is "[https://petstore.swagger.io/v2](https://petstore.swagger.io/v2)"
And I set header "Accept" to "application/json"
And I set header "Content-Type" to "application/json"

@critical @user @create @schema
Scenario: Create a user and verify retrieval by username
When I POST "/user" with JSON body:
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
Then the response status should be 200
When I GET "/user/qa_user_501"
Then the response status should be 200
And the response matches schema "User"
And the response body at "$.email" equals "[qa501@example.com](mailto:qa501@example.com)"

@critical @user @auth
Scenario: Login with valid credentials returns session info headers
When I GET "/user/login?username=qa_user_501&password=Secret#123"
Then the response status should be 200
And the response body contains "logged in user session"
And the response header "X-Rate-Limit" exists
And the response header "X-Expires-After" exists

@high @user @auth @negative
Scenario: Login with invalid credentials fails
When I GET "/user/login?username=qa_user_501&password=WrongPass!"
Then the response status should be 400

@medium @user @auth
Scenario: Logout current user session
When I GET "/user/logout"
Then the response status should be 200

@high @user @bulk
Scenario: Create multiple users with array input
When I POST "/user/createWithArray" with JSON body:
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
Then the response status should be 200
When I GET "/user/qa_user_601"
Then the response status should be 200
When I GET "/user/qa_user_602"
Then the response status should be 200

@medium @user @bulk
Scenario: Create multiple users with list input
When I POST "/user/createWithList" with JSON body:
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
Then the response status should be 200
When I GET "/user/qa_user_611"
Then the response status should be 200

@high @user @update
Scenario: Update existing user details
Given a user exists with username "qa_user_501"
When I PUT "/user/qa_user_501" with JSON body:
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
Then the response status should be 200
When I GET "/user/qa_user_501"
Then the response status should be 200
And the response body at "$.lastName" equals "User-Updated"
And the response body at "$.userStatus" equals 2

@critical @user @delete
Scenario: Delete user and verify subsequent lookup returns 404
Given a user exists with username "qa_user_to_delete"
When I DELETE "/user/qa_user_to_delete"
Then the response status should be 200
When I GET "/user/qa_user_to_delete"
Then the response status should be 404

@medium @user @negative
Scenario Outline: User operations with invalid usernames return client error
When I GET "/user/<username>"
Then the response status should be 400
Examples:
| username        |
| ""              |
| " "             |
| "../../etc"     |

@medium @user @negative @validation
Scenario: Create a user with invalid email format should be rejected
When I POST "/user" with JSON body:
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
Then the response status should be 400

Feature: Cross-cutting quality attributes and robustness (security, limits, and schema conformance)
Background:
Given the API base URL is "[https://petstore.swagger.io/v2](https://petstore.swagger.io/v2)"
And I set header "Accept" to "application/json"

@security @headers @negative
Scenario: Reject requests with unsupported media type
And I set header "Content-Type" to "text/plain"
When I POST "/pet" with body "plain text is not allowed"
Then the response status should be 415

@limits @negative
Scenario: Reject oversized request body for pet creation
And I set header "Content-Type" to "application/json"
And I generate a JSON body for "/pet" with "photoUrls" containing 10_000 entries
When I POST "/pet" with the generated JSON body
Then the response status should be 413

@schema @contract
Scenario Outline: All successful responses conform to Swagger schemas
When I <method> "<path>"<maybeBody>
Then the response status should be 200
And the response matches schema "<schema>"
Examples:
| method | path                                 | maybeBody                                                                                                                                                                                                                          | schema      |
| GET    | /pet/9223372036854710001             |                                                                                                                                                                                                                                    | Pet         |
| GET    | /pet/findByStatus?status=available   |                                                                                                                                                                                                                                    | Pet[]       |
| GET    | /store/order/7001                    |                                                                                                                                                                                                                                    | Order       |
| GET    | /store/inventory                     |                                                                                                                                                                                                                                    | map<string,int> |
| GET    | /user/qa_user_501                    |                                                                                                                                                                                                                                    | User        |
| POST   | /store/order                         | with JSON body: {"id":7200,"petId":9223372036854710001,"quantity":1,"shipDate":"2025-10-01T10:00:00.000Z","status":"placed","complete":false}                                                                                       | Order       |

@id-boundaries @pet
Scenario Outline: Boundary testing for 64-bit ids on pet resource
When I POST "/pet" with JSON body:
"""
{
"id": <id>,
"name": "BoundaryPet",
"photoUrls": ["[https://img.example/pets/boundary.png](https://img.example/pets/boundary.png)"],
"status": "available"
}
"""
Then the response status should be 200
When I GET "/pet/<id>"
Then the response status should be 200
Examples:
| id                  |
| 1                   |
| 9223372036854775806 |
| 9223372036854775807 |

@negative @id-boundaries @pet
Scenario Outline: Invalid id boundaries are rejected for pet resource
When I GET "/pet/<id>"
Then the response status should be 400
Examples:
| id                   |
| -9223372036854775808 |
| 9223372036854775808  |
| NaN                  |

@security @api-key @pet
Scenario: Requests requiring api_key are authorized when header present
And I set header "api_key" to "special-key"
When I GET "/pet/9223372036854710001"
Then the response status should be 200

@security @api-key @negative @pet
Scenario: Requests requiring api_key are rejected when header missing
And I remove header "api_key" if present
When I GET "/pet/9223372036854710001"
Then the response status should be one of 400,401,403

@resilience @method-override @negative
Scenario: Method not allowed returns 405
When I PUT "/store/inventory" with empty body
Then the response status should be 405

@performance @headers
Scenario: Rate limit headers present on user login response
When I GET "/user/login?username=qa_user_501&password=Secret#123"
Then the response status should be 200
And the response header "X-Rate-Limit" exists
And the response header "X-Expires-After" exists

@compat @deprecation
Scenario: Find pets by tags remains available but flagged as deprecated
When I GET "/pet/findByTags?tags=tag1,tag2"
Then the response status should be 200
And the response matches schema "Pet[]"
And the operation is marked as deprecated in the API description

@observability @errors
Scenario Outline: Error responses return machine-readable bodies
When I <method> "<path>"
Then the response status should be <status>
And the response matches schema "ApiResponse"
Examples:
| method | path                     | status |
| GET    | /pet/0                   | 400    |
| GET    | /pet/999999999999999     | 404    |
| DELETE | /store/order/0           | 400    |
| GET    | /user/nonexistent_user   | 404    |
