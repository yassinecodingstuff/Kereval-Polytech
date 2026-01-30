package com.petstore.api.runners;

import com.intuit.karate.Results;
import com.intuit.karate.Runner;
import com.intuit.karate.junit5.Karate;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertEquals;

/**
 * Main Test Runner for Petstore API Karate Tests
 * 
 * This runner executes all feature files in the project.
 * Supports parallel execution and tag-based filtering.
 * 
 * Usage:
 *   mvn test -Dtest=TestRunner
 *   mvn test -Dtest=TestRunner -Dkarate.options="--tags @smoke"
 *   mvn test -Psmoke -Dtest=TestRunner
 */
public class TestRunner {

    @Karate.Test
    Karate testAll() {
        return Karate.run("classpath:com/petstore/api")
                .relativeTo(getClass());
    }

    @Karate.Test
    Karate testPet() {
        return Karate.run("classpath:com/petstore/api/pet")
                .relativeTo(getClass());
    }

    @Karate.Test
    Karate testStore() {
        return Karate.run("classpath:com/petstore/api/store")
                .relativeTo(getClass());
    }

    @Karate.Test
    Karate testUser() {
        return Karate.run("classpath:com/petstore/api/user")
                .relativeTo(getClass());
    }

    @Karate.Test
    Karate testCommon() {
        return Karate.run("classpath:com/petstore/api/common")
                .relativeTo(getClass());
    }

    @Test
    void testParallel() {
        Results results = Runner.path("classpath:com/petstore/api")
                .outputCucumberJson(true)
                .outputJunitXml(true)
                .outputHtmlReport(true)
                .parallel(5);
        assertEquals(0, results.getFailCount(), results.getErrorMessages());
    }

    @Test
    void testSmokeParallel() {
        Results results = Runner.path("classpath:com/petstore/api")
                .tags("@smoke")
                .outputCucumberJson(true)
                .outputJunitXml(true)
                .outputHtmlReport(true)
                .parallel(5);
        assertEquals(0, results.getFailCount(), results.getErrorMessages());
    }

    @Test
    void testCriticalParallel() {
        Results results = Runner.path("classpath:com/petstore/api")
                .tags("@critical")
                .outputCucumberJson(true)
                .outputJunitXml(true)
                .outputHtmlReport(true)
                .parallel(5);
        assertEquals(0, results.getFailCount(), results.getErrorMessages());
    }

    @Test
    void testRegressionParallel() {
        Results results = Runner.path("classpath:com/petstore/api")
                .tags("@regression")
                .outputCucumberJson(true)
                .outputJunitXml(true)
                .outputHtmlReport(true)
                .parallel(5);
        assertEquals(0, results.getFailCount(), results.getErrorMessages());
    }

    @Test
    void testSecurityParallel() {
        Results results = Runner.path("classpath:com/petstore/api")
                .tags("@security")
                .outputCucumberJson(true)
                .outputJunitXml(true)
                .outputHtmlReport(true)
                .parallel(3);
        assertEquals(0, results.getFailCount(), results.getErrorMessages());
    }

    @Test
    void testNegativeParallel() {
        Results results = Runner.path("classpath:com/petstore/api")
                .tags("@negative")
                .outputCucumberJson(true)
                .outputJunitXml(true)
                .outputHtmlReport(true)
                .parallel(5);
        assertEquals(0, results.getFailCount(), results.getErrorMessages());
    }

    @Test
    void testE2EParallel() {
        Results results = Runner.path("classpath:com/petstore/api")
                .tags("@e2e")
                .outputCucumberJson(true)
                .outputJunitXml(true)
                .outputHtmlReport(true)
                .parallel(2);
        assertEquals(0, results.getFailCount(), results.getErrorMessages());
    }
}
