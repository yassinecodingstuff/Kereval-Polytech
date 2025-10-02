Feature: Pet Search Operations

Background:
  * url baseUrl

Scenario: Retrieve all pets with available status
  Given path 'pet', 'findByStatus'
  And param status = 'available'
  When method get
  Then status 200
  And match response == '#[]'
  And match each response[*].status == 'available'

Scenario: Retrieve pets with multiple status values
  Given path 'pet', 'findByStatus'
  And param status = 'available', 'pending', 'sold'
  When method get
  Then status 200
  And match response == '#[]'
  And match each response[*].status == '#regex (available|pending|sold)'

Scenario: Attempt to find pets with invalid status value
  Given path 'pet', 'findByStatus'
  And param status = 'invalidStatus'
  When method get
  Then status 400

Scenario: Retrieve pets filtered by specific tags
  Given path 'pet', 'findByTags'
  And param tags = 'tag1', 'tag2'
  When method get
  Then status 200
  And match response == '#[]'

Scenario: Find pets by status and verify response structure
  Given path 'pet', 'findByStatus'
  And param status = 'available'
  When method get
  Then status 200
  And match response == '#[]'
  And match each response == { id: '#number', name: '#string', photoUrls: '#[]', status: '#string' }
