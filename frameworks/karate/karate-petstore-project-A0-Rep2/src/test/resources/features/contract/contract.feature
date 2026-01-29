Feature: Cross-Cutting — Contract and Negotiation

Background:
  * url baseUrl
  * configure headers = { Accept: 'application/json' }

@contract @high
Scenario: Pet, Order and User models match Swagger enums and formats
  Given url 'https://petstore.swagger.io/v2/swagger.json'
  When method get
  Then status 200
  * def swagger = response
  * def petReq = swagger.definitions.Pet.required
  * match petReq contains ['name','photoUrls']
  * def petStatusEnum = swagger.definitions.Pet.properties.status.enum
  * match petStatusEnum == ['available','pending','sold']
  * match swagger.definitions.Pet.properties.id.type == 'integer'
  * match swagger.definitions.Pet.properties.id.format == 'int64'
  * def orderStatusEnum = swagger.definitions.Order.properties.status.enum
  * match orderStatusEnum == ['placed','approved','delivered']
  * match swagger.definitions.Order.properties.id.type == 'integer'
  * match swagger.definitions.Order.properties.id.format == 'int64'
  * match swagger.definitions.Order.properties.petId.type == 'integer'
  * match swagger.definitions.Order.properties.petId.format == 'int64'
  * match swagger.definitions.Order.properties.complete.type == 'boolean'
  * match swagger.definitions.Order.properties.shipDate.format == 'date-time'

@regression @medium
Scenario: JSON content negotiation is supported
  Given path 'pet', 'findByStatus'
  And param status = 'available'
  When method get
  Then status 200
  And match response == '#[]'
