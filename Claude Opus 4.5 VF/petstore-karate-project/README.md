# Petstore API Karate Test Automation Project

A comprehensive, production-ready API test automation suite for the Petstore API using the Karate framework.

## Project Structure

```
petstore-karate-tests/
├── pom.xml                                    # Maven configuration
├── README.md                                  # This file
└── src/
    └── test/
        ├── java/
        │   ├── karate-config.js               # Karate configuration
        │   └── com/
        │       └── petstore/
        │           └── api/
        │               ├── runners/           # JUnit 5 test runners
        │               │   ├── TestRunner.java
        │               │   ├── PetRunner.java
        │               │   ├── StoreRunner.java
        │               │   └── UserRunner.java
        │               ├── helpers/           # Reusable helper features
        │               │   ├── api-helpers.feature
        │               │   └── generators.feature
        │               ├── pet/               # Pet API tests
        │               │   ├── pet-create.feature
        │               │   ├── pet-read.feature
        │               │   ├── pet-update.feature
        │               │   ├── pet-delete.feature
        │               │   └── pet-upload.feature
        │               ├── store/             # Store API tests
        │               │   ├── store-inventory.feature
        │               │   └── store-order.feature
        │               ├── user/              # User API tests
        │               │   ├── user-create.feature
        │               │   ├── user-auth.feature
        │               │   └── user-crud.feature
        │               └── common/            # Cross-cutting & E2E tests
        │                   ├── cross-cutting.feature
        │                   ├── e2e-workflows.feature
        │                   └── regression-suite.feature
        └── resources/
            ├── logback-test.xml               # Logging configuration
            ├── data/                          # Test data files
            │   ├── test-pets.json
            │   ├── test-users.json
            │   └── test-orders.json
            └── schemas/                       # JSON schemas
                ├── pet-schema.json
                ├── order-schema.json
                └── user-schema.json
```

## Prerequisites

- Java 11 or higher
- Maven 3.6 or higher
- IntelliJ IDEA (recommended) or any Java IDE

## Quick Start

### Import into IntelliJ IDEA

1. Open IntelliJ IDEA
2. Select `File > Open`
3. Navigate to the project directory and select `pom.xml`
4. Click `Open as Project`
5. Wait for Maven to download dependencies

### Run Tests

#### Run All Tests
```bash
mvn test
```

#### Run Specific Test Suites
```bash
# Run Pet API tests only
mvn test -Dtest=PetRunner

# Run Store API tests only
mvn test -Dtest=StoreRunner

# Run User API tests only
mvn test -Dtest=UserRunner

# Run all tests via TestRunner
mvn test -Dtest=TestRunner
```

#### Run Tests by Tags
```bash
# Run smoke tests
mvn test -Psmoke

# Run critical tests
mvn test -Pcritical

# Run security tests
mvn test -Psecurity

# Run specific tag via command line
mvn test -Dkarate.options="--tags @smoke"

# Run multiple tags
mvn test -Dkarate.options="--tags @critical,@smoke"

# Exclude tags
mvn test -Dkarate.options="--tags ~@negative"
```

#### Run Tests by Environment
```bash
# Development environment (default)
mvn test -Pdev

# Staging environment
mvn test -Pstaging

# Production environment
mvn test -Pprod
```

#### Combine Profiles
```bash
# Run smoke tests on staging
mvn test -Pstaging,smoke

# Run critical tests on production
mvn test -Pprod,critical
```

## Test Tags

| Tag | Description |
|-----|-------------|
| `@smoke` | Quick health check tests |
| `@critical` | Business-critical functionality |
| `@negative` | Negative/error case tests |
| `@security` | Security-related tests |
| `@performance` | Performance validation tests |
| `@e2e` | End-to-end workflow tests |
| `@regression` | Full regression suite |
| `@pet` | Pet API tests |
| `@store` | Store API tests |
| `@user` | User API tests |
| `@create` | Create operation tests |
| `@read` | Read operation tests |
| `@update` | Update operation tests |
| `@delete` | Delete operation tests |
| `@boundary` | Boundary value tests |
| `@validation` | Input validation tests |

## Configuration

### Environment Configuration

The `karate-config.js` file contains environment-specific settings:

- **dev**: Development environment (default)
- **staging**: Staging environment
- **prod**: Production environment

### Timeout Settings

```javascript
connectTimeout: 10000,  // Connection timeout in milliseconds
readTimeout: 30000      // Read timeout in milliseconds
```

## Reports

After test execution, reports are generated in:

- **HTML Report**: `target/karate-reports/karate-summary.html`
- **JUnit XML**: `target/surefire-reports/`
- **Cucumber JSON**: `target/karate-reports/`
- **Logs**: `target/logs/karate.log`

## Test Design Standards

This project follows ISO/IEC/IEEE 29119 software testing standards:

- **29119-1**: Test concepts and definitions
- **29119-2**: Test processes and workflows
- **29119-3**: Test documentation structure
- **29119-4**: Test design techniques
- **29119-5**: Keyword-driven testing approach

## Risk-Based Testing Approach

Tests are prioritized based on:

1. **Critical** - Core business functionality (authentication, orders)
2. **High** - Important features (CRUD operations)
3. **Medium** - Supporting features (search, filtering)
4. **Low** - Edge cases and boundary conditions

## Parallel Execution

Tests support parallel execution with configurable thread count:

```bash
# Run with custom thread count
mvn test -Dtest.parallel.threads=10
```

## Troubleshooting

### Common Issues

1. **Connection timeout**: Increase timeout in `karate-config.js`
2. **Test failures on CI**: Ensure proper network access to API
3. **SSL errors**: SSL is enabled by default; verify certificates

### Debug Mode

Enable debug logging:
```bash
mvn test -Dkarate.options="--tags @smoke" -X
```

## Contributing

1. Follow existing code style and structure
2. Add appropriate tags to new tests
3. Update documentation for new features
4. Run full regression before submitting changes

## License

This project is for testing purposes only.
