function fn() {
  var env = karate.env || 'dev';
  var config = {};
  if (env == 'dev') {
    config.baseUrl = 'https://petstore.swagger.io/v2';
  } else if (env == 'staging') {
    config.baseUrl = 'https://petstore.swagger.io/v2';
  } else {
    config.baseUrl = 'https://petstore.swagger.io/v2';
  }
  karate.configure('connectTimeout', 15000);
  karate.configure('readTimeout', 20000);
  return config;
}
