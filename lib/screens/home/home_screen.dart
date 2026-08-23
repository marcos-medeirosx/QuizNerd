import 'package:flutter/material.dart';
import '../difficulty/difficulty_screen.dart';
import '../settings/settings_screen.dart';
import '../shop/shop_screen.dart';
import '../../core/storage_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final StorageService storage = StorageService();
  int _xpTotal = 0;
  int _maxLevel = 1;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final xpTotal = storage.getXpTotal();
    final maxLevel = storage.getMaxLevel();
    setState(() {
      _xpTotal = xpTotal;
      _maxLevel = maxLevel;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const AssetImage('assets/images/quiz_nerd_bg.png'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.4),
              BlendMode.darken,
            ),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Espaço superior para centralizar verticalmente
                const Spacer(flex: 1),

                // Ranking
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.emoji_events, color: Colors.amber, size: 32),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Nível Máx: $_maxLevel',
                          style: const TextStyle(color: Colors.white, fontSize: 18),
                        ),
                        Text(
                          'XP Total: $_xpTotal',
                          style: TextStyle(color: Colors.grey[400], fontSize: 14),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // Botões de categorias + BUILD
                Center(
                  child: Column(
                    children: [
                      _buildCategoryButton(
                        context: context,
                        icon: '🎬',
                        label: 'FILMES',
                        categoryKey: 'movies',
                        categoryTitle: 'Filmes',
                        color: Colors.blue.shade600,
                      ),
                      const SizedBox(height: 16),
                      _buildCategoryButton(
                        context: context,
                        icon: '📺',
                        label: 'ANIMES',
                        categoryKey: 'anime',
                        categoryTitle: 'Animes',
                        color: Colors.purple.shade600,
                      ),
                      const SizedBox(height: 16),
                      _buildCategoryButton(
                        context: context,
                        icon: '🎮',
                        label: 'GAMES',
                        categoryKey: 'games',
                        categoryTitle: 'Games',
                        color: Colors.green.shade600,
                      ),
                      const SizedBox(height: 16),
                      _buildCategoryButton(
                        context: context,
                        icon: '🔥',
                        label: 'MIX NERD',
                        categoryKeys: ['movies', 'anime', 'games'],
                        categoryTitle: 'Mix Nerd',
                        color: Colors.orange.shade600,
                      ),
                      const SizedBox(height: 16),
                      // Botão BUILD com mesmo estilo
                      _buildBuildButton(context),
                    ],
                  ),
                ),

                const Spacer(flex: 2),

                // Configurações
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
                      const Icon(Icons.settings, color: Colors.white),
                      const SizedBox(width: 8),
                      Text(
                        'Configurações',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
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
    required Color color,
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
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 8,
          shadowColor: color.withOpacity(0.6),
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

  Widget _buildBuildButton(BuildContext context) {
    return SizedBox(
      width: 280,
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ShopScreen()),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.purple.shade700,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 8,
          shadowColor: Colors.purple.shade700.withOpacity(0.6),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.build, size: 28),
            SizedBox(width: 12),
            Text(
              'BUILD',
              style: TextStyle(
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