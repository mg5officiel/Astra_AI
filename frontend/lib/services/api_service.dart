import "dart:convert";
import "dart:io";
import "package:http/http.dart" as http;
import "../models/extraction_result.dart";

class ApiService {
  final String baseUrl;
  const ApiService({required this.baseUrl});

  Future<ExtractionResult> extract(File image) async {
    final request = http.MultipartRequest("POST", Uri.parse("$baseUrl/api/extraction/image"));
    request.files.add(await http.MultipartFile.fromPath("file", image.path));
    final streamed = await request.send().timeout(const Duration(seconds: 90));
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception("Erreur API (${response.statusCode}) : ${response.body}");
    }

    return ExtractionResult.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }
}