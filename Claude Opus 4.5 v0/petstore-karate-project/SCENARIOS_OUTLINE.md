# Test Scenarios Outline by Endpoint

This document organizes all test scenarios from the Pet, Store, and User feature files, grouped by endpoint.

---

## PET ENDPOINTS

### POST /pet - Create Pet

**Test Scenarios:**

1. **TC-PET-001** - Successfully add a new pet with all required fields

   - Creates pet with id, name, and photoUrls
   - Verifies response contains expected fields

2. **TC-PET-002** - Successfully add a new pet with complete data model

   - Creates pet with full data: category, photoUrls, tags, status
   - Verifies all nested objects are returned correctly

3. **TC-PET-003** - Successfully add pet with valid status enum values (Scenario Outline)

   - Tests with status values: available, pending, sold

4. **TC-PET-004** - Reject pet creation with missing required field name

   - Negative test: missing name field
   - Expected: 405 status

5. **TC-PET-005** - Reject pet creation with missing required field photoUrls

   - Negative test: missing photoUrls field
   - Expected: 405 status

6. **TC-PET-006** - Reject pet creation with empty request body

   - Negative test: empty JSON object
   - Expected: 405 or 400 status

7. **TC-PET-007** - Reject pet creation with malformed JSON payload

   - Negative test: invalid JSON syntax
   - Expected: 400, 405, or 500 status

8. **TC-PET-008** - Reject pet creation with invalid data type for id field

   - Negative test: string instead of number for id
   - Expected: 400, 405, or 500 status

9. **TC-PET-009** - Successfully add pet with special characters in name

   - Tests Unicode and special characters: "Señor Whiskers 日本語 🐱"

10. **TC-PET-010** - Successfully add pet with maximum allowed name length

    - Boundary test: 255 character name

11. **TC-PET-011** - Successfully add pet with multiple photoUrls

    - Tests array with 3 photo URLs

12. **TC-PET-012** - Successfully add pet with multiple tags

    - Tests array with 2 tag objects

13. **TC-PET-013** - Successfully add pet with XML content type

    - Content negotiation: XML format

14. **TC-PET-014** - Verify behavior without authentication

    - Security test: no API key
    - Expected: 200, 401, or 403 status

15. **TC-PET-015** - Successfully add pet with nested category object

    - Tests nested object structure

16. **TC-PET-016** - Successfully add pet with only required fields

    - Minimal payload test

17. **TC-PET-017** - Handle pet creation with empty photoUrls array
    - Boundary test: empty array
    - Expected: 200 or 405 status

---

### GET /pet/{petId} - Get Pet by ID

**Test Scenarios:**

1. **TC-PET-028** - Successfully retrieve pet by valid ID

   - Creates pet, then retrieves it
   - Verifies response matches created data

2. **TC-PET-029** - Successfully retrieve pet with API key authentication

   - Tests with special API key

3. **TC-PET-030** - Return 404 for non-existent pet ID

   - Negative test: ID 999999999999
   - Expected: 404 status

4. **TC-PET-031** - Return 400 for invalid pet ID format

   - Negative test: string ID "invalid_id"
   - Expected: 400 or 404 status

5. **TC-PET-032** - Handle negative pet ID gracefully

   - Boundary test: ID = -1
   - Expected: 400 or 404 status

6. **TC-PET-033** - Handle zero pet ID

   - Boundary test: ID = 0
   - Expected: 400 or 404 status

7. **TC-PET-034** - Handle integer overflow for pet ID

   - Boundary test: very large number
   - Expected: 400, 404, or 500 status

8. **TC-PET-035** - Retrieve pet in XML format when requested

   - Content negotiation: XML Accept header

9. **TC-PET-036** - Verify pet retrieval response time is acceptable

   - Performance test: response time < 2000ms

10. **TC-PET-044** - Verify pet response matches expected schema
    - Schema validation test

---

### GET /pet/findByStatus - Find Pets by Status

**Test Scenarios:**

1. **TC-PET-037** - Successfully find pets by single status

   - Tests with status: "available"
   - Verifies array response and status matching

2. **TC-PET-038** - Successfully find pets by each valid status value (Scenario Outline)

   - Tests with statuses: available, pending, sold

3. **TC-PET-039** - Successfully find pets by multiple statuses

   - Tests with multiple status parameters

4. **TC-PET-040** - Return 400 for invalid status value

   - Negative test: "invalid_status"
   - Expected: 200 or 400 status

5. **TC-PET-041** - Handle missing status parameter
   - Negative test: no status param
   - Expected: 400 or 200 status

---

### GET /pet/findByTags - Find Pets by Tags (Deprecated)

**Test Scenarios:**

1. **TC-PET-042** - Successfully find pets by single tag (deprecated endpoint)

   - Tests with tag: "friendly"

2. **TC-PET-043** - Successfully find pets by multiple tags
   - Tests with multiple tag parameters

---

### PUT /pet - Update Pet

**Test Scenarios:**

1. **TC-PET-018** - Successfully update an existing pet

   - Creates pet, then updates name and status
   - Verifies changes are reflected

2. **TC-PET-019** - Successfully update pet status from available to pending

   - Tests status transition

3. **TC-PET-020** - Reject update with invalid pet ID format

   - Negative test: string ID
   - Expected: 400 or 500 status

4. **TC-PET-021** - Return 404 when updating non-existent pet

   - Negative test: non-existent ID
   - Expected: 200 or 404 status

5. **TC-PET-022** - Reject update with validation exception on invalid status

   - Negative test: invalid status value
   - Expected: 200 or 405 status

6. **TC-PET-023** - Verify PUT operation is idempotent

   - Idempotency test: same request twice

7. **TC-PET-024** - Successfully update pet category

   - Tests nested object update

8. **TC-PET-025** - Successfully add tags to existing pet

   - Tests array modification

9. **TC-PET-026** - Successfully update pet photoUrls

   - Tests array replacement

10. **TC-PET-027** - Reject update with empty request body
    - Negative test: empty JSON
    - Expected: 400 or 405 status

---

### POST /pet/{petId} - Update Pet with Form Data

**Test Scenarios:**

1. **TC-PET-045** - Successfully update pet name using form data

   - Creates pet, updates name via form
   - Verifies update with GET

2. **TC-PET-046** - Successfully update pet status using form data

   - Updates status via form

3. **TC-PET-047** - Successfully update both name and status using form data

   - Updates multiple fields via form

4. **TC-PET-048** - Reject form update with invalid pet ID
   - Negative test: string ID
   - Expected: 405, 400, or 404 status

---

### DELETE /pet/{petId} - Delete Pet

**Test Scenarios:**

1. **TC-PET-049** - Successfully delete an existing pet

   - Creates pet, deletes it, verifies 404 on GET

2. **TC-PET-050** - Successfully delete pet with api_key header

   - Tests with special API key

3. **TC-PET-051** - Return 404 when deleting non-existent pet

   - Negative test: non-existent ID
   - Expected: 404 status

4. **TC-PET-052** - Return 400 for invalid pet ID format on delete

   - Negative test: string ID
   - Expected: 400 or 404 status

5. **TC-PET-053** - Verify delete is not idempotent (second call returns 404)

   - Idempotency test: delete twice

6. **TC-PET-055** - Handle deletion with negative pet ID

   - Boundary test: ID = -12345
   - Expected: 400 or 404 status

7. **TC-PET-056** - Handle deletion with zero pet ID
   - Boundary test: ID = 0
   - Expected: 400 or 404 status

---

### POST /pet/{petId}/uploadImage - Upload Pet Image

**Test Scenarios:**

1. **TC-PET-054** - Successfully upload image for existing pet (mock test)
   - Creates pet, uploads image via multipart/form-data
   - Verifies response code

---

## STORE ENDPOINTS

### GET /store/inventory - Get Store Inventory

**Test Scenarios:**

1. **TC-STORE-001** - Successfully retrieve store inventory

   - Verifies JSON object response
   - Checks Content-Type header

2. **TC-STORE-002** - Verify inventory returns status counts as integers

   - Schema validation test

3. **TC-STORE-003** - Verify inventory request behavior without API key

   - Security test: no API key
   - Expected: 200, 401, or 403 status

4. **TC-STORE-004** - Verify inventory response time is acceptable
   - Performance test: response time < 3000ms

---

### POST /store/order - Place Order

**Test Scenarios:**

1. **TC-STORE-005** - Successfully place a new order

   - Creates order with id, petId, quantity, status, complete
   - Verifies response fields

2. **TC-STORE-006** - Successfully place order with complete data

   - Includes shipDate field

3. **TC-STORE-007** - Successfully place order with valid status values (Scenario Outline)

   - Tests with statuses: placed, approved, delivered

4. **TC-STORE-008** - Reject order with invalid order data

   - Negative test: invalid payload structure
   - Expected: 200 or 400 status

5. **TC-STORE-009** - Reject order with invalid quantity data type

   - Negative test: string instead of number
   - Expected: 400 or 500 status

6. **TC-STORE-010** - Successfully place order with minimum quantity

   - Boundary test: quantity = 1

7. **TC-STORE-011** - Handle order with zero quantity

   - Boundary test: quantity = 0
   - Expected: 200 or 400 status

8. **TC-STORE-012** - Handle order with negative quantity

   - Boundary test: quantity = -1
   - Expected: 200 or 400 status

9. **TC-STORE-013** - Successfully place order with complete flag true

   - Tests complete field

10. **TC-STORE-026** - Verify order response matches expected schema
    - Schema validation test

---

### GET /store/order/{orderId} - Get Order by ID

**Test Scenarios:**

1. **TC-STORE-014** - Successfully retrieve order by valid ID

   - Creates order, then retrieves it
   - Verifies ID matches

2. **TC-STORE-015** - Successfully retrieve order with boundary IDs (1-10) (Scenario Outline)

   - Tests with IDs: 1, 5, 10

3. **TC-STORE-016** - Return 404 for non-existent order ID

   - Negative test: ID 999999999
   - Expected: 404 status

4. **TC-STORE-017** - Return 400 for invalid order ID format

   - Negative test: string ID
   - Expected: 400 or 404 status

5. **TC-STORE-018** - Return error for order ID greater than 10

   - Boundary test: ID = 11
   - Expected: 404 status

6. **TC-STORE-019** - Return error for order ID less than 1

   - Boundary test: ID = 0
   - Expected: 400 or 404 status

7. **TC-STORE-020** - Handle negative order ID

   - Boundary test: ID = -5
   - Expected: 400 or 404 status

8. **TC-STORE-021** - Retrieve order in XML format
   - Content negotiation: XML Accept header

---

### DELETE /store/order/{orderId} - Delete Order

**Test Scenarios:**

1. **TC-STORE-022** - Successfully delete an existing order

   - Creates order, deletes it, verifies 404 on GET

2. **TC-STORE-023** - Return 404 when deleting non-existent order

   - Negative test: non-existent ID
   - Expected: 404 status

3. **TC-STORE-024** - Return 400 for invalid order ID format on delete

   - Negative test: string ID
   - Expected: 400 or 404 status

4. **TC-STORE-025** - Return error when deleting order with negative ID
   - Boundary test: ID = -1
   - Expected: 400 or 404 status

---

## USER ENDPOINTS

### POST /user - Create User

**Test Scenarios:**

1. **TC-USER-001** - Successfully create a new user

   - Creates user with all fields: id, username, firstName, lastName, email, password, phone, userStatus

2. **TC-USER-002** - Successfully create user with minimum required fields

   - Minimal payload: only username

3. **TC-USER-003** - Successfully create user with special characters in name
   - Tests Unicode: "José María", "O'Brien-Smith"

---

### POST /user/createWithArray - Create Users with Array

**Test Scenarios:**

1. **TC-USER-004** - Successfully create multiple users with array
   - Creates 3 users in single request

---

### POST /user/createWithList - Create Users with List

**Test Scenarios:**

1. **TC-USER-005** - Successfully create multiple users with list
   - Creates 2 users in single request

---

### GET /user/login - User Login

**Test Scenarios:**

1. **TC-USER-006** - Successfully login with valid credentials

   - Creates user, then logs in
   - Verifies response string and rate limit headers

2. **TC-USER-007** - Verify login response contains rate limit header

   - Tests X-Rate-Limit header format

3. **TC-USER-008** - Reject login with invalid username

   - Negative test: non-existent username
   - Expected: 200 or 400 status

4. **TC-USER-009** - Reject login with empty username

   - Negative test: empty string
   - Expected: 200 or 400 status

5. **TC-USER-010** - Handle SQL injection attempt in username
   - Security test: SQL injection payload
   - Expected: 200 or 400 status

---

### GET /user/logout - User Logout

**Test Scenarios:**

1. **TC-USER-011** - Successfully logout current session

   - Basic logout test

2. **TC-USER-012** - Verify logout can be called multiple times
   - Idempotency test: logout twice

---

### GET /user/{username} - Get User by Username

**Test Scenarios:**

1. **TC-USER-013** - Successfully retrieve user by username

   - Creates user, then retrieves it
   - Verifies username matches

2. **TC-USER-014** - Verify retrieved user contains all expected fields

   - Schema validation test

3. **TC-USER-015** - Return 404 for non-existent username

   - Negative test: non-existent username
   - Expected: 404 status

4. **TC-USER-021** - Retrieve user in XML format
   - Content negotiation: XML Accept header

---

### PUT /user/{username} - Update User

**Test Scenarios:**

1. **TC-USER-016** - Successfully update existing user

   - Creates user, then updates firstName, lastName, email
   - Verifies update

2. **TC-USER-017** - Return 404 when updating non-existent user
   - Negative test: non-existent username
   - Expected: 200 or 404 status

---

### DELETE /user/{username} - Delete User

**Test Scenarios:**

1. **TC-USER-018** - Successfully delete existing user

   - Creates user, deletes it, verifies 404 on GET

2. **TC-USER-019** - Return 404 when deleting non-existent user

   - Negative test: non-existent username
   - Expected: 404 status

3. **TC-USER-020** - Verify delete is not idempotent
   - Idempotency test: delete twice, second returns 404

---

## Summary Statistics

### Pet Endpoints

- **POST /pet**: 17 scenarios
- **GET /pet/{petId}**: 10 scenarios
- **GET /pet/findByStatus**: 5 scenarios
- **GET /pet/findByTags**: 2 scenarios (deprecated)
- **PUT /pet**: 10 scenarios
- **POST /pet/{petId}** (form): 4 scenarios
- **DELETE /pet/{petId}**: 7 scenarios
- **POST /pet/{petId}/uploadImage**: 1 scenario
- **Total Pet Scenarios**: 56

### Store Endpoints

- **GET /store/inventory**: 4 scenarios
- **POST /store/order**: 10 scenarios
- **GET /store/order/{orderId}**: 8 scenarios
- **DELETE /store/order/{orderId}**: 4 scenarios
- **Total Store Scenarios**: 26

### User Endpoints

- **POST /user**: 3 scenarios
- **POST /user/createWithArray**: 1 scenario
- **POST /user/createWithList**: 1 scenario
- **GET /user/login**: 5 scenarios
- **GET /user/logout**: 2 scenarios
- **GET /user/{username}**: 4 scenarios
- **PUT /user/{username}**: 2 scenarios
- **DELETE /user/{username}**: 3 scenarios
- **Total User Scenarios**: 21

### Grand Total: 103 Test Scenarios
