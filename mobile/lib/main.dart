import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'models/extraction_result.dart';
import 'pages/settings_page.dart';
import 'services/api_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AstraAiApp());
}

class AstraAiApp extends StatelessWidget {
  const AstraAiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Astra AI',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF6F8FC),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF5B5FEF)),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final picker = ImagePicker();
  final api = ApiService();

  XFile? image;
  ExtractionResult? result;
  String? error;
  bool loading = false;

  Future<void> pick(ImageSource source) async {
    setState(() {
      error = null;
      result = null;
    });
    final selected = await picker.pickImage(
      source: source,
      imageQuality: 90,
      maxWidth: 2400,
    );
    if (selected != null) setState(() => image = selected);
  }

  Future<void> extract() async {
    if (image == null) return;
    setState(() {
      loading = true;
      error = null;
      result = null;
    });

    try {
      final data = await api.extractImage(File(image!.path));
      if (mounted) setState(() => result = data);
    } catch (e) {
      if (mounted) {
        setState(() => error = e.toString().replaceFirst('Exception: ', ''));
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  void reset() {
    setState(() {
      image = null;
      result = null;
      error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Astra AI', style: TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          IconButton(
            tooltip: 'Paramètres',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => SettingsPage(api: api)),
            ),
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          children: [
            _HeaderCard(),
            const SizedBox(height: 18),
            _ImageCard(
              image: image,
              onGallery: () => pick(ImageSource.gallery),
              onCamera: () => pick(ImageSource.camera),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: image == null || loading ? null : extract,
              icon: loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.auto_awesome_rounded),
              label: Text(loading ? 'Analyse en cours…' : 'Extraire les données'),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(54),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
            if (image != null && !loading)
              TextButton.icon(
                onPressed: reset,
                icon: const Icon(Icons.close_rounded),
                label: const Text('Réinitialiser'),
              ),
            if (error != null) ...[
              const SizedBox(height: 10),
              _ErrorCard(message: error!),
            ],
            if (result != null) ...[
              const SizedBox(height: 24),
              _ResultCard(result: result!),
            ],
          ],
        ),
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF5B5FEF), Color(0xFF7B61FF)],
        ),
        borderRadius: BorderRadius.circular(26),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 34),
          SizedBox(height: 16),
          Text(
            'Extraction intelligente',
            style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800),
          ),
          SizedBox(height: 8),
          Text(
            'Importez un document ou utilisez la caméra. '
            'Astra AI extrait les informations lisibles avec Gemini.',
            style: TextStyle(color: Colors.white70, height: 1.45),
          ),
        ],
      ),
    );
  }
}

class _ImageCard extends StatelessWidget {
  const _ImageCard({
    required this.image,
    required this.onGallery,
    required this.onCamera,
  });

  final XFile? image;
  final VoidCallback onGallery;
  final VoidCallback onCamera;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(blurRadius: 24, offset: Offset(0, 8), color: Color(0x0D000000)),
        ],
      ),
      child: Column(
        children: [
          if (image == null)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 34),
              child: Column(
                children: [
                  Icon(Icons.image_outlined, size: 52, color: Colors.black26),
                  SizedBox(height: 10),
                  Text('Aucune image sélectionnée', style: TextStyle(fontWeight: FontWeight.w700)),
                  SizedBox(height: 4),
                  Text('Choisissez une photo ou utilisez la caméra'),
                ],
              ),
            )
          else
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.file(
                File(image!.path),
                height: 240,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onGallery,
                  icon: const Icon(Icons.photo_library_outlined),
                  label: const Text('Galerie'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onCamera,
                  icon: const Icon(Icons.camera_alt_outlined),
                  label: const Text('Caméra'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline_rounded, color: Colors.red),
          const SizedBox(width: 10),
          Expanded(child: Text(message)),
        ],
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({required this.result});
  final ExtractionResult result;

  @override
  Widget build(BuildContext context) {
    final confidence = (result.confidence.clamp(0, 1) * 100).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Résultat', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                result.documentType.isEmpty ? 'Document non identifié' : result.documentType,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 6),
              Text('Confiance globale : $confidence%'),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: result.confidence.clamp(0, 1),
                minHeight: 6,
                borderRadius: BorderRadius.circular(10),
              ),
              const Divider(height: 28),
              if (result.fields.isEmpty)
                const Text('Aucun champ exploitable n’a été identifié.')
              else
                ...result.fields.map((field) => Padding(
                      padding: const EdgeInsets.only(bottom: 18),
                      child: _FieldTile(field: field),
                    )),
              if (result.warnings.isNotEmpty) ...[
                const Divider(height: 20),
                const Text('Avertissements', style: TextStyle(fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                ...result.warnings.map((warning) => Padding(
                      padding: const EdgeInsets.only(bottom: 5),
                      child: Text('• $warning'),
                    )),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _FieldTile extends StatelessWidget {
  const _FieldTile({required this.field});
  final ExtractedField field;

  @override
  Widget build(BuildContext context) {
    final confidence = (field.confidence.clamp(0, 1) * 100).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(field.name, style: const TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 5),
        SelectableText(field.value.isEmpty ? 'Non lisible' : field.value),
        const SizedBox(height: 7),
        Row(
          children: [
            Expanded(
              child: LinearProgressIndicator(
                value: field.confidence.clamp(0, 1),
                minHeight: 4,
              ),
            ),
            const SizedBox(width: 10),
            Text('$confidence%'),
          ],
        ),
      ],
    );
  }
}
