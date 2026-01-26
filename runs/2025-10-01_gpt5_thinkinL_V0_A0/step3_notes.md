Le récap montre 61 scénarios, 15 PASS, 46 FAIL (4 features, toutes rouges). C’est exactement le résultat attendu d’une baseline “prompts TAIA bruts” : maintenant on peut diagnostiquer proprement.

Ce que signifient les dossiers/fichiers

target/ : dossiers générés à l’exécution (ne pas versionner).

target/karate-reports/karate-summary.html : tableau de bord (ce que tu as ouvert).

features.*.html : détail par feature (messages d’échec + requêtes/réponses).

Lecture rapide de tes erreurs (et cause probable)
1) Attentes de statuts irréalistes pour Petstore v2 → fail_assertions

Exemples :

POST /pet avec payload incomplet → 200 au lieu de 405.

GET /pet/-1, /pet/0, /pet/abc → 404 au lieu de 400.

POST /store/order payload invalide → 200 ou 500 au lieu de 400.

GET /user/login mauvais mot de passe → 200 au lieu de 400.

👉 Le service Petstore v2 n’applique pas la validation comme on l’imagine (ou comme le Swagger le suggère). Les prompts baseline ont supposé des 400/405 “idéaux”, d’où la majorité des FAIL.

2) Construction/parse de données → fail_syntax / fail_data

ParseException: Unexpected token + (pet-lifecycle:177)
Vient du scénario “big payload” (concaténation / placeholder **PHOTO**, listes générées).
👉 JSON/JS mal construit pour Karate.

Emails / URLs en Markdown dans le JSON (ex. [qa@x.com](mailto:...))
👉 Valeurs non réalistes ; peuvent casser des assertions ou la logique serveur.

3) Assertions trop strictes sur l’inventaire → fail_assertions

Tu tests que les clés du map inventaire ∈ {available,pending,sold}, mais la réponse publique contient plein d’autres clés (données injectées).
👉 Il faut tester seulement que les valeurs sont numériques (>= 0).

4) Préconditions fragiles / dépendances implicites

GET /user/qa_user_501 attend 200 mais tu n’avais pas forcément créé l’utilisateur juste avant (ou la création n’a pas “persisté”).
👉 Toujours créer la ressource dans le scénario et réutiliser l’id/username retourné.

Taxonomie conseillée pour l’Excel :

fail_assertions : la grande majorité (statuts attendus ≠ réels, inventaire, login…).

fail_syntax : 1 (le ParseException).

fail_dependencies : 0 (build OK).

fail_data : quelques cas possibles (Markdown dans JSON), mais tes logs montrent surtout des assertions.




Amélioration v1 (ce qu’on va changer côté prompts — pas à la main)

On garde le même Swagger et le même LLM, mais on renforce les prompts Étape 2 et 3 pour générer des tests robustes à Petstore v2.

Bloc à ajouter à la fin du prompt Étape 2 (v1)

Contraintes de conversion (qualité v1)

Sanitize JSON : pas de Markdown dans les chaînes (liens/e-mails bruts).

Préconditions : créer les entités nécessaires (POST) et capturer l’id/username renvoyé pour les étapes suivantes du même scénario.

Statuts réalistes Petstore v2 :

id inexistant ou invalide (négatif / 0 / non numérique) → 404 (pas 400).

login mauvais mot de passe → 200 mais message “logged in user session:…”.

payload “incomplet” → ne pas attendre 400/405 (Petstore accepte souvent) ; privilégier des négatifs documentés (404 / 405 method not allowed).

Inventaire : vérifier que les valeurs du map sont des entiers ≥ 0 ; ne pas restreindre les clés au triplet {available,pending,sold}.

Payloads “géants” : ne pas générer de boucles complexes; supprimer les placeholders type **PHOTO**; garder des exemples simples.

api_key : l’utiliser uniquement pour /store/inventory.

Background / Outline obligatoires, réutilisation des variables.
Sortie : fichiers .feature complets et valides Karate.

Bloc à ajouter à la fin du prompt Étape 3 (v1)

pom.xml : io.karatelabs:karate-junit5:1.5.1, Java 17, surefire 3.1.2 incluant **/*Runner.java.

karate-config.js : baseUrl sans markdown, timeouts réglés.

Replacer tous les .feature sous src/test/resources/features/....

Fichiers complets, pas de fragments.