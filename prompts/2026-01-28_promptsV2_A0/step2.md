Your task now is to generate comprehensive Karate feature files based on the previously defined Gherkin-style API test cases.
Requirements :
•	Output must be precise, technically accurate, and production-ready.
•	Each feature file must have a clear, descriptive title and logically structured scenarios.
•	Implement a risk-based testing approach, prioritizing high-impact API functionality.
•	Follow ISO/IEC/IEEE 29119 guidance (29119-1..5) for quality, structure, and automation design.
Karate guardrails (MUST follow exactly) :
Status assertions :
•	For a single expected code: Then status <code>
•	For multiple acceptable codes:
Then match [<codes>] contains responseStatus
(or) Then match responseStatus == '#? [<codes>].includes(_)'\)
•	Never use match responseStatus in [...].
ID handling (precision) :
•	Never emit unquoted large numbers (> 2^53-1) in path or JSON.
•	Always quote path IDs or use a string variable:
Given path 'pet', '<id>' (examples must set <id> small like 1001..9999 or as strings)
* def bigId = '9223372036854710002' then Given path 'pet', bigId
•	Prefer small deterministic IDs for test data; reuse the same ID for GET/PUT/DELETE.
Schema syntax :
•	All matchers must be single-quoted inside JSON:
'#string', '#number', '#boolean', '#object', '#array', '#uuid'
•	Arrays of type: '#[] #string', '#[] #object' (single space between #[] and child)
•	Optional fields: prefix with ## and keep quoted: '##string', '##[] #object'
•	Predicates: '#? <expression>' (also quoted), e.g. '##? allowedStatuses.includes(_)'
General :
•	Start each file with Feature: and use a Background: that sets:
•	* url baseUrl
•	* configure headers = { Accept: 'application/json' }
•	Use built-in helpers only (e.g., karate.uuid() or java.util.UUID.randomUUID()); do not use karate.timestamp() or external JS files.
•	Keep features self-contained (no callSingle to external scripts).
•	Organize features by domain: pet, store, user, plus a contract/security file for Swagger contract checks and content negotiation.
Output format :
•	Return only valid Karate feature syntax (no explanations, no markdown fences).
•	Start directly with the Feature: line for each file. Include all scenarios and examples
