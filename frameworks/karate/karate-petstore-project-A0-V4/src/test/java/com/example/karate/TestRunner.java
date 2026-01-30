package com.example.karate;

import com.intuit.karate.junit5.Karate;

public class TestRunner {

    @Karate.Test
    Karate runAll() {
        return Karate.run("classpath:features");
    }
}
