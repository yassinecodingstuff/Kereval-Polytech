package petstore;

import com.intuit.karate.junit5.Karate;

/**
 * Runner principal pour exécuter tous les tests Karate de l'API Petstore.
 * 
 * Ce runner exécute tous les fichiers .feature situés dans le classpath.
 * 
 * Endpoints couverts:
 * - /pet: Gestion des animaux (CRUD complet)
 * - /store: Gestion du magasin et des commandes
 * - /user: Gestion des utilisateurs
 * 
 * Codes retour testés: 200, 201, 400, 404, 405, 500
 * 
 * Usage:
 * - mvn test                                    # Exécuter tous les tests
 * - mvn test -Dkarate.options="--tags @smoke"   # Exécuter les tests smoke
 * - mvn test -Dkarate.options="--tags @pet"     # Exécuter les tests pet uniquement
 */
public class TestRunner {

    @Karate.Test
    Karate testAll() {
        return Karate.run("classpath:features")
                .outputCucumberJson(true)
                .outputJunitXml(true);
    }

    @Karate.Test
    Karate testSmoke() {
        return Karate.run("classpath:features")
                .tags("@smoke")
                .outputCucumberJson(true);
    }

    @Karate.Test
    Karate testRegression() {
        return Karate.run("classpath:features")
                .tags("@regression")
                .outputCucumberJson(true);
    }
}
