# Astra AI

Application d’extraction de données depuis une image avec Google Gemini.

## Architecture

Flutter → Spring Boot → Gemini API → JSON structuré → Flutter

- Frontend : Flutter
- Backend : Spring Boot 3.3.5 / Java 17
- IA : Gemini Developer API
- Modèle par défaut : gemini-2.5-flash
- Transport image : multipart/form-data vers Spring Boot, puis inline_data base64 vers Gemini

## API

### Vérification
GET /api/health

### Extraction
POST /api/extraction/image

Form-data :
- file : image à analyser

Réponse :

{
  "documentType": "Carte d’identité",
  "fields": [
    { "name": "Nom", "value": "DUPONT", "confidence": 0.98 }
  ],
  "confidence": 0.95,
  "warnings": []
}

## Configuration Gemini

Configurer la clé API dans src/main/resources/application.properties :

gemini.api-key=VOTRE_CLE_GEMINI
gemini.model=gemini-2.5-flash
gemini.base-url=https://generativelanguage.googleapis.com

Pour un déploiement, il est préférable de fournir la clé via une variable d’environnement GEMINI_API_KEY et de ne jamais l’inclure dans Flutter.

## Flutter

Le frontend se trouve dans frontend/.

cd frontend
flutter create .
flutter pub get
flutter run

Pour Android Emulator, l’API locale est configurée sur http://10.0.2.2:8080. Pour un téléphone physique, remplacer cette adresse par l’adresse IP LAN du PC hébergeant Spring Boot.

## Remarque

L’extraction est volontairement générique : Gemini retourne uniquement les informations visibles et lisibles et ne doit pas inventer une valeur absente.
