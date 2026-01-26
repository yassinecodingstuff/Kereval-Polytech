package com.example.karate;

import com.intuit.karate.junit5.Karate;

/**
 * Tests pour l'endpoint: /user, /user/createWithArray, /user/createWithList,
 *                        /user/login, /user/logout, /user/{username}
 * Méthodes testées: GET, POST, PUT, DELETE
 * Codes retour couverts: 2xx, 200, 400, 404
 */
public class UserTest {

  @Karate.Test
  Karate testUserDomain() {
    return Karate.run("classpath:features/user");
  }
}
