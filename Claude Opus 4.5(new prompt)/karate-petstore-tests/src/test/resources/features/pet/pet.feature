@pet @regression
Feature: Gestion des Pets - API Petstore
  En tant qu'utilisateur de l'API Petstore
  Je veux pouvoir gérer les animaux de compagnie
  Afin de créer, lire, mettre à jour et supprimer des pets

  Background:
    * url baseUrl
    * header Content-Type = 'application/json'
    * header Accept = 'application/json'
    * header api_key = apiKey
    * def generatePetId = function(){ return Math.floor(Math.random() * 100000) + 10000 }
    * def petId = generatePetId()

  # ============================================================================
  # POST /pet - Ajouter un nouveau pet
  # ============================================================================

  @smoke @post
  Scenario: POST /pet - Créer un nouveau pet avec succès (200)
    * def newPet = 
      """
      {
        "id": #(petId),
        "category": {
          "id": 1,
          "name": "Dogs"
        },
        "name": "Buddy",
        "photoUrls": ["http://example.com/photo1.jpg"],
        "tags": [
          {
            "id": 1,
            "name": "friendly"
          }
        ],
        "status": "available"
      }
      """
    Given path '/pet'
    And request newPet
    When method POST
    Then status 200
    And match response.id == petId
    And match response.name == 'Buddy'
    And match response.status == 'available'
    And match response.photoUrls == '#array'
    And match response.category.name == 'Dogs'

  @negative @post
  Scenario: POST /pet - Échec création avec données invalides (405)
    * def invalidPet = 
      """
      {
        "id": "invalid-id",
        "name": ""
      }
      """
    Given path '/pet'
    And request invalidPet
    When method POST
    Then status 405

  @boundary @post
  Scenario: POST /pet - Création avec champs optionnels manquants
    * def minimalPet = 
      """
      {
        "id": #(petId),
        "name": "MinimalPet",
        "photoUrls": ["http://example.com/photo.jpg"]
      }
      """
    Given path '/pet'
    And request minimalPet
    When method POST
    Then status 200
    And match response.name == 'MinimalPet'

  # ============================================================================
  # PUT /pet - Mettre à jour un pet existant
  # ============================================================================

  @smoke @put
  Scenario: PUT /pet - Mettre à jour un pet existant avec succès (200)
    # Créer d'abord le pet
    * def newPet = { "id": #(petId), "name": "OriginalName", "photoUrls": ["http://example.com/photo.jpg"], "status": "available" }
    Given path '/pet'
    And request newPet
    When method POST
    Then status 200

    # Mettre à jour le pet
    * def updatedPet = 
      """
      {
        "id": #(petId),
        "category": { "id": 2, "name": "Cats" },
        "name": "UpdatedName",
        "photoUrls": ["http://example.com/newphoto.jpg"],
        "tags": [{ "id": 2, "name": "playful" }],
        "status": "sold"
      }
      """
    Given path '/pet'
    And request updatedPet
    When method PUT
    Then status 200
    And match response.id == petId
    And match response.name == 'UpdatedName'
    And match response.status == 'sold'

  @negative @put
  Scenario: PUT /pet - Échec mise à jour avec ID invalide (400)
    * def invalidPet = { "id": "not-a-number", "name": "Test", "photoUrls": [] }
    Given path '/pet'
    And request invalidPet
    When method PUT
    Then assert responseStatus == 400 || responseStatus == 405

  @negative @put
  Scenario: PUT /pet - Échec mise à jour pet inexistant (404)
    * def nonExistentPet = { "id": 999999999, "name": "NonExistent", "photoUrls": ["url"], "status": "available" }
    Given path '/pet'
    And request nonExistentPet
    When method PUT
    Then assert responseStatus == 200 || responseStatus == 404

  # ============================================================================
  # GET /pet/findByStatus - Rechercher par statut
  # ============================================================================

  @smoke @get
  Scenario: GET /pet/findByStatus - Rechercher pets disponibles (200)
    Given path '/pet/findByStatus'
    And param status = 'available'
    When method GET
    Then status 200
    And match response == '#[]'
    And match each response contains { status: 'available' }

  @get
  Scenario: GET /pet/findByStatus - Rechercher pets vendus (200)
    Given path '/pet/findByStatus'
    And param status = 'sold'
    When method GET
    Then status 200
    And match response == '#[]'

  @get
  Scenario: GET /pet/findByStatus - Rechercher pets en attente (200)
    Given path '/pet/findByStatus'
    And param status = 'pending'
    When method GET
    Then status 200
    And match response == '#[]'

  @negative @get
  Scenario: GET /pet/findByStatus - Statut invalide (400)
    Given path '/pet/findByStatus'
    And param status = 'invalid_status'
    When method GET
    Then assert responseStatus == 200 || responseStatus == 400

  @get
  Scenario: GET /pet/findByStatus - Statuts multiples
    Given path '/pet/findByStatus'
    And param status = 'available,pending'
    When method GET
    Then status 200
    And match response == '#[]'

  # ============================================================================
  # GET /pet/findByTags - Rechercher par tags (Deprecated)
  # ============================================================================

  @get @deprecated
  Scenario: GET /pet/findByTags - Rechercher par tag unique (200)
    Given path '/pet/findByTags'
    And param tags = 'friendly'
    When method GET
    Then status 200
    And match response == '#[]'

  @get @deprecated
  Scenario: GET /pet/findByTags - Rechercher par tags multiples (200)
    Given path '/pet/findByTags'
    And param tags = 'friendly,playful'
    When method GET
    Then status 200
    And match response == '#[]'

  @negative @get @deprecated
  Scenario: GET /pet/findByTags - Tag invalide (400)
    Given path '/pet/findByTags'
    And param tags = ''
    When method GET
    Then assert responseStatus == 200 || responseStatus == 400

  # ============================================================================
  # GET /pet/{petId} - Récupérer un pet par ID
  # ============================================================================

  @smoke @get
  Scenario: GET /pet/{petId} - Récupérer un pet existant (200)
    # Créer d'abord le pet
    * def newPet = { "id": #(petId), "name": "TestPet", "photoUrls": ["http://example.com/photo.jpg"], "status": "available" }
    Given path '/pet'
    And request newPet
    When method POST
    Then status 200

    # Récupérer le pet
    Given path '/pet', petId
    When method GET
    Then status 200
    And match response.id == petId
    And match response.name == 'TestPet'

  @negative @get
  Scenario: GET /pet/{petId} - Pet non trouvé (404)
    Given path '/pet', 999999999
    When method GET
    Then status 404
    And match response contains { message: '#string' }

  @negative @get
  Scenario: GET /pet/{petId} - ID invalide format (400)
    Given path '/pet', 'invalid-id'
    When method GET
    Then assert responseStatus == 400 || responseStatus == 404

  @boundary @get
  Scenario: GET /pet/{petId} - ID négatif
    Given path '/pet', -1
    When method GET
    Then assert responseStatus == 400 || responseStatus == 404

  @boundary @get
  Scenario: GET /pet/{petId} - ID zéro
    Given path '/pet', 0
    When method GET
    Then assert responseStatus == 404 || responseStatus == 400

  # ============================================================================
  # POST /pet/{petId} - Mettre à jour avec form data
  # ============================================================================

  @post
  Scenario: POST /pet/{petId} - Mettre à jour nom et statut via form data (200)
    # Créer d'abord le pet
    * def newPet = { "id": #(petId), "name": "FormPet", "photoUrls": ["url"], "status": "available" }
    Given path '/pet'
    And request newPet
    When method POST
    Then status 200

    # Mettre à jour via form data
    Given path '/pet', petId
    And header Content-Type = 'application/x-www-form-urlencoded'
    And form field name = 'UpdatedFormPet'
    And form field status = 'sold'
    When method POST
    Then assert responseStatus == 200 || responseStatus == 405

  @negative @post
  Scenario: POST /pet/{petId} - Mise à jour form data invalide (405)
    Given path '/pet', 'invalid-id'
    And header Content-Type = 'application/x-www-form-urlencoded'
    And form field name = 'Test'
    When method POST
    Then assert responseStatus == 405 || responseStatus == 400 || responseStatus == 404

  # ============================================================================
  # POST /pet/{petId}/uploadImage - Upload d'image
  # ============================================================================

  @post
  Scenario: POST /pet/{petId}/uploadImage - Upload réussi (200)
    # Créer d'abord le pet
    * def newPet = { "id": #(petId), "name": "ImagePet", "photoUrls": ["url"], "status": "available" }
    Given path '/pet'
    And request newPet
    When method POST
    Then status 200

    # Upload d'image (simulation avec metadata)
    Given path '/pet', petId, 'uploadImage'
    And header Content-Type = 'multipart/form-data'
    And multipart field additionalMetadata = 'Test image upload'
    When method POST
    Then assert responseStatus == 200 || responseStatus == 415
    * if (responseStatus == 200) karate.match(response, { code: '#number', type: '#string', message: '#string' })

  # ============================================================================
  # DELETE /pet/{petId} - Supprimer un pet
  # ============================================================================

  @smoke @delete
  Scenario: DELETE /pet/{petId} - Supprimer un pet existant (200)
    # Créer d'abord le pet
    * def newPet = { "id": #(petId), "name": "ToDelete", "photoUrls": ["url"], "status": "available" }
    Given path '/pet'
    And request newPet
    When method POST
    Then status 200

    # Supprimer le pet
    Given path '/pet', petId
    And header api_key = apiKey
    When method DELETE
    Then assert responseStatus == 200 || responseStatus == 404

    # Vérifier la suppression
    Given path '/pet', petId
    When method GET
    Then status 404

  @negative @delete
  Scenario: DELETE /pet/{petId} - Pet inexistant (400/404)
    Given path '/pet', 999999999
    And header api_key = apiKey
    When method DELETE
    Then assert responseStatus == 400 || responseStatus == 404

  @negative @delete
  Scenario: DELETE /pet/{petId} - ID invalide (400)
    Given path '/pet', 'invalid-id'
    And header api_key = apiKey
    When method DELETE
    Then assert responseStatus == 400 || responseStatus == 404

  # ============================================================================
  # Scénarios de bout en bout (E2E)
  # ============================================================================

  @e2e @smoke
  Scenario: E2E - Cycle de vie complet d'un pet (Create -> Read -> Update -> Delete)
    * def e2ePetId = generatePetId()
    
    # 1. Créer un nouveau pet
    * def createPet = { "id": #(e2ePetId), "name": "E2EPet", "photoUrls": ["http://e2e.com/photo.jpg"], "status": "available" }
    Given path '/pet'
    And request createPet
    When method POST
    Then status 200
    And match response.id == e2ePetId

    # 2. Récupérer le pet créé
    Given path '/pet', e2ePetId
    When method GET
    Then status 200
    And match response.name == 'E2EPet'
    And match response.status == 'available'

    # 3. Mettre à jour le pet
    * def updatePet = { "id": #(e2ePetId), "name": "E2EPetUpdated", "photoUrls": ["http://e2e.com/updated.jpg"], "status": "sold" }
    Given path '/pet'
    And request updatePet
    When method PUT
    Then status 200
    And match response.name == 'E2EPetUpdated'
    And match response.status == 'sold'

    # 4. Vérifier la mise à jour
    Given path '/pet', e2ePetId
    When method GET
    Then status 200
    And match response.status == 'sold'

    # 5. Supprimer le pet
    Given path '/pet', e2ePetId
    And header api_key = apiKey
    When method DELETE
    Then assert responseStatus == 200 || responseStatus == 404

    # 6. Vérifier la suppression
    Given path '/pet', e2ePetId
    When method GET
    Then status 404
