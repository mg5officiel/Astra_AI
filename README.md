# Traitement d'Images avec Google Gemini 1.5 Flash — Java Spring Boot (sans Vertex API)

Une API Java Spring Boot pour interagir avec Google Gemini afin de télécharger des images, traiter des invites et générer du contenu facilement. Cette intégration utilise l'API gratuite de Google AI Studio pour une utilisation limitée, la rendant accessible aux développeurs intéressés par l'analyse d'images et la génération de contenu assistées par IA.

---

# Intégration Java de l'API Google Gemini

Ce projet open-source fournit un service et un controller Java Spring Boot pour interagir avec les fonctionnalités de traitement d'images et de génération de contenu de Google Gemini via une API REST.

## Présentation

Cette intégration offre un moyen simplifié de télécharger des images, de les traiter avec une invite textuelle et de recevoir des réponses générées par le modèle Gemini de Google. Elle utilise une clé API gratuite disponible via Google AI Studio pour une utilisation limitée non commerciale, la rendant accessible pour des expérimentations. Ce projet est particulièrement utile pour ceux qui souhaitent explorer l'API Gemini de Google sans s'engager dans des offres payantes.

## Fonctionnalités

- **Téléchargement d'images** : Permet l'envoi d'images en multipart vers le service Google, pour analyse ou génération de contenu.
- **Invites texte et image** : Combine des entrées image et texte pour des résultats de génération de contenu plus dynamiques.
- **Configuration flexible** : Les clés API et les paramètres de requête sont facilement personnalisables.
- **Open Source et personnalisable** : Conçu pour être modifiable selon divers cas d'usage, idéal pour les développeurs intéressés par les intégrations IA.

## Installation

### Prérequis

- **Java JDK** 11 ou version ultérieure
- **Maven** : Pour gérer les dépendances et construire le projet
- **Clé API Google** : Disponible via Google AI Studio pour accéder à l'API Gemini

### Étapes

1. **Cloner le dépôt** :

   ```bash
   git clone https://github.com/yourusername/Google-Gemini-1.5-Flash-Image-Processing-Java-Spring-Boot-without-VertexAPI.git
   cd Google-Gemini-1.5-Flash-Image-Processing-Java-Spring-Boot-without-VertexAPI
   ```

2. **Configurer la clé API** :  
   Ouvrez le fichier `application.properties` et ajoutez votre clé API Google.
   ```properties
   google.api.key=VOTRE_CLE_API_GOOGLE
   ```

## Utilisation

L'API expose un endpoint pour télécharger des images et envoyer des invites, vous permettant d'interagir avec l'API Gemini de Google de manière transparente.

### Endpoint : `POST /gemini/process-image`

- **Paramètres** :
    - `file` (MultipartFile) : Le fichier image à traiter.
    - `prompt` (String) : L'invite textuelle associée à l'image pour guider la génération de contenu.
- **Réponse** :
    - L'endpoint retourne une structure JSON contenant un code de succès, un message et les données générées par Google Gemini.

**Exemple de requête (avec cURL)** :
```bash
curl -X POST "http://localhost:8080/gemini/process-image" \
     -F "file=@/chemin/vers/votre/image.jpg" \
     -F "prompt=Décrivez le contenu de cette image."
```

## Personnalisation

Ce projet vous permet de modifier divers paramètres et la logique de traitement pour s'adapter à différentes applications :

1. **Modifier les paramètres de requête** :
   Ajustez les propriétés comme `temperature`, `topK` et `topP` dans la classe `GeminiApiService.java` pour contrôler la façon dont le modèle Gemini traite vos entrées, en influençant l'aléatoire et la créativité des résultats.

2. **Analyser la réponse** :
   Si votre application nécessite un format différent ou un sous-ensemble de la réponse, vous pouvez personnaliser la façon dont la réponse de Google Gemini est analysée ou formatée en modifiant la logique de traitement des réponses du service.

3. **Étendre les fonctionnalités** :
   Les utilisateurs peuvent ajouter des endpoints API supplémentaires ou s'intégrer davantage aux services IA de Google pour étendre les fonctionnalités au-delà des tâches initiales de génération d'images et de texte.

## Licence

Ce projet est sous licence MIT, qui autorise une large utilisation et modification. Consultez le fichier `LICENSE` pour plus de détails.
