function fn() {
  var env = karate.env; // get system property 'karate.env'
  karate.log("karate.env system property was:", env);

  if (!env) {
    env = "dev";
  }

  var config = {
    baseUrl: "https://petstore.swagger.io/v2",
    apiKey: "special-key",
    timeout: 30000,
  };

  if (env === "dev") {
    config.baseUrl = "https://petstore.swagger.io/v2";
  } else if (env === "qa") {
    config.baseUrl = "https://petstore.swagger.io/v2";
  } else if (env === "prod") {
    config.baseUrl = "https://petstore.swagger.io/v2";
  }

  // Authentication tokens and headers
  config.headers = {
    Accept: "application/json",
    "Content-Type": "application/json",
  };

  return config;
}
