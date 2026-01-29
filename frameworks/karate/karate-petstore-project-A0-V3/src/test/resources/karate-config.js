function fn() {
  var env = karate.env || 'dev';
  var config = { env: env };
  if (env == 'dev') {
    config.baseUrl = 'https://petstore.swagger.io/v2';
  } else if (env == 'qa') {
    config.baseUrl = 'https://petstore.swagger.io/v2';
  } else if (env == 'prod') {
    config.baseUrl = 'https://petstore.swagger.io/v2';
  } else {
    config.baseUrl = 'https://petstore.swagger.io/v2';
  }
  karate.configure('connectTimeout', 10000);
  karate.configure('readTimeout', 15000);
  return config;
}
