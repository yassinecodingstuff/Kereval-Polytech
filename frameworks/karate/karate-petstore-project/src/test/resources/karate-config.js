function fn() {
  var env = karate.env || 'dev';
  var config = {
    env: env,
    baseUrl: 'https://petstore.swagger.io/v2',
    headers: { Accept: 'application/json' }
  };
  karate.configure('ssl', true);
  karate.configure('connectTimeout', 15000);
  karate.configure('readTimeout', 30000);
  return config;
}
