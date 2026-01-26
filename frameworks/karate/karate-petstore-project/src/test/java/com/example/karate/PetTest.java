package com.example.karate;

import com.intuit.karate.junit5.Karate;

/**
 * Tests pour l'endpoint: /pet, /pet/findByStatus, /pet/findByTags, /pet/{petId}, /pet/{petId}/uploadImage
 * Méthodes testées: GET, POST, PUT, DELETE
 * Codes retour couverts: 2xx, 200, 400, 404, 405
 */
public class PetTest {

  @Karate.Test
  Karate testPetDomain() {
    return Karate.run("classpath:features/pet");
  }
}
