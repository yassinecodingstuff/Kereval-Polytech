prompt 2 [Modifié ==> J'ai dû adapter le prompt car l'IA générait des étapes dans le désordre, ce qui faisait échouer les tests Karate (ex: définir le chemin après l'envoi). J'ai ajouté une contrainte technique stricte pour forcer l'ordre d'exécution chronologique]:

our task now is to generate comprehensive Karate feature files based on the previously defined Gherkin-style API test cases. Requirements: Output must be precise, technically accurate, and production-ready.
Each feature file must have a clear, descriptive title and logically structured scenarios.
Implement a risk-based testing approach, prioritizing high-impact API functionality.
Crucial Technical Requirement for Karate Execution Order: Karate executes steps procedurally. To avoid execution failures (like 404 Not Found or 400 Bad Request due to misordering), you MUST strictly adhere to this sequence for every scenario:
1.	Preparation Phase (Given/And): Define ALL request components here: URL, path, query params, headers, and the request JSON body payload.
2.	Action Phase (When): This is the single trigger line containing the HTTP method (e.g., When method POST). Never place preparation steps after this line.
3.	Verification Phase (Then/And): Assertions on the status and matchers on the response body.
Follow best practices from the ISO/IEC/IEEE 29119 standards as guidance for quality, structure, and automation design:
Standard Focus Automation Relevance 29119-1 Concepts Foundational context for test activities 29119-2 Processes Embedding automation in structured workflows 29119-3 Documentation Structured, reusable, automation-friendly docs 29119-4 Techniques Criteria for what and how to automate 29119-5 Keyword-Driven Testing Framework-oriented automation design
Instructions: Do not include any commentary, explanation, or formatting outside of the Karate feature syntax.
Only return the Karate feature files, starting directly with the Feature: line.