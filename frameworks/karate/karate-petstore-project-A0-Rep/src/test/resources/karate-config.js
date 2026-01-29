function fn() {
  var env = karate.env || 'dev';
  var config = {
    env: env,
    baseUrl: 'https://petstore.swagger.io/v2',
    apiKey: karate.properties['KARATE_API_KEY'] || 'special-key',
    oauthToken: karate.properties['KARATE_OAUTH_TOKEN'] || '',
    headers: { Accept: 'application/json' }
  };

  karate.configure('ssl', true);
  karate.configure('connectTimeout', 15000);
  karate.configure('readTimeout', 30000);
  karate.configure('logPrettyRequest', true);
  karate.configure('logPrettyResponse', true);
  karate.configure('headers', config.headers);

  return config;
}
