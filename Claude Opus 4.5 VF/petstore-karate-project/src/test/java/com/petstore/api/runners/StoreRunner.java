package com.petstore.api.runners;

import com.intuit.karate.Results;
import com.intuit.karate.Runner;
import com.intuit.karate.junit5.Karate;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertEquals;

/**
 * Test Runner for Store API Tests
 * 
 * Executes all store/order-related feature files.
 * Supports tag-based filtering for smoke, critical, and negative tests.
 */
public class StoreRunner {

    @Karate.Test
    Karate testStoreFeatures() {
        return Karate.run("classpath:com/petstore/api/store")
                .relativeTo(getClass());
    }

    @Test
    void testStoreParallel() {
        Results results = Runner.path("classpath:com/petstore/api/store")
                .outputCucumberJson(true)
                .outputJunitXml(true)
                .outputHtmlReport(true)
                .parallel(5);
        assertEquals(0, results.getFailCount(), results.getErrorMessages());
    }

    @Test
    void testStoreSmoke() {
        Results results = Runner.path("classpath:com/petstore/api/store")
                .tags("@smoke")
                .outputCucumberJson(true)
                .parallel(3);
        assertEquals(0, results.getFailCount(), results.getErrorMessages());
    }

    @Test
    void testStoreCritical() {
        Results results = Runner.path("classpath:com/petstore/api/store")
                .tags("@critical")
                .outputCucumberJson(true)
                .parallel(3);
        assertEquals(0, results.getFailCount(), results.getErrorMessages());
    }

    @Test
    void testStoreNegative() {
        Results results = Runner.path("classpath:com/petstore/api/store")
                .tags("@negative")
                .outputCucumberJson(true)
                .parallel(5);
        assertEquals(0, results.getFailCount(), results.getErrorMessages());
    }
}
