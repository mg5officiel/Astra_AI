# Astra AI

Astra AI est une application d'extraction intelligente d'informations depuis des images.

## Application mobile

L'application active est désormais **Flutter** et se trouve dans le dossier [mobile](mobile).

Architecture de fonctionnement :

Flutter → Google Gemini API

Le client Flutter ne dépend plus de l'API Spring Boot pour effectuer l'extraction. La clé Gemini est saisie par l'utilisateur dans Paramètres et conservée dans le stockage sécurisé de l'appareil.

## Lancer l'application

Depuis le dossier mobile :

flutter create --platforms=android --org=com.astraai .
flutter pub get
flutter run

## Générer l'APK

flutter build apk --release

Un workflow GitHub Actions est également fourni dans .github/workflows/flutter-apk.yml pour analyser et construire l'APK automatiquement.

## Sécurité

Ne committez jamais une clé API Gemini dans le dépôt.

Le backend Spring Boot historique est conservé dans le dépôt pour le moment, mais il n'est plus utilisé par l'application Flutter.
