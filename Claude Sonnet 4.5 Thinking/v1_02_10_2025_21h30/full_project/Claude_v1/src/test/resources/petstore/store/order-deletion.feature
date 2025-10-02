Feature: Order Deletion

Background:
  * url baseUrl
  * def orderId = ~~(Math.random() * 10) + 1

Scenario: Successfully delete an existing order
  Given path 'store', 'order'
  And request { id: '#(orderId)', petId: 300, quantity: 1, status: 'placed', complete: false }
  When method post
  Then status 200
  
  Given path 'store', 'order', orderId
  When method delete
  Then status 200
  
  Given path 'store', 'order', orderId
  When method get
  Then status 404

Scenario: Attempt to delete an order with ID outside valid range
  Given path 'store', 'order', 0
  When method delete
  Then status 400
