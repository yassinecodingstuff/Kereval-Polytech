function fn() {
  var env = karate.env;
  if (!env) env = 'dev';

  var config = {
    env: env,
    baseUrl: karate.properties['baseUrl'] || 'https://petstore.swagger.io/v2',
    apiKey: karate.properties['apiKey'] || 'special-key',
    writePetsToken: karate.properties['writePetsToken'] || 'REPLACE_ME_WRITE_PETS_TOKEN',
    readPetsToken: karate.properties['readPetsToken'] || 'REPLACE_ME_READ_PETS_TOKEN'
  };

  karate.configure('ssl', true);
  karate.configure('connectTimeout', 10000);
  karate.configure('readTimeout', 20000);
  karate.configure('retry', { count: 2, interval: 1000 });

  return config;
}
