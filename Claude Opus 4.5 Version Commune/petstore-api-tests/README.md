# Petstore API Test Automation

A comprehensive API test automation project for the [Petstore API](https://petstore.swagger.io/) using the Karate Framework.

## Project Structure

```
petstore-api-tests/
├── pom.xml                                    # Maven configuration
├── README.md                                  # This file
└── src/
    └── test/
        ├── java/
        │   └── com/petstore/tests/
        │       └── TestRunner.java            # JUnit 5 test runner
        └── resources/
            ├── karate-config.js               # Karate configuration
            ├── logback-test.xml               # Logging configuration
            ├── features/
            │   ├── pet/
            │   │   └── pet-crud.feature       # Pet API tests
            │   ├── store/
            │   │   └── store.feature          # Store/Order API tests
            │   ├── user/
            │   │   └── user.feature           # User API tests
            │   └── common/
            │       └── contract-security.feature  # Contract & security tests
            └── img/
                ├── test-image.jpg             # Test image for uploads
                └── test-image.png             # Test image for uploads
```

## Prerequisites

- Java 11 or higher
- Maven 3.6 or higher
- IntelliJ IDEA (recommended) or any Java IDE

## Quick Start

### 1. Import into IntelliJ IDEA

1. Open IntelliJ IDEA
2. File → Open → Select the `petstore-api-tests` folder
3. IntelliJ will automatically detect the Maven project
4. Wait for dependencies to download

### 2. Run All Tests

```bash
mvn clean test
```

### 3. Run Tests by Tag

```bash
# Run smoke tests only
mvn test -Dkarate.options="--tags @smoke"

# Run critical tests
mvn test -Dkarate.options="--tags @critical"

# Run high priority tests
mvn test -Dkarate.options="--tags @high"

# Run pet API tests
mvn test -Dkarate.options="--tags @pet"

# Run store API tests
mvn test -Dkarate.options="--tags @store"

# Run user API tests
mvn test -Dkarate.options="--tags @user"

# Run security tests
mvn test -Dkarate.options="--tags @security"
```

### 4. Run Tests by Environment

```bash
# Development (default)
mvn test -Dkarate.env=dev

# Staging
mvn test -Dkarate.env=staging

# Production
mvn test -Dkarate.env=prod
```

### 5. Run Using Maven Profiles

```bash
# Run smoke tests
mvn test -Psmoke

# Run critical tests
mvn test -Pcritical
```

## Test Reports

After test execution, reports are generated in:

- **HTML Report**: `target/karate-reports/karate-summary.html`
- **JUnit XML**: `target/surefire-reports/`
- **Log File**: `target/karate.log`

## Test Categories

| Tag | Description |
|-----|-------------|
| `@critical` | Critical business functionality |
| `@high` | High priority tests |
| `@medium` | Medium priority tests |
| `@smoke` | Quick sanity checks |
| `@pet` | Pet API tests |
| `@store` | Store/Order API tests |
| `@user` | User API tests |
| `@security` | Security tests |
| `@contract` | Contract/Schema validation |
| `@negative` | Negative test cases |

## Features Covered

### Pet API (`/pet`)
- Create, Read, Update, Delete pets
- Find pets by status
- Find pets by tags (deprecated)
- Upload pet images
- Schema validation
- Data consistency tests

### Store API (`/store`)
- Get inventory
- Place orders
- Get order by ID
- Delete orders
- Order schema validation

### User API (`/user`)
- Create single user
- Create users in bulk (array/list)
- Get user by username
- Update user
- Delete user
- User login/logout
- Authentication tests

### Security & Contract
- API key authentication
- Authorization scopes
- Input validation (SQL injection, XSS)
- Boundary value testing
- Content negotiation (JSON/XML)
- Response time validation
- HTTPS enforcement
- Swagger contract validation

## Configuration

### karate-config.js

The configuration file sets:
- Base URL based on environment
- Connection and read timeouts (30 seconds)
- SSL configuration
- Retry settings (3 retries, 1 second interval)

### Environment URLs

| Environment | URL |
|-------------|-----|
| dev | https://petstore.swagger.io/v2 |
| staging | https://petstore.swagger.io/v2 |
| prod | https://petstore.swagger.io/v2 |

## Best Practices Applied

1. **Seed-before-read**: All GET/PUT/DELETE tests create resources first
2. **Tolerant assertions**: Multiple acceptable status codes where appropriate
3. **ID handling**: Small deterministic IDs, string path parameters
4. **Schema validation**: Single-quoted matchers, proper array syntax
5. **Error handling**: Type detection before body assertions
6. **Self-contained tests**: No external scripts or dependencies

## Troubleshooting

### Tests fail with connection timeout
Increase timeout in `karate-config.js`:
```javascript
karate.configure('connectTimeout', 60000);
karate.configure('readTimeout', 60000);
```

### Image upload tests fail
Ensure test images exist in `src/test/resources/img/`

### SSL certificate errors
SSL is enabled by default. For self-signed certificates:
```javascript
karate.configure('ssl', { trustAll: true });
```

## License

This project is provided for educational and testing purposes.
