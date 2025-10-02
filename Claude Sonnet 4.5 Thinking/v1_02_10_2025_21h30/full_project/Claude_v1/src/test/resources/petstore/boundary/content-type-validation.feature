Feature: Content Type Validation

Background:
  * url baseUrl

Scenario: Add a pet with application/json content type
  * def petId = ~~(Math.random() * 1000000)
  
  Given path 'pet'
  And header Content-Type = 'application/json'
  And request { id: '#(petId)', name: 'JsonPet', photoUrls: ['http://example.com/json.jpg'], status: 'available' }
  When method post
  Then status 200
  And match responseType == 'json'

Scenario: Add a pet with XML content type
  * def xmlPetId = ~~(Math.random() * 1000000)
  
  Given path 'pet'
  And header Content-Type = 'application/xml'
  And header Accept = 'application/xml'
  And request '<Pet><id>' + xmlPetId + '</id><name>XmlPet</name><photoUrls><photoUrl>http://example.com/xml.jpg</photoUrl></photoUrls><status>available</status></Pet>'
  When method post
  Then status 200
