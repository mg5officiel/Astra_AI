import 'package:flutter/material.dart';

import '../services/api_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key, required this.api});
  final ApiService api;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final controller = TextEditingController();
  bool loading = true;
  bool obscure = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final key = await widget.api.readApiKey();
    if (mounted) {
      controller.text = key ?? '';
      setState(() => loading = false);
    }
  }

  Future<void> _save() async {
    await widget.api.saveApiKey(controller.text);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Clé API enregistrée sur cet appareil.')),
    );
  }

  Future<void> _delete() async {
    await widget.api.deleteApiKey();
    controller.clear();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Clé API supprimée.')),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Paramètres')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Icon(Icons.key_rounded, size: 52),
          const SizedBox(height: 16),
          const Text(
            'Clé API Gemini',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          const Text(
            'Astra AI utilise Gemini directement depuis Flutter. '
            'La clé saisie ici est conservée dans le stockage sécurisé de l’appareil.',
            style: TextStyle(height: 1.5),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: controller,
            obscureText: obscure,
            autocorrect: false,
            enableSuggestions: false,
            decoration: InputDecoration(
              labelText: 'API Key Gemini',
              hintText: 'AIza...',
              prefixIcon: const Icon(Icons.vpn_key_outlined),
              suffixIcon: IconButton(
                onPressed: () => setState(() => obscure = !obscure),
                icon: Icon(obscure ? Icons.visibility : Icons.visibility_off),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _save,
            icon: const Icon(Icons.save_outlined),
            label: const Text('Enregistrer'),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: _delete,
            icon: const Icon(Icons.delete_outline),
            label: const Text('Supprimer la clé'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          const SizedBox(height: 28),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Sécurité : ne publiez jamais une clé Gemini personnelle dans GitHub, '
                'un dépôt public ou une capture d’écran.',
                style: TextStyle(height: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
