package petstore;

import com.intuit.karate.junit5.Karate;

/**
 * Runner pour les tests de l'endpoint /pet
 * 
 * Endpoint: /pet, /pet/{petId}, /pet/findByStatus, /pet/findByTags, /pet/{petId}/uploadImage
 * Méthodes testées: GET, POST, PUT, DELETE
 * Codes retour couverts: 200, 400, 404, 405
 * 
 * Scénarios couverts:
 * - Création d'un pet (POST /pet)
 * - Mise à jour d'un pet (PUT /pet)
 * - Récupération par ID (GET /pet/{petId})
 * - Recherche par status (GET /pet/findByStatus)
 * - Recherche par tags (GET /pet/findByTags)
 * - Mise à jour avec form data (POST /pet/{petId})
 * - Upload d'image (POST /pet/{petId}/uploadImage)
 * - Suppression (DELETE /pet/{petId})
 */
public class PetTest {

    @Karate.Test
    Karate testPet() {
        return Karate.run("classpath:features/pet/pet.feature")
                .outputCucumberJson(true);
    }

    @Karate.Test
    Karate testPetSmoke() {
        return Karate.run("classpath:features/pet/pet.feature")
                .tags("@smoke")
                .outputCucumberJson(true);
    }
}
