package com.example.karate;

import com.intuit.karate.junit5.Karate;
import org.junit.jupiter.api.MethodOrderer.OrderAnnotation;
import org.junit.jupiter.api.Order;
import org.junit.jupiter.api.TestMethodOrder;

@TestMethodOrder(OrderAnnotation.class)
public class TestRunner {

  @Karate.Test
  @Order(1)
  Karate riskP0() {
    return Karate.run("classpath:features").tags("@P0");
  }

  @Karate.Test
  @Order(2)
  Karate remainingRisk() {
    return Karate.run("classpath:features").tags("~@P0", "~@Ignore");
  }
}
