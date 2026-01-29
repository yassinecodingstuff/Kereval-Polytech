Feature: Store API — P0/P1 risk-based inventory visibility and order lifecycle

  Background:
    * url baseUrl
    * configure headers = { Accept: 'application/json' }

  @P0 @HighRisk @Positive @Auth
  Scenario: Get Inventory — Retrieve inventory map by status (authorized via api_key)
    * header api_key = apiKey
    Given path 'store', 'inventory'
    When method get
    Then status 200
    And match response == '#object'
    And match each response.* == '#number'

  @P0 @HighRisk @Negative @AuthZ
  Scenario: Get Inventory — Reject request without required api_key header
    Given path 'store', 'inventory'
    When method get
    Then assert responseStatus == 401 || responseStatus == 403

  @P0 @HighRisk @Positive @Order
  Scenario: Place Order — Place a valid order for a pet
    * def orderId = karate.time()
    * def petId = karate.time() + 1
    * def create = call read('classpath:features/common/keywords.feature@CreateOrderJson') { orderId: orderId, petId: petId, quantity: 1, shipDate: '2030-01-01T00:00:00Z', status: 'placed', complete: false }
    * match create.createdOrder.id == orderId
    * match create.createdOrder.petId == petId
    * match create.createdOrder.status == 'placed'

  @P0 @HighRisk @Negative @Validation
  Scenario: Place Order — Reject invalid order (negative quantity)
    * header Content-Type = 'application/json'
    * def orderInvalid =
      """
      {
        "id": 1,
        "petId": 1,
        "quantity": -1,
        "shipDate": "2030-01-01T00:00:00Z",
        "status": "placed",
        "complete": false
      }
      """
    Given path 'store', 'order'
    And request orderInvalid
    When method post
    Then status 400

  @P0 @HighRisk @Boundary @Positive
  Scenario Outline: Get Order By ID — Retrieve order for valid boundary IDs (1..10) after creation
    * def _ = call read('classpath:features/common/keywords.feature@CreateOrderJson') { orderId: orderId, petId: 1, quantity: 1, shipDate: '2030-01-01T00:00:00Z', status: 'placed', complete: false }
    Given path 'store', 'order', orderId
    When method get
    Then status 200
    And match response.id == '#number'
    Examples:
      | orderId |
      | 1       |
      | 10      |

  @P0 @HighRisk @Negative @Boundary
  Scenario: Get Order By ID — Return 400 for invalid ID supplied (orderId below minimum)
    Given path 'store', 'order', 0
    When method get
    Then status 400

  @P0 @HighRisk @Negative @NotFound
  Scenario: Get Order By ID — Return 404 when order is not found (orderId within spec but absent)
    Given path 'store', 'order', 9
    When method delete
    Then assert responseStatus == 200 || responseStatus == 404
    Given path 'store', 'order', 9
    When method get
    Then status 404

  @P0 @HighRisk @Negative @Boundary
  Scenario: Get Order By ID — Return 400 for non-integer orderId
    Given path 'store', 'order', 'not-an-integer'
    When method get
    Then status 400

  @P0 @HighRisk @Positive @Order
  Scenario: Delete Order — Delete an existing order and verify it is no longer retrievable
    * def orderId = karate.time()
    * def create = call read('classpath:features/common/keywords.feature@CreateOrderJson') { orderId: orderId, petId: 1, quantity: 1, shipDate: '2030-01-01T00:00:00Z', status: 'placed', complete: false }
    * match create.createdOrder.id == orderId

    Given path 'store', 'order', orderId
    When method delete
    Then status 200

    Given path 'store', 'order', orderId
    When method get
    Then status 404

  @P0 @HighRisk @Negative @Boundary
  Scenario: Delete Order — Return 400 for invalid ID supplied (orderId below minimum)
    Given path 'store', 'order', 0
    When method delete
    Then status 400

  @P0 @HighRisk @Negative @NotFound
  Scenario: Delete Order — Return 404 when order is not found
    Given path 'store', 'order', 9223372036854775000
    When method delete
    Then status 404

  @P1 @MediumRisk @Reliability
  Scenario: Delete Order — Idempotency behavior on repeated deletion (second call)
    Given path 'store', 'order', 1
    When method delete
    Then assert responseStatus == 200 || responseStatus == 404

    Given path 'store', 'order', 1
    When method delete
    Then status 404
