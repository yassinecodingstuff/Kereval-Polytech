PROMPT 3 — ÉTAPE 3 : GÉNÉRATION DU CODE SOURCE COMPLET (PROJET MAVEN)

En te basant sur les fichiers Karate .feature et le tableau de couverture que tu viens de générer à l’ÉTAPE 2 dans cette même conversation, génère la structure complète du projet Maven avec tous les fichiers nécessaires.

ÉTAPE 3 : GÉNÉRATION DU CODE SOURCE COMPLET

Structure du projet :

karate-tests/
├── pom.xml
├── src/
│   ├── test/
│   │   ├── java/
│   │   │   └── [package]/
│   │   │       ├── TestRunner.java
│   │   │       └── [Resource]Test.java
│   │   └── resources/
│   │       ├── karate-config.js
│   │       ├── logback-test.xml
│   │       └── features/
│   │           └── *.feature
└── README.md


Contenu requis du pom.xml :

<!-- Dépendances minimales -->
- com.intuit.karate:karate-junit5 (dernière version stable)
- org.junit.jupiter:junit-jupiter-engine
- com.intuit.karate:karate-core
- Plugins : maven-surefire-plugin


karate-config.js :

Configuration des environnements (dev, test, prod)

Variables globales (baseUrl, timeouts)

Configuration de l'authentification

Commentaires dans le code source :
Chaque test doit inclure en commentaire :

/**
 * Tests pour l'endpoint: [endpoint]
 * Méthodes testées: [GET, POST, etc.]
 * Codes retour couverts: [200, 201, 400, 404, 500]
 */


Livrable 3 : Code source complet de tous les fichiers.

FORMAT DE SORTIE (Étape 3)

Pour cette étape, fournis :

Le contenu généré (tous les fichiers + arborescence)

Le tableau de couverture correspondant (si nécessaire)

Un résumé des choix techniques et justifications

Les prochaines étapes ou améliorations possibles