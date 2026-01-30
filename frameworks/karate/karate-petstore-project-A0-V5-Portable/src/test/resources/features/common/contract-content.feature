Feature: Common — Contract & Content Negotiation Checks — Swagger Petstore v2
  Background:
    * url baseUrl
    * configure headers = { Accept: 'application/json' }

  Scenario: Fetch OpenAPI (Swagger v2) document and basic structure
    Given path 'swagger.json'
    When method get
    Then status 200
    And match response.swagger == '2.0'
    And match response.basePath == '/v2'
    And match response.host contains 'petstore.swagger.io'
    And match response.paths == '#object'
    And match response.definitions == '#object'

  Scenario: Contract — Pet.status enum values
    Given path 'swagger.json'
    When method get
    Then status 200
    * def petStatus = response.definitions.Pet.properties.status.enum
    * match petStatus contains ['available','pending','sold']

  Scenario: Contract — Order.status enum values
    Given path 'swagger.json'
    When method get
    Then status 200
    * def orderStatus = response.definitions.Order.properties.status.enum
    * match orderStatus contains ['placed','approved','delivered']

  Scenario: Content negotiation — create Pet with JSON returns JSON
    * def pid = '1301'
    Given path 'pet'
    And header Content-Type = 'application/json'
    And header Accept = 'application/json'
    And request { "id": 1301, "name": "ContractJSON", "photoUrls": ["u"] }
    When method post
    Then status 200
    * match responseHeaders['Content-Type'][0] contains 'application/json'
    And match response contains { id: '#number', name: 'ContractJSON', photoUrls: '##[] #string' }

  Scenario: Content negotiation — create Pet with XML returns XML
    * def pid = '1302'
    Given path 'pet'
    And header Content-Type = 'application/xml'
    And header Accept = 'application/xml'
    And request <Pet><id>1302</id><name>ContractXML</name><photoUrls><photoUrls>u</photoUrls></photoUrls><status>available</status></Pet>
    When method post
    Then status 200
    * match responseHeaders['Content-Type'][0] contains 'xml'
