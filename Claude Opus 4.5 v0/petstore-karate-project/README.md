# Petstore API Karate Test Automation Project

## Overview

Production-ready API test automation project for the Petstore Swagger API (v1.0.7) using the Karate framework. This project is designed following **ISO/IEC/IEEE 29119** Software Testing Standards with a comprehensive risk-based testing approach.

## Features

- **Karate Framework** - BDD-style API testing with native JSON/XML support
- **JUnit 5 Integration** - Modern test execution and reporting
- **Maven Build** - Standard project structure for IntelliJ IDEA
- **Risk-Based Testing** - Prioritized test coverage for critical functionality
- **ISO/IEC/IEEE 29119 Compliance** - Structured documentation and processes

## Test Coverage Summary

| Feature Area | Test Count | Priority |
|--------------|------------|----------|
| Pet Management (POST) | 17 | Critical |
| Pet Management (PUT) | 10 | Critical |
| Pet Management (GET) | 17 | Critical |
| Pet Management (DELETE/Form) | 12 | High |
| Store Operations | 26 | High |
| User Management | 21 | High |
| Security Testing | 17 | Critical |
| Schema Validation | 14 | High |
| Error Handling | 20 | Medium |
| Performance Testing | 14 | Medium |
| Integration Testing | 8 | Medium |
| Content Negotiation | 15 | Low |

**Total Test Scenarios: ~190**

## Project Structure

```
petstore-karate-project/
├── pom.xml                                    # Maven configuration
├── README.md                                  # This file
└── src/
    └── test/
        ├── java/
        │   ├── karate-config.js               # Karate configuration
        │   └── petstore/
        │       ├── TestRunner.java            # JUnit 5 test runner
        │       ├── common/
        │       │   ├── common-utils.feature   # Shared utilities
        │       │   ├── pet-helpers.feature    # Pet API helpers
        │       │   ├── store-helpers.feature  # Store API helpers
        │       │   └── user-helpers.feature   # User API helpers
        │       └── tests/
        │           ├── pet/
        │           │   ├── pet-post.feature
        │           │   ├── pet-put.feature
        │           │   ├── pet-get.feature
        │           │   └── pet-delete-form.feature
        │           ├── store/
        │           │   └── store-operations.feature
        │           ├── user/
        │           │   └── user-management.feature
        │           ├── security/
        │           │   └── security-tests.feature
        │           ├── contract/
        │           │   └── schema-validation.feature
        │           ├── error/
        │           │   └── error-handling.feature
        │           ├── performance/
        │           │   └── performance-tests.feature
        │           ├── integration/
        │           │   └── integration-tests.feature
        │           └── content/
        │               └── content-negotiation.feature
        └── resources/
            ├── logback-test.xml               # Logging configuration
            └── test-data/
                └── test-image.txt             # Test data placeholder
```

## Prerequisites

- **Java 11** or higher
- **Maven 3.6** or higher
- **IntelliJ IDEA** (recommended) or any Java IDE
- Internet connectivity to access https://petstore.swagger.io/v2

## Quick Start

### 1. Import into IntelliJ IDEA

1. Open IntelliJ IDEA
2. File → Open → Select the project folder
3. Import as Maven project
4. Wait for dependencies to download

### 2. Run All Tests

```bash
mvn clean test
```

### 3. Run Smoke Tests

```bash
mvn test -Psmoke
```

### 4. View Reports

After test execution, reports are available at:
- **HTML Report**: `target/karate-reports/karate-summary.html`
- **JUnit Report**: `target/surefire-reports/`
- **Logs**: `target/logs/karate-tests.log`

## Running Tests

### By Profile

```bash
# Smoke tests (quick validation)
mvn test -Psmoke

# Critical path tests
mvn test -Pcritical

# High priority tests
mvn test -Phigh

# Security tests
mvn test -Psecurity

# Performance tests
mvn test -Pperformance

# Integration tests
mvn test -Pintegration

# Contract/Schema tests
mvn test -Pcontract

# Pet API tests
mvn test -Ppet

# Store API tests
mvn test -Pstore

# User API tests
mvn test -Puser

# Positive scenarios only
mvn test -Ppositive

# Negative scenarios only
mvn test -Pnegative

# CI/CD pipeline (smoke + critical, parallel)
mvn test -Pci

# Parallel execution
mvn test -Pparallel
```

### By Tags

```bash
# Single tag
mvn test -Dkarate.options="--tags @smoke"

# Multiple tags (AND condition)
mvn test -Dkarate.options="--tags @critical --tags @positive"

# Multiple tags (OR condition)
mvn test -Dkarate.options="--tags @smoke,@critical"

# Exclude tags
mvn test -Dkarate.options="--tags ~@low"

# Combine include and exclude
mvn test -Dkarate.options="--tags @pet --tags ~@negative"
```

### By Feature File

```bash
# Single feature
mvn test -Dkarate.options="classpath:petstore/tests/pet/pet-post.feature"

# Multiple features
mvn test -Dkarate.options="classpath:petstore/tests/pet/pet-post.feature classpath:petstore/tests/pet/pet-get.feature"
```

### By Environment

```bash
# Development (default)
mvn test -Dkarate.env=dev

# Staging
mvn test -Dkarate.env=staging

# Production
mvn test -Dkarate.env=prod
```

## Test Tags Reference

### Priority Tags
| Tag | Description |
|-----|-------------|
| `@critical` | Must pass for release - highest priority |
| `@high` | Important functionality |
| `@medium` | Standard coverage |
| `@low` | Nice to have |

### Type Tags
| Tag | Description |
|-----|-------------|
| `@smoke` | Quick validation tests |
| `@positive` | Happy path scenarios |
| `@negative` | Error/edge cases |
| `@security` | Security and vulnerability tests |
| `@performance` | Performance and response time tests |
| `@integration` | End-to-end integration tests |
| `@contract` | Schema/contract validation |

### HTTP Method Tags
| Tag | Description |
|-----|-------------|
| `@GET` | GET request tests |
| `@POST` | POST request tests |
| `@PUT` | PUT request tests |
| `@DELETE` | DELETE request tests |

### Resource Tags
| Tag | Description |
|-----|-------------|
| `@pet` | Pet API tests |
| `@store` | Store API tests |
| `@order` | Order-related tests |
| `@user` | User API tests |
| `@inventory` | Inventory tests |

### Specific Test Tags
| Tag | Description |
|-----|-------------|
| `@validation` | Input validation tests |
| `@boundary` | Boundary value tests |
| `@datatype` | Data type validation |
| `@injection` | Injection attack tests |
| `@xss` | XSS vulnerability tests |
| `@auth` | Authentication tests |
| `@oauth2` | OAuth2 specific tests |
| `@apikey` | API key tests |
| `@schema` | Schema validation |
| `@crud` | CRUD operation tests |
| `@idempotency` | Idempotency tests |
| `@e2e` | End-to-end workflows |

## Configuration

### karate-config.js

The main configuration file located at `src/test/java/karate-config.js` contains:

- **Environment Settings**: Base URLs for different environments
- **Timeout Configuration**: Connect and read timeouts
- **Retry Settings**: Automatic retry for failed requests
- **Schema Definitions**: Response schemas for validation
- **Utility Functions**: Helper functions for test data generation

### Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `karate.env` | Environment selector | dev |
| `baseUrl` | API base URL | https://petstore.swagger.io/v2 |
| `apiKey` | API authentication key | special-key |

## ISO/IEC/IEEE 29119 Compliance

This project aligns with the ISO/IEC/IEEE 29119 Software Testing Standards:

| Standard | Focus | Implementation |
|----------|-------|----------------|
| **29119-1** | Concepts | Risk-based test prioritization with critical path coverage |
| **29119-2** | Processes | Structured test workflows and Maven profiles |
| **29119-3** | Documentation | Comprehensive feature file documentation |
| **29119-4** | Techniques | Boundary, equivalence, error guessing techniques |
| **29119-5** | Keyword-Driven | Reusable scenarios and utility functions |

## Best Practices

1. **Test Data Isolation** - Each test generates unique IDs to prevent conflicts
2. **Cleanup** - Tests clean up created resources after execution
3. **Schema Validation** - Response schemas are validated against OpenAPI spec
4. **Error Handling** - Comprehensive negative testing for edge cases
5. **Performance Awareness** - Response time assertions included
6. **Security Coverage** - Injection, XSS, and authentication tests
7. **Reusability** - Common utilities and helper features

## Troubleshooting

### Common Issues

1. **Tests not found**
   - Ensure feature files are in `src/test/java` directory
   - Check that `testResources` is configured in pom.xml

2. **Connection timeout**
   - Verify internet connectivity
   - Check if API endpoint is accessible

3. **Authentication errors**
   - Verify API key in karate-config.js
   - Check OAuth2 configuration if applicable

### Debugging

Enable debug logging:
```bash
mvn test -Dkarate.options="--tags @smoke" -Dlogback.configurationFile=logback-debug.xml
```

## Contributing

1. Follow existing naming conventions
2. Add appropriate tags to new scenarios
3. Include cleanup steps for created resources
4. Update README for significant changes
5. Run smoke tests before committing

## License

Apache 2.0
