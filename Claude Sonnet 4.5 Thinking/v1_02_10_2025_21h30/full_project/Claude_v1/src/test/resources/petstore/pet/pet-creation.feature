Feature: Pet Creation

Background:
  * url baseUrl

Scenario: Successfully add a new pet with all required fields
  Given path 'pet'
  And request { id: '#(~~(Math.random() * 1000000))', name: 'Buddy', photoUrls: ['http://example.com/photo.jpg'], status: 'available' }
  When method post
  Then status 200
  And match response.name == 'Buddy'
  And match response.status == 'available'
  And match response.id == '#notnull'

Scenario: Attempt to add a pet with missing required fields
  Given path 'pet'
  And request { id: 100 }
  When method post
  Then status 405

Scenario: Attempt to add a pet with invalid input
  Given path 'pet'
  And request { id: 'invalid', name: null }
  When method post
  Then status 405

Scenario: Create pet with all fields including category and tags
  Given path 'pet'
  And request { id: '#(~~(Math.random() * 1000000))', name: 'MaxPet', category: { id: 1, name: 'Dogs' }, photoUrls: ['http://example.com/max.jpg'], tags: [{ id: 1, name: 'friendly' }, { id: 2, name: 'trained' }], status: 'available' }
  When method post
  Then status 200
  And match response.name == 'MaxPet'
  And match response.category.name == 'Dogs'
  And match response.tags[*].name contains 'friendly'
  And match response.status == 'available'
