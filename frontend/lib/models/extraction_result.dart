class ExtractedField {
  final String name;
  final String value;
  final double confidence;

  const ExtractedField({required this.name, required this.value, required this.confidence});

  factory ExtractedField.fromJson(Map<String, dynamic> json) => ExtractedField(
    name: json["name"]?.toString() ?? "",
    value: json["value"]?.toString() ?? "",
    confidence: (json["confidence"] as num?)?.toDouble() ?? 0,
  );
}

class ExtractionResult {
  final String documentType;
  final List<ExtractedField> fields;
  final double confidence;
  final List<String> warnings;

  const ExtractionResult({required this.documentType, required this.fields, required this.confidence, required this.warnings});

  factory ExtractionResult.fromJson(Map<String, dynamic> json) => ExtractionResult(
    documentType: json["documentType"]?.toString() ?? "Document",
    fields: ((json["fields"] as List?) ?? []).
        whereType<Map<String, dynamic>>().map(ExtractedField.fromJson).toList(),
    confidence: (json["confidence"] as num?)?.toDouble() ?? 0,
    warnings: ((json["warnings"] as List?) ?? []).map((e) => e.toString()).toList(),
  );
}