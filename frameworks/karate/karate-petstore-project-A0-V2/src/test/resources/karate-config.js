function fn() {
  var env = karate.env || 'dev';
  var config = {};
  if (env == 'dev') {
    config.baseUrl = 'https://petstore.swagger.io/v2';
  } else if (env == 'local') {
    config.baseUrl = 'http://localhost:8080/v2';
  } else {
    config.baseUrl = 'https://petstore.swagger.io/v2';
  }
  karate.configure('connectTimeout', 10000);
  karate.configure('readTimeout', 20000);
  return config;
}
