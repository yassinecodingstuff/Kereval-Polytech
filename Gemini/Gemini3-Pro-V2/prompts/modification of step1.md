
## 1. Clarification et extension du rôle de l’expert

### Avant :
- “world-class test automation engineer with over 25 years of hands-on experience”

### Après :
- Ajout d’expertises plus spécifiques : API testing, Karate, Gherkin, ISTQB, ISO 29119.

**Impact :** meilleure compréhension du rôle attendu (orientation API + Gherkin + standards industriels).

---

## 2. Élargissement du périmètre des tests à produire

### Avant :
- “write comprehensive API test cases”

### Après :
- “write a COMPLETE set of API test scenarios”
- Couvrir tous les endpoints majeurs + variations positives/négatives

**Impact :** livrable plus exhaustif et structuré.

---

## 3. Formalisation stricte des exigences de précision

### Avant :
- “Be precise, thorough, and technically accurate.”

### Après :
- Exigence explicite : les champs, types, status codes doivent suivre _exactement_ le Swagger.

**Impact :** réduction drastique d’erreurs dans les payloads et endpoints.

---

## 4. Ajout du bloc "COVERAGE REQUIREMENTS"

Section entièrement nouvelle, contenant :

- Risk-based testing
- Tests positifs obligatoires
- Tests négatifs obligatoires
- Variations valides
- Invalid inputs (champs manquants, mauvais types, enums invalides)

**Impact :** Augmentation des cas de tests.

---

## 5. Renforcement de la couverture négative

### Avant :
- pas de règles négatives spécifiques

### Après :
- Tests négatifs obligatoires :  
  - mauvais types  
  - mauvais enums  
  - champs manquants  
  - formats invalides  
  - credentials incorrects

**Impact :** meilleure robustesse et détection de défauts.

---

## 6. Renforcement de la règle de nommage

La nouvelle version insiste davantage sur :

- titres descriptifs  
- cohérence documentaire  

**Impact :** structure de tests plus professionnelle.

---

## 7. Alignement renforcé avec ISO/IEC/IEEE 29119

Pour chaque norme :

- **29119-1 :** concepts et terminologie cohérente  
- **29119-2 :** workflow structuré  
- **29119-3 :** documentation lisible et réutilisable  
- **29119-4 :** techniques de tests en boîte noire  
- **29119-5 :** approche keyword-driven  

**Impact :** les scénarios générés respectent les standards du secteur.

---




## 8. Clarification de la contrainte d'output

Toujours présente mais mieux cadrée :

- aucun texte  
- aucun commentaire  
- uniquement du Gherkin pur  

**Impact :** output propre, prêt à l’usage.

---



