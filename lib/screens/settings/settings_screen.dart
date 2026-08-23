import 'package:flutter/material.dart';
import '../shop/shop_screen.dart';
import '../../core/storage_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final StorageService storage = StorageService();
  bool _progressive = false;

  @override
  void initState() {
    super.initState();
    _progressive = storage.isProgressiveDifficulty();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Configurações', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              color: Colors.grey[900],
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: SwitchListTile(
                title: const Text(
                  'Dificuldade Progressiva',
                  style: TextStyle(color: Colors.white),
                ),
                subtitle: Text(
                  'Conforme você sobe de nível, perguntas mais difíceis são misturadas.',
                  style: TextStyle(color: Colors.grey[400]),
                ),
                value: _progressive,
                onChanged: (value) async {
                  setState(() {
                    _progressive = value;
                  });
                  await storage.setProgressiveDifficulty(value);
                },
                activeColor: Colors.blue,
              ),
            ),
            const SizedBox(height: 20),
            // Botão para ir à loja (já temos o BUILD na Home, mas mantemos opcional)
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ShopScreen()),
                );
              },
              icon: const Icon(Icons.shopping_cart, color: Colors.white),
              label: const Text('🛒 Ir à Loja'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber[700],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}