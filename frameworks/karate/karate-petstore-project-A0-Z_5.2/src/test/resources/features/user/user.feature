Feature: User API — P0/P1 risk-based account lifecycle, bulk creation, and session endpoints

  Background:
    * url baseUrl
    * configure headers = { Accept: 'application/json' }

  @P0 @HighRisk @Positive
  Scenario: Create User — Create a single user (POST /user)
    * def username = 'auto-user-' + karate.time()
    * header Content-Type = 'application/json'
    * def user =
      """
      {
        "id": 1,
        "username": "#(username)",
        "firstName": "Auto",
        "lastName": "User",
        "email": "auto.user@example.invalid",
        "password": "P@ssw0rd!",
        "phone": "+33123456789",
        "userStatus": 1
      }
      """
    * def _ = call read('classpath:features/common/keywords.feature@CreateUserJson') { user: user }

  @P0 @HighRisk @Positive
  Scenario: Get User By Name — Retrieve a user created in the same test
    * def username = 'auto-user-' + karate.time()
    * header Content-Type = 'application/json'
    * def user =
      """
      {
        "id": 2,
        "username": "#(username)",
        "firstName": "Auto",
        "lastName": "User",
        "email": "auto.user2@example.invalid",
        "password": "P@ssw0rd!",
        "phone": "+33123456780",
        "userStatus": 1
      }
      """
    * def _ = call read('classpath:features/common/keywords.feature@CreateUserJson') { user: user }

    Given path 'user', username
    When method get
    Then status 200
    And match response.username == username
    And match response.email == 'auto.user2@example.invalid'

  @P0 @HighRisk @Negative @Validation
  Scenario: Get User By Name — Return 400 for invalid username supplied (blank)
    Given path 'user', '%20'
    When method get
    Then status 400

  @P0 @HighRisk @Negative @NotFound
  Scenario: Get User By Name — Return 404 when user is not found
    Given path 'user', 'auto-user-does-not-exist'
    When method get
    Then status 404

  @P0 @HighRisk @Positive
  Scenario: Update User — Update an existing user (PUT /user/{username})
    * def username = 'auto-user-' + karate.time()
    * header Content-Type = 'application/json'
    * def userCreate =
      """
      {
        "id": 3,
        "username": "#(username)",
        "firstName": "Auto",
        "lastName": "User",
        "email": "auto.user3@example.invalid",
        "password": "P@ssw0rd!",
        "phone": "+33123456781",
        "userStatus": 1
      }
      """
    * def _ = call read('classpath:features/common/keywords.feature@CreateUserJson') { user: userCreate }

    * def userUpdate =
      """
      {
        "id": 3,
        "username": "#(username)",
        "firstName": "AutoUpdated",
        "lastName": "UserUpdated",
        "email": "auto.user3.updated@example.invalid",
        "password": "P@ssw0rd!",
        "phone": "+33123456782",
        "userStatus": 2
      }
      """
    Given path 'user', username
    And request userUpdate
    When method put
    Then status 200

    Given path 'user', username
    When method get
    Then status 200
    And match response.firstName == 'AutoUpdated'
    And match response.userStatus == 2

  @P0 @HighRisk @Negative @NotFound
  Scenario: Update User — Return 404 when user is not found
    * header Content-Type = 'application/json'
    * def userMissing =
      """
      {
        "id": 4,
        "username": "auto-user-missing",
        "firstName": "X",
        "lastName": "Y"
      }
      """
    Given path 'user', 'auto-user-missing'
    And request userMissing
    When method put
    Then status 404

  @P0 @HighRisk @Positive
  Scenario: Delete User — Delete an existing user and verify it is no longer retrievable
    * def username = 'auto-user-' + karate.time()
    * header Content-Type = 'application/json'
    * def userCreate =
      """
      {
        "id": 5,
        "username": "#(username)",
        "firstName": "Auto",
        "lastName": "User",
        "email": "auto.user5@example.invalid",
        "password": "P@ssw0rd!",
        "phone": "+33123456783",
        "userStatus": 1
      }
      """
    * def _ = call read('classpath:features/common/keywords.feature@CreateUserJson') { user: userCreate }

    Given path 'user', username
    When method delete
    Then status 200

    Given path 'user', username
    When method get
    Then status 404

  @P0 @HighRisk @Negative @NotFound
  Scenario: Delete User — Return 404 when user is not found
    Given path 'user', 'auto-user-does-not-exist'
    When method delete
    Then status 404

  @P0 @HighRisk @Negative @Validation
  Scenario: Delete User — Return 400 for invalid username supplied (blank)
    Given path 'user', '%20'
    When method delete
    Then status 400

  @P1 @MediumRisk @Positive @Bulk
  Scenario: Create Users With Array — Bulk create users (POST /user/createWithArray)
    * def u1 = 'auto-bulk-' + karate.time()
    * def u2 = 'auto-bulk-' + (karate.time() + 1)
    * header Content-Type = 'application/json'
    * def users =
      """
      [
        { "id": 101, "username": "#(u1)", "firstName": "Bulk", "lastName": "One", "email": "bulk.one@example.invalid" },
        { "id": 102, "username": "#(u2)", "firstName": "Bulk", "lastName": "Two", "email": "bulk.two@example.invalid" }
      ]
      """
    Given path 'user', 'createWithArray'
    And request users
    When method post
    Then status 200

    Given path 'user', u1
    When method get
    Then status 200

    Given path 'user', u2
    When method get
    Then status 200

  @P1 @MediumRisk @Positive @Bulk
  Scenario: Create Users With List — Bulk create users (POST /user/createWithList)
    * def u1 = 'auto-list-' + karate.time()
    * def u2 = 'auto-list-' + (karate.time() + 1)
    * header Content-Type = 'application/json'
    * def users =
      """
      [
        { "id": 201, "username": "#(u1)", "firstName": "List", "lastName": "One", "email": "list.one@example.invalid" },
        { "id": 202, "username": "#(u2)", "firstName": "List", "lastName": "Two", "email": "list.two@example.invalid" }
      ]
      """
    Given path 'user', 'createWithList'
    And request users
    When method post
    Then status 200

    Given path 'user', u1
    When method get
    Then status 200

    Given path 'user', u2
    When method get
    Then status 200

  @P0 @HighRisk @Positive @Session
  Scenario: Login User — Successful login returns token string and required headers
    Given path 'user', 'login'
    And param username = 'user1'
    And param password = 'password'
    When method get
    Then status 200
    And match header X-Rate-Limit == '#regex ^\\d+$'
    And match header X-Expires-After == '#regex ^\\d{4}-\\d{2}-\\d{2}T\\d{2}:\\d{2}:\\d{2}.*$'
    And match response == '#string'
    And match response != ''

  @P0 @HighRisk @Negative @Validation @Session
  Scenario: Login User — Return 400 when required query parameter "username" is missing
    Given path 'user', 'login'
    And param password = 'password'
    When method get
    Then status 400

  @P0 @HighRisk @Negative @Validation @Session
  Scenario: Login User — Return 400 when required query parameter "password" is missing
    Given path 'user', 'login'
    And param username = 'user1'
    When method get
    Then status 400

  @P0 @HighRisk @Negative @AuthN @Session
  Scenario: Login User — Return 400 for invalid username/password supplied
    Given path 'user', 'login'
    And param username = 'user1'
    And param password = 'wrong-password'
    When method get
    Then status 400

  @P1 @MediumRisk @Positive @Session
  Scenario: Logout User — Successful logout terminates session (GET /user/logout)
    Given path 'user', 'logout'
    When method get
    Then status 200
