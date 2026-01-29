function fn() {
  var env = karate.env || 'dev';
  var config = {};
  if (env == 'dev') {
    config.baseUrl = 'https://petstore.swagger.io/v2';
  } else if (env == 'qa') {
    config.baseUrl = 'https://petstore.swagger.io/v2';
  } else {
    config.baseUrl = 'https://petstore.swagger.io/v2';
  }
  karate.configure('ssl', true);
  karate.configure('connectTimeout', 30000);
  karate.configure('readTimeout', 30000);
  return config;
}
