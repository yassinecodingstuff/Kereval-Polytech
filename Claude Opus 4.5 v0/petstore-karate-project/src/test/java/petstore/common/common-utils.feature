@ignore
Feature: Common Utilities and Reusable Functions
  Shared utility functions for Petstore API testing
  ISO/IEC/IEEE 29119-5 Keyword-Driven Testing Support

  Background:
    * def config = karate.callSingle('classpath:karate-config.js')

  @ignore @utility
  Scenario: Generate unique ID
    * def generateUniqueId =
      """
      function() {
        return Math.floor(Math.random() * 900000000) + 100000000;
      }
      """

  @ignore @utility
  Scenario: Generate unique username
    * def generateUniqueUsername =
      """
      function(prefix) {
        return prefix + '_' + Math.floor(Math.random() * 100000) + '_' + Date.now();
      }
      """

  @ignore @utility
  Scenario: Generate string of specified length
    * def generateStringOfLength =
      """
      function(length) {
        var result = '';
        var characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
        for (var i = 0; i < length; i++) {
          result += characters.charAt(Math.floor(Math.random() * characters.length));
        }
        return result;
      }
      """

  @ignore @utility
  Scenario: Generate random email
    * def generateRandomEmail =
      """
      function(prefix) {
        return prefix + '_' + Date.now() + '@test.com';
      }
      """

  @ignore @utility
  Scenario: Get current timestamp
    * def getCurrentTimestamp =
      """
      function() {
        return new Date().toISOString();
      }
      """

  @ignore @utility
  Scenario: Get future timestamp
    * def getFutureTimestamp =
      """
      function(daysAhead) {
        var date = new Date();
        date.setDate(date.getDate() + daysAhead);
        return date.toISOString();
      }
      """

  @ignore @utility
  Scenario: Validate response time
    * def validateResponseTime =
      """
      function(responseTime, maxTime) {
        return responseTime < maxTime;
      }
      """

  @ignore @utility
  Scenario: Create pet payload
    * def createPetPayload =
      """
      function(id, name, status, photoUrls, category, tags) {
        var pet = {
          name: name || 'TestPet',
          photoUrls: photoUrls || ['https://example.com/pet.jpg']
        };
        if (id) pet.id = id;
        if (status) pet.status = status;
        if (category) pet.category = category;
        if (tags) pet.tags = tags;
        return pet;
      }
      """

  @ignore @utility
  Scenario: Create order payload
    * def createOrderPayload =
      """
      function(id, petId, quantity, status, complete, shipDate) {
        var order = {
          petId: petId || 1,
          quantity: quantity || 1,
          status: status || 'placed',
          complete: complete || false
        };
        if (id) order.id = id;
        if (shipDate) order.shipDate = shipDate;
        return order;
      }
      """

  @ignore @utility
  Scenario: Create user payload
    * def createUserPayload =
      """
      function(username, firstName, lastName, email, password, phone, userStatus) {
        var id = Math.floor(Math.random() * 900000000) + 100000000;
        var user = username || ('user_' + Math.floor(Math.random() * 100000) + '_' + Date.now());
        return {
          id: id,
          username: user,
          firstName: firstName || 'Test',
          lastName: lastName || 'User',
          email: email || (user + '@test.com'),
          password: password || 'Password123',
          phone: phone || '1234567890',
          userStatus: userStatus || 1
        };
      }
      """

  @ignore @utility
  Scenario: Check if array contains item by property
    * def arrayContainsItemByProperty =
      """
      function(array, property, value) {
        for (var i = 0; i < array.length; i++) {
          if (array[i][property] == value) return true;
        }
        return false;
      }
      """

  @ignore @utility
  Scenario: Filter array by property value
    * def filterArrayByProperty =
      """
      function(array, property, value) {
        var result = [];
        for (var i = 0; i < array.length; i++) {
          if (array[i][property] == value) result.push(array[i]);
        }
        return result;
      }
      """

  @ignore @utility
  Scenario: Wait function
    * def sleep =
      """
      function(millis) {
        java.lang.Thread.sleep(millis);
      }
      """

  @ignore @utility
  Scenario: UUID generator
    * def uuid =
      """
      function() {
        return java.util.UUID.randomUUID().toString();
      }
      """
