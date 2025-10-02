package petstore;

import com.intuit.karate.junit5.Karate;

class UserTests {

    @Karate.Test
    Karate testUserCreation() {
        return Karate.run("classpath:petstore/user/user-creation.feature");
    }

    @Karate.Test
    Karate testUserAuthentication() {
        return Karate.run("classpath:petstore/user/user-authentication.feature");
    }

    @Karate.Test
    Karate testUserRetrieval() {
        return Karate.run("classpath:petstore/user/user-retrieval.feature");
    }

    @Karate.Test
    Karate testUserUpdate() {
        return Karate.run("classpath:petstore/user/user-update.feature");
    }

    @Karate.Test
    Karate testUserDeletion() {
        return Karate.run("classpath:petstore/user/user-deletion.feature");
    }
}
