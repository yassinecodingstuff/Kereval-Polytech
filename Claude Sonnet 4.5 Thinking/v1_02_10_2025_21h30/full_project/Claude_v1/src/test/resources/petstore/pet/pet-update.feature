Feature: Pet Update

Background:
  * url baseUrl
  * def petId = ~~(Math.random() * 1000000)
  * def initialPet = { id: '#(petId)', name: 'InitialName', photoUrls: ['http://example.com/initial.jpg'], status: 'available' }

Scenario: Successfully update an existing pet's information
  Given path 'pet'
  And request initialPet
  When method post
  Then status 200
  
  Given path 'pet'
  And request { id: '#(petId)', name: 'UpdatedName', photoUrls: ['http://example.com/updated.jpg'], status: 'sold' }
  When method put
  Then status 200
  And match response.name == 'UpdatedName'
  And match response.status == 'sold'

Scenario: Attempt to update a pet with invalid ID
  Given path 'pet'
  And request { id: 'invalidId', name: 'TestName', photoUrls: ['http://example.com/test.jpg'] }
  When method put
  Then status 400

Scenario: Attempt to update a pet that does not exist
  Given path 'pet'
  And request { id: 999999, name: 'NonExistent', photoUrls: ['http://example.com/none.jpg'], status: 'available' }
  When method put
  Then status 404

Scenario: Update pet with form data
  * def formPetId = ~~(Math.random() * 1000000)
  
  Given path 'pet'
  And request { id: '#(formPetId)', name: 'OriginalFormName', photoUrls: ['http://example.com/original.jpg'], status: 'available' }
  When method post
  Then status 200
  
  Given path 'pet', formPetId
  And form field name = 'UpdatedFormName'
  And form field status = 'sold'
  When method post
  Then status 200
