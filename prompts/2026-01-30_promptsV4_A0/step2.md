Your task now is to generate comprehensive Karate feature files based on the previously defined Gherkin-style API test cases.
Requirements:
•	Output must be precise, technically accurate, and production-ready.
•	Each feature file must have a clear, descriptive title and logically structured scenarios.
•	Implement a risk-based testing approach, prioritizing high-impact API functionality.
•	Follow ISO/IEC/IEEE 29119 guidance (29119-1..5) for quality, structure, and automation design.
Karate guardrails (MUST follow exactly):
Status assertions:
•	Single expected code: Then status <code>
•	Multiple acceptable codes:
Then match [<codes>] contains responseStatus
or Then match responseStatus == '#? [<codes>].includes(_)'}
•	Never use match responseStatus in [...].
IDs & path parameters (precision):
•	Never emit unquoted large numbers (> 2^53-1) in path or JSON.
•	Always quote path IDs or use a string variable:
Given path '<resource>', '<id>' (examples should use small deterministic ids like 1001..1999 or string ids)
* def bigId = '9223372036854710002' then Given path '<resource>', bigId
•	Reuse the same ID across create/read/update/delete within a scenario.
Schema syntax (generic, OpenAPI-friendly):
•	All matchers must be single-quoted inside JSON: '#string', '#number', '#boolean', '#object', '#array', '#uuid'
•	Arrays of type: '#[] #string', '#[] #object' (exactly one space between #[] and the child type)
•	Optional fields: keep quoted with ## prefix, e.g., '##string', '##[] #object'
•	Predicates are quoted, e.g., '##? <boolean-expression>'
Error/4xx-5xx bodies (do NOT assume JSON):
•	When asserting errors, first detect body type and assert accordingly:
•	* def t = karate.typeOf(response)
•	* if (t == 'map') match response contains { message: '#string' }
•	* else match response == '#string'
•	If you don’t assert the body, assert only status (and optionally Content-Type).
Seed-before-read rule:
•	Any GET/PUT/DELETE that expects 200 MUST first create/seed the resource in the same scenario (or Background).
•	If seeding is not possible, make the assertion tolerant: Then match [200,404] contains responseStatus.
Optional arrays & empty collections (portable rule):
•	For optional arrays that may be empty, use '##[]' in the parent schema.
•	If the array is present and non-empty, validate element shape conditionally:
•	* def arr = response.<arrayField>
•	* if (arr != null && karate.sizeOf(arr) > 0)
•	  match each arr contains <itemsMinimalSchema>
•	Prefer match response contains deep <schemaMinimal> when the service may add fields not relevant to the test.
Content negotiation:
•	Set Accept / Content-Type per the test intent; when multiple media types are supported, assert via responseType or Content-Type and adapt checks (JSON vs XML vs text).
Determinism & stability:
•	Avoid unnecessary randomness; prefer small reusable IDs and stable data in Background.
•	Keep features self-contained (no callSingle to external scripts or custom JS); use only built-in helpers (e.g., karate.uuid() or java.util.UUID.randomUUID()).
General:
•	Start each file with Feature: and a Background: that sets:
•	* url baseUrl
•	* configure headers = { Accept: 'application/json' }
•	Organize features by resource/domain (e.g., per API tag), plus an optional common feature for contract/content-negotiation checks derived from the spec.
Output format:
•	Return only valid Karate feature syntax (no explanations, no markdown fences).
•	Start directly with the Feature: line for each file. Include all scenarios and examples.
•	Use Scenario Outline with ≥3 examples when it reduces duplication.

