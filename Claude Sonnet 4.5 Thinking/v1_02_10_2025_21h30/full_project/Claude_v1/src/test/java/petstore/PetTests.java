package petstore;

import com.intuit.karate.junit5.Karate;

class PetTests {

    @Karate.Test
    Karate testPetCreation() {
        return Karate.run("classpath:petstore/pet/pet-creation.feature");
    }

    @Karate.Test
    Karate testPetUpdate() {
        return Karate.run("classpath:petstore/pet/pet-update.feature");
    }

    @Karate.Test
    Karate testPetSearch() {
        return Karate.run("classpath:petstore/pet/pet-search.feature");
    }

    @Karate.Test
    Karate testPetRetrieval() {
        return Karate.run("classpath:petstore/pet/pet-retrieval.feature");
    }

    @Karate.Test
    Karate testPetDeletion() {
        return Karate.run("classpath:petstore/pet/pet-deletion.feature");
    }

    @Karate.Test
    Karate testPetImageUpload() {
        return Karate.run("classpath:petstore/pet/pet-image-upload.feature");
    }
}
