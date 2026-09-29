package com.WebVipers.gemini.controller;

import com.WebVipers.gemini.dto.ExtractionResponse;
import com.WebVipers.gemini.service.GeminiApiService;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import java.io.IOException;

@RestController
@RequestMapping("/api/extraction")
@CrossOrigin(origins = "*")
public class ImageController {
    private final GeminiApiService geminiApiService;

    public ImageController(GeminiApiService geminiApiService) {
        this.geminiApiService = geminiApiService;
    }

    @PostMapping(value = "/image", consumes = MediaType.MULTIPART_FORM_DATA_VALUE, produces = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<ExtractionResponse> extract(@RequestParam("file") MultipartFile file) throws IOException {
        if (file.isEmpty()) throw new IllegalArgumentException("Aucun fichier image n’a été envoyé.");
        return ResponseEntity.ok(geminiApiService.extractFromImage(file));
    }
}