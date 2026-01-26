# Karate Tests (Petstore)

Suite de tests API REST basée sur **Karate** (JUnit 5).

## 📦 Installation
1. Dézipper ce projet quelque part (`karate-tests/`).
2. Vérifier les prérequis ci-dessous.
3. Ouvrir dans votre IDE ou exécuter Maven en ligne de commande.

## ✅ Prérequis
- **Java**: JDK 17+
- **Maven**: 3.9+
- Accès Internet (utilise la Petstore publique)

## 🚀 Commandes
```bash
# Exécuter tous les tests
mvn clean test

# Exécuter un feature ou un sous-dossier par tags (ex: @smoke / @happy / @error)
mvn test -Dkarate.options="--tags @smoke"

# Générer le rapport (exécute les tests @regression)
mvn test -Dkarate.options="--tags @regression"
```

> Tags présents dans les features : `@happy`, `@error`, `@deprecated`, `@limit`  
> (vous pouvez remplacer `@smoke` / `@regression` par `@happy` ou tout autre tag selon votre besoin).

## 🌐 Environnements & configuration
- Environnements: `dev` (par défaut), `test`, `prod` via profils Maven.
- Base URL par environnement définie dans `karate-config.js`.
- Variables d'auth optionnelles: `apiKey`, `oauthToken` (propriétés Maven ou variables d'environnement).

Exemples:
```bash
# Sélection d'environnement
mvn -Pdev test
mvn -Ptest test
mvn -Pprod test

# Injection d'un apiKey / oauthToken
mvn -DapiKey=XXXX -DoauthToken=YYYY test
```

### Fichier d’exemple `application.properties`
Situé sous `src/test/resources/application.properties`.  
Ce fichier **n’est pas chargé automatiquement** par Karate mais sert d’exemple documentaire pour vos valeurs.
Vous pouvez exporter ces propriétés en variables d’environnement ou les passer à Maven avec `-D`.

## 🧪 Couverture des tests (récapitulatif)
| Endpoint | Méthode | Codes | Feature |
|---|---|---|---|
| /pet | POST | 2xx, 405 | pet/pet-create-update.feature |
| /pet | PUT | 2xx, 400, 404, 405 | pet/pet-create-update.feature |
| /pet/findByStatus | GET | 200, 400 | pet/pet-search.feature |
| /pet/findByTags (deprecated) | GET | 200, 400 | pet/pet-search.feature |
| /pet/{petId} | GET | 200, 400, 404 | pet/pet-by-id.feature |
| /pet/{petId} | POST | 405 | pet/pet-by-id.feature |
| /pet/{petId}/uploadImage | POST | 200 | pet/pet-upload-image.feature |
| /store/inventory | GET | 200 | store/store.feature |
| /store/order | POST | 200, 400 | store/store.feature |
| /store/order/{orderId} | GET | 200, 400, 404 | store/store.feature |
| /store/order/{orderId} | DELETE | 400, 404 | store/store.feature |
| /user | POST | 2xx | user/user.feature |
| /user/createWithArray | POST | 2xx | user/user.feature |
| /user/createWithList | POST | 2xx | user/user.feature |
| /user/login | GET | 200, 400 | user/user.feature |
| /user/logout | GET | 2xx | user/user.feature |
| /user/{username} | GET | 200, 400, 404 | user/user.feature |
| /user/{username} | PUT | 400, 404 | user/user.feature |
| /user/{username} | DELETE | 400, 404 | user/user.feature |

## 📝 Notes
- Les scénarios couvrent cas nominaux, erreurs et cas limites selon le Swagger Petstore.
- Les endpoints avec codes `default` sont validés via `assert responseStatus in [200..299]`.
- Un échantillon d'image `files/sample.png` est inclus pour `uploadImage`.

## 📄 Licence
Usage pédagogique / démonstration.
