package petstore;

import com.intuit.karate.junit5.Karate;

class StoreTests {

    @Karate.Test
    Karate testStoreInventory() {
        return Karate.run("classpath:petstore/store/store-inventory.feature");
    }

    @Karate.Test
    Karate testOrderCreation() {
        return Karate.run("classpath:petstore/store/order-creation.feature");
    }

    @Karate.Test
    Karate testOrderRetrieval() {
        return Karate.run("classpath:petstore/store/order-retrieval.feature");
    }

    @Karate.Test
    Karate testOrderDeletion() {
        return Karate.run("classpath:petstore/store/order-deletion.feature");
    }
}
