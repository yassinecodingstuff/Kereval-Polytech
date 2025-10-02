Feature: Pet Retrieval by ID

Background:
  * url baseUrl
  * def petId = ~~(Math.random() * 1000000)
  * def testPet = { id: '#(petId)', name: 'TestPet', photoUrls: ['http://example.com/photo.jpg'], status: 'available' }

Scenario: Successfully retrieve a pet by its ID
  Given path 'pet'
  And request testPet
  When method post
  Then status 200
  
  Given path 'pet', petId
  When method get
  Then status 200
  And match response.id == petId
  And match response.name == '#notnull'
  And match response.photoUrls == '#[]'
  And match response.status == '#notnull'

Scenario: Attempt to retrieve a pet that does not exist
  Given path 'pet', 888888
  When method get
  Then status 404

Scenario: Retrieve pet and verify all fields are present
  * def fullPetId = ~~(Math.random() * 1000000)
  * def fullPet = { id: '#(fullPetId)', name: 'FullPet', category: { id: 1, name: 'Cats' }, photoUrls: ['http://example.com/full.jpg'], tags: [{ id: 1, name: 'tag1' }], status: 'available' }
  
  Given path 'pet'
  And request fullPet
  When method post
  Then status 200
  
  Given path 'pet', fullPetId
  When method get
  Then status 200
  And match response == { id: '#(fullPetId)', name: 'FullPet', category: '#object', photoUrls: '#[]', tags: '#[]', status: 'available' }

Scenario: Verify proper error response format for invalid pet ID
  Given path 'pet', 'invalidId'
  When method get
  Then status 404
  And match response == '#object'
