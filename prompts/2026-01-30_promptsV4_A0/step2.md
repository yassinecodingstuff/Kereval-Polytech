Your task now is to generate comprehensive Karate feature files based on the previously defined Gherkin-style API test cases.
Requirements:
•	Output must be precise, technically accurate, and production-ready.
•	Each feature file must have a clear, descriptive title and logically structured scenarios.
•	Implement a risk-based testing approach, prioritizing high-impact API functionality.
•	Follow ISO/IEC/IEEE 29119 guidance (29119-1..5) for quality, structure, and automation design.

Conversion scope (NO DRIFT) :
• Convert 100% of Step 1 Gherkin scenarios into Karate scenarios.
• No additions, no deletions, no merges, no splitting of scenarios.
• Enforce a strict 1-to-1 mapping: each Karate scenario must match exactly one Step 1 scenario (same intent, same endpoint/method, same expected statuses).

Karate guardrails (MUST follow exactly):
Status assertions:
•	For a single expected code: Then status <code>
•	For multiple acceptable codes:
Then match [<codes>] contains responseStatus
or Then match responseStatus == '#? [<codes>].includes(_)'}
•	Never use match responseStatus in [...].
ID handling (precision):
•	Never emit unquoted large numbers (> 2^53-1) in path or JSON.
•	Always quote path IDs or use a string variable:
Given path 'pet', '<id>' (examples should use small ids like 1001..9999 or string ids)
* def bigId = '9223372036854710002' then Given path 'pet', bigId
•	Prefer small deterministic IDs; reuse the same ID for GET/PUT/DELETE.
Schema syntax:
•	All matchers must be single-quoted inside JSON: '#string', '#number', '#boolean', '#object', '#array', '#uuid'
•	Arrays of type: '#[] #string', '#[] #object' (exactly one space between #[] and the child)
•	Optional fields: keep quoted with ## prefix, e.g., '##string', '##[] #object'
•	Predicates: quoted as well, e.g., '##? allowedStatuses.includes(_)'}
Error/404 bodies (do NOT assume JSON):
•	When asserting errors (4xx/5xx), first detect the body type and assert accordingly, e.g.:
•	* def t = karate.typeOf(response)
•	* if (t == 'map') match response contains { message: '#string' }
•	* else match response == '#string'
•	If not asserting the body, assert only status (and optionally Content-Type).
Seed-before-read rule:
•	Any GET/PUT/DELETE that expects 200 MUST first create/seed the resource in the same scenario (or Background).
•	If seeding is not possible, make the assertion tolerant: Then match [200,404] contains responseStatus.
Assertions (STRICT + GraalVM-safe) :
 • Always validate the real response type (object vs array) before structural assertions.
* If array expected: use array matchers ('#[]', '#[] #object', '#[1]', etc.)
* If object expected: use object matches ({ ... })
  • Do NOT broaden acceptable status codes silently:
* If runtime status differs from Swagger/Step1 expectations, the test must flag it explicitly (no silent success).

Swagger is not absolute truth (TEST MUST SIGNAL MISMATCH) :
• Swagger describes intent, not guaranteed runtime behavior.
• If API behavior differs from Swagger:
* the test must explicitly signal it
* never treat it as a silent success

Scenario independence (AUTONOMOUS) :
• No scenario may depend on pre-existing data.
• Every resource (pet, order, user…) must be:

* created in the scenario, or
* created dynamically in Background (or a dedicated call within the same feature)
  • Prefer autonomous lifecycle patterns: CREATE → ACTION → VERIFY

Generate ONLY really supported HTTP methods :
• Generate scenarios only for methods actually supported by the endpoint.
• Never force PUT/PATCH/DELETE “for coverage”.

Dynamic data (ALLOWED) :
• Allowed dynamic data patterns:
* def timestamp = java.lang.System.currentTimeMillis()
* def randomId = Math.floor(Math.random() * 1000000)
* def uuid = java.util.UUID.randomUUID() + ''
  • Use built-in helpers only (e.g., karate.uuid() or java.util.UUID.randomUUID()).
  • Do not use karate.timestamp() and do not use external JS files.
  • Keep features self-contained (no callSingle to external scripts).

Auth patterns (ONLY if defined in Swagger/Step1) :
• API Key:

* header api_key = apiKey
  • Bearer Token:
* header Authorization = 'Bearer ' + authToken
  • Basic Auth:
* configure headers = { Authorization: 'Basic ' + authCredentials }
  • If auth is required but not automatable from inputs, mark as TODO (do not invent credentials).

General:
•	Start each file with Feature: and a Background: that sets:
•	* url baseUrl
•	* configure headers = { Accept: 'application/json' }
•	Use built-in helpers only (e.g., karate.uuid() or java.util.UUID.randomUUID()); do not use karate.timestamp() or external JS files.
•	Keep features self-contained (no callSingle to external scripts).
Output format:
•	Return only valid Karate feature syntax (no explanations, no markdown fences).
•	Start directly with the Feature: line for each file. Include all scenarios and examples.
