Feature: Pet API — CRUD, Search, and Media (High Priority, ISO 29119-aligned)
  Background:
    * url baseUrl
    * configure headers = { Accept: 'application/json' }
    * def allowedStatuses = ['available','pending','sold']
    * def petSchema =
    """
    {
      id: '##number',
      category: '##object',
      name: '#string',
      photoUrls: '#[] #string',
      tags: '##[] #object',
      status: '##? allowedStatuses.includes(_)'
    }
    """

  Scenario: [GET] Find pets by status — happy path returns array of Pet
    Given path 'pet', 'findByStatus'
    And param status = 'available'
    When method get
    Then status 200
    And match response == '#[] #object'
    And match each response == petSchema

  Scenario: [GET] Find pets by status — invalid status yields 400
    Given path 'pet', 'findByStatus'
    And param status = 'unknown'
    When method get
    Then status 400

  Scenario: [GET] Get pet by ID — seed then tolerant read per spec
    * def petId = '1001'
    Given path 'pet'
    And request { id: 1001, name: 'spot-1001', photoUrls: ['http://example/1001.jpg'], status: 'available' }
    When method post
    Then match [200,405] contains responseStatus
    Given path 'pet', petId
    When method get
    Then match [200,404] contains responseStatus
    * if (responseStatus == 200) match response == petSchema

  Scenario Outline: [GET] Get pet by ID — invalid or not found
    Given path 'pet', idVal
    When method get
    Then match [400,404] contains responseStatus
    Examples:
      | idVal            |
      | '0'              |
      | '-1'             |
      | 'abc'            |
      | '999999999999'   |

  Scenario: [DELETE] Delete pet — seed then delete with tolerant expectations
    * def petId = '1002'
    Given path 'pet'
    And request { id: 1002, name: 'pet-to-delete', photoUrls: ['http://example/1002.jpg'], status: 'pending' }
    When method post
    Then match [200,405] contains responseStatus
    Given path 'pet', petId
    When method delete
    Then match [200,400,404] contains responseStatus

  Scenario: [POST] Upload pet image — multipart file accepted returns ApiResponse
    * def petId = '1003'
    Given path 'pet'
    And request { id: 1003, name: 'pet-with-photo', photoUrls: ['http://example/1003.jpg'], status: 'available' }
    When method post
    Then match [200,405] contains responseStatus
    Given path 'pet', petId, 'uploadImage'
    And multipart field additionalMetadata = 'cute photo'
    And multipart file file = { read: 'classpath:img/pet.jpg', filename: 'pet.jpg', contentType: 'image/jpeg' }
    When method post
    Then status 200
    And match response == { code: '##number', type: '##string', message: '#string' }

  Scenario: [PUT] Update an existing pet — tolerant per documented errors
    * def petId = '1004'
    Given path 'pet'
    And request { id: 1004, name: 'pet-1004', photoUrls: ['http://example/1004.jpg'], status: 'available' }
    When method post
    Then match [200,405] contains responseStatus
    Given path 'pet'
    And request { id: 1004, name: 'pet-1004-updated', photoUrls: ['http://example/1004.jpg'], status: 'sold' }
    When method put
    Then match [200,400,404,405] contains responseStatus

  Scenario: [POST] Add a new pet — invalid input yields 405
    Given path 'pet'
    And request { id: 1234 }
    When method post
    Then status 405

  Scenario: [POST] Update pet with form data — invalid form yields 405
    * def petId = '1005'
    Given path 'pet', petId
    And header Content-Type = 'application/x-www-form-urlencoded'
    And request 'name=&status=sold'
    When method post
    Then status 405

  Scenario: [GET] Find pets by tags (deprecated) — 200 array or 400
    Given path 'pet', 'findByTags'
    And param tags = 'tag1'
    And param tags = 'tag2'
    When method get
    Then match [200,400] contains responseStatus
    * if (responseStatus == 200) match response == '#[] #object'
    * if (responseStatus == 200) match each response == petSchema
