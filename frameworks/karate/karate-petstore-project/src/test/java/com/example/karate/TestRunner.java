package com.example.karate;

import com.intuit.karate.junit5.Karate;

/**
 * Tests globaux:
 * Tests pour l'endpoint: /pet, /pet/findByStatus, /pet/findByTags, /pet/{petId}, /pet/{petId}/uploadImage,
 *                        /store/inventory, /store/order, /store/order/{orderId},
 *                        /user, /user/createWithArray, /user/createWithList,
 *                        /user/login, /user/logout, /user/{username}
 * Méthodes testées: GET, POST, PUT, DELETE
 * Codes retour couverts: 2xx, 200, 400, 404, 405
 */
public class TestRunner {

  @Karate.Test
  Karate runAll() {
    return Karate.run("classpath:features");
  }
}
