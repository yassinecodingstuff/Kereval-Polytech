function fn() {
  var env = karate.env || 'dev';
  var oasDefault = 'https://petstore.swagger.io/v2';
  var base = karate.properties['BASE_URL'] || oasDefault || 'http://localhost:8080';

  karate.configure('connectTimeout', 30000);
  karate.configure('readTimeout', 30000);

  return { env: env, baseUrl: base };
}
