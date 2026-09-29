package com.WebVipers.gemini.service;

import com.WebVipers.gemini.dto.ExtractionResponse;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestClient;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.*;

@Service
public class GeminiApiService {
    private static final String EXTRACTION_PROMPT = """
        Analyse attentivement l’image fournie et extrais uniquement les informations
        réellement visibles et lisibles.

        Règles :
        - Ne devine aucune information.
        - Respecte l’orthographe et les chiffres visibles.
        - Si une valeur est absente ou illisible, ne l’invente pas.
        - Identifie le type de document si possible.
        - Retourne uniquement le JSON demandé par le schéma.
        - Pour chaque donnée extraite, donne son nom, sa valeur et un niveau
          de confiance entre 0 et 1.
        """;

    private final RestClient restClient;
    private final ObjectMapper objectMapper;
    private final String apiKey;
    private final String model;

    public GeminiApiService(RestClient.Builder builder, ObjectMapper objectMapper,
                            @Value("${gemini.api-key:}") String apiKey,
                            @Value("${gemini.model:gemini-2.5-flash}") String model,
                            @Value("${gemini.base-url:https://generativelanguage.googleapis.com}") String baseUrl) {
        this.restClient = builder.baseUrl(baseUrl).build();
        this.objectMapper = objectMapper;
        this.apiKey = apiKey;
        this.model = model;
    }

    public ExtractionResponse extractFromImage(MultipartFile file) throws IOException {
        if (apiKey.isBlank()) throw new IllegalStateException("GEMINI_API_KEY n’est pas configurée.");
        String mimeType = Optional.ofNullable(file.getContentType())
                .filter(v -> v.startsWith("image/"))
                .orElseThrow(() -> new IllegalArgumentException("Le fichier doit être une image."));
        String base64 = Base64.getEncoder().encodeToString(file.getBytes());

        Map<String, Object> request = Map.of(
                "contents", List.of(Map.of("parts", List.of(
                        Map.of("inline_data", Map.of("mime_type", mimeType, "data", base64)),
                        Map.of("text", EXTRACTION_PROMPT)
                ))),
                "generationConfig", Map.of(
                        "responseMimeType", "application/json",
                        "responseSchema", schema()
                )
        );

        JsonNode response = restClient.post()
                .uri("/v1beta/models/{model}:generateContent", model)
                .contentType(MediaType.APPLICATION_JSON)
                .header("x-goog-api-key", apiKey)
                .body(request)
                .retrieve()
                .body(JsonNode.class);

        if (response == null) throw new IllegalStateException("Réponse vide de Gemini.");
        JsonNode candidates = response.path("candidates");
        if (!candidates.isArray() || candidates.isEmpty())
            throw new IllegalStateException("Gemini n’a retourné aucun résultat.");

        JsonNode parts = candidates.get(0).path("content").path("parts");
        if (!parts.isArray() || parts.isEmpty())
            throw new IllegalStateException("Gemini n’a retourné aucun contenu.");
        String json = parts.get(0).path("text").asText(null);
        if (json == null || json.isBlank())
            throw new IllegalStateException("Gemini n’a retourné aucune donnée exploitable.");

        return objectMapper.readValue(json, ExtractionResponse.class);
    }

    private Map<String, Object> schema() {
        Map<String, Object> field = Map.of(
                "type", "OBJECT",
                "properties", Map.of(
                        "name", Map.of("type", "STRING"),
                        "value", Map.of("type", "STRING"),
                        "confidence", Map.of("type", "NUMBER")
                ),
                "required", List.of("name", "value", "confidence")
        );
        return Map.of(
                "type", "OBJECT",
                "properties", Map.of(
                        "documentType", Map.of("type", "STRING"),
                        "fields", Map.of("type", "ARRAY", "items", field),
                        "confidence", Map.of("type", "NUMBER"),
                        "warnings", Map.of("type", "ARRAY", "items", Map.of("type", "STRING"))
                ),
                "required", List.of("documentType", "fields", "confidence", "warnings")
        );
    }
}