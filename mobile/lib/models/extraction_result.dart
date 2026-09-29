class ExtractedField {
  final String name;
  final String value;
  final double confidence;

  const ExtractedField({
    required this.name,
    required this.value,
    required this.confidence,
  });

  factory ExtractedField.fromJson(Map<String, dynamic> json) {
    return ExtractedField(
      name: json['name']?.toString() ?? '',
      value: json['value']?.toString() ?? '',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0,
    );
  }
}

class ExtractionResult {
  final String documentType;
  final List<ExtractedField> fields;
  final double confidence;
  final List<String> warnings;

  const ExtractionResult({
    required this.documentType,
    required this.fields,
    required this.confidence,
    required this.warnings,
  });

  factory ExtractionResult.fromJson(Map<String, dynamic> json) {
    return ExtractionResult(
      documentType: json['documentType']?.toString() ?? '',
      fields: (json['fields'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(ExtractedField.fromJson)
          .toList(),
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0,
      warnings: (json['warnings'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
    );
  }
}
