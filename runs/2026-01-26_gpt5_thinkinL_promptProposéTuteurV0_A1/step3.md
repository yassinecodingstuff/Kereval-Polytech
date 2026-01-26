Parfait — voici l’**ÉTAPE 3** : un **projet Maven complet** prêt à cloner, avec runners JUnit 5, `karate-config.js`, `logback-test.xml`, et l’ensemble des features issus de l’Étape 2.

---

# Arborescence

```
karate-tests/
├── pom.xml
├── README.md
└── src/
    └── test/
        ├── java/
        │   └── com/
        │       └── example/
        │           └── karate/
        │               ├── TestRunner.java
        │               ├── PetTest.java
        │               ├── StoreTest.java
        │               └── UserTest.java
        └── resources/
            ├── karate-config.js
            ├── logback-test.xml
            └── features/
                ├── pet/
                │   ├── pet-create-update.feature
                │   ├── pet-search.feature
                │   ├── pet-by-id.feature
                │   └── pet-upload-image.feature
                ├── store/
                │   └── store.feature
                └── user/
                    └── user.feature
```

---

# Fichiers

## `pom.xml`

```xml
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0
                             https://maven.apache.org/xsd/maven-4.0.0.xsd">
  <modelVersion>4.0.0</modelVersion>

  <groupId>com.example</groupId>
  <artifactId>karate-tests</artifactId>
  <version>1.0.0</version>
  <name>karate-tests</name>
  <description>Suite d’automatisation API avec Karate</description>
  <packaging>jar</packaging>

  <properties>
    <maven.compiler.source>17</maven.compiler.source>
    <maven.compiler.target>17</maven.compiler.target>
    <!-- ⚠️ Ajuste ces versions si besoin -->
    <karate.version>1.5.0</karate.version>
    <junit.jupiter.version>5.10.2</junit.jupiter.version>
    <surefire.version>3.2.5</surefire.version>
    <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
  </properties>

  <dependencies>
    <!-- Dépendances minimales -->
    <dependency>
      <groupId>com.intuit.karate</groupId>
      <artifactId>karate-junit5</artifactId>
      <version>${karate.version}</version>
      <scope>test</scope>
    </dependency>
    <dependency>
      <groupId>com.intuit.karate</groupId>
      <artifactId>karate-core</artifactId>
      <version>${karate.version}</version>
      <scope>test</scope>
    </dependency>
    <dependency>
      <groupId>org.junit.jupiter</groupId>
      <artifactId>junit-jupiter-engine</artifactId>
      <version>${junit.jupiter.version}</version>
      <scope>test</scope>
    </dependency>
  </dependencies>

  <build>
    <plugins>
      <!-- JUnit 5 + inclusion des *Test.java et *Runner.java -->
      <plugin>
        <groupId>org.apache.maven.plugins</groupId>
        <artifactId>maven-surefire-plugin</artifactId>
        <version>${surefire.version}</version>
        <configuration>
          <useSystemClassLoader>true</useSystemClassLoader>
          <includes>
            <include>**/*Test.java</include>
            <include>**/*Runner.java</include>
          </includes>
          <systemPropertyVariables>
            <!-- karate.env=dev|test|prod -->
            <karate.env>${karate.env}</karate.env>
          </systemPropertyVariables>
        </configuration>
      </plugin>
    </plugins>
  </build>

  <!-- Profils d'exemple pour changer d'environnement -->
  <profiles>
    <profile>
      <id>dev</id>
      <properties>
        <karate.env>dev</karate.env>
      </properties>
    </profile>
    <profile>
      <id>test</id>
      <properties>
        <karate.env>test</karate.env>
      </properties>
    </profile>
    <profile>
      <id>prod</id>
      <properties>
        <karate.env>prod</karate.env>
      </properties>
    </profile>
  </profiles>
</project>
```

---

## `README.md`

````markdown
# Karate Tests (Petstore)

Suite de tests API REST basée sur **Karate** (JUnit 5).

## Prérequis
- JDK 17+
- Maven 3.9+
- Accès Internet (utilise la Petstore publique)

## Lancer les tests
```bash
# Environnement par défaut: dev
mvn -q -Dtest=* test

# Spécifier un profil
mvn -q -Pdev test
mvn -q -Ptest test
mvn -q -Pprod test

# Tags (exemples)
mvn -q -Dkarate.options="--tags @smoke" test
````

## Configuration (karate-config.js)

* `baseUrl` selon `karate.env` (`dev`, `test`, `prod`)
* `apiKey` / `oauthToken` injectables via variables d'env ou propriétés Maven:

  * `-DapiKey=xxxx`
  * `-DoauthToken=yyyy`

## Arborescence

Voir le repo: `src/test/java` (runners) et `src/test/resources/features` (features).

## Rapports

Les rapports HTML et JUnit XML sont générés par Karate sous `target/karate-reports` et `target/surefire-reports`.

## Notes

* Les scénarios couvrent *happy paths*, erreurs et cas limites selon le Swagger Petstore.
* Certains endpoints spécifient des codes “default” → assertions 2xx génériques.

````

---

## `src/test/resources/karate-config.js`
```javascript
/**
 * Configuration globale Karate :
 * - Environnements: dev | test | prod
 * - Variables: baseUrl, apiKey, oauthToken
 * - Timeouts: connect / read
 */
function fn() {
  var env = karate.env || 'dev';
  var config = {};

  // Base URLs par environnement
  if (env === 'dev') {
    config.baseUrl = 'https://petstore.swagger.io/v2';
  } else if (env === 'test') {
    // Exemples de placeholders si tu rediriges vers un backend de test
    config.baseUrl = 'https://test.api.example.com/v2';
  } else if (env === 'prod') {
    config.baseUrl = 'https://api.example.com/v2';
  } else {
    karate.log('Environnement inconnu, fallback -> dev');
    config.baseUrl = 'https://petstore.swagger.io/v2';
  }

  // Auth optionnelle: apiKey / OAuth2 Bearer
  config.apiKey = karate.properties['apiKey'] || karate.envApiKey || java.lang.System.getenv('API_KEY');
  config.oauthToken = karate.properties['oauthToken'] || java.lang.System.getenv('OAUTH_TOKEN');

  // Timeouts
  karate.configure('connectTimeout', 15000);
  karate.configure('readTimeout', 30000);

  // SSL permissif si besoin
  karate.configure('ssl', true);

  // Headers par défaut (peuvent être overridés dans les Features)
  config.headers = { Accept: 'application/json', 'Content-Type': 'application/json' };

  return config;
}
````

---

## `src/test/resources/logback-test.xml`

```xml
<configuration>
  <appender name="STDOUT" class="ch.qos.logback.core.ConsoleAppender">
    <encoder>
      <pattern>%d{HH:mm:ss.SSS} [%thread] %-5level %logger{36} - %msg%n</pattern>
    </encoder>
  </appender>

  <logger name="com.intuit.karate" level="INFO"/>
  <logger name="org.apache.http" level="WARN"/>

  <root level="INFO">
    <appender-ref ref="STDOUT"/>
  </root>
</configuration>
```

---

## Runners JUnit 5

### `src/test/java/com/example/karate/TestRunner.java`

```java
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
    // Exécute toutes les features sous classpath:features
    return Karate.run("classpath:features");
  }
}
```

### `src/test/java/com/example/karate/PetTest.java`

```java
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
```

### `src/test/java/com/example/karate/StoreTest.java`

```java
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
```

### `src/test/java/com/example/karate/UserTest.java`

```java
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
```

---

## Features (identiques à l’Étape 2)

### `src/test/resources/features/pet/pet-create-update.feature`

```gherkin
Feature: PET - Création & Mise à jour (/pet)

Background:
  * url baseUrl
  * configure headers = { Accept: 'application/json', Content-Type: 'application/json' }
  * if (karate.get('apiKey')) header api_key = apiKey
  * if (karate.get('oauthToken')) header Authorization = 'Bearer ' + oauthToken
  * def petId = 100000 + Math.floor(Math.random() * 100000)
  * def petValid =
  """
  {
    "id": #(petId),
    "name": "doggie",
    "photoUrls": ["https://example.com/pets/doggie.png"],
    "status": "available",
    "tags": [ { "id": 1, "name": "cute" } ],
    "category": { "id": 10, "name": "dogs" }
  }
  """
  * def petInvalid = { "id": "abc" }

@happy
Scenario: POST /pet - cas nominal (2xx)
  * path 'pet'
  * request petValid
  * method post
  * assert responseStatus >= 200 && responseStatus < 300
  * match response contains { id: #(petId), name: 'doggie' }

@error
Scenario: POST /pet - 405 Invalid input
  * path 'pet'
  * request { }
  * method post
  * status 405

@happy
Scenario: PUT /pet - mise à jour existante (2xx)
  * def updated = karate.clone(petValid)
  * set updated.status = 'sold'
  * path 'pet'
  * request updated
  * method put
  * assert responseStatus >= 200 && responseStatus < 300
  * match response contains { id: #(petId), status: 'sold' }

@error
Scenario: PUT /pet - 400 Invalid ID supplied
  * path 'pet'
  * request petInvalid
  * method put
  * status 400

@error
Scenario: PUT /pet - 404 Pet not found
  * def petUnknown = karate.clone(petValid)
  * set petUnknown.id = 999999
  * path 'pet'
  * request petUnknown
  * method put
  * status 404

@error
Scenario: PUT /pet - 405 Validation exception
  * path 'pet'
  * request { "name": "", "photoUrls": [] }
  * method put
  * status 405
```

### `src/test/resources/features/pet/pet-search.feature`

```gherkin
Feature: PET - Recherche (/pet/findByStatus, /pet/findByTags)

Background:
  * url baseUrl
  * configure headers = { Accept: 'application/json', Content-Type: 'application/json' }
  * if (karate.get('apiKey')) header api_key = apiKey
  * if (karate.get('oauthToken')) header Authorization = 'Bearer ' + oauthToken

@happy
Scenario Outline: GET /pet/findByStatus - statut valide → 200
  * path 'pet', 'findByStatus'
  * param status = <status>
  * method get
  * status 200
  * match response == '#[]'
  * match each response contains { id: '#number', name: '#string' }

  Examples:
    | status    |
    | available |
    | pending   |
    | sold      |

@error
Scenario: GET /pet/findByStatus - 400 Invalid status value
  * path 'pet', 'findByStatus'
  * param status = 'unknown'
  * method get
  * status 400

@deprecated @happy
Scenario: GET /pet/findByTags - 200
  * path 'pet', 'findByTags'
  * param tags = ['cute','brown']
  * method get
  * status 200
  * match response == '#[]'

@deprecated @limit @error
Scenario: GET /pet/findByTags - 400 Invalid tag value (chaine vide)
  * path 'pet', 'findByTags'
  * param tags = ['']
  * method get
  * status 400
```

### `src/test/resources/features/pet/pet-by-id.feature`

```gherkin
Feature: PET - Par ID, Form Update & Delete (/pet/{petId})

Background:
  * url baseUrl
  * configure headers = { Accept: 'application/json', Content-Type: 'application/json' }
  * if (karate.get('apiKey')) header api_key = apiKey
  * if (karate.get('oauthToken')) header Authorization = 'Bearer ' + oauthToken

@happy
Scenario: GET /pet/{petId} - 200
  * path 'pet', 1
  * method get
  * status 200
  * match response contains { id: 1 }

@error
Scenario: GET /pet/{petId} - 400 Invalid ID supplied
  * path 'pet', 'abc'
  * method get
  * status 400

@error
Scenario: GET /pet/{petId} - 404 Pet not found
  * path 'pet', 999999
  * method get
  * status 404

@error
Scenario: POST /pet/{petId} (form) - 405 Invalid input
  * path 'pet', 1
  * form field name = ''
  * form field status = ''
  * method post
  * status 405

@error
Scenario: DELETE /pet/{petId} - 400 Invalid ID supplied
  * path 'pet', 'abc'
  * method delete
  * status 400

@error
Scenario: DELETE /pet/{petId} - 404 Pet not found
  * path 'pet', 999999
  * method delete
  * status 404
```

### `src/test/resources/features/pet/pet-upload-image.feature`

```gherkin
Feature: PET - Upload image (/pet/{petId}/uploadImage)

Background:
  * url baseUrl
  * configure headers = { Accept: 'application/json' }
  * if (karate.get('apiKey')) header api_key = apiKey
  * if (karate.get('oauthToken')) header Authorization = 'Bearer ' + oauthToken
  * def samplePath = 'classpath:files/sample.png'

@happy
Scenario: POST /pet/{petId}/uploadImage - 200
  * path 'pet', 1, 'uploadImage'
  * multipart file file = { read: #(samplePath), filename: 'sample.png', contentType: 'image/png' }
  * multipart field additionalMetadata = 'avatar'
  * method post
  * status 200
  * match response contains { code: '#number', message: '##string' }
```

### `src/test/resources/features/store/store.feature`

```gherkin
Feature: STORE - Inventaire & Commandes

Background:
  * url baseUrl
  * configure headers = { Accept: 'application/json', Content-Type: 'application/json' }
  * if (karate.get('apiKey')) header api_key = apiKey
  * if (karate.get('oauthToken')) header Authorization = 'Bearer ' + oauthToken
  * def orderId = 11

@happy
Scenario: GET /store/inventory - 200
  * path 'store', 'inventory'
  * method get
  * status 200
  * match response == '#object'
  * match each response.* == '#number'

@happy
Scenario: POST /store/order - 200
  * def orderValid =
  """
  { "id": #(orderId), "petId": 1001, "quantity": 1, "status": "placed", "complete": true }
  """
  * path 'store', 'order'
  * request orderValid
  * method post
  * status 200
  * match response contains { id: #(orderId), status: '#string' }

@error
Scenario: POST /store/order - 400 Invalid Order
  * path 'store', 'order'
  * request { "id": 12, "quantity": -1 }
  * method post
  * status 400

@happy
Scenario: GET /store/order/{orderId} - 200 (1..10)
  * path 'store', 'order', 5
  * method get
  * status 200
  * match response contains { id: 5 }

@limit @error
Scenario: GET /store/order/{orderId} - 400 Invalid ID supplied
  * path 'store', 'order', 0
  * method get
  * status 400

@error
Scenario: GET /store/order/{orderId} - 404 Order not found
  * path 'store', 'order', 9999
  * method get
  * status 404

@limit @error
Scenario: DELETE /store/order/{orderId} - 400 Invalid ID supplied
  * path 'store', 'order', 0
  * method delete
  * status 400

@error
Scenario: DELETE /store/order/{orderId} - 404 Order not found
  * path 'store', 'order', 9999
  * method delete
  * status 404
```

### `src/test/resources/features/user/user.feature`

```gherkin
Feature: USER - Création, Login, CRUD

Background:
  * url baseUrl
  * configure headers = { Accept: 'application/json', Content-Type: 'application/json' }
  * if (karate.get('apiKey')) header api_key = apiKey
  * if (karate.get('oauthToken')) header Authorization = 'Bearer ' + oauthToken
  * def userValid =
  """
  { "id": 201, "username": "user1", "firstName": "Ada", "lastName": "Lovelace",
    "email": "ada@example.com", "password": "P@ssw0rd", "phone": "0600000000", "userStatus": 1 }
  """

@happy
Scenario: POST /user - succès
  * path 'user'
  * request userValid
  * method post
  * assert responseStatus >= 200 && responseStatus < 300

@happy
Scenario: POST /user/createWithArray - succès
  * path 'user', 'createWithArray'
  * request [ userValid ]
  * method post
  * assert responseStatus >= 200 && responseStatus < 300

@happy
Scenario: POST /user/createWithList - succès
  * path 'user', 'createWithList'
  * request [ userValid ]
  * method post
  * assert responseStatus >= 200 && responseStatus < 300

@happy
Scenario: GET /user/login - 200 + entêtes
  * path 'user', 'login'
  * param username = 'user1'
  * param password = 'P@ssw0rd'
  * method get
  * status 200
  * match responseHeaders['X-Rate-Limit'][0] == '#number'
  * match responseHeaders['X-Expires-After'][0] == '#string'

@error
Scenario: GET /user/login - 400 Invalid username/password supplied
  * path 'user', 'login'
  * param username = 'user1'
  * param password = ''
  * method get
  * status 400

@happy
Scenario: GET /user/logout - succès
  * path 'user', 'logout'
  * method get
  * assert responseStatus >= 200 && responseStatus < 300

@happy
Scenario: GET /user/{username} - 200
  * path 'user', 'user1'
  * method get
  * status 200
  * match response contains { username: 'user1' }

@error
Scenario: GET /user/{username} - 400 Invalid username supplied
  * path 'user', ''
  * method get
  * status 400

@error
Scenario: GET /user/{username} - 404 User not found
  * path 'user', 'ghost-user'
  * method get
  * status 404

@error
Scenario: PUT /user/{username} - 400 Invalid user supplied
  * path 'user', 'user1'
  * request { "id": "abc" }
  * method put
  * status 400

@error
Scenario: PUT /user/{username} - 404 User not found
  * path 'user', 'ghost-user'
  * request userValid
  * method put
  * status 404

@error
Scenario: DELETE /user/{username} - 400 Invalid username supplied
  * path 'user', ''
  * method delete
  * status 400

@error
Scenario: DELETE /user/{username} - 404 User not found
  * path 'user', 'ghost-user'
  * method delete
  * status 404
```

---

## Tableau de couverture

Le tableau de couverture **reste identique à l’Étape 2** (mêmes features et scénarios, mêmes endpoints/méthodes/codes).
Si tu veux, je peux ré-exporter ce tableau avec des numéros de lignes recalculés automatiquement à partir des fichiers (script rapide possible).

---

## Résumé des choix techniques

* **Karate + JUnit 5** via `karate-junit5` et runners dédiés par domaine (`PetTest`, `StoreTest`, `UserTest`) + un `TestRunner` global.
* **Config centralisée** dans `karate-config.js` (envs `dev|test|prod`, timeouts, headers, auth conditionnelle).
* **Features idiomatiques** (usage de `*`, `match`, `status`, `assert`, `#()` / `##`), organisation par **ressource**.
* **Maven Surefire** configuré pour détecter `*Test.java` et `*Runner.java`, profils pour surcharger `karate.env`.

---

## Prochaines étapes / améliorations

1. **Données test stables** : créer des factories JS (ex. `helpers/petFactory.js`) et utiliser `call` / `callSingle`.
2. **Tags & CI** : séparer `@smoke`, `@regression`, `@negative` et intégrer à un pipeline CI (GitHub Actions, GitLab CI…).
3. **Paramétrage secrets** : utiliser des variables chiffrées CI/CD pour `apiKey` / `oauthToken`.
4. **Rapports avancés** : publier `target/karate-reports/karate-summary.html` en artefact CI ; ajouter l’historique (Allure, si souhaité).
5. **Données aléatoires contrôlées** : `karate.randomUUID()` + horodatage pour éviter les collisions côté Petstore publique.

Si tu veux, je peux aussi te livrer un **zip** ou un **repo** prêt à utiliser avec ces fichiers.
