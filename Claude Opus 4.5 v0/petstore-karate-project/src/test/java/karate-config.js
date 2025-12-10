function fn() {
    // Get environment from system property, default to 'dev'
    var env = karate.env;
    karate.log('karate.env system property:', env);
    
    if (!env) {
        env = 'dev';
    }
    
    // Base configuration object
    var config = {
        env: env,
        
        // API Configuration
        baseUrl: 'https://petstore.swagger.io/v2',
        apiKey: 'special-key',
        
        // Timeout Configuration (milliseconds)
        connectTimeout: 30000,
        readTimeout: 30000,
        
        // Retry Configuration
        retryCount: 3,
        retryInterval: 1000,
        
        // Test Data Configuration
        testDataPath: 'classpath:test-data/',
        
        // Response Time Thresholds (milliseconds)
        responseTimeThreshold: {
            fast: 1000,
            normal: 2000,
            slow: 5000,
            veryLow: 10000
        },
        
        // Logging Configuration
        logPrettyRequest: true,
        logPrettyResponse: true
    };
    
    // Environment-specific configurations
    if (env === 'dev') {
        config.baseUrl = 'https://petstore.swagger.io/v2';
        config.logPrettyRequest = true;
        config.logPrettyResponse = true;
    } else if (env === 'staging') {
        config.baseUrl = 'https://petstore-staging.swagger.io/v2';
        config.logPrettyRequest = true;
        config.logPrettyResponse = true;
    } else if (env === 'prod') {
        config.baseUrl = 'https://petstore.swagger.io/v2';
        config.logPrettyRequest = false;
        config.logPrettyResponse = false;
    }
    
    // Configure Karate settings
    karate.configure('connectTimeout', config.connectTimeout);
    karate.configure('readTimeout', config.readTimeout);
    karate.configure('retry', { count: config.retryCount, interval: config.retryInterval });
    karate.configure('logPrettyRequest', config.logPrettyRequest);
    karate.configure('logPrettyResponse', config.logPrettyResponse);
    
    // SSL Configuration (disable certificate validation for testing)
    karate.configure('ssl', true);
    
    // =========================================================================
    // SCHEMA DEFINITIONS (OpenAPI/Swagger Specification Aligned)
    // =========================================================================
    
    // Pet Schema Definition
    config.petSchema = {
        id: '#number',
        name: '#string',
        photoUrls: '#[] #string',
        status: '##string',
        category: '##object',
        tags: '##array'
    };
    
    // Category Schema Definition
    config.categorySchema = {
        id: '#number',
        name: '#string'
    };
    
    // Tag Schema Definition
    config.tagSchema = {
        id: '#number',
        name: '#string'
    };
    
    // Order Schema Definition
    config.orderSchema = {
        id: '#number',
        petId: '#number',
        quantity: '#number',
        shipDate: '##string',
        status: '#string',
        complete: '#boolean'
    };
    
    // User Schema Definition
    config.userSchema = {
        id: '#number',
        username: '#string',
        firstName: '##string',
        lastName: '##string',
        email: '##string',
        password: '##string',
        phone: '##string',
        userStatus: '##number'
    };
    
    // API Response Schema Definition
    config.apiResponseSchema = {
        code: '#number',
        type: '#string',
        message: '#string'
    };
    
    // =========================================================================
    // UTILITY FUNCTIONS
    // =========================================================================
    
    // Generate unique ID for test data isolation
    config.generateUniqueId = function() {
        return Math.floor(Math.random() * 900000000) + 100000000;
    };
    
    // Generate unique username with prefix
    config.generateUniqueUsername = function(prefix) {
        return prefix + '_' + Math.floor(Math.random() * 100000) + '_' + Date.now();
    };
    
    // Generate string of specified length
    config.generateStringOfLength = function(length) {
        var result = '';
        var characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
        for (var i = 0; i < length; i++) {
            result += characters.charAt(Math.floor(Math.random() * characters.length));
        }
        return result;
    };
    
    // Generate random email
    config.generateRandomEmail = function(prefix) {
        return prefix + '_' + Date.now() + '@test.com';
    };
    
    // Get current timestamp in ISO format
    config.getCurrentTimestamp = function() {
        return new Date().toISOString();
    };
    
    // Get future timestamp
    config.getFutureTimestamp = function(daysAhead) {
        var date = new Date();
        date.setDate(date.getDate() + daysAhead);
        return date.toISOString();
    };
    
    // Validate response time
    config.validateResponseTime = function(responseTime, threshold) {
        return responseTime < threshold;
    };
    
    // =========================================================================
    // COMMON HEADERS
    // =========================================================================
    
    config.commonHeaders = {
        'Content-Type': 'application/json',
        'Accept': 'application/json'
    };
    
    config.authHeaders = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'api_key': config.apiKey
    };
    
    // =========================================================================
    // TEST DATA TEMPLATES
    // =========================================================================
    
    // Pet template
    config.createPetPayload = function(id, name, status, photoUrls, category, tags) {
        var pet = {
            name: name || 'TestPet',
            photoUrls: photoUrls || ['https://example.com/pet.jpg']
        };
        if (id) pet.id = id;
        if (status) pet.status = status;
        if (category) pet.category = category;
        if (tags) pet.tags = tags;
        return pet;
    };
    
    // Order template
    config.createOrderPayload = function(id, petId, quantity, status, complete, shipDate) {
        var order = {
            petId: petId || 1,
            quantity: quantity || 1,
            status: status || 'placed',
            complete: complete || false
        };
        if (id) order.id = id;
        if (shipDate) order.shipDate = shipDate;
        return order;
    };
    
    // User template
    config.createUserPayload = function(username, firstName, lastName, email, password, phone, userStatus) {
        return {
            id: config.generateUniqueId(),
            username: username || config.generateUniqueUsername('user'),
            firstName: firstName || 'Test',
            lastName: lastName || 'User',
            email: email || config.generateRandomEmail('user'),
            password: password || 'Password123',
            phone: phone || '1234567890',
            userStatus: userStatus || 1
        };
    };
    
    // Log configuration summary
    karate.log('='.repeat(60));
    karate.log('KARATE CONFIGURATION LOADED');
    karate.log('Environment:', config.env);
    karate.log('Base URL:', config.baseUrl);
    karate.log('Connect Timeout:', config.connectTimeout, 'ms');
    karate.log('Read Timeout:', config.readTimeout, 'ms');
    karate.log('='.repeat(60));
    
    return config;
}
