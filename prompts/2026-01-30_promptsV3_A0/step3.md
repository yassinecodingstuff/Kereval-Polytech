Your task now is to generate a complete, production-ready API test automation project using Karate, based on the previously defined Karate feature files.
Requirements:
•	Output must be technically accurate, precise, and immediately executable.
•	Structure the project to Maven standards for IntelliJ IDEA.
•	Include:
o	pom.xml with karate-junit5, gherkin, cucumber-java, and maven-surefire-plugin (configured to run Karate tests).
o	Folder hierarchy: src/test/java, src/test/resources.
o	karate-config.js (sets baseUrl per env).
o	JUnit 5 runner at src/test/java/.../TestRunner.java.
o	Feature files organized by domain: features/pet, features/store, features/user, and a features/common/contract-security.feature.
o	Test assets (tiny images under src/test/resources/img for multipart tests).
Karate guardrails (MUST follow exactly):
Status assertions:
•	Single expected code: Then status <code>
•	Multiple acceptable codes: Then match [<codes>] contains responseStatus
or Then match responseStatus == '#? [<codes>].includes(_)'}
•	Never use match responseStatus in [...].
ID handling (precision & stability):
•	Quote path IDs or use string variables: Given path 'pet', '<id>'.
•	Prefer small deterministic IDs (e.g., 1001..1999). If a large ID is required, keep it as a string variable.
•	Reuse the same ID across create/read/update/delete steps.
Schema syntax:
•	All matchers must be single-quoted inside JSON: '#string', '#number', '#boolean', '#object', '#array', '#uuid'
•	Arrays of type: '#[] #string', '#[] #object' (exactly one space).
•	Optional fields: '##string', '##[] #object'
•	Predicates: quoted, e.g., '##? allowedStatuses.includes(_)'.
Error/404 bodies (do NOT assume JSON):
•	Error endpoints may return plain text. When asserting the body, detect type first:
•	* def t = karate.typeOf(response)
•	* if (t == 'map') match response contains { message: '#string' }
•	* else match response == '#string'
•	If you don’t assert the body, assert only status (and optionally Content-Type).
Seed-before-read rule:
•	Any GET/PUT/DELETE that expects 200 MUST first create/seed the resource in the same scenario (or Background).
•	If seeding is not possible, make the assertion tolerant: Then match [200,404] contains responseStatus.
General feature conventions:
•	Each feature starts with Feature: and a Background: that sets:
•	* url baseUrl
•	* configure headers = { Accept: 'application/json' }
•	Keep features self-contained (no external scripts or callSingle to custom JS).
•	Use built-in helpers only (e.g., java.util.UUID.randomUUID()); do not use unsupported helpers like karate.timestamp().
Project specifics to generate:
•	pom.xml:
o	Java 11+.
o	karate-junit5 dependency.
o	io.cucumber:gherkin and io.cucumber:cucumber-java as test-scope.
o	Surefire includes: **/*Test.java, **/*Tests.java, **/*TestRunner.java.
•	karate-config.js: returns config.baseUrl from env (dev default https://petstore.swagger.io/v2) and sets reasonable timeouts.
•	TestRunner.java: JUnit 5 runner executing classpath:features.
•	Feature files:
o	features/pet/pet-crud.feature (CRUD + search).
o	features/store/store.feature (orders + inventory).
o	features/user/user.feature (accounts + auth).
o	features/common/contract-security.feature (Swagger contract checks, content negotiation).
•	Include tiny placeholder images for multipart upload tests in src/test/resources/img/.
Self-check before returning:
•	No match responseStatus in [...]
•	No unquoted matchers (#string, #[] #object, etc. must be single-quoted)
•	No large numeric IDs unquoted in path/JSON
•	No external scripts/helpers; features are self-contained
Output:
•	Return only the full project deliverables (folder structure, source, and configs).
•	Generate a downloadable ZIP archive of the complete project, ready to import as a Maven project in IntelliJ IDEA.
•	Do not include any commentary, explanation, or extra text outside the deliverables.

