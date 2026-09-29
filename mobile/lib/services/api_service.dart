import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/extraction_result.dart';

class ApiService {
  ApiService({
    String? baseUrl,
  }) : baseUrl = baseUrl ??
            const String.fromEnvironment(
              'API_URL',
              defaultValue: 'http://10.0.2.2:8080',
            );

  final String baseUrl;

  Future<ExtractionResult> extractImage(File image) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/api/extraction/image'),
    );

    request.files.add(await http.MultipartFile.fromPath('file', image.path));

    final streamed = await request.send().timeout(const Duration(seconds: 90));
    final response = await http.Response.fromStream(streamed);

    dynamic body;
    try {
      body = jsonDecode(response.body);
    } catch (_) {
      throw Exception('Le serveur a renvoyé une réponse invalide.');
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final message = body is Map<String, dynamic>
          ? body['message']?.toString()
          : null;
      throw Exception(
        message ?? ('Erreur ' + response.statusCode.toString() + ' lors de l’analyse.'),
      );
    }

    if (body is! Map<String, dynamic>) {
      throw Exception('Réponse invalide du serveur.');
    }

    return ExtractionResult.fromJson(body);
  }
}
