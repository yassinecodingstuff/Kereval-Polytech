package com.example.karate;

import com.intuit.karate.junit5.Karate;

/**
 * Tests pour l'endpoint: /store/inventory, /store/order, /store/order/{orderId}
 * Méthodes testées: GET, POST, DELETE
 * Codes retour couverts: 200, 400, 404
 */
public class StoreTest {

  @Karate.Test
  Karate testStoreDomain() {
    return Karate.run("classpath:features/store");
  }
}
