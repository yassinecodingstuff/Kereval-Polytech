function fn() {
  var env = karate.env || 'dev';
  var config = { env: env, baseUrl: 'https://petstore.swagger.io/v2' };

  if (env === 'dev') {
    config.baseUrl = 'https://petstore.swagger.io/v2';
  } else if (env === 'local') {
    config.baseUrl = 'http://localhost:8080/v2';
  } else if (env === 'staging') {
    config.baseUrl = 'https://petstore.swagger.io/v2';
  }

  karate.configure('connectTimeout', 5000);
  karate.configure('readTimeout', 20000);
  karate.configure('ssl', true);

  return config;
}
