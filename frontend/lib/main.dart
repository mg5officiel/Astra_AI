import "dart:io";
import "package:flutter/material.dart";
import "package:image_picker/image_picker.dart";
import "models/extraction_result.dart";
import "services/api_service.dart";

void main() => runApp(const AstraAiApp());

class AstraAiApp extends StatelessWidget {
  const AstraAiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Astra AI",
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
      home: const ExtractionPage(),
    );
  }
}

class ExtractionPage extends StatefulWidget {
  const ExtractionPage({super.key});
  @override
  State<ExtractionPage> createState() => _ExtractionPageState();
}

class _ExtractionPageState extends State<ExtractionPage> {
  final picker = ImagePicker();
  final api = const ApiService(baseUrl: "http://10.0.2.2:8080");
  File? image;
  ExtractionResult? result;
  bool loading = false;
  String? error;

  Future<void> pick(ImageSource source) async {
    final selected = await picker.pickImage(source: source, imageQuality: 90);
    if (selected == null) return;
    setState(() { image = File(selected.path); result = null; error = null; });
  }

  Future<void> extract() async {
    if (image == null) return;
    setState(() { loading = true; error = null; });
    try {
      final value = await api.extract(image!);
      if (mounted) setState(() => result = value);
    } catch (e) {
      if (mounted) setState(() => error = e.toString());
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Astra AI"), centerTitle: true),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        const Text("Extraction intelligente", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const Text("Sélectionnez une image et Gemini extraira les données visibles."),
        const SizedBox(height: 24),
        Container(
          height: 260,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: Theme.of(context).colorScheme.surfaceContainerHighest),
          clipBehavior: Clip.antiAlias,
          child: image == null
              ? const Center(child: Icon(Icons.document_scanner_outlined, size: 72))
              : Image.file(image!, fit: BoxFit.cover),
        ),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(child: OutlinedButton.icon(onPressed: () => pick(ImageSource.gallery), icon: const Icon(Icons.photo_library_outlined), label: const Text("Galerie"))),
          const SizedBox(width: 12),
          Expanded(child: OutlinedButton.icon(onPressed: () => pick(ImageSource.camera), icon: const Icon(Icons.camera_alt_outlined), label: const Text("Caméra"))),
        ]),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: image == null || loading ? null : extract,
          icon: loading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.auto_awesome),
          label: Text(loading ? "Extraction en cours..." : "Extraire les données"),
        ),
        if (error != null) ...[
          const SizedBox(height: 16),
          Card(child: Padding(padding: const EdgeInsets.all(16), child: Text(error!, style: TextStyle(color: Theme.of(context).colorScheme.error)))),
        ],
        if (result != null) ...[
          const SizedBox(height: 24),
          Text(result!.documentType, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          LinearProgressIndicator(value: result!.confidence.clamp(0, 1)),
          const SizedBox(height: 16),
          ...result!.fields.map((field) => Card(
            child: ListTile(
              title: Text(field.name),
              subtitle: Text(field.value.isEmpty ? "Non détecté" : field.value),
              trailing: Text("${(field.confidence * 100).round()}%"),
            ),
          )),
          if (result!.warnings.isNotEmpty) ...[
            const SizedBox(height: 8),
            const Text("Avertissements", style: TextStyle(fontWeight: FontWeight.bold)),
            ...result!.warnings.map((w) => ListTile(leading: const Icon(Icons.warning_amber_rounded), title: Text(w))),
          ]
        ],
      ]),
    );
  }
}