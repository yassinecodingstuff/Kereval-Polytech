package com.example.petstore;

import com.intuit.karate.junit5.Karate;

public class TestRunner {

    @Karate.Test
    Karate testAll() {
        return Karate.run("classpath:pet", "classpath:store", "classpath:user");
    }
}
