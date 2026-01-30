Feature: Contract & Security — Content Negotiation, Schema Conformance, and Auth (Cross-Cutting)
  Background:
    * url baseUrl
    * configure headers = { Accept: 'application/json' }
    * def allowedStatuses = ['available','pending','sold']
    * def petSchema =
    """
    {
      id: '##number',
      category: '##object',
      name: '#string',
      photoUrls: '#[] #string',
      tags: '##[] #object',
      status: '##? allowedStatuses.includes(_)'
    }
    """
    * def orderSchema =
    """
    {
      id: '##number',
      petId: '##number',
      quantity: '##number',
      shipDate: '##string',
      status: '##string',
      complete: '##boolean'
    }
    """

  Scenario: Content negotiation — JSON when Accept = application/json (findByStatus)
    Given path 'pet', 'findByStatus'
    And param status = 'available'
    When method get
    Then status 200
    * def ct = responseHeaders['Content-Type'][0]
    * match ct startsWith 'application/json'
    And match response == '#[] #object'
    And match each response == petSchema

  Scenario: Content negotiation — JSON when Accept = application/json (get pet by id)
    * def petId = '1101'
    Given path 'pet'
    And request { id: 1101, name: 'pet-1101', photoUrls: ['http://example/1101.jpg'], status: 'sold' }
    When method post
    Then match [200,405] contains responseStatus
    Given path 'pet', petId
    When method get
    Then match [200,404] contains responseStatus
    * if (responseStatus == 200) * def ct = responseHeaders['Content-Type'][0]
    * if (responseStatus == 200) match ct startsWith 'application/json'
    * if (responseStatus == 200) match response == petSchema

  Scenario: Security — api_key header honored for protected reads
    * def petId = '1201'
    Given path 'pet'
    And request { id: 1201, name: 'secured-pet', photoUrls: ['http://example/1201.jpg'], status: 'available' }
    When method post
    Then match [200,405] contains responseStatus
    Given path 'pet', petId
    And header api_key = 'special-key'
    When method get
    Then match [200,404] contains responseStatus

  Scenario: Schema validation — [GET] /pet/findByStatus?status=sold → array of Pet
    Given path 'pet', 'findByStatus'
    And param status = 'sold'
    When method get
    Then status 200
    And match response == '#[] #object'
    And match each response == petSchema

  Scenario: Schema validation — [POST] /store/order → Order
    * def orderId = 2100
    Given path 'store', 'order'
    And request { id: 2100, petId: 1101, quantity: 1, shipDate: '2020-02-01T00:00:00.000Z', status: 'placed', complete: true }
    When method post
    Then status 200
    And match response == orderSchema

  Scenario: Schema validation — [GET] /store/order/{id} → Order
    * def orderId = '2101'
    Given path 'store', 'order'
    And request { id: 2101, petId: 1101, quantity: 2, shipDate: '2020-02-02T00:00:00.000Z', status: 'approved', complete: false }
    When method post
    Then status 200
    Given path 'store', 'order', orderId
    When method get
    Then status 200
    And match response == orderSchema

  Scenario: Error codes — invalid status for findByStatus should be 400
    Given path 'pet', 'findByStatus'
    And param status = 'x'
    When method get
    Then status 400
    * def t = karate.typeOf(response)
    * if (t == 'map') match response contains { message: '#string' }
    * else match response == '#string'

  Scenario: Error codes — invalid order id should be 400 / 404 on get
    Given path 'store', 'order', '0'
    When method get
    Then match [400,404] contains responseStatus

  Scenario: Error codes — invalid order id should be 400 / 404 on delete
    Given path 'store', 'order', '-1'
    When method delete
    Then match [400,404] contains responseStatus

  Scenario: Error codes — invalid login parameters should be 400
    Given path 'user', 'login'
    And param username = ''
    And param password = ''
    When method get
    Then status 400
    * def t = karate.typeOf(response)
    * if (t == 'map') match response contains { message: '#string' }
    * else match response == '#string'
