// lib/screens/home/home_screen.dart

import 'package:flutter/material.dart';
import '../difficulty/difficulty_screen.dart';
import '../settings/settings_screen.dart';
import '../shop/shop_screen.dart';
import '../../core/storage_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
                // ---- RANKING (FUTUREBUILDER COM CORREÇÃO) ----
                FutureBuilder<List<Map<String, dynamic>>>(
                  future: StorageService().getRankingAsync(), // agora é Future
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const SizedBox.shrink();
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    final ranking = snapshot.data!;
                    return _buildRankingWidget(ranking);
                  },
                ),
                const SizedBox(height: 16),

                // ---- BOTÕES CENTRALIZADOS ----
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
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
                      _buildBuildButton(context),
                    ],
                  ),
                ),
                const Spacer(flex: 1),

                // ---- CONFIGURAÇÕES ----
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

  // ---------- WIDGET RANKING (TOP 3) ----------
  Widget _buildRankingWidget(List<Map<String, dynamic>> ranking) {
    return Column(
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.emoji_events, color: Colors.amber, size: 28),
            SizedBox(width: 8),
            Text(
              '🏆 TOP 3',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 300,
          child: Column(
            children: ranking.asMap().entries.map((entry) {
              int index = entry.key;
              var item = entry.value;
              String name = item['name'] ?? 'Anônimo';
              int xp = item['xp'] ?? 0;
              int level = item['level'] ?? 1;

              Color medalColor;
              if (index == 0) medalColor = Colors.amber.shade700;
              else if (index == 1) medalColor = Colors.grey.shade400;
              else medalColor = Colors.brown.shade300;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: medalColor.withOpacity(0.5)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.emoji_events, color: medalColor, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            '#${index + 1} $name',
                            style: const TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            'Nv.$level',
                            style: TextStyle(color: Colors.grey[400], fontSize: 14),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            '${xp} XP',
                            style: const TextStyle(color: Colors.amber, fontSize: 14),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  // ---------- BOTÃO DE CATEGORIA ----------
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

  // ---------- BOTÃO BUILD ----------
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