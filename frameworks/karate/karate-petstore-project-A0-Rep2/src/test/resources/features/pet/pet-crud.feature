Feature: Pets API — High-Risk CRUD and Retrieval

Background:
  * url baseUrl
  * configure headers = { Accept: 'application/json' }
  * def allowedStatuses = ['available','pending','sold']
  * def PetSchema =
    """
    {
      id: '##number',
      category: '##object',
      name: '#string',
      photoUrls: '#[]',
      tags: '##[]',
      status: '##? allowedStatuses.includes(_)'
    }
    """

@smoke @high
Scenario Outline: Create Pet with required fields and retrieve by ID
  Given path 'pet'
  And request
    """
    {
      id: <id>,
      name: "<name>",
      photoUrls: ["<photo1>", "<photo2>"],
      status: "<status>"
    }
    """
  When method post
  Then status 200
  And match response == PetSchema
  And match response.id == <id>
  And match response.name == "<name>"
  And match response.status == "<status>"
  Given path 'pet', <id>
  When method get
  Then status 200
  And match response == PetSchema
  And match response.id == <id>
Examples:
  | id   | name       | photo1            | photo2             | status    |
  | 1001 | golden boy | http://img/pet1   | http://img/pet1-b  | available |
  | 1002 | snow kitty | http://img/pet2   | http://img/pet2-b  | pending   |
  | 1003 | speedy     | http://img/pet3   | http://img/pet3-b  | sold      |

@regression @high @negative
Scenario Outline: Pet creation with weak payloads (implementation-tolerant)
  Given path 'pet'
  And header Content-Type = 'application/json'
  And request <payload>
  When method post
  Then match [200,400,405] contains responseStatus
Examples:
  | payload                                                                                                   |
  | { "id": 2001, "photoUrls": ["http://img/pet"], "status": "available" }                                    |
  | { "id": 2002, "name": "nameless", "status": "available" }                                                 |
  | { "id": 2003, "name": "badstatus", "photoUrls": ["u"], "status": "unknown" }                              |
  | { "id": 2004, "name": 123, "photoUrls": ["u"] }                                                            |
  | { "id": "abc", "name": "wrongid", "photoUrls": ["u"] }                                                     |

@smoke @high
Scenario Outline: Update Pet via PUT and verify persisted changes
  Given path 'pet'
  And request { id: <id>, name: "<name>", photoUrls: ["<photo1>"], status: "available" }
  When method post
  Then match responseStatus in [200,201]
  And match response.id == <id>
  Given path 'pet'
  And request
    """
    {
      "id": <id>,
      "name": "<newName>",
      "photoUrls": ["<photo1>"],
      "status": "<newStatus>"
    }
    """
  When method put
  Then status 200
  And match response.name == "<newName>"
  And match response.status == "<newStatus>"
  Given path 'pet', <id>
  When method get
  Then status 200
  And match response.name == "<newName>"
  And match response.status == "<newStatus>"
Examples:
  | id   | name      | photo1          | newName    | newStatus |
  | 3001 | shadow    | http://img/s1   | shadow-2   | sold      |
  | 3002 | marmalade | http://img/m1   | marmalade! | available |

@regression @high @negative
Scenario Outline: Update Pet via PUT with invalid identifiers or payloads
  Given path 'pet'
  And request
    """
    {
      "id": <id>,
      "name": "<name>",
      "photoUrls": ["<photo1>"],
      "status": "<status>"
    }
    """
  When method put
  Then match responseStatus in [400,404,405]
Examples:
  | id     | name  | photo1        | status    |
  | -1     | bad   | http://img/x  | sold      |
  | 0      | zero  | http://img/x  | pending   |
  | 999999 | miss  | http://img/x  | available |
  | 4004   |       | http://img/x  | available |

@regression @high
Scenario Outline: Update Pet using form data
  Given path 'pet'
  And request { id: <id>, name: "seed", photoUrls: ["http://img/seed"], status: "available" }
  When method post
  Then match responseStatus in [200,201]
  Given path 'pet', <id>
  And header Content-Type = 'application/x-www-form-urlencoded'
  And form field name = <newName>
  And form field status = <newStatus>
  When method post
  Then status 200
  Given path 'pet', <id>
  When method get
  Then status 200
  And if (<newName> != '') karate.match(response.name, <newName>)
  And if (<newStatus> != '') karate.match(response.status, <newStatus>)
Examples:
  | id   | newName | newStatus |
  | 5001 | formy   | pending   |
  | 5002 |         | sold      |

@regression @medium
Scenario Outline: Upload Pet image with multipart form data
  Given path 'pet'
  And request { id: <id>, name: "seed", photoUrls: ["http://img/seed"] }
  When method post
  Then match responseStatus in [200,201]
  Given path 'pet', <id>, 'uploadImage'
  And header Content-Type = 'multipart/form-data'
  And multipart file file = { read: '<filePath>' }
  And multipart field additionalMetadata = '<metadata>'
  When method post
  Then status 200
  And if ('<metadata>' != '') match response.message contains '<metadata>'
Examples:
  | id   | filePath               | metadata |
  | 6001 | classpath:img/cat.png  | cute cat |
  | 6002 | classpath:img/dog.jpg  |         |

@smoke @high
Scenario Outline: Find Pets by status returns only allowed enum values
  Given path 'pet', 'findByStatus'
  And param status = <statuses>
  When method get
  Then status 200
  And match response == '#[]'
  And match each response == PetSchema
  And match each response[*].status contains only allowedStatuses
Examples:
  | statuses               |
  | available              |
  | pending                |
  | sold                   |
  | available,pending,sold |

@regression @medium
Scenario: Find Pets by status with unknown mixed enum
  Given path 'pet', 'findByStatus'
  And param status = 'available,unknown'
  When method get
  Then match responseStatus in [200,400]
  And if (responseStatus == 200) match each response[*].status contains only allowedStatuses

@regression @medium
Scenario Outline: Find Pets by tags returns results (if any)
  Given path 'pet', 'findByTags'
  And param tags = <tags>
  When method get
  Then status 200
  And match response == '#[]'
  And match each response == PetSchema
Examples:
  | tags        |
  | cats        |
  | dogs,fluffy |

@smoke @high
Scenario Outline: Get Pet by ID
  Given path 'pet'
  And request { id: <id>, name: 'gettable', photoUrls: ['http://img/p'] }
  When method post
  Then match responseStatus in [200,201]
  And header api_key = "<apiKey>"
  Given path 'pet', <id>
  When method get
  Then status 200
  And match response == PetSchema
Examples:
  | id   | apiKey      |
  | 1001 |             |
  | 1002 | special-key |

@regression @high @negative
Scenario Outline: Get Pet by ID returns error for not found or invalid ID
  Given path 'pet', <id>
  When method get
  Then match responseStatus in [400,404]
Examples:
  | id     |
  | -5     |
  | 0      |
  | 999999 |

@regression @medium
Scenario: Accept XML gracefully (server may support XML)
  Given header Accept = 'application/xml'
  And path 'pet', 'findByStatus'
  And param status = 'available'
  When method get
  Then match responseStatus in [200,406]
