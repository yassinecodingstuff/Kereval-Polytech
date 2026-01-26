En te basant sur les cas de tests Gherkin et le tableau de couverture que tu viens de générer à l’ÉTAPE 1 dans cette même conversation, transforme les cas de tests Gherkin en fichiers .feature Karate.

ÉTAPE 2 : CONVERSION EN FEATURES KARATE

Règles de conversion :

Respecte la syntaxe Karate (utilise * au lieu de Given/When/Then si approprié)

Intègre les assertions Karate : match, status, contains

Utilise les variables Karate : #(), ##() pour JSON dynamique

Configure les headers (Content-Type, Authorization si nécessaire)

Organise les features par ressource/domaine

Format attendu :

Feature: Gestion des utilisateurs

Background:
  * url baseUrl
  * header Content-Type = 'application/json'

Scenario: Récupérer la liste des utilisateurs avec succès
  Given path '/users'
  When method GET
  Then status 200
  And match response == '#[]'


Livrable 2 : Tableau de couverture au format :

Endpoint	Méthode	Code Retour	Feature Karate	Ligne	Couvert
FORMAT DE SORTIE (Étape 2)

Pour cette étape, fournis :

Le contenu généré (features Karate)

Le tableau de couverture correspondant

Un résumé des choix techniques et justifications

Les prochaines étapes ou améliorations possibles