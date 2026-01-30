package com.petstore.tests;

import com.intuit.karate.junit5.Karate;

class TestRunner {

    @Karate.Test
    Karate testAll() {
        return Karate.run("classpath:features").relativeTo(getClass());
    }

    @Karate.Test
    Karate testPet() {
        return Karate.run("classpath:features/pet").relativeTo(getClass());
    }

    @Karate.Test
    Karate testStore() {
        return Karate.run("classpath:features/store").relativeTo(getClass());
    }

    @Karate.Test
    Karate testUser() {
        return Karate.run("classpath:features/user").relativeTo(getClass());
    }

    @Karate.Test
    Karate testContractSecurity() {
        return Karate.run("classpath:features/common").relativeTo(getClass());
    }

    @Karate.Test
    Karate testSmoke() {
        return Karate.run("classpath:features").tags("@smoke").relativeTo(getClass());
    }

    @Karate.Test
    Karate testCritical() {
        return Karate.run("classpath:features").tags("@critical").relativeTo(getClass());
    }

    @Karate.Test
    Karate testHigh() {
        return Karate.run("classpath:features").tags("@high").relativeTo(getClass());
    }
}
