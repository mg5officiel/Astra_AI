package com.WebVipers.gemini.service;

import java.io.IOException;

import javax.print.attribute.standard.Media;

import org.springframework.util.MimeType;
import org.springframework.web.multipart.MultipartFile;

public class GeminiImageService {

    private static final String PROMPT = """
            Analyse cette image de carte d'identité et extrait précisément chaque champ visible.
            Respecte l'orthographe exacte telle qu'elle apparaît sur le document.
            Si un champ n'est pas visible ou illisible, retourne une chaîne vide pour ce champ.
            Ne fournis aucun texte en dehors du format demandé.
            """;
    private final ChatClient chatClient;

    public GeminiImageService(ChatClient.Builder chatClientBuilder) {
        this.chatClient = chatClientBuilder.build();
    }

    public CarteIdentiteDTO extraireDonnees(MultipartFile fichier) throws IOException {
        String mimeType = fichier.getContentType() != null ? fichier.getContentType() : "image/jpeg";
        Media image = new Media(MimeType.valueOf(mimeType), fichier.getResource());

        return chatClient.prompt()
                .user(u -> u.text(PROMPT).media(image))
                .call()
                .entity(CarteIdentiteDTO.class);
    }
    
}
