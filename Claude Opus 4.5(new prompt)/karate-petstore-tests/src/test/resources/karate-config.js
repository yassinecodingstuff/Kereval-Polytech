/**
 * Configuration Karate pour l'API Petstore
 * 
 * Environnements supportés:
 * - dev: Environnement de développement local
 * - test: Environnement de test/staging
 * - prod: Environnement de production (lecture seule recommandée)
 * 
 * Usage:
 * - mvn test                           # Utilise l'environnement par défaut (dev)
 * - mvn test -Dkarate.env=test         # Utilise l'environnement test
 * - mvn test -Dkarate.env=prod         # Utilise l'environnement prod
 */
function fn() {
  // Récupérer l'environnement depuis la variable système ou utiliser 'dev' par défaut
  var env = karate.env;
  
  karate.log('karate.env system property:', env);
  
  if (!env) {
    env = 'dev';
  }

  // Configuration de base commune à tous les environnements
  var config = {
    env: env,
    
    // Timeouts par défaut
    connectTimeout: 30000,
    readTimeout: 30000,
    
    // Clé API pour l'authentification (utilisez 'special-key' pour les tests)
    apiKey: 'special-key',
    
    // Données de test par défaut
    testData: {
      pet: {
        id: karate.get('petId', Math.floor(Math.random() * 100000)),
        name: 'TestPet_' + java.util.UUID.randomUUID().toString().substring(0, 8),
        status: 'available'
      },
      user: {
        username: 'testuser_' + java.util.UUID.randomUUID().toString().substring(0, 8),
        password: 'Test@123'
      },
      order: {
        id: karate.get('orderId', Math.floor(Math.random() * 1000) + 1),
        quantity: 1,
        status: 'placed'
      }
    },
    
    // Headers communs
    commonHeaders: {
      'Content-Type': 'application/json',
      'Accept': 'application/json'
    }
  };

  // Configuration spécifique par environnement
  if (env === 'dev') {
    config.baseUrl = 'http://petstore.swagger.io/v2';
    config.logLevel = 'DEBUG';
  } else if (env === 'test') {
    config.baseUrl = 'http://petstore.swagger.io/v2';
    config.logLevel = 'INFO';
  } else if (env === 'prod') {
    config.baseUrl = 'http://petstore.swagger.io/v2';
    config.logLevel = 'WARN';
    // En production, on pourrait vouloir des timeouts plus courts
    config.connectTimeout = 10000;
    config.readTimeout = 15000;
  } else {
    // Environnement personnalisé - utiliser l'URL par défaut
    config.baseUrl = 'http://petstore.swagger.io/v2';
  }

  // Configuration Karate
  karate.configure('connectTimeout', config.connectTimeout);
  karate.configure('readTimeout', config.readTimeout);
  karate.configure('logPrettyRequest', true);
  karate.configure('logPrettyResponse', true);

  // Fonction utilitaire pour générer un ID unique
  config.generateId = function() {
    return Math.floor(Math.random() * 100000) + 1;
  };

  // Fonction utilitaire pour générer une date au format ISO
  config.generateDate = function() {
    return new Date().toISOString();
  };

  // Fonction utilitaire pour générer un nom unique
  config.generateName = function(prefix) {
    return (prefix || 'Test') + '_' + java.util.UUID.randomUUID().toString().substring(0, 8);
  };

  // Schémas de validation réutilisables
  config.schemas = {
    pet: {
      id: '#number',
      name: '#string',
      photoUrls: '#array',
      status: '#? _ == "available" || _ == "pending" || _ == "sold"'
    },
    order: {
      id: '#number',
      petId: '#number',
      quantity: '#number',
      status: '#? _ == "placed" || _ == "approved" || _ == "delivered"'
    },
    user: {
      id: '#number',
      username: '#string',
      email: '#string'
    },
    apiResponse: {
      code: '#number',
      type: '#string',
      message: '#string'
    }
  };

  return config;
}
