# 🐾 Karate Petstore API Tests

[![Karate](https://img.shields.io/badge/Karate-1.4.1-green.svg)](https://github.com/karatelabs/karate)
[![Java](https://img.shields.io/badge/Java-17+-blue.svg)](https://openjdk.org/)
[![Maven](https://img.shields.io/badge/Maven-3.8+-orange.svg)](https://maven.apache.org/)

Projet de tests automatisés pour l'API [Swagger Petstore](https://petstore.swagger.io/) utilisant le framework **Karate**.

## 📋 Table des matières

- [Prérequis](#-prérequis)
- [Installation](#-installation)
- [Structure du projet](#-structure-du-projet)
- [Exécution des tests](#-exécution-des-tests)
- [Couverture des tests](#-couverture-des-tests)
- [Configuration](#-configuration)
- [Rapports](#-rapports)
- [Tags disponibles](#-tags-disponibles)

## ✅ Prérequis

| Outil | Version minimale |
|-------|------------------|
| Java JDK | 17+ |
| Maven | 3.8+ |
| Git | 2.x |

### Vérification des prérequis

```bash
# Vérifier Java
java -version

# Vérifier Maven
mvn -version
```

## 🚀 Installation

1. **Cloner le projet**
```bash
git clone <repository-url>
cd karate-petstore-tests
```

2. **Installer les dépendances**
```bash
mvn clean install -DskipTests
```

3. **Vérifier l'installation**
```bash
mvn test -Dtest=TestRunner#testSmoke
```

## 📁 Structure du projet

```
karate-petstore-tests/
├── pom.xml                              # Configuration Maven
├── README.md                            # Documentation
├── .gitignore                           # Fichiers ignorés par Git
└── src/
    └── test/
        ├── java/
        │   └── petstore/
        │       ├── TestRunner.java      # Runner principal
        │       ├── PetTest.java         # Runner tests Pet
        │       ├── StoreTest.java       # Runner tests Store
        │       └── UserTest.java        # Runner tests User
        └── resources/
            ├── karate-config.js         # Configuration Karate
            ├── logback-test.xml         # Configuration logs
            ├── data/
            │   └── test-data.json       # Données de test
            └── features/
                ├── pet/
                │   └── pet.feature      # Tests endpoint /pet
                ├── store/
                │   └── store.feature    # Tests endpoint /store
                └── user/
                    └── user.feature     # Tests endpoint /user
```

## 🏃 Exécution des tests

### Commandes de base

```bash
# Exécuter TOUS les tests
mvn clean test

# Exécuter avec un environnement spécifique
mvn test -Dkarate.env=dev
mvn test -Dkarate.env=test
mvn test -Dkarate.env=prod
```

### Exécution par tags

```bash
# Tests smoke (rapides, essentiels)
mvn test -Dkarate.options="--tags @smoke"

# Tests de régression complets
mvn test -Dkarate.options="--tags @regression"

# Tests par domaine
mvn test -Dkarate.options="--tags @pet"
mvn test -Dkarate.options="--tags @store"
mvn test -Dkarate.options="--tags @user"

# Tests négatifs uniquement
mvn test -Dkarate.options="--tags @negative"

# Tests End-to-End
mvn test -Dkarate.options="--tags @e2e"

# Combiner les tags (ET logique)
mvn test -Dkarate.options="--tags @smoke --tags @pet"

# Exclure des tags
mvn test -Dkarate.options="--tags ~@deprecated"
```

### Exécution d'une feature spécifique

```bash
# Feature Pet
mvn test -Dkarate.options="classpath:features/pet/pet.feature"

# Feature Store
mvn test -Dkarate.options="classpath:features/store/store.feature"

# Feature User
mvn test -Dkarate.options="classpath:features/user/user.feature"
```

### Utilisation des profils Maven

```bash
# Profil smoke
mvn test -Psmoke

# Profil regression
mvn test -Pregression

# Profil par domaine
mvn test -Ppet
mvn test -Pstore
mvn test -Puser
```

## 📊 Couverture des tests

### Vue d'ensemble

| Domaine | Endpoints | Scénarios | Smoke | Regression |
|---------|-----------|-----------|-------|------------|
| Pet | 8 | 25+ | ✅ | ✅ |
| Store | 4 | 18+ | ✅ | ✅ |
| User | 8 | 25+ | ✅ | ✅ |
| **Total** | **20** | **68+** | ✅ | ✅ |

### Détail par endpoint

#### 🐕 Pet (`/pet`)

| Endpoint | Méthode | Codes Retour | Scénarios |
|----------|---------|--------------|-----------|
| `/pet` | POST | 200, 405 | Création valide, données invalides |
| `/pet` | PUT | 200, 400, 404, 405 | Mise à jour valide, ID invalide, non trouvé |
| `/pet/findByStatus` | GET | 200, 400 | Recherche par status (available, pending, sold) |
| `/pet/findByTags` | GET | 200, 400 | Recherche par tags (deprecated) |
| `/pet/{petId}` | GET | 200, 400, 404 | Récupération valide, ID invalide, non trouvé |
| `/pet/{petId}` | POST | 200, 405 | Mise à jour form data |
| `/pet/{petId}` | DELETE | 200, 400 | Suppression valide, ID invalide |
| `/pet/{petId}/uploadImage` | POST | 200 | Upload image |

#### 🏪 Store (`/store`)

| Endpoint | Méthode | Codes Retour | Scénarios |
|----------|---------|--------------|-----------|
| `/store/inventory` | GET | 200 | Récupération inventaire |
| `/store/order` | POST | 200, 400 | Création commande valide/invalide |
| `/store/order/{orderId}` | GET | 200, 400, 404 | Récupération valide, ID invalide, non trouvée |
| `/store/order/{orderId}` | DELETE | 200, 400, 404 | Suppression valide, ID invalide |

#### 👤 User (`/user`)

| Endpoint | Méthode | Codes Retour | Scénarios |
|----------|---------|--------------|-----------|
| `/user` | POST | 200/default | Création utilisateur |
| `/user/createWithArray` | POST | 200/default | Création en masse (array) |
| `/user/createWithList` | POST | 200/default | Création en masse (list) |
| `/user/login` | GET | 200, 400 | Login valide/invalide |
| `/user/logout` | GET | 200/default | Logout |
| `/user/{username}` | GET | 200, 400, 404 | Récupération valide, username invalide |
| `/user/{username}` | PUT | 200, 400, 404 | Mise à jour valide, données invalides |
| `/user/{username}` | DELETE | 200, 400, 404 | Suppression valide, username invalide |

## ⚙️ Configuration

### Environnements (`karate-config.js`)

| Environnement | URL | Description |
|---------------|-----|-------------|
| `dev` | http://petstore.swagger.io/v2 | Développement (défaut) |
| `test` | http://petstore.swagger.io/v2 | Test/Staging |
| `prod` | http://petstore.swagger.io/v2 | Production |

### Variables de configuration

```javascript
// karate-config.js
{
  baseUrl: 'http://petstore.swagger.io/v2',
  apiKey: 'special-key',
  connectTimeout: 30000,
  readTimeout: 30000
}
```

### Authentification

L'API Petstore utilise une clé API (`api_key`) pour certains endpoints. La valeur `special-key` est utilisée pour les tests.

```gherkin
* header api_key = 'special-key'
```

## 📈 Rapports

### Localisation des rapports

Après exécution, les rapports sont générés dans :

```
target/
├── karate-reports/           # Rapports HTML Karate
│   └── karate-summary.html   # Résumé exécution
├── surefire-reports/         # Rapports JUnit
└── karate-logs/              # Logs détaillés
```

### Ouvrir le rapport HTML

```bash
# Linux/Mac
open target/karate-reports/karate-summary.html

# Windows
start target/karate-reports/karate-summary.html
```

### Rapports Cucumber JSON

Les rapports Cucumber JSON sont également générés pour intégration CI/CD :
```
target/karate-reports/*.json
```

## 🏷️ Tags disponibles

| Tag | Description |
|-----|-------------|
| `@smoke` | Tests rapides essentiels |
| `@regression` | Suite de régression complète |
| `@pet` | Tests endpoint Pet |
| `@store` | Tests endpoint Store |
| `@user` | Tests endpoint User |
| `@get` | Tests méthode GET |
| `@post` | Tests méthode POST |
| `@put` | Tests méthode PUT |
| `@delete` | Tests méthode DELETE |
| `@negative` | Tests cas d'erreur |
| `@boundary` | Tests valeurs limites |
| `@e2e` | Tests End-to-End |
| `@deprecated` | Tests endpoints dépréciés |

## 🔧 Dépannage

### Problèmes courants

1. **Tests timeout**
   ```bash
   # Augmenter le timeout
   mvn test -Dkarate.options="--threads 1"
   ```

2. **Erreurs de connexion**
   ```bash
   # Vérifier la connectivité
   curl -X GET "https://petstore.swagger.io/v2/pet/findByStatus?status=available"
   ```

3. **Conflits de dépendances**
   ```bash
   mvn dependency:tree
   mvn clean install -U
   ```

## 📝 Bonnes pratiques

1. **Exécuter les tests smoke avant de committer**
   ```bash
   mvn test -Psmoke
   ```

2. **Utiliser des données de test uniques** (UUID générés automatiquement)

3. **Nettoyer les données après les tests E2E**

4. **Consulter les logs en cas d'échec**
   ```bash
   cat target/karate-logs/karate.log
   ```

## 🤝 Contribution

1. Créer une branche feature
2. Ajouter/modifier les tests
3. Vérifier avec `mvn test -Psmoke`
4. Soumettre une Pull Request

## 📄 Licence

Ce projet est sous licence MIT. Voir le fichier [LICENSE](LICENSE) pour plus de détails.

---

**Généré automatiquement pour l'API Swagger Petstore v3.0**
