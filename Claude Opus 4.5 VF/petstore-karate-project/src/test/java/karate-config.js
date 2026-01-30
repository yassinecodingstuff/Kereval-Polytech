function fn() {
  var env = karate.env;
  karate.log('karate.env system property was:', env);

  if (!env) {
    env = 'dev';
  }

  var config = {
    env: env,
    baseUrl: 'https://petstore.swagger.io/v2',
    apiKey: 'special-key',
    
    // Timeout configurations
    connectTimeout: 10000,
    readTimeout: 30000,
    
    // Test data defaults
    defaultPetStatus: 'available',
    defaultOrderStatus: 'placed',
    defaultUserStatus: 1,
    
    // Retry configuration
    retryCount: 3,
    retryInterval: 1000,
    
    // Parallel execution threads
    parallelThreads: 5
  };

  // Environment-specific configurations
  if (env === 'dev') {
    config.baseUrl = 'https://petstore.swagger.io/v2';
    config.apiKey = 'special-key';
    config.connectTimeout = 10000;
    config.readTimeout = 30000;
  } else if (env === 'staging') {
    config.baseUrl = 'https://petstore-staging.swagger.io/v2';
    config.apiKey = 'staging-key';
    config.connectTimeout = 15000;
    config.readTimeout = 45000;
  } else if (env === 'prod') {
    config.baseUrl = 'https://petstore.swagger.io/v2';
    config.apiKey = 'prod-key';
    config.connectTimeout = 5000;
    config.readTimeout = 20000;
  }

  // Configure Karate settings
  karate.configure('connectTimeout', config.connectTimeout);
  karate.configure('readTimeout', config.readTimeout);
  karate.configure('ssl', true);
  karate.configure('logPrettyRequest', true);
  karate.configure('logPrettyResponse', true);

  // Utility functions available in all features
  config.generatePetId = function() {
    return Math.floor(Math.random() * 900000) + 100000;
  };

  config.generateUsername = function() {
    return 'testuser_' + Math.floor(Math.random() * 1000000);
  };

  config.generateOrderId = function() {
    return Math.floor(Math.random() * 9) + 1;
  };

  config.currentDateTime = function() {
    return new Date().toISOString();
  };

  config.generateEmail = function(prefix) {
    return (prefix || 'test') + '_' + Math.floor(Math.random() * 100000) + '@test.com';
  };

  // UUID generator
  config.uuid = function() {
    return java.util.UUID.randomUUID().toString();
  };

  karate.log('Configuration loaded for environment:', env);
  karate.log('Base URL:', config.baseUrl);

  return config;
}
