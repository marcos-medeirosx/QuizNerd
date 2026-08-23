import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  late SharedPreferences _prefs;
  bool _initialized = false;

  Future<void> init() async {
    if (!_initialized) {
      _prefs = await SharedPreferences.getInstance();
      _initialized = true;
    }
  }

  // Moedas
  int getMoedas() => _prefs.getInt('moedas') ?? 0;
  Future<void> setMoedas(int value) => _prefs.setInt('moedas', value);
  Future<void> addMoedas(int amount) => setMoedas(getMoedas() + amount);

  // XP total
  int getXpTotal() => _prefs.getInt('xpTotal') ?? 0;
  Future<void> setXpTotal(int value) => _prefs.setInt('xpTotal', value);
  Future<void> addXpTotal(int amount) => setXpTotal(getXpTotal() + amount);

  // Nível máximo
  int getMaxLevel() => _prefs.getInt('maxLevel') ?? 1;
  Future<void> setMaxLevel(int value) => _prefs.setInt('maxLevel', value);

  // Dificuldade progressiva
  bool isProgressiveDifficulty() => _prefs.getBool('progressiveDifficulty') ?? false;
  Future<void> setProgressiveDifficulty(bool value) =>
      _prefs.setBool('progressiveDifficulty', value);

  // Itens comprados
  List<String> getPurchasedItems() => _prefs.getStringList('purchasedItems') ?? [];
  Future<void> setPurchasedItems(List<String> items) =>
      _prefs.setStringList('purchasedItems', items);
  Future<void> addPurchasedItem(String item) async {
    List<String> list = getPurchasedItems();
    if (!list.contains(item)) {
      list.add(item);
      await setPurchasedItems(list);
    }
  }

  // Consumíveis
  int getConsumableCount(String key) => _prefs.getInt('consumable_$key') ?? 0;
  Future<void> setConsumableCount(String key, int value) =>
      _prefs.setInt('consumable_$key', value);
  Future<void> addConsumable(String key, int amount) =>
      setConsumableCount(key, getConsumableCount(key) + amount);
  Future<void> useConsumable(String key) =>
      setConsumableCount(key, getConsumableCount(key) - 1);

  // Contadores permanentes (para remoção a cada 10 perguntas)
  int getPermanentCounter(String key) => _prefs.getInt('perm_counter_$key') ?? 0;
  Future<void> setPermanentCounter(String key, int value) =>
      _prefs.setInt('perm_counter_$key', value);
  Future<void> incrementPermanentCounter(String key) =>
      setPermanentCounter(key, getPermanentCounter(key) + 1);
  Future<void> resetPermanentCounter(String key) =>
      setPermanentCounter(key, 0);
}