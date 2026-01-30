package petstore;

import com.intuit.karate.junit5.Karate;

/**
 * Runner pour les tests de l'endpoint /user
 * 
 * Endpoint: /user, /user/login, /user/logout, /user/{username}, /user/createWithArray, /user/createWithList
 * Méthodes testées: GET, POST, PUT, DELETE
 * Codes retour couverts: 200, 400, 404, default
 * 
 * Scénarios couverts:
 * - Création d'un utilisateur (POST /user)
 * - Création d'utilisateurs par liste (POST /user/createWithArray, /user/createWithList)
 * - Login (GET /user/login)
 * - Logout (GET /user/logout)
 * - Récupération par username (GET /user/{username})
 * - Mise à jour (PUT /user/{username})
 * - Suppression (DELETE /user/{username})
 */
public class UserTest {

    @Karate.Test
    Karate testUser() {
        return Karate.run("classpath:features/user/user.feature")
                .outputCucumberJson(true);
    }

    @Karate.Test
    Karate testUserSmoke() {
        return Karate.run("classpath:features/user/user.feature")
                .tags("@smoke")
                .outputCucumberJson(true);
    }
}
