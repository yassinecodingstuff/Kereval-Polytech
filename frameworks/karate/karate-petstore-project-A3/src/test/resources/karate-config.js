function fn() {
  var env = karate.env || 'dev';
  var config = {
    env: env,
    baseUrl: 'https://petstore.swagger.io/v2'
  };
  karate.configure('ssl', true);
  karate.configure('connectTimeout', 20000);
  karate.configure('readTimeout', 20000);
  return config;
}
