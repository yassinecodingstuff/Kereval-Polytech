package petstore;

import com.intuit.karate.junit5.Karate;

/**
 * Runner pour les tests de l'endpoint /store
 * 
 * Endpoint: /store/inventory, /store/order, /store/order/{orderId}
 * Méthodes testées: GET, POST, DELETE
 * Codes retour couverts: 200, 400, 404
 * 
 * Scénarios couverts:
 * - Récupération de l'inventaire (GET /store/inventory)
 * - Création d'une commande (POST /store/order)
 * - Récupération d'une commande par ID (GET /store/order/{orderId})
 * - Suppression d'une commande (DELETE /store/order/{orderId})
 */
public class StoreTest {

    @Karate.Test
    Karate testStore() {
        return Karate.run("classpath:features/store/store.feature")
                .outputCucumberJson(true);
    }

    @Karate.Test
    Karate testStoreSmoke() {
        return Karate.run("classpath:features/store/store.feature")
                .tags("@smoke")
                .outputCucumberJson(true);
    }
}
