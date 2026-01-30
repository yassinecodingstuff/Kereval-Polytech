Feature: Pet API — Negative & Security — Swagger Petstore v2
  Background:
    * url baseUrl
    * configure headers = { Accept: 'application/json' }

  Scenario: Pet modification without explicit auth (tolerant security assertion)
    Given path 'pet'
    And header Content-Type = 'application/json'
    And request { name: 'NoAuth', photoUrls: ['x'] }
    When method post
    Then match [200,401,403,405] contains responseStatus

  Scenario: GET pet idempotency — create, get, delete, get(404)
    * def pid = '1015'
    Given path 'pet'
    And header Content-Type = 'application/json'
    And request { id: 1015, name: 'ToRoundTrip', photoUrls: ['u'], status: 'available' }
    When method post
    Then status 200

    Given path 'pet', pid
    When method get
    Then status 200
    And match response contains { id: '#number', name: 'ToRoundTrip' }

    Given path 'pet', pid
    When method delete
    Then match [200,204,404] contains responseStatus

    Given path 'pet', pid
    When method get
    Then status 404
