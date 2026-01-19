function fn() {
  var env = karate.env || 'dev';
  var config = {
    env: env,
    apiBaseUrl: 'https://petstore.swagger.io/v2',
    apiKey: 'special-key',
    timeout: 5000
  };
  if (env == 'ci') {
    // override for CI if necessary
    config.timeout = 10000;
  }
  karate.configure('connectTimeout', config.timeout);
  karate.configure('readTimeout', config.timeout);
  return config;
}
