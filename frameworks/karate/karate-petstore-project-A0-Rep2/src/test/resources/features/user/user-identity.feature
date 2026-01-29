Feature: User API — Identity and Session (Access and Data Integrity Risk)

Background:
  * url baseUrl
  * configure headers = { Accept: 'application/json' }
  * def UserSchema =
    """
    {
      id: '##number',
      username: '#string',
      firstName: '##string',
      lastName: '##string',
      email: '##string',
      password: '##string',
      phone: '##string',
      userStatus: '##number'
    }
    """

@smoke @high
Scenario: Create user and retrieve by username
  * def username = 'alice_' + java.util.UUID.randomUUID()
  Given path 'user'
  And request
    """
    {
      "id": 8001,
      "username": "#(username)",
      "firstName": "Ali",
      "lastName": "Ce",
      "email": "alice@example.com",
      "password": "s3cr3t",
      "phone": "123-456-7",
      "userStatus": 1
    }
    """
  When method post
  Then status 200
  Given path 'user', username
  When method get
  Then status 200
  And match response == UserSchema
  And match response.username == username

@regression @medium
Scenario: Create multiple users with an array
  Given path 'user', 'createWithArray'
  And request
    """
    [
      { "id": 8101, "username":"u1","firstName":"F1","lastName":"L1","email":"u1@x.com","password":"p1","phone":"1","userStatus":0 },
      { "id": 8102, "username":"u2","firstName":"F2","lastName":"L2","email":"u2@x.com","password":"p2","phone":"2","userStatus":1 }
    ]
    """
  When method post
  Then status 200

@regression @medium
Scenario: Create multiple users with a list
  Given path 'user', 'createWithList'
  And request
    """
    [
      { "id": 8201, "username":"l1","firstName":"F1","lastName":"L1","email":"l1@x.com","password":"p1","phone":"1","userStatus":0 },
      { "id": 8202, "username":"l2","firstName":"F2","lastName":"L2","email":"l2@x.com","password":"p2","phone":"2","userStatus":1 }
    ]
    """
  When method post
  Then status 200

@smoke @high
Scenario: Login with valid credentials returns session info
  * def username = 'login_' + java.util.UUID.randomUUID()
  * def password = 's3cr3t'
  Given path 'user'
  And request { "id": 8300, "username": "#(username)", "firstName":"F", "lastName":"L", "email":"e@x.com", "password":"#(password)", "phone":"1", "userStatus":0 }
  When method post
  Then status 200
  Given path 'user', 'login'
  And param username = username
  And param password = password
  When method get
  Then status 200
  And match response contains 'logged in user session'

@regression @high
Scenario: Logout clears session
  Given path 'user', 'logout'
  When method get
  Then status 200

@regression @high
Scenario: Update user profile and verify changes
  * def username = 'alice_' + java.util.UUID.randomUUID()
  Given path 'user'
  And request { "id": 8001, "username": "#(username)", "firstName":"Ali","lastName":"Ce","email":"alice@example.com","password":"s3cr3t","phone":"123-456-7","userStatus":1 }
  When method post
  Then status 200
  Given path 'user', username
  And request
    """
    {
      "id": 8001,
      "username": "#(username)",
      "firstName": "Alicia",
      "lastName": "Cee",
      "email": "alicia@example.com",
      "password": "s3cr3t",
      "phone": "999-9999",
      "userStatus": 2
    }
    """
  When method put
  Then status 200
  Given path 'user', username
  When method get
  Then status 200
  And match response.firstName == 'Alicia'
  And match response.lastName == 'Cee'
  And match response.email == 'alicia@example.com'
  And match response.phone == '999-9999'

@regression @medium @negative
Scenario Outline: Get or delete user returns error for unknown username
  Given path 'user', <username>
  When method get
  Then status 404
  Given path 'user', <username>
  When method delete
  Then status 404
Examples:
  | username   |
  | no_such    |
  | deletedGuy |

@regression @medium
Scenario: Delete an existing user
  * def username = 'to_delete_' + java.util.UUID.randomUUID()
  Given path 'user'
  And request { "id": 8401, "username": "#(username)", "firstName":"F","lastName":"L","email":"e@x.com","password":"p","phone":"1","userStatus":0 }
  When method post
  Then status 200
  Given path 'user', username
  When method delete
  Then match responseStatus in [200,204]
  Given path 'user', username
  When method get
  Then status 404
