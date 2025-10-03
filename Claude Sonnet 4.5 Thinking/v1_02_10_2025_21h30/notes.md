# Rapport d'Évaluation Technique (itération 1)

## Projet d'Automatisation des Tests API Karate avec IA

---

## 1. Contexte

Ce rapport évalue les limitations techniques rencontrées lors de la première itération pour la génération d'un projet d'automatisation de tests API Karate utilisant Claude Sonnet 4.5 Thinking

## 2. Données d'entrée

Fichier Swagger initial : https://petstore.swagger.io/
Prompts : Voir prompt_1/2/3.txt

---

## 2. Limitations Identifiées

### 2.1 Impossibilité de Génération de Fichiers ZIP

**Problème constaté :**
Le prompt initial demandait explicitement la génération d'une "archive ZIP téléchargeable" contenant l'ensemble du projet. Cette exigence est techniquement impossible pour certains assistants IA basés sur des modèles de langage (LLM).

**Cause technique :**
Les LLM, incluant Claude Sonnet 4.5 Thinking, ne peuvent générer que du contenu textuel. Ils ne peuvent pas créer de fichiers binaires (ZIP, RAR, PDF compilés, exécutables).

**Solution appliquée :**
Fourniture de 23+ fichiers individuels avec contenu complet en format texte, accompagnés de la structure des répertoires et des instructions de placement.

**Impact :**

- ✅ Projet fonctionnellement complet et utilisable
- ✅ Tous les fichiers fournis (pom.xml, .java, .feature, configurations)
- ⚠️ Nécessite une création manuelle de la structure de dossiers
- ⚠️ Risque d'erreur humaine lors de l'assemblage

**Recommandation :**
Reformuler le prompt final comme suit :

> _"Fournir tous les fichiers du projet sous forme d'assets textuels séparés avec leur contenu complet, organisés selon leur structure de répertoires, pour permettre la création manuelle de l'arborescence."_

---

### 2.2 Qualité Insuffisante des Dépendances Maven

**Problème constaté :**
Les fichiers pom.xml générés par les LLM nécessitent fréquemment des modifications manuelles avant utilisation, notamment concernant :

- Versions obsolètes des dépendances
- Dépendances manquantes ou redondantes
- Configuration incomplète des plugins Maven
- Incompatibilités entre versions

**Cause racine :**
Manque de spécificité dans le prompt initial permettant au LLM de choisir arbitrairement les versions des bibliothèques, basé sur des données d'entraînement historiques potentiellement obsolètes.

**Solution proposée :**
Spécifier explicitement dans le prompt initial toutes les dépendances avec leurs versions exactes. Exemple :

```
DÉPENDANCES OBLIGATOIRES (versions exactes à utiliser) :

1. Karate Framework :
   - com.intuit.karate:karate-junit5:1.4.1 (scope: test)

2. JUnit 5 :
   - org.junit.jupiter:junit-jupiter-api:5.11.1 (scope: test)
   - org.junit.jupiter:junit-jupiter-engine:5.11.1 (scope: test)

3. Cucumber :
   - io.cucumber:cucumber-java:7.14.0
   - io.cucumber:gherkin:27.0.0

4. Logging :
   - ch.qos.logback:logback-classic:1.4.11 (scope: test)

PLUGINS MAVEN OBLIGATOIRES :

1. maven-compiler-plugin:3.11.0
   Configuration :
   - source: 17
   - target: 17
   - encoding: UTF-8

2. maven-surefire-plugin:3.2.2
   Configuration :
   - includes: **/*Test.java, **/*Tests.java, **/TestRunner.java

PROPERTIES REQUISES :
- maven.compiler.source: 17
- maven.compiler.target: 17
- project.build.sourceEncoding: UTF-8
- karate.version: 1.4.1
- junit.version: 5.11.1
```

**Bénéfices attendus :**

- Réduction du temps de correction de 80-90%
- Élimination des conflits de versions
- Pom.xml immédiatement exécutable
- Meilleure reproductibilité du projet

---

## 3. Conclusions

Ces problèmes sont entièrement résolubles par :

1. **Ajustement des prompts** : Demander des fichiers textuels séparés plutôt que des archives binaires
2. **Spécification exhaustive** : Fournir les versions exactes de toutes les dépendances Maven dès le prompt initial

---

## 4. Recommandations

1. Développer des scripts d'automatisation pour la création de structures de fichiers à partir des contenus fournis

---

**Date :** 2 octobre 2025  
**Projet :** Automatisation Tests API Petstore avec Karate Framework
