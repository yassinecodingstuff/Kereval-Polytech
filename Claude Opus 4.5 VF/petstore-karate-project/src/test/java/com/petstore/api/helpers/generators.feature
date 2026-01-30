@ignore
Feature: Test Data Generators
  Reusable data generators for test automation

  @ignore @generatePetId
  Scenario: generatePetId
    * def result = Math.floor(Math.random() * 900000) + 100000

  @ignore @generateUsername
  Scenario: generateUsername
    * def result = 'testuser_' + Math.floor(Math.random() * 1000000)

  @ignore @generateEmail
  Scenario: generateEmail
    * def prefix = __arg.prefix || 'test'
    * def result = prefix + '_' + Math.floor(Math.random() * 100000) + '@test.com'

  @ignore @generateOrderId
  Scenario: generateOrderId
    * def result = Math.floor(Math.random() * 9) + 1

  @ignore @generateUUID
  Scenario: generateUUID
    * def result = java.util.UUID.randomUUID().toString()

  @ignore @generateTimestamp
  Scenario: generateTimestamp
    * def result = new Date().toISOString()

  @ignore @generateRandomString
  Scenario: generateRandomString
    * def length = __arg.length || 10
    * def chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789'
    * def result = ''
    * eval for(var i = 0; i < length; i++) result += chars.charAt(Math.floor(Math.random() * chars.length))

  @ignore @generatePhone
  Scenario: generatePhone
    * def result = '555-' + Math.floor(Math.random() * 9000 + 1000)

  @ignore @generatePetPayload
  Scenario: generatePetPayload
    * def petId = __arg.petId || Math.floor(Math.random() * 900000) + 100000
    * def name = __arg.name || 'GeneratedPet_' + petId
    * def status = __arg.status || 'available'
    * def result =
      """
      {
        "id": #(petId),
        "name": "#(name)",
        "category": { "id": 1, "name": "Dogs" },
        "photoUrls": ["https://example.com/generated.jpg"],
        "tags": [{ "id": 1, "name": "generated" }],
        "status": "#(status)"
      }
      """

  @ignore @generateOrderPayload
  Scenario: generateOrderPayload
    * def petId = __arg.petId || Math.floor(Math.random() * 900000) + 100000
    * def quantity = __arg.quantity || 1
    * def status = __arg.status || 'placed'
    * def shipDate = new Date().toISOString()
    * def result =
      """
      {
        "petId": #(petId),
        "quantity": #(quantity),
        "shipDate": "#(shipDate)",
        "status": "#(status)",
        "complete": false
      }
      """

  @ignore @generateUserPayload
  Scenario: generateUserPayload
    * def username = __arg.username || 'testuser_' + Math.floor(Math.random() * 1000000)
    * def email = __arg.email || username + '@test.com'
    * def result =
      """
      {
        "username": "#(username)",
        "firstName": "Generated",
        "lastName": "User",
        "email": "#(email)",
        "password": "GeneratedPass123!",
        "phone": "555-1234",
        "userStatus": 1
      }
      """
