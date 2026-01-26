/**
 * Configuration globale Karate :
 * - Environnements: dev | test | prod
 * - Variables: baseUrl, apiKey, oauthToken
 * - Timeouts: connect / read
 */
function fn() {
  var env = karate.env || 'dev';
  var config = {};

  if (env === 'dev') {
    config.baseUrl = 'https://petstore.swagger.io/v2';
  } else if (env === 'test') {
    config.baseUrl = 'https://test.api.example.com/v2';
  } else if (env === 'prod') {
    config.baseUrl = 'https://api.example.com/v2';
  } else {
    karate.log('Environnement inconnu, fallback -> dev');
    config.baseUrl = 'https://petstore.swagger.io/v2';
  }

  // Auth optionnelle: apiKey / OAuth2 Bearer
  config.apiKey = karate.properties['apiKey'] || karate.envApiKey || java.lang.System.getenv('API_KEY');
  config.oauthToken = karate.properties['oauthToken'] || java.lang.System.getenv('OAUTH_TOKEN');

  // Timeouts
  karate.configure('connectTimeout', 15000);
  karate.configure('readTimeout', 30000);
  karate.configure('ssl', true);

  // Headers par défaut (surclassables dans les Features)
  config.headers = { Accept: 'application/json', 'Content-Type': 'application/json' };

  return config;
}
