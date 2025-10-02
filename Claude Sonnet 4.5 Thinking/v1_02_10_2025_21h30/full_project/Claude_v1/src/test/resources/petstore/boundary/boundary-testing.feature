Feature: Boundary Testing

Background:
  * url baseUrl

Scenario: Place and retrieve order with minimum valid ID
  Given path 'store', 'order'
  And request { id: 1, petId: 100, quantity: 1, status: 'placed', complete: false }
  When method post
  Then status 200
  
  Given path 'store', 'order', 1
  When method get
  Then status 200
  And match response.id == 1

Scenario: Create pets with all valid status enum values
  * def statuses = ['available', 'pending', 'sold']
  * def petId = ~~(Math.random() * 1000000)
  
  Given path 'pet'
  And request { id: '#(petId)', name: 'StatusPet', photoUrls: ['http://example.com/status.jpg'], status: 'available' }
  When method post
  Then status 200
  And match response.status == 'available'
