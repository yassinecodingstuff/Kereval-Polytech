Feature: Data Integrity Validation

Background:
  * url baseUrl

Scenario: Verify pet data integrity after create and retrieve
  * def petId = ~~(Math.random() * 1000000)
  * def petData = { id: '#(petId)', name: 'IntegrityPet', category: { id: 1, name: 'Dogs' }, photoUrls: ['http://example.com/integrity.jpg'], tags: [{ id: 1, name: 'tag1' }], status: 'available' }
  
  Given path 'pet'
  And request petData
  When method post
  Then status 200
  
  Given path 'pet', petId
  When method get
  Then status 200
  And match response.name == 'IntegrityPet'
  And match response.status == 'available'

Scenario: Verify order data integrity after create and retrieve
  * def orderId = ~~(Math.random() * 10) + 1
  * def orderData = { id: '#(orderId)', petId: 600, quantity: 5, shipDate: '#(new Date().toISOString())', status: 'delivered', complete: true }
  
  Given path 'store', 'order'
  And request orderData
  When method post
  Then status 200
  
  Given path 'store', 'order', orderId
  When method get
  Then status 200
  And match response.petId == 600
  And match response.quantity == 5
