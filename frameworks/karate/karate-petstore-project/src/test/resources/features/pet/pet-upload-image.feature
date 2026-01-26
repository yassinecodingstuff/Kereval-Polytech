Feature: PET - Upload image (/pet/{petId}/uploadImage)

Background:
  * url baseUrl
  * configure headers = { Accept: 'application/json' }
  * if (karate.get('apiKey')) header api_key = apiKey
  * if (karate.get('oauthToken')) header Authorization = 'Bearer ' + oauthToken
  * def samplePath = 'classpath:files/sample.png'

@happy
Scenario: POST /pet/{petId}/uploadImage - 200
  * path 'pet', 1, 'uploadImage'
  * multipart file file = { read: #(samplePath), filename: 'sample.png', contentType: 'image/png' }
  * multipart field additionalMetadata = 'avatar'
  * method post
  * status 200
  * match response contains { code: '#number', message: '##string' }
