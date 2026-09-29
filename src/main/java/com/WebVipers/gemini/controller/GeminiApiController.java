package com.WebVipers.gemini.controller;

import com.WebVipers.gemini.service.GeminiApiService;
import com.fasterxml.jackson.databind.JsonNode;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.HashMap;
import java.util.logging.Logger;

@RestController
@RequestMapping("/gemini")
public class GeminiApiController {

    @Autowired
    private GeminiApiService geminiApiService;

    // Endpoint de test : POST /ia/ask  { "prompt": "..." }
    @PostMapping("/ask")
    public String ask(@RequestBody PromptRequest request) {
        return geminiApiService.generateText(request.getPrompt());
    }

    public static class PromptRequest {
        private String prompt;

        public String getPrompt() {
            return prompt;
        }

        public void setPrompt(String prompt) {
            this.prompt = prompt;
        }
    }
}
