Feature: STORE - Inventaire & Commandes

Background:
  * url baseUrl
  * configure headers = { Accept: 'application/json', Content-Type: 'application/json' }
  * if (karate.get('apiKey')) header api_key = apiKey
  * if (karate.get('oauthToken')) header Authorization = 'Bearer ' + oauthToken
  * def orderId = 11

@happy
Scenario: GET /store/inventory - 200
  * path 'store', 'inventory'
  * method get
  * status 200
  * match response == '#object'
  * match each response.* == '#number'

@happy
Scenario: POST /store/order - 200
  * def orderValid =
  """
  { "id": #(orderId), "petId": 1001, "quantity": 1, "status": "placed", "complete": true }
  """
  * path 'store', 'order'
  * request orderValid
  * method post
  * status 200
  * match response contains { id: #(orderId), status: '#string' }

@error
Scenario: POST /store/order - 400 Invalid Order
  * path 'store', 'order'
  * request { "id": 12, "quantity": -1 }
  * method post
  * status 400

@happy
Scenario: GET /store/order/{orderId} - 200 (1..10)
  * path 'store', 'order', 5
  * method get
  * status 200
  * match response contains { id: 5 }

@limit @error
Scenario: GET /store/order/{orderId} - 400 Invalid ID supplied
  * path 'store', 'order', 0
  * method get
  * status 400

@error
Scenario: GET /store/order/{orderId} - 404 Order not found
  * path 'store', 'order', 9999
  * method get
  * status 404

@limit @error
Scenario: DELETE /store/order/{orderId} - 400 Invalid ID supplied
  * path 'store', 'order', 0
  * method delete
  * status 400

@error
Scenario: DELETE /store/order/{orderId} - 404 Order not found
  * path 'store', 'order', 9999
  * method delete
  * status 404
