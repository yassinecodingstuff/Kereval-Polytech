package com.petstore.api.runners;

import com.intuit.karate.Results;
import com.intuit.karate.Runner;
import com.intuit.karate.junit5.Karate;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertEquals;

/**
 * Test Runner for User API Tests
 * 
 * Executes all user-related feature files.
 * Supports tag-based filtering for smoke, critical, security, and negative tests.
 */
public class UserRunner {

    @Karate.Test
    Karate testUserFeatures() {
        return Karate.run("classpath:com/petstore/api/user")
                .relativeTo(getClass());
    }

    @Test
    void testUserParallel() {
        Results results = Runner.path("classpath:com/petstore/api/user")
                .outputCucumberJson(true)
                .outputJunitXml(true)
                .outputHtmlReport(true)
                .parallel(5);
        assertEquals(0, results.getFailCount(), results.getErrorMessages());
    }

    @Test
    void testUserSmoke() {
        Results results = Runner.path("classpath:com/petstore/api/user")
                .tags("@smoke")
                .outputCucumberJson(true)
                .parallel(3);
        assertEquals(0, results.getFailCount(), results.getErrorMessages());
    }

    @Test
    void testUserCritical() {
        Results results = Runner.path("classpath:com/petstore/api/user")
                .tags("@critical")
                .outputCucumberJson(true)
                .parallel(3);
        assertEquals(0, results.getFailCount(), results.getErrorMessages());
    }

    @Test
    void testUserSecurity() {
        Results results = Runner.path("classpath:com/petstore/api/user")
                .tags("@security")
                .outputCucumberJson(true)
                .parallel(3);
        assertEquals(0, results.getFailCount(), results.getErrorMessages());
    }

    @Test
    void testUserNegative() {
        Results results = Runner.path("classpath:com/petstore/api/user")
                .tags("@negative")
                .outputCucumberJson(true)
                .parallel(5);
        assertEquals(0, results.getFailCount(), results.getErrorMessages());
    }
}
