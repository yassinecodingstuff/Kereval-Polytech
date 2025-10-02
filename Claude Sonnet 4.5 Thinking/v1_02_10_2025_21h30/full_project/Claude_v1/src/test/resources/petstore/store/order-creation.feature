Feature: Order Creation

Background:
  * url baseUrl

Scenario: Successfully place an order for a pet
  Given path 'store', 'order'
  And request { id: '#(~~(Math.random() * 1000))', petId: 100, quantity: 1, shipDate: '#(new Date().toISOString())', status: 'placed', complete: true }
  When method post
  Then status 200
  And match response.id == '#notnull'
  And match response.status == 'placed'
  And match response.petId == 100
  And match response.quantity == 1

Scenario: Attempt to place an order with invalid data
  Given path 'store', 'order'
  And request { invalidField: 'invalid' }
  When method post
  Then status 400

Scenario: Place order with all fields and verify response
  * def orderId = ~~(Math.random() * 1000)
  
  Given path 'store', 'order'
  And request { id: '#(orderId)', petId: 500, quantity: 3, shipDate: '#(new Date().toISOString())', status: 'approved', complete: true }
  When method post
  Then status 200
  And match response == { id: '#notnull', petId: '#notnull', quantity: '#notnull', shipDate: '#notnull', status: '#notnull', complete: '#boolean' }
