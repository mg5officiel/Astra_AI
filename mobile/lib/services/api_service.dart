import 'dart:convert';
import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../models/extraction_result.dart';

class ApiService {
  ApiService({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  static const _apiKeyKey = 'gemini_api_key';
  static const _model = 'gemini-2.5-flash';
  static const _baseUrl = 'https://generativelanguage.googleapis.com';

  final FlutterSecureStorage _storage;

  Future<bool> hasApiKey() async {
    final key = await _storage.read(key: _apiKeyKey);
    return key != null && key.trim().isNotEmpty;
  }

  Future<void> saveApiKey(String key) async {
    final value = key.trim();
    if (value.isEmpty) {
      await _storage.delete(key: _apiKeyKey);
      return;
    }
    await _storage.write(key: _apiKeyKey, value: value);
  }

  Future<void> deleteApiKey() => _storage.delete(key: _apiKeyKey);
  Future<String?> readApiKey() => _storage.read(key: _apiKeyKey);

  Future<ExtractionResult> extractImage(File image) async {
    final apiKey = await readApiKey();
    if (apiKey == null || apiKey.trim().isEmpty) {
      throw Exception('Configurez d’abord votre clé API Gemini dans Paramètres.');
    }

    final bytes = await image.readAsBytes();
    final body = {
      'contents': [
        {
          'parts': [
            {
              'text': '''Analyse cette image et extrais uniquement les informations visibles et lisibles.
Identifie le type de document. Pour chaque information, retourne un nom, une valeur et une confiance de 0 à 1.
Ne devine jamais. Respecte l’orthographe, les chiffres et les dates visibles.
Ajoute un avertissement si une zone est illisible. Retourne exclusivement le JSON demandé.''',
            },
            {
              'inline_data': {
                'mime_type': _mimeType(image.path),
                'data': base64Encode(bytes),
              }
            }
          ]
        }
      ],
      'generationConfig': {
        'temperature': 0.1,
        'responseMimeType': 'application/json',
        'responseSchema': {
          'type': 'OBJECT',
          'properties': {
            'documentType': {'type': 'STRING'},
            'fields': {
              'type': 'ARRAY',
              'items': {
                'type': 'OBJECT',
                'properties': {
                  'name': {'type': 'STRING'},
                  'value': {'type': 'STRING'},
                  'confidence': {'type': 'NUMBER'},
                },
                'required': ['name', 'value', 'confidence'],
              }
            },
            'confidence': {'type': 'NUMBER'},
            'warnings': {
              'type': 'ARRAY',
              'items': {'type': 'STRING'},
            },
          },
          'required': ['documentType', 'fields', 'confidence', 'warnings'],
        }
      }
    };

    final uri = Uri.parse(
      '$_baseUrl/v1beta/models/$_model:generateContent',
    );

    final result = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'x-goog-api-key': apiKey.trim(),
      },
      body: jsonEncode(body),
    ).timeout(const Duration(seconds: 90));

    dynamic decoded;
    try {
      decoded = jsonDecode(result.body);
    } catch (_) {
      throw Exception('Gemini a renvoyé une réponse invalide.');
    }

    if (result.statusCode < 200 || result.statusCode >= 300) {
      final error = decoded is Map<String, dynamic> ? decoded['error'] : null;
      final message = error is Map<String, dynamic>
          ? error['message']?.toString()
          : null;
      throw Exception(
        message ?? 'Gemini a refusé la requête (${result.statusCode}).',
      );
    }

    final text = _extractText(decoded);
    if (text == null || text.trim().isEmpty) {
      throw Exception('Gemini n’a retourné aucune donnée exploitable.');
    }

    try {
      final json = jsonDecode(text);
      if (json is! Map<String, dynamic>) throw const FormatException();
      return ExtractionResult.fromJson(json);
    } catch (_) {
      throw Exception('Le JSON retourné par Gemini est invalide.');
    }
  }

  String? _extractText(dynamic response) {
    if (response is! Map<String, dynamic>) return null;
    final candidates = response['candidates'];
    if (candidates is! List || candidates.isEmpty) return null;
    final candidate = candidates.first;
    if (candidate is! Map<String, dynamic>) return null;
    final content = candidate['content'];
    if (content is! Map<String, dynamic>) return null;
    final parts = content['parts'];
    if (parts is! List) return null;
    final buffer = StringBuffer();
    for (final part in parts) {
      if (part is Map<String, dynamic> && part['text'] != null) {
        buffer.write(part['text'].toString());
      }
    }
    return buffer.toString();
  }

  String _mimeType(String path) {
    final lower = path.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.webp')) return 'image/webp';
    if (lower.endsWith('.heic')) return 'image/heic';
    if (lower.endsWith('.heif')) return 'image/heif';
    return 'image/jpeg';
  }
}
