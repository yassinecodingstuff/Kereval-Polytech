package com.example.petstore;

import com.intuit.karate.junit5.Karate;

public class TestRunner {
    @Karate.Test
    Karate runAll() {
        return Karate.run("classpath:features").tags("~@ignore");
    }
}
