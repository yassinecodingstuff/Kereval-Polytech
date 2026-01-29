Feature: Contract validation — P0 schema conformance for Pet, Order, and User resources

  Background:
    * url baseUrl
    * configure headers = { Accept: 'application/json' }

  @P0 @HighRisk @Contract
  Scenario: Pet Schema — Response from GET /pet/{petId} conforms to Pet definition (types and enums)
    * def petId = karate.time()
    * header Content-Type = 'application/json'
    * header Authorization = 'Bearer ' + writePetsToken
    * def petCreate =
      """
      {
        "id": #(petId),
        "category": { "id": 10, "name": "dogs" },
        "name": "automation-schema-pet",
        "photoUrls": ["https://example.invalid/pets/#(petId)/1.jpg"],
        "tags": [{ "id": 1, "name": "tag1" }],
        "status": "available"
      }
      """
    Given path 'pet'
    And request petCreate
    When method post
    Then status 200

    * header api_key = apiKey
    Given path 'pet', petId
    When method get
    Then status 200
    And match response ==
      """
      {
        "id": "#number",
        "category": { "id": "#number", "name": "#string" },
        "name": "#string",
        "photoUrls": "#[]",
        "tags": [ { "id": "#number", "name": "#string" } ],
        "status": "#string"
      }
      """
    And match response.status == '#? ["available","pending","sold"].includes(_)'
    And match response.name == 'automation-schema-pet'
    And match response.category.name == 'dogs'
    And match response.tags[0].name == 'tag1'

  @P0 @HighRisk @Contract
  Scenario: Order Schema — Response from POST /store/order conforms to Order definition (types and enums)
    * def orderId = karate.time()
    * header Content-Type = 'application/json'
    * def order =
      """
      {
        "id": #(orderId),
        "petId": 1,
        "quantity": 2,
        "shipDate": "2030-01-01T00:00:00Z",
        "status": "approved",
        "complete": true
      }
      """
    Given path 'store', 'order'
    And request order
    When method post
    Then status 200
    And match response ==
      """
      {
        "id": "#number",
        "petId": "#number",
        "quantity": "#number",
        "shipDate": "#string",
        "status": "#string",
        "complete": "#boolean"
      }
      """
    And match response.id == orderId
    And match response.status == '#? ["placed","approved","delivered"].includes(_)'
    And match response.complete == true

  @P0 @HighRisk @Contract
  Scenario: User Schema — Response from GET /user/{username} conforms to User definition (types)
    * def username = 'auto-schema-user-' + karate.time()
    * header Content-Type = 'application/json'
    * def user =
      """
      {
        "id": 999,
        "username": "#(username)",
        "firstName": "Schema",
        "lastName": "User",
        "email": "schema.user@example.invalid",
        "password": "P@ssw0rd!",
        "phone": "+33123456700",
        "userStatus": 3
      }
      """
    Given path 'user'
    And request user
    When method post
    Then status 200

    Given path 'user', username
    When method get
    Then status 200
    And match response ==
      """
      {
        "id": "#number",
        "username": "#string",
        "firstName": "#string",
        "lastName": "#string",
        "email": "#string",
        "password": "#string",
        "phone": "#string",
        "userStatus": "#number"
      }
      """
    And match response.username == username
    And match response.userStatus == 3
