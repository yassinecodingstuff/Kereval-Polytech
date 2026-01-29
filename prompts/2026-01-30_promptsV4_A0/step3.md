Your task now is to generate a complete, production-ready Karate API test automation project, based on the previously defined Karate feature files.
Requirements:
•	Output must be technically accurate, precise, and immediately executable.
•	Structure the project to Maven standards for IntelliJ IDEA.
•	Include:
o	pom.xml with karate-junit5, gherkin, cucumber-java, and maven-surefire-plugin (configured to run Karate tests).
o	Folder hierarchy: src/test/java, src/test/resources.
o	karate-config.js (sets baseUrl per env; default from the OpenAPI server if available, else from BASE_URL env or http://localhost:8080).
o	JUnit 5 runner at src/test/java/.../TestRunner.java.
o	Feature files organized by API tags / resources from the OpenAPI spec (e.g., features/<tag>/...), plus a features/common/contract-content.feature for contract & content-negotiation checks.
o	Test assets (tiny images under src/test/resources/img for multipart tests).
Karate guardrails (MUST follow exactly):
Status assertions:
•	Single expected code: Then status <code>
•	Multiple acceptable codes: Then match [<codes>] contains responseStatus or
Then match responseStatus == '#? [<codes>].includes(_)'}
•	Never use match responseStatus in [...]. (See Karate response variables.) 
IDs & path parameters (precision & stability):
•	Quote path IDs or use string variables: Given path '<resource>', '<id>'.
•	Prefer small deterministic IDs (e.g., 1001..1999). If a large ID is required, keep it as a string variable.
•	Reuse the same ID across create/read/update/delete steps.
Schema syntax (portable, OpenAPI-friendly):
•	All matchers must be single-quoted inside JSON: '#string', '#number', '#boolean', '#object', '#array', '#uuid'. 
•	Arrays of type: '#[] #string', '#[] #object' (exactly one space).
•	Optional fields: '##string', '##[] #object'.
•	Predicates: quoted, e.g., '##? <boolean-expression>'.
Error/4xx-5xx bodies (do NOT assume JSON):
•	Error endpoints may return plain text. When asserting the body, detect type first:
•	* def t = karate.typeOf(response)
•	* if (t == 'map') match response contains { message: '#string' }
•	* else match response == '#string'
(Use karate.typeOf, response, and responseStatus.) 
•	If you don’t assert the body, assert only status (and optionally Content-Type / responseType). 
Seed-before-read rule:
•	Any GET/PUT/DELETE that expects 200 MUST first create/seed the resource in the same scenario (or Background).
•	If seeding is not possible, make the assertion tolerant: Then match [200,404] contains responseStatus.
Optional arrays & empty collections (portable rule):
•	For optional arrays that may be empty, use '##[]' in the parent schema.
•	If the array is present and non-empty, validate items conditionally:
•	* def arr = response.<arrayField>
•	* if (arr != null && karate.sizeOf(arr) > 0)
•	  match each arr contains <itemsMinimalSchema>
Content negotiation:
•	Set Accept / Content-Type per the spec and scenario. When multiple media types are supported, assert via responseType or Content-Type and adapt checks (JSON vs XML vs text). 
General feature conventions:
•	Each feature starts with Feature: and a Background: that sets:
•	* url baseUrl
•	* configure headers = { Accept: 'application/json' }
(Use Background to apply headers to all scenarios.) 
•	Keep features self-contained (no external scripts or callSingle to custom JS).
•	Use built-in helpers only (e.g., java.util.UUID.randomUUID()).
Project specifics to generate:
•	pom.xml:
o	Java 11+.
o	karate-junit5 dependency.
o	io.cucumber:gherkin and io.cucumber:cucumber-java as test-scope.
o	Surefire includes: **/*Test.java, **/*Tests.java, **/*TestRunner.java.
•	karate-config.js: returns config.baseUrl from env (and sets reasonable timeouts).
•	TestRunner.java: JUnit 5 runner executing classpath:features.
•	Feature files:
o	One folder per API tag / resource under src/test/resources/features/<tag>/....
o	features/common/contract-content.feature to fetch the OpenAPI document and verify key enums/required fields + JSON/XML content negotiation.
•	Include tiny placeholder images for multipart upload tests in src/test/resources/img/.
Optional coverage target:
•	Produce at least: 15 scenarios for the largest tag/resource group, 10 each for the next two, and 5 common (contract/content). Use Scenario Outline with ≥3 examples when it reduces duplication.
Self-check before returning:
•	No match responseStatus in [...]
•	No unquoted matchers (#string, #[] #object, etc. must be single-quoted) 
•	No large numeric IDs unquoted in path/JSON
•	No external scripts/helpers; features are self-contained
•	Background sets url and default headers for each file 
Output:
•	Return only the full project deliverables (folder structure, source, and configs).
•	Generate a downloadable ZIP archive of the complete project, ready to import as a Maven project in IntelliJ IDEA.
•	Do not include any commentary, explanation, or extra text outside the deliverables.
