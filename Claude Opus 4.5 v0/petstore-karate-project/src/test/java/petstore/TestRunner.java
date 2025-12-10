package petstore;

import com.intuit.karate.junit5.Karate;
import com.intuit.karate.Results;
import com.intuit.karate.Runner;
import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;

/**
 * Petstore API Test Runner
 * 
 * Main test runner for executing Karate feature files.
 * Aligned with ISO/IEC/IEEE 29119 Software Testing Standards.
 * 
 * Usage:
 *   mvn test                           - Run all tests
 *   mvn test -Psmoke                   - Run smoke tests
 *   mvn test -Pcritical                - Run critical tests
 *   mvn test -Dkarate.options="--tags @pet"  - Run with specific tags
 */
public class TestRunner {

    /**
     * Run all test features
     */
    @Karate.Test
    Karate testAll() {
        return Karate.run()
                .relativeTo(getClass());
    }

    /**
     * Run smoke tests for quick validation
     */
    @Karate.Test
    Karate testSmoke() {
        return Karate.run()
                .tags("@smoke")
                .relativeTo(getClass());
    }

    /**
     * Run critical path tests
     */
    @Karate.Test
    Karate testCritical() {
        return Karate.run()
                .tags("@critical")
                .relativeTo(getClass());
    }

    /**
     * Run high priority tests
     */
    @Karate.Test
    Karate testHighPriority() {
        return Karate.run()
                .tags("@high")
                .relativeTo(getClass());
    }

    /**
     * Run Pet API tests
     */
    @Karate.Test
    Karate testPetApi() {
        return Karate.run("tests/pet")
                .relativeTo(getClass());
    }

    /**
     * Run Store API tests
     */
    @Karate.Test
    Karate testStoreApi() {
        return Karate.run("tests/store")
                .relativeTo(getClass());
    }

    /**
     * Run User API tests
     */
    @Karate.Test
    Karate testUserApi() {
        return Karate.run("tests/user")
                .relativeTo(getClass());
    }

    /**
     * Run Security tests
     */
    @Karate.Test
    Karate testSecurity() {
        return Karate.run("tests/security")
                .relativeTo(getClass());
    }

    /**
     * Run Contract/Schema validation tests
     */
    @Karate.Test
    Karate testContract() {
        return Karate.run("tests/contract")
                .relativeTo(getClass());
    }

    /**
     * Run Performance tests
     */
    @Karate.Test
    Karate testPerformance() {
        return Karate.run("tests/performance")
                .relativeTo(getClass());
    }

    /**
     * Run Integration/E2E tests
     */
    @Karate.Test
    Karate testIntegration() {
        return Karate.run("tests/integration")
                .relativeTo(getClass());
    }

    /**
     * Run Error Handling tests
     */
    @Karate.Test
    Karate testErrorHandling() {
        return Karate.run("tests/error")
                .relativeTo(getClass());
    }

    /**
     * Run Content Negotiation tests
     */
    @Karate.Test
    Karate testContentNegotiation() {
        return Karate.run("tests/content")
                .relativeTo(getClass());
    }

    /**
     * Run positive scenario tests
     */
    @Karate.Test
    Karate testPositiveScenarios() {
        return Karate.run()
                .tags("@positive")
                .relativeTo(getClass());
    }

    /**
     * Run negative scenario tests
     */
    @Karate.Test
    Karate testNegativeScenarios() {
        return Karate.run()
                .tags("@negative")
                .relativeTo(getClass());
    }

    /**
     * Parallel test execution with configurable thread count
     */
    @Test
    void testParallel() {
        Results results = Runner.path("classpath:petstore/tests")
                .tags("@smoke", "@critical")
                .parallel(5);
        
        assertEquals(0, results.getFailCount(), results.getErrorMessages());
    }

    /**
     * Full regression test suite with parallel execution
     */
    @Test
    void testFullRegression() {
        Results results = Runner.path("classpath:petstore/tests")
                .outputCucumberJson(true)
                .parallel(10);
        
        // Generate summary
        System.out.println("=".repeat(60));
        System.out.println("TEST EXECUTION SUMMARY");
        System.out.println("=".repeat(60));
        System.out.println("Total Features: " + results.getFeatureResults().count());
        System.out.println("Total Scenarios: " + results.getScenariosTotal());
        System.out.println("Passed: " + results.getScenariosPassed());
        System.out.println("Failed: " + results.getFailCount());
        System.out.println("Time Taken: " + results.getElapsedTime() + " ms");
        System.out.println("=".repeat(60));
        
        assertEquals(0, results.getFailCount(), results.getErrorMessages());
    }
}
