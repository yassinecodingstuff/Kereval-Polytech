function fn() {
  var env = karate.env;
  karate.log('karate.env system property is:', env);
  
  if (!env) {
    env = 'dev';
  }
  
  var config = {
    env: env,
    baseUrl: 'https://petstore.swagger.io/v2',
    apiKey: 'special-key'
  };
  
  if (env == 'dev') {
    config.baseUrl = 'https://petstore.swagger.io/v2';
  } else if (env == 'staging') {
    config.baseUrl = 'https://petstore.swagger.io/v2';
  } else if (env == 'prod') {
    config.baseUrl = 'https://petstore.swagger.io/v2';
  }
  
  karate.configure('connectTimeout', 30000);
  karate.configure('readTimeout', 30000);
  karate.configure('ssl', true);
  karate.configure('retry', { count: 3, interval: 1000 });
  karate.configure('logPrettyRequest', true);
  karate.configure('logPrettyResponse', true);
  
  return config;
}
