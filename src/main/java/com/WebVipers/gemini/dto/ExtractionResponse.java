package com.WebVipers.gemini.dto;

import java.util.List;

public record ExtractionResponse(
        String documentType,
        List<ExtractedField> fields,
        double confidence,
        List<String> warnings
) {}