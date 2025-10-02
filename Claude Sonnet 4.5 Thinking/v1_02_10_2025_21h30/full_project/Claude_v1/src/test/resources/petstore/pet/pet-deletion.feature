Feature: Pet Deletion

Background:
  * url baseUrl
  * def petId = ~~(Math.random() * 1000000)

Scenario: Successfully delete an existing pet
  Given path 'pet'
  And request { id: '#(petId)', name: 'DeleteMe', photoUrls: ['http://example.com/delete.jpg'], status: 'available' }
  When method post
  Then status 200
  
  Given path 'pet', petId
  When method delete
  Then status 200
  
  Given path 'pet', petId
  When method get
  Then status 404

Scenario: Attempt to delete a pet that does not exist
  Given path 'pet', 777777
  When method delete
  Then status 404

Scenario: Delete pet and verify cascading effects
  * def deletePetId = ~~(Math.random() * 1000000)
  
  Given path 'pet'
  And request { id: '#(deletePetId)', name: 'CascadeDelete', photoUrls: ['http://example.com/cascade.jpg'], status: 'available' }
  When method post
  Then status 200
  
  Given path 'pet', deletePetId
  When method delete
  Then status 200
  
  Given path 'pet', 'findByStatus'
  And param status = 'available'
  When method get
  Then status 200
  And match response[*].id !contains deletePetId
