# Astra AI — Flutter

Astra AI est désormais une application mobile 100 % Flutter côté client pour analyser des images avec Google Gemini.

## Architecture

Flutter → HTTPS → Google Gemini API

Spring Boot n'est plus nécessaire pour faire fonctionner l'application mobile.

## Fonctionnalités
- Sélection d'une image depuis la galerie
- Prise de photo avec la caméra
- Analyse multimodale avec Gemini
- Extraction structurée en JSON
- Type de document
- Champs extraits
- Niveau de confiance par champ et global
- Avertissements lorsque des informations sont illisibles
- Gestion des erreurs
- Écran Paramètres
- Stockage sécurisé de la clé API Gemini

## Configuration
1. Ouvrir l'application.
2. Aller dans Paramètres.
3. Saisir une clé API Gemini.
4. Enregistrer.
5. Sélectionner une image.
6. Appuyer sur Extraire les données.

La clé API n'est pas écrite dans le code source. Elle est stockée localement avec flutter_secure_storage.

## Lancer localement
Depuis le dossier mobile : flutter create --platforms=android --org=com.astraai . puis flutter pub get et flutter run.

## Générer l'APK
Depuis mobile : flutter create --platforms=android --org=com.astraai . ; flutter pub get ; flutter analyze ; flutter build apk --release.

L'APK sera généré dans build/app/outputs/flutter-apk/app-release.apk.

## Sécurité
La clé Gemini saisie dans l'application est une clé utilisateur. Elle ne doit jamais être commitée dans GitHub.

Pour une application distribuée à grande échelle, un backend intermédiaire avec authentification, quotas et rotation des clés reste préférable.