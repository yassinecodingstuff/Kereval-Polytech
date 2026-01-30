package com.petstore.api.runners;

import com.intuit.karate.Results;
import com.intuit.karate.Runner;
import com.intuit.karate.junit5.Karate;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertEquals;

/**
 * Test Runner for Pet API Tests
 * 
 * Executes all pet-related feature files.
 * Supports tag-based filtering for smoke, critical, and negative tests.
 */
public class PetRunner {

    @Karate.Test
    Karate testPetFeatures() {
        return Karate.run("classpath:com/petstore/api/pet")
                .relativeTo(getClass());
    }

    @Test
    void testPetParallel() {
        Results results = Runner.path("classpath:com/petstore/api/pet")
                .outputCucumberJson(true)
                .outputJunitXml(true)
                .outputHtmlReport(true)
                .parallel(5);
        assertEquals(0, results.getFailCount(), results.getErrorMessages());
    }

    @Test
    void testPetSmoke() {
        Results results = Runner.path("classpath:com/petstore/api/pet")
                .tags("@smoke")
                .outputCucumberJson(true)
                .parallel(3);
        assertEquals(0, results.getFailCount(), results.getErrorMessages());
    }

    @Test
    void testPetCritical() {
        Results results = Runner.path("classpath:com/petstore/api/pet")
                .tags("@critical")
                .outputCucumberJson(true)
                .parallel(3);
        assertEquals(0, results.getFailCount(), results.getErrorMessages());
    }

    @Test
    void testPetNegative() {
        Results results = Runner.path("classpath:com/petstore/api/pet")
                .tags("@negative")
                .outputCucumberJson(true)
                .parallel(5);
        assertEquals(0, results.getFailCount(), results.getErrorMessages());
    }
}
