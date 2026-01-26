Feature: PET - Recherche (/pet/findByStatus, /pet/findByTags)

Background:
  * url baseUrl
  * configure headers = { Accept: 'application/json', Content-Type: 'application/json' }
  * if (karate.get('apiKey')) header api_key = apiKey
  * if (karate.get('oauthToken')) header Authorization = 'Bearer ' + oauthToken

@happy
Scenario Outline: GET /pet/findByStatus - statut valide → 200
  * path 'pet', 'findByStatus'
  * param status = <status>
  * method get
  * status 200
  * match response == '#[]'
  * match each response contains { id: '#number', name: '#string' }

  Examples:
    | status    |
    | available |
    | pending   |
    | sold      |

@error
Scenario: GET /pet/findByStatus - 400 Invalid status value
  * path 'pet', 'findByStatus'
  * param status = 'unknown'
  * method get
  * status 400

@deprecated @happy
Scenario: GET /pet/findByTags - 200
  * path 'pet', 'findByTags'
  * param tags = ['cute','brown']
  * method get
  * status 200
  * match response == '#[]'

@deprecated @limit @error
Scenario: GET /pet/findByTags - 400 Invalid tag value (chaine vide)
  * path 'pet', 'findByTags'
  * param tags = ['']
  * method get
  * status 400
