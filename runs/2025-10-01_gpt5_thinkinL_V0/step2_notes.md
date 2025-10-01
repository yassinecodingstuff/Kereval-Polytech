Je te liste les risques par catégorie (ça t’aidera à classer les FAIL après mvn test).

A) CONFIG / ENV

baseUrl contient un lien Markdown

* def baseUrl = '[https://petstore.swagger.io/v2](https://petstore.swagger.io/v2)'


→ URL invalide pour Karate (va probablement planter tous les appels).
Taxonomie : fail_dependencies ou fail_data (selon le message).
(On laissera comme ça pour la photo baseline, mais sache que c’est le bug n°1.)

B) DATA / PAYLOADS

JSON avec Markdown à l’intérieur (photoUrls, email), ex.
"photoUrls": ["[https://...](https://...)"], "email": "[qa501@example.com](mailto:...)"
→ JSON valide mais valeurs non réalistes → assertions / logique serveur imprévisibles.
Taxonomie : fail_data (si le serveur rejette) ou fail_assertions.

Scénario payload énorme (10 000 URLs)
→ Peut être très lent voire rejeté ; 413 pas garanti par la spec Petstore.
Taxonomie : fail_assertions (si statut ≠ 413) ou timeouts.

C) ASSERTIONS / LOGIQUE

Inventaire /store/inventory :

* def keys = karate.keysOf(response)
* match each keys contains '#? ["available","pending","sold"].includes(_ )'
* match each response[*] == '#? _ >= 0'


→ contains + #? est mal employé ; et response[*] sur objet n’est pas la bonne façon de récupérer les valeurs.
Taxonomie : fail_assertions.

api_key sur /pet :

“Delete sans api_key → 400/401/403” : le serveur pourrait accepter sans clé → test fragile.
Taxonomie : fail_assertions.

“Unsupported media type (415)” / “Oversized (413)” : non garantis par la spec → peuvent échouer.
Taxonomie : fail_assertions.

D) SYNTAXE / CONSTRUCTION

Scénario “big payload” :

* def big = """ { ..., photoUrls: **PHOTO**, ... } """
* big.photoUrls = photoUrls


→ **PHOTO** n’est pas du JSON valide → risque d’erreur de parse.
Taxonomie : fail_syntax (parse JSON) ou fail_data.

Quelques expressions “for each …” ont été bien converties en match each, mais attends-toi à des ajustements nécessaires (ex. préférer match each response[*].status == ...).

Ce que tu fais maintenant (baseline = on garde tel quel)

Sauvegarde cette sortie dans
runs/2025-10-01__gpt5__v0_temp0.2_seed42/step2_features.md.

(Optionnel mais recommandé) Crée un fichier de notes à côté :
runs/2025-10-01__gpt5__v0_temp0.2_seed42/step2_notes.md
et liste-y les points à améliorer plus tard (reprends les bullets A–D ci-dessus).

On n’édite pas les features et on ne change pas les prompts pour cette baseline.

Passe à l’Étape 3 (toujours prompt TAIA tel quel). Donne au LLM toute la sortie Étape 2.
Il doit te livrer : arbo Maven, pom.xml, runner JUnit5, karate-config.js, toutes les .feature complètes.

Reproduis l’arbo fournie par l’LLM dans ton repo :
frameworks/karate/ (avec les sous-dossiers src/test/java/... et src/test/resources/...).

Exécute :

mvn -q -f frameworks\karate\pom.xml test


Note les résultats (Excel metrics_template_kereval.xlsx, onglet Runs) :

scenarios_total, scenarios_passed, scenarios_failed

répartis les échecs : fail_syntax, fail_dependencies, fail_assertions, fail_data

endpoints_tested vs endpoints_total (du Swagger)

C’est normal si cette baseline a beaucoup d’échecs (le but est de voir). On utilisera ces constats pour forger v1 (prompts plus stricts) et on mesurera le gain.