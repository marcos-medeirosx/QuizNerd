import 'package:flutter/material.dart';
import '../difficulty/difficulty_screen.dart';
import '../settings/settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 1),
              Column(
                children: [
                  const Text(
                    '🧠 QUIZ NERD',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '"Você realmente sabe?"',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[400],
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              const Spacer(flex: 1),
              Center(
                child: Column(
                  children: [
                    _buildCategoryButton(
                      context: context,
                      icon: '🎬',
                      label: 'FILMES',
                      categoryKey: 'movies',
                      categoryTitle: 'Filmes',
                    ),
                    const SizedBox(height: 16),
                    _buildCategoryButton(
                      context: context,
                      icon: '📺',
                      label: 'ANIMES',
                      categoryKey: 'anime',
                      categoryTitle: 'Animes',
                    ),
                    const SizedBox(height: 16),
                    _buildCategoryButton(
                      context: context,
                      icon: '🎮',
                      label: 'GAMES',
                      categoryKey: 'games',
                      categoryTitle: 'Games',
                    ),
                    const SizedBox(height: 16),
                    _buildCategoryButton(
                      context: context,
                      icon: '🔥',
                      label: 'MIX NERD',
                      categoryKeys: ['movies', 'anime', 'games'],
                      categoryTitle: 'Mix Nerd',
                    ),
                  ],
                ),
              ),
              const Spacer(flex: 2),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SettingsScreen()),
                  );
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.settings, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(
                      'Configurações',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryButton({
    required BuildContext context,
    required String icon,
    required String label,
    String? categoryKey,
    List<String>? categoryKeys,
    required String categoryTitle,
  }) {
    return SizedBox(
      width: 280,
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DifficultyScreen(
                categoryTitle: categoryTitle,
                categoryKeys: categoryKeys ?? [categoryKey!],
                subtitle: 'Teste seus conhecimentos sobre ${categoryTitle.toLowerCase()}!',
              ),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey[850],
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              icon,
              style: const TextStyle(fontSize: 28),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}