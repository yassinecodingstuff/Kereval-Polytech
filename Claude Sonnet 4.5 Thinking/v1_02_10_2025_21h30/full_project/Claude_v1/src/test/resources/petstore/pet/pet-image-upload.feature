Feature: Pet Image Upload

Background:
  * url baseUrl
  * def petId = ~~(Math.random() * 1000000)

Scenario: Successfully upload an image for a pet
  Given path 'pet'
  And request { id: '#(petId)', name: 'PhotoPet', photoUrls: ['http://example.com/photo.jpg'], status: 'available' }
  When method post
  Then status 200
  
  Given path 'pet', petId, 'uploadImage'
  And multipart field additionalMetadata = 'Test image upload'
  When method post
  Then status 200
  And match response.message == '#notnull'

Scenario: Upload image with metadata
  * def imagePetId = ~~(Math.random() * 1000000)
  
  Given path 'pet'
  And request { id: '#(imagePetId)', name: 'MetadataPet', photoUrls: ['http://example.com/metadata.jpg'], status: 'available' }
  When method post
  Then status 200
  
  Given path 'pet', imagePetId, 'uploadImage'
  And multipart field additionalMetadata = 'Profile picture for pet'
  When method post
  Then status 200
  And match response.code == 200
  And match response.type == 'unknown'
