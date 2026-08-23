import 'package:flutter/material.dart';
import '../../core/storage_service.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  final StorageService storage = StorageService();

  // Nomes amigáveis dos itens (para exibir requisitos)
  final Map<String, String> itemNames = {
    'life_extra': '❤️ Vida Extra',
    'skip_3': '⏭️ 3 Pulos',
    'remove_1_permanent': '❌ Remover 1 errada (a cada 10 perguntas)',
    'remove_2_permanent': '❌❌ Remover 2 erradas (a cada 10 perguntas)',
    'xp_boost': '⚡ Bônus XP +50%',
    'coin_boost': '💰 Bônus de Moedas +2',
    'regen_boost': '🔄 Regeneração rápida (7 acertos)',
    'second_chance_2': '🛡️ 2 Segundas chances',
  };

  final List<ShopItem> items = [
    ShopItem(
      id: 'life_extra',
      name: '❤️ Vida Extra',
      description: 'Começa cada partida com +1 vida máxima.',
      price: 50,
      type: ShopItemType.permanent,
      icon: Icons.favorite,
      requirement: null,
    ),
    ShopItem(
      id: 'skip_3',
      name: '⏭️ 3 Pulos',
      description: 'Ganhe 3 pulos de pergunta (consumíveis).',
      price: 30,
      type: ShopItemType.consumable,
      icon: Icons.skip_next,
      requirement: null,
    ),
    ShopItem(
      id: 'remove_1_permanent',
      name: '❌ Remover 1 errada (a cada 10 perguntas)',
      description: 'A cada 10 perguntas, uma alternativa errada é removida automaticamente.',
      price: 80,
      type: ShopItemType.permanent,
      icon: Icons.remove_circle_outline,
      requirement: 'life_extra',
    ),
    ShopItem(
      id: 'remove_2_permanent',
      name: '❌❌ Remover 2 erradas (a cada 10 perguntas)',
      description: 'A cada 10 perguntas, duas alternativas erradas são removidas automaticamente.',
      price: 120,
      type: ShopItemType.permanent,
      icon: Icons.remove_circle,
      requirement: 'remove_1_permanent',
    ),
    ShopItem(
      id: 'xp_boost',
      name: '⚡ Bônus XP +50%',
      description: 'Aumenta permanentemente o ganho de XP em 50%.',
      price: 100,
      type: ShopItemType.permanent,
      icon: Icons.flash_on,
      requirement: null,
    ),
    ShopItem(
      id: 'coin_boost',
      name: '💰 Bônus de Moedas +2',
      description: 'Ganha +2 moedas extras por acerto (permanente).',
      price: 120,
      type: ShopItemType.permanent,
      icon: Icons.attach_money,
      requirement: 'xp_boost',
    ),
    ShopItem(
      id: 'regen_boost',
      name: '🔄 Regeneração rápida',
      description: 'Reduz o limite de regeneração de 10 para 7 acertos (permanente).',
      price: 70,
      type: ShopItemType.permanent,
      icon: Icons.autorenew,
      requirement: null,
    ),
    ShopItem(
      id: 'second_chance_2',
      name: '🛡️ 2 Segundas chances',
      description: 'Ganhe 2 segundas chances (consumíveis).',
      price: 40,
      type: ShopItemType.consumable,
      icon: Icons.shield,
      requirement: null,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    int moedas = storage.getMoedas();
    List<String> purchased = storage.getPurchasedItems();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('🛠️ BUILD', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        actions: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Colors.amber[700],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.monetization_on, color: Colors.white, size: 18),
                const SizedBox(width: 4),
                Text(
                  '$moedas',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          final bool alreadyPurchased = purchased.contains(item.id);
          final bool hasRequirement = item.requirement == null || purchased.contains(item.requirement);
          final bool canAfford = moedas >= item.price;

          int count = 0;
          if (item.type == ShopItemType.consumable) {
            count = storage.getConsumableCount(item.id);
          }

          // Nome amigável do requisito
          String requirementName = item.requirement != null
              ? (itemNames[item.requirement] ?? item.requirement!)
              : '';

          return Card(
            color: Colors.grey[900],
            margin: const EdgeInsets.symmetric(vertical: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(item.icon, color: Colors.amber, size: 32),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.description,
                          style: TextStyle(color: Colors.grey[400], fontSize: 14),
                        ),
                        if (item.requirement != null)
                          Text(
                            'Requer: $requirementName',
                            style: TextStyle(
                              color: hasRequirement ? Colors.green : Colors.red,
                              fontSize: 12,
                            ),
                          ),
                        if (item.type == ShopItemType.consumable && count > 0)
                          Text(
                            'Possui: $count',
                            style: const TextStyle(color: Colors.green, fontSize: 12),
                          ),
                        if (alreadyPurchased && item.type == ShopItemType.permanent)
                          const Text(
                            '✓ Adquirido',
                            style: TextStyle(color: Colors.green, fontSize: 12),
                          ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      ElevatedButton(
                        onPressed: (canAfford && hasRequirement && (!alreadyPurchased || item.type == ShopItemType.consumable))
                            ? () => _buyItem(item)
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: (canAfford && hasRequirement) ? Colors.blue : Colors.grey[700],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        ),
                        child: Text(
                          alreadyPurchased && item.type == ShopItemType.permanent
                              ? '✅'
                              : '${item.price} 💰',
                        ),
                      ),
                      if (!hasRequirement && item.requirement != null)
                        const Text(
                          '🔒',
                          style: TextStyle(color: Colors.red, fontSize: 16),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _buyItem(ShopItem item) async {
    int moedas = storage.getMoedas();
    if (moedas < item.price) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Moedas insuficientes!')),
      );
      return;
    }

    await storage.setMoedas(moedas - item.price);

    if (item.type == ShopItemType.permanent) {
      await storage.addPurchasedItem(item.id);
    } else {
      await storage.addConsumable(item.id, 1);
    }

    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Comprou: ${item.name}')),
    );
  }
}

enum ShopItemType { permanent, consumable }

class ShopItem {
  final String id;
  final String name;
  final String description;
  final int price;
  final ShopItemType type;
  final IconData icon;
  final String? requirement;

  ShopItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.type,
    required this.icon,
    this.requirement,
  });
}