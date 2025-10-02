Feature: Order Retrieval by ID

Background:
  * url baseUrl
  * def orderId = ~~(Math.random() * 10) + 1

Scenario: Successfully retrieve an order by its ID
  Given path 'store', 'order'
  And request { id: '#(orderId)', petId: 200, quantity: 2, status: 'placed', complete: false }
  When method post
  Then status 200
  
  Given path 'store', 'order', orderId
  When method get
  Then status 200
  And match response.id == orderId
  And match response.petId == '#notnull'
  And match response.quantity == '#notnull'
  And match response.status == '#notnull'

Scenario: Attempt to retrieve an order with invalid ID format
  Given path 'store', 'order', 'invalidId'
  When method get
  Then status 404

Scenario: Attempt to retrieve an order that does not exist
  Given path 'store', 'order', 99999
  When method get
  Then status 404
