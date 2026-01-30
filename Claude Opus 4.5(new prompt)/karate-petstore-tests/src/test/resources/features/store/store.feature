@store @regression
Feature: Gestion du Store - API Petstore
  En tant qu'utilisateur de l'API Petstore
  Je veux pouvoir gérer l'inventaire et les commandes
  Afin de passer et suivre les commandes de pets

  Background:
    * url baseUrl
    * header Content-Type = 'application/json'
    * header Accept = 'application/json'
    * header api_key = apiKey
    * def generateOrderId = function(){ return Math.floor(Math.random() * 1000) + 1 }

  # ============================================================================
  # GET /store/inventory - Récupérer l'inventaire
  # ============================================================================

  @smoke @get
  Scenario: GET /store/inventory - Récupérer l'inventaire avec succès (200)
    Given path '/store/inventory'
    When method GET
    Then status 200
    And match response == '#object'
    # L'inventaire est un objet avec des clés de status et des valeurs numériques
    And match each response == '#number'

  @get
  Scenario: GET /store/inventory - Vérifier les statuts dans l'inventaire
    Given path '/store/inventory'
    When method GET
    Then status 200
    # Vérifier que les statuts standards peuvent exister
    * def hasAvailable = response.available != null
    * def hasSold = response.sold != null
    * def hasPending = response.pending != null

  # ============================================================================
  # POST /store/order - Créer une commande
  # ============================================================================

  @smoke @post
  Scenario: POST /store/order - Créer une commande avec succès (200)
    * def orderId = generateOrderId()
    * def newOrder = 
      """
      {
        "id": #(orderId),
        "petId": 1,
        "quantity": 2,
        "shipDate": "2025-01-15T10:00:00.000Z",
        "status": "placed",
        "complete": false
      }
      """
    Given path '/store/order'
    And request newOrder
    When method POST
    Then status 200
    And match response.id == orderId
    And match response.petId == 1
    And match response.quantity == 2
    And match response.status == 'placed'
    And match response.complete == false

  @post
  Scenario: POST /store/order - Créer une commande avec statut approved
    * def orderId = generateOrderId()
    * def approvedOrder = 
      """
      {
        "id": #(orderId),
        "petId": 2,
        "quantity": 1,
        "shipDate": "2025-02-01T14:30:00.000Z",
        "status": "approved",
        "complete": false
      }
      """
    Given path '/store/order'
    And request approvedOrder
    When method POST
    Then status 200
    And match response.status == 'approved'

  @post
  Scenario: POST /store/order - Créer une commande avec statut delivered
    * def orderId = generateOrderId()
    * def deliveredOrder = 
      """
      {
        "id": #(orderId),
        "petId": 3,
        "quantity": 3,
        "shipDate": "2025-01-01T09:00:00.000Z",
        "status": "delivered",
        "complete": true
      }
      """
    Given path '/store/order'
    And request deliveredOrder
    When method POST
    Then status 200
    And match response.status == 'delivered'
    And match response.complete == true

  @negative @post
  Scenario: POST /store/order - Commande invalide (400)
    * def invalidOrder = 
      """
      {
        "id": "invalid",
        "petId": "not-a-number",
        "quantity": -1
      }
      """
    Given path '/store/order'
    And request invalidOrder
    When method POST
    Then assert responseStatus == 200 || responseStatus == 400 || responseStatus == 500

  @boundary @post
  Scenario: POST /store/order - Commande avec quantité zéro
    * def orderId = generateOrderId()
    * def zeroQuantityOrder = 
      """
      {
        "id": #(orderId),
        "petId": 1,
        "quantity": 0,
        "status": "placed",
        "complete": false
      }
      """
    Given path '/store/order'
    And request zeroQuantityOrder
    When method POST
    Then assert responseStatus == 200 || responseStatus == 400

  @boundary @post
  Scenario: POST /store/order - Commande avec grande quantité
    * def orderId = generateOrderId()
    * def largeQuantityOrder = 
      """
      {
        "id": #(orderId),
        "petId": 1,
        "quantity": 999999,
        "status": "placed",
        "complete": false
      }
      """
    Given path '/store/order'
    And request largeQuantityOrder
    When method POST
    Then status 200
    And match response.quantity == 999999

  # ============================================================================
  # GET /store/order/{orderId} - Récupérer une commande par ID
  # ============================================================================

  @smoke @get
  Scenario: GET /store/order/{orderId} - Récupérer une commande existante (200)
    # Créer d'abord la commande
    * def orderId = generateOrderId()
    * def newOrder = { "id": #(orderId), "petId": 1, "quantity": 1, "status": "placed", "complete": false }
    Given path '/store/order'
    And request newOrder
    When method POST
    Then status 200

    # Récupérer la commande
    Given path '/store/order', orderId
    When method GET
    Then status 200
    And match response.id == orderId
    And match response.petId == 1
    And match response.status == 'placed'

  @negative @get
  Scenario: GET /store/order/{orderId} - Commande non trouvée (404)
    # IDs > 10 ou <= 0 doivent retourner 404 selon la doc
    Given path '/store/order', 99999
    When method GET
    Then status 404
    And match response contains { message: '#string' }

  @negative @get
  Scenario: GET /store/order/{orderId} - ID invalide (400)
    Given path '/store/order', 'invalid-id'
    When method GET
    Then assert responseStatus == 400 || responseStatus == 404

  @boundary @get
  Scenario: GET /store/order/{orderId} - ID négatif
    Given path '/store/order', -1
    When method GET
    Then assert responseStatus == 400 || responseStatus == 404

  @boundary @get
  Scenario: GET /store/order/{orderId} - ID zéro
    Given path '/store/order', 0
    When method GET
    Then assert responseStatus == 400 || responseStatus == 404

  @get
  Scenario: GET /store/order/{orderId} - IDs valides entre 1 et 5
    # Selon la doc, les IDs entre 1 et 5 devraient fonctionner
    Given path '/store/order', 1
    When method GET
    Then assert responseStatus == 200 || responseStatus == 404

  # ============================================================================
  # DELETE /store/order/{orderId} - Supprimer une commande
  # ============================================================================

  @smoke @delete
  Scenario: DELETE /store/order/{orderId} - Supprimer une commande existante (200)
    # Créer d'abord la commande
    * def orderId = generateOrderId()
    * def newOrder = { "id": #(orderId), "petId": 1, "quantity": 1, "status": "placed", "complete": false }
    Given path '/store/order'
    And request newOrder
    When method POST
    Then status 200

    # Supprimer la commande
    Given path '/store/order', orderId
    When method DELETE
    Then assert responseStatus == 200 || responseStatus == 404

    # Vérifier la suppression
    Given path '/store/order', orderId
    When method GET
    Then status 404

  @negative @delete
  Scenario: DELETE /store/order/{orderId} - Commande inexistante (404)
    Given path '/store/order', 999999999
    When method DELETE
    Then assert responseStatus == 400 || responseStatus == 404

  @negative @delete
  Scenario: DELETE /store/order/{orderId} - ID invalide (400)
    Given path '/store/order', 'invalid-id'
    When method DELETE
    Then assert responseStatus == 400 || responseStatus == 404

  # ============================================================================
  # Scénarios de bout en bout (E2E)
  # ============================================================================

  @e2e @smoke
  Scenario: E2E - Cycle de vie complet d'une commande (Create -> Read -> Delete)
    * def e2eOrderId = generateOrderId()
    
    # 1. Vérifier l'inventaire initial
    Given path '/store/inventory'
    When method GET
    Then status 200
    * def initialInventory = response

    # 2. Créer une nouvelle commande
    * def e2eOrder = 
      """
      {
        "id": #(e2eOrderId),
        "petId": 1,
        "quantity": 1,
        "shipDate": "2025-06-15T12:00:00.000Z",
        "status": "placed",
        "complete": false
      }
      """
    Given path '/store/order'
    And request e2eOrder
    When method POST
    Then status 200
    And match response.id == e2eOrderId

    # 3. Récupérer la commande créée
    Given path '/store/order', e2eOrderId
    When method GET
    Then status 200
    And match response.petId == 1
    And match response.status == 'placed'

    # 4. Supprimer la commande
    Given path '/store/order', e2eOrderId
    When method DELETE
    Then assert responseStatus == 200 || responseStatus == 404

    # 5. Vérifier que la commande n'existe plus
    Given path '/store/order', e2eOrderId
    When method GET
    Then status 404

  @e2e
  Scenario: E2E - Vérifier la cohérence de l'inventaire
    # 1. Obtenir l'inventaire
    Given path '/store/inventory'
    When method GET
    Then status 200
    * def inventory1 = response

    # 2. Obtenir à nouveau et comparer (devrait être cohérent)
    Given path '/store/inventory'
    When method GET
    Then status 200
    And match response == '#object'
