package com.WebVipers.gemini.controller;

import com.WebVipers.gemini.dto.ImageDTO;
import com.WebVipers.gemini.service.GeminiApiService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;

public class ImageController {

    private final GeminiApiService geminiApiService;

    public ImageController(GeminiApiService geminiApiService) {
        this.geminiApiService = geminiApiService;
    }

    @PostMapping(value = "/extraire", consumes = "multipart/form-data")
    public ResponseEntity<?> extraire(@RequestParam("fichier") MultipartFile fichier) {
        if (fichier.isEmpty()) {
            return ResponseEntity.badRequest().body("Aucun fichier fourni.");
        }
        try {
            ImageDTO donnees = geminiApiService.extraireDonnees(fichier);
            return ResponseEntity.ok(donnees);
        } catch (IOException e) {
            return ResponseEntity.status(HttpStatus.BAD_GATEWAY)
                    .body("Échec de l'extraction via Gemini : " + e.getMessage());
        }
    }

    /**
     * Extrait les données de la carte et renvoie directement un Patient
     * pré-rempli (prénom, nom, sexe) — non enregistré en base. Le frontend
     * peut afficher ce Patient dans le formulaire de création, laisser
     * l'utilisateur compléter téléphone/adresse (absents de la carte),
     * puis envoyer l'objet complété à POST /patients/new pour l'enregistrer.
     */
    @PostMapping(value = "/extraire-patient", consumes = "multipart/form-data")
    public ResponseEntity<?> extrairePatient(@RequestParam("fichier") MultipartFile fichier) {
        if (fichier.isEmpty()) {
            return ResponseEntity.badRequest().body("Aucun fichier fourni.");
        }
        try {
            ImageDTO donnees = geminiApiService.extraireDonnees(fichier);
            Patient patient = versPatient(donnees);
            return ResponseEntity.ok(patient);
        } catch (IOException e) {
            return ResponseEntity.status(HttpStatus.BAD_GATEWAY)
                    .body("Échec de l'extraction via Gemini : " + e.getMessage());
        }
    }

}
