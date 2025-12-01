prompt 1 : 

Ignore all previous instructions.
You are a world-class test automation engineer with over 25 years of hands-on experience.
Your task is to write comprehensive API test cases in Gherkin syntax, based on the Swagger specification located at:
https://petstore.swagger.io/v2/swagger.json
Requirements:
Be precise, thorough, and technically accurate.

Every test case must have a clear and descriptive title.

Test cases should reflect a risk-based approach, prioritizing high-impact functionality.

Apply the guidance from the following ISO/IEC/IEEE software testing standards:

Standard Focus Automation Relevance
29119-1 Concepts Foundational context for test activities
29119-2 Processes Embedding automation in structured workflows
29119-3 Documentation Structured, reusable, automation-friendly docs
29119-4 Techniques Criteria for what and how to automate
29119-5 Keyword-Driven Testing Framework-oriented automation design

Do not include any introductory or concluding comments. Just return the Gherkin test cases with titles.

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

prompt 3:

Your task now is to generate a complete, production-ready API test automation project using Karate, based on the previously defined Karate feature files.
Requirements:
- Output must be technically accurate, precise, and immediately executable.
- Structure the project according to Maven standards for seamless integration with IntelliJ IDEA.
- Include a fully configured pom.xml with all required dependencies and plugins, including:
	- karate-junit5
	- gherkin
	- cucumber-java
	- maven-surefire-plugin (configured to run Karate tests)
- Ensure the project includes:
	- Proper folder hierarchy (src/test/java, src/test/resources)
	- A karate-config.js for environment setup
	- A JUnit 5 test runner (TestRunner.java)
	- All feature files organized by domain (e.g., pet, store, user)

Testing Strategy:

- Apply a risk-based testing approach:
	- Prioritize test coverage for high-impact and business-critical API functionalities.
- Design tests and structure the framework based on the ISO/IEC/IEEE 29119 software testing standards:
	- 29119-1: Ensure test coverage is driven by core testing concepts and risk assessment.
	- 29119-2: Integrate automation into structured test processes.
	- 29119-3: Produce reusable, maintainable, and structured documentation (feature files).
	- 29119-4: Apply rigorous, standards-based test design techniques.
	- 29119-5: Use keyword-driven principles to support scalable and modular automation.

Output Instructions:
- Return only the full Karate test automation project:
	- Folder structure
	- Source code and test assets
	- Configuration files
- Generate a downloadable ZIP archive of the complete project, ready to be imported into IntelliJ IDEA as a Maven project.

Do not include any commentary, explanation, or extra text outside the deliverables.
