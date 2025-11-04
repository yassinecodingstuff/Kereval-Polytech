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

