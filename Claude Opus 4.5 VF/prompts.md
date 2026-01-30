## Prompt_1-----------------------------------------------------------------

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

## Prompt_2-----------------------------------------------------------------

Your task now is to generate comprehensive Karate feature files based on the previously defined Gherkin-style API test cases.
Requirements:
Output must be precise, technically accurate, and production-ready.

Each feature file must have a clear, descriptive title and logically structured scenarios.

Implement a risk-based testing approach, prioritizing high-impact API functionality.

Follow best practices from the ISO/IEC/IEEE 29119 standards as guidance for quality, structure, and automation design:

Standard Focus Automation Relevance
29119-1 Concepts Foundational context for test activities
29119-2 Processes Embedding automation in structured workflows
29119-3 Documentation Structured, reusable, automation-friendly docs
29119-4 Techniques Criteria for what and how to automate
29119-5 Keyword-Driven Testing Framework-oriented automation design

Instructions:
Do not include any commentary, explanation, or formatting outside of the Karate feature syntax.

Only return the Karate feature files, starting directly with the Feature: line.

## Prompt_3 ----------------------------------------------------------------

Generate a production-ready Maven pom.xml for a Karate API test automation project with the following specifications:

Project Coordinates:

- groupId: com.petstore.api
- artifactId: petstore-karate-tests
- version: 1.0.0
- packaging: jar
- Java version: 11

Required Dependencies (with these exact versions defined in properties):

- com.intuit.karate:karate-junit5:1.4.1
- com.intuit.karate:karate-core:1.4.1
- org.junit.jupiter:junit-jupiter-api:5.10.1
- org.junit.jupiter:junit-jupiter-engine:5.10.1
- org.junit.jupiter:junit-jupiter-params:5.10.1
- io.cucumber:gherkin:26.2.0
- io.cucumber:cucumber-java:7.14.0
- io.cucumber:cucumber-junit-platform-engine:7.14.0
- org.slf4j:slf4j-api:2.0.9
- ch.qos.logback:logback-classic:1.4.11
- com.fasterxml.jackson.core:jackson-databind:2.15.3
- org.apache.commons:commons-lang3:3.13.0

Required Plugins (with these exact versions):

- maven-compiler-plugin:3.11.0 (source/target Java 11, UTF-8 encoding)
- maven-resources-plugin:3.3.1 (UTF-8 encoding)
- maven-surefire-plugin:3.0.0-M9 (configured to run *Runner.java, *Test.java, exclude \*IT.java)
- maven-failsafe-plugin:3.0.0-M9 (configured for \*IT.java, bound to integration-test and verify phases)

Test Resources Configuration:

- Include feature files from src/test/java (exclude \*.java)
- Include src/test/resources

Properties to Define:

- karate.env (default: dev)
- karate.options (default: empty)
- test.parallel.threads (default: 5)

Maven Profiles:

- Environment profiles: dev, staging, prod (sets karate.env)
- Tag profiles: smoke, critical, high, security, pet, store, user (sets karate.options with --tags @tagname)
- default profile (activeByDefault)

System Properties passed to Surefire:

- karate.env=${karate.env}
- karate.options=${karate.options}

Output only the complete pom.xml file, no commentary.

## Prompt_4 ----------------------------------------------------------------

Your task now is to generate a complete, production-ready API test automation project using Karate, based on the previously defined Karate feature files and the pom.xml generated in the previous step.

Requirements:

- Output must be technically accurate, precise, and immediately executable.
- Structure the project according to Maven standards for seamless integration with IntelliJ IDEA.
- Use the pom.xml exactly as generated in the previous step, do not modify it.
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
