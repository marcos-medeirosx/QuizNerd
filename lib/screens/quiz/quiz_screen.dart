// lib/screens/quiz/quiz_screen.dart (completo, com salvamento garantido)

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../models/question.dart';
import '../../core/storage_service.dart';
import '../home/home_screen.dart';
class QuizScreen extends StatefulWidget {
  final List<ProcessedQuestion> questions;

  const QuizScreen({super.key, required this.questions});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> with SingleTickerProviderStateMixin {
  final StorageService storage = StorageService();

  // --- Estado do jogador ---
  int _xp = 0;
  int _xpMax = 50;
  int _level = 1;
  int _vidas = 3;
  int _maxVidas = 3;

  int _bonusXPAdicional = 0;
  int _bonusMoedas = 0;
  int _regenerationThreshold = 10;

  int _removeOneCount = 0;
  int _removeTwoCount = 0;
  int _secondChanceCount = 0;
  int _skipCount = 0;

  bool _hasExtraLife = false;
  bool _hasXpBoost = false;
  bool _hasCoinBoost = false;
  bool _hasRegenBoost = false;
  bool _hasRemoveOnePermanent = false;
  bool _hasRemoveTwoPermanent = false;

  int _permanentRemoveCounter = 0;
  int _permanentRemoveTwoCounter = 0;

  int _currentIndex = 0;
  int _score = 0;
  bool _answered = false;
  int? _selectedOptionIndex;
  bool _gameOver = false;

  List<AnswerOption> _currentOptions = [];

  Timer? _timer;
  int _timeLeft = 30;
  bool _timerActive = false;

  late AnimationController _shakeController;
  int _regenerationCounter = 0;

  @override
  void initState() {
    super.initState();
    _loadPurchasedItems();
    _applyPermanentEffects();
    _currentOptions = List.from(widget.questions[_currentIndex].options);
    _startTimer();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
  }

  Future<void> _loadPurchasedItems() async {
    List<String> purchased = storage.getPurchasedItems();
    _hasExtraLife = purchased.contains('life_extra');
    _hasRemoveOnePermanent = purchased.contains('remove_1_permanent');
    _hasRemoveTwoPermanent = purchased.contains('remove_2_permanent');
    _hasXpBoost = purchased.contains('xp_boost');
    _hasCoinBoost = purchased.contains('coin_boost');
    _hasRegenBoost = purchased.contains('regen_boost');

    _skipCount = storage.getConsumableCount('skip_1');
    _secondChanceCount = storage.getConsumableCount('second_chance_2');

    _permanentRemoveCounter = storage.getPermanentCounter('remove_1_permanent');
    _permanentRemoveTwoCounter = storage.getPermanentCounter('remove_2_permanent');

    if (_hasXpBoost) _bonusXPAdicional += 5;
    if (_hasCoinBoost) _bonusMoedas += 2;
    if (_hasRegenBoost) _regenerationThreshold = 7;
  }

  void _applyPermanentEffects() {
    if (_hasExtraLife) {
      _maxVidas = 4;
      _vidas = 4;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _shakeController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timeLeft = 30;
    _timerActive = true;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _timeLeft--;
        if (_timeLeft <= 5 && _timeLeft > 0) {
          _shakeController.forward(from: 0.0);
        }
        if (_timeLeft <= 0) {
          timer.cancel();
          _timerActive = false;
          _shakeController.reset();
          _handleTimeout();
        }
      });
    });
  }

  void _handleTimeout() {
    if (_answered || _gameOver) return;
    setState(() {
      _answered = true;
      _selectedOptionIndex = null;
    });

    if (_secondChanceCount > 0) {
      _secondChanceCount--;
      storage.useConsumable('second_chance_2');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('🔄 Segunda chance usada! Você não perdeu vida.')),
      );
    } else {
      _vidas--;
      if (_vidas <= 0) {
        _gameOver = true;
        _showGameOverDialog();
        return;
      }
    }
    setState(() {});
  }

  void _selectOption(int index) {
    if (_answered || _gameOver) return;
    _timer?.cancel();
    _timerActive = false;

    final selected = _currentOptions[index];
    final isCorrect = selected.isCorrect;

    setState(() {
      _answered = true;
      _selectedOptionIndex = index;
    });

    if (isCorrect) {
      int xpGain = 10 + _bonusXPAdicional;
      int moedasGanhas = 2 + _bonusMoedas;
      _xp += xpGain;
      storage.addMoedas(moedasGanhas);
      storage.addXpTotal(xpGain); // Salva XP total

      if (_regenerationThreshold < 100 && _vidas < _maxVidas) {
        _regenerationCounter++;
        if (_regenerationCounter >= _regenerationThreshold) {
          _vidas++;
          _regenerationCounter = 0;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('❤️ Regenerou uma vida!')),
          );
        }
      }

      if (_xp >= _xpMax) {
        _levelUp();
      } else {
        setState(() {});
      }
      _score++;
    } else {
      if (_secondChanceCount > 0) {
        _secondChanceCount--;
        storage.useConsumable('second_chance_2');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('🔄 Segunda chance usada!')),
        );
      } else {
        _vidas--;
        if (_vidas <= 0) {
          _gameOver = true;
          _showGameOverDialog();
          return;
        }
      }
      setState(() {});
    }
  }

  void _useSkip() {
    if (_skipCount <= 0 || _answered || _gameOver) return;
    _timer?.cancel();
    _timerActive = false;
    setState(() {
      _skipCount--;
      storage.useConsumable('skip_1');
      _answered = true;
      _selectedOptionIndex = null;
    });
  }

  void _levelUp() {
    _xp = 0;
    _level++;
    int currentMax = storage.getMaxLevel();
    if (_level > currentMax) storage.setMaxLevel(_level); // Salva nível máximo
    _xpMax = 50 + (_level - 1) * 30;

    List<Map<String, dynamic>> options = _generateLevelUpOptions();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          width: double.infinity,
          constraints: BoxConstraints(
            maxWidth: 400,
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.grey[900]!, Colors.grey[800]!],
            ),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.amber.withOpacity(0.3),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
            border: Border.all(
              color: Colors.amber.withOpacity(0.5),
              width: 2,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.emoji_events, color: Colors.amber, size: 36),
                  const SizedBox(width: 12),
                  Text(
                    'NÍVEL $_level!',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Escolha uma vantagem:',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 24),
              ...options.map((opt) {
                Color btnColor = _getUpgradeColor(opt['type']);
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _applyLevelUpOption(opt);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: btnColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 6,
                        shadowColor: btnColor.withOpacity(0.5),
                      ),
                      child: Text(
                        opt['label'],
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                );
              }).toList(),
              const SizedBox(height: 8),
              Text(
                'Escolha sabiamente!',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getUpgradeColor(String type) {
    switch (type) {
      case 'xp':
        return Colors.amber.shade700;
      case 'remove1':
        return Colors.orange.shade600;
      case 'remove2':
        return Colors.red.shade700;
      case 'life':
        return Colors.pink.shade600;
      case 'regen':
        return Colors.teal.shade600;
      case 'second':
        return Colors.green.shade700;
      case 'skip':
        return Colors.blue.shade600;
      default:
        return Colors.grey[700]!;
    }
  }

  List<Map<String, dynamic>> _generateLevelUpOptions() {
    List<Map<String, dynamic>> pool = [];

    if (_bonusXPAdicional < 20) {
      pool.add({
        'type': 'xp',
        'label': '⚡ +2 XP por acerto',
        'weight': 5,
        'value': 2,
      });
      pool.add({
        'type': 'xp',
        'label': '⚡⚡ +4 XP por acerto',
        'weight': 2,
        'value': 4,
      });
    }

    pool.add({
      'type': 'remove1',
      'label': '❌ Remover 1 alternativa errada',
      'weight': 4,
    });

    if (_removeTwoCount == 0) {
      pool.add({
        'type': 'remove2',
        'label': '🔥 Remover 2 alternativas erradas (uma vez)',
        'weight': 1,
      });
    }

    pool.add({
      'type': 'life',
      'label': '❤️ Aumentar +1 vida (máximo)',
      'weight': 3,
    });

    if (_regenerationThreshold > 5) {
      pool.add({
        'type': 'regen',
        'label': '🔄 Regeneração: a cada $_regenerationThreshold acertos, +1 vida (reduz para ${_regenerationThreshold - 1})',
        'weight': 3,
      });
    }

    pool.add({
      'type': 'second',
      'label': '🛡️ Segunda chance (não perde vida ao errar)',
      'weight': 2,
    });

    pool.add({
      'type': 'skip',
      'label': '⏭️ Pular pergunta (uma vez)',
      'weight': 3,
    });

    pool.shuffle();
    int count = pool.length >= 3 ? 3 : pool.length;
    return pool.sublist(0, count);
  }

  void _applyLevelUpOption(Map<String, dynamic> option) {
    setState(() {
      switch (option['type']) {
        case 'xp':
          int value = option['value'] ?? 2;
          _bonusXPAdicional += value;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('⚡ Bônus de XP agora: +$_bonusXPAdicional XP por acerto!')),
          );
          break;
        case 'remove1':
          _removeOneCount++;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('❌ Remover 1 alternativa errada disponível!')),
          );
          break;
        case 'remove2':
          _removeTwoCount = 1;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('🔥 Remover 2 alternativas erradas disponível!')),
          );
          break;
        case 'life':
          _maxVidas++;
          _vidas++;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('❤️ Máximo de vidas aumentado para $_maxVidas!')),
          );
          break;
        case 'regen':
          _regenerationThreshold--;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('🔄 Regeneração: a cada $_regenerationThreshold acertos!')),
          );
          break;
        case 'second':
          _secondChanceCount++;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('🛡️ Segunda chance adquirida!')),
          );
          break;
        case 'skip':
          _skipCount++;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('⏭️ Pular pergunta disponível!')),
          );
          break;
      }
    });
  }


void _showGameOverDialog() {
  final TextEditingController nomeController = TextEditingController();
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      backgroundColor: Colors.grey[900],
      title: const Text('💀 Fim de Jogo', style: TextStyle(color: Colors.white)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Você perdeu todas as vidas!',
            style: TextStyle(color: Colors.grey[400]),
          ),
          const SizedBox(height: 8),
          Text(
            'Acertos: $_score de ${widget.questions.length}',
            style: const TextStyle(color: Colors.white, fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(
            'Nível alcançado: $_level',
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            'Moedas: ${storage.getMoedas()}',
            style: TextStyle(color: Colors.grey[400], fontSize: 14),
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.grey),
          const SizedBox(height: 8),
          const Text(
            'Digite seu nome para o ranking:',
            style: TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: nomeController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Seu nome...',
              hintStyle: TextStyle(color: Colors.grey[500]),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.grey[700]!),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.blue[700]!),
              ),
            ),
            autofocus: true,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            String nome = nomeController.text.trim();
            if (nome.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Digite seu nome!')),
              );
              return;
            }
            // Salvar no ranking
            storage.addRankingEntry(nome, storage.getXpTotal(), _level);
            // Fecha o diálogo
            Navigator.pop(context);
            // Vai direto para a HomeScreen, substituindo a pilha
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const HomeScreen()),
            );
          },
          child: const Text('Salvar', style: TextStyle(color: Colors.blue)),
        ),
      ],
    ),
  );
}


  void _useRemoveOne() {
    if (_removeOneCount <= 0 || _answered || _gameOver) return;
    setState(() {
      _removeOneCount--;
      _removeAlternatives(1);
    });
  }

  void _useRemoveTwo() {
    if (_removeTwoCount <= 0 || _answered || _gameOver) return;
    setState(() {
      _removeTwoCount--;
      _removeAlternatives(2);
    });
  }

  void _removeAlternatives(int count) {
    List<AnswerOption> incorrect = _currentOptions.where((opt) => !opt.isCorrect).toList();
    if (incorrect.length <= count) {
      _currentOptions = _currentOptions.where((opt) => opt.isCorrect).toList();
    } else {
      incorrect.shuffle();
      Set<String> toRemove = incorrect.take(count).map((e) => e.text).toSet();
      _currentOptions = _currentOptions.where((opt) => !toRemove.contains(opt.text)).toList();
    }
    _currentOptions.shuffle();
  }

  void _nextQuestion() {
    if (_gameOver) return;
    if (_currentIndex < widget.questions.length - 1) {
      setState(() {
        _currentIndex++;
        _answered = false;
        _selectedOptionIndex = null;
        _currentOptions = List.from(widget.questions[_currentIndex].options);
        _currentOptions.shuffle();

        if (_hasRemoveOnePermanent) {
          _permanentRemoveCounter++;
          storage.setPermanentCounter('remove_1_permanent', _permanentRemoveCounter);
          if (_permanentRemoveCounter >= 10) {
            _removeAlternatives(1);
            _permanentRemoveCounter = 0;
            storage.resetPermanentCounter('remove_1_permanent');
          }
        }
        if (_hasRemoveTwoPermanent) {
          _permanentRemoveTwoCounter++;
          storage.setPermanentCounter('remove_2_permanent', _permanentRemoveTwoCounter);
          if (_permanentRemoveTwoCounter >= 10) {
            _removeAlternatives(2);
            _permanentRemoveTwoCounter = 0;
            storage.resetPermanentCounter('remove_2_permanent');
          }
        }

        _timer?.cancel();
        _startTimer();
      });
    } else {
      _showResultDialog();
    }
  }

  void _showResultDialog() {
    // Garantir que o XP total e nível máximo sejam salvos
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('🏆 Resultado', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Você acertou $_score de ${widget.questions.length} perguntas!',
              style: const TextStyle(color: Colors.white, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              'Nível: $_level',
              style: TextStyle(color: Colors.grey[400], fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Moedas: ${storage.getMoedas()}',
              style: TextStyle(color: Colors.grey[400], fontSize: 14),
            ),
            const SizedBox(height: 16),
            Text(
              _score == widget.questions.length
                  ? 'Parabéns, você é um nerd de verdade! 🧠'
                  : 'Continue praticando!',
              style: TextStyle(color: Colors.grey[400], fontSize: 16),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Voltar', style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );
  }

  Color _getTimerColor() {
    if (_timeLeft > 15) return Colors.green;
    if (_timeLeft > 5) return Colors.orange;
    return Colors.red;
  }

  List<ProcessedQuestion> _applyProgressiveDifficulty(List<ProcessedQuestion> original) {
    if (!storage.isProgressiveDifficulty()) return original;

    List<ProcessedQuestion> easy = original.where((q) => q.original.difficulty == 'easy').toList();
    List<ProcessedQuestion> medium = original.where((q) => q.original.difficulty == 'medium').toList();
    List<ProcessedQuestion> hard = original.where((q) => q.original.difficulty == 'hard').toList();

    int level = _level;
    int total = original.length;
    int easyCount = (total * max(0.6 - (level - 1) * 0.05, 0.1)).round();
    int hardCount = (total * min(0.05 + (level - 1) * 0.03, 0.4)).round();
    int mediumCount = total - easyCount - hardCount;

    easyCount = easyCount.clamp(0, easy.length);
    mediumCount = mediumCount.clamp(0, medium.length);
    hardCount = hardCount.clamp(0, hard.length);

    easy.shuffle();
    medium.shuffle();
    hard.shuffle();

    List<ProcessedQuestion> selected = [];
    selected.addAll(easy.take(easyCount));
    selected.addAll(medium.take(mediumCount));
    selected.addAll(hard.take(hardCount));
    selected.shuffle();
    return selected;
  }

  @override
  Widget build(BuildContext context) {
    List<ProcessedQuestion> questions = _applyProgressiveDifficulty(widget.questions);
    final question = questions[_currentIndex];
    final total = questions.length;
    final progress = (_currentIndex + 1) / total;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Quiz', style: TextStyle(color: Colors.white)),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue[700],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Acertos: $_score',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
            const Spacer(),
            Row(
              children: List.generate(_maxVidas, (index) {
                return index < _vidas
                    ? const Icon(Icons.favorite, color: Colors.red, size: 28)
                    : Icon(Icons.favorite_border, color: Colors.grey[600], size: 24);
              }),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.amber[700],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Nv.$_level',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4.0),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[800],
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
            minHeight: 4,
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const AssetImage('assets/images/quiz_nerd_bg.png'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.6),
              BlendMode.darken,
            ),
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Categoria: ${question.original.category}',
                          style: TextStyle(color: Colors.grey[500], fontSize: 14),
                        ),
                        if (_timerActive && !_answered)
                          AnimatedBuilder(
                            animation: _shakeController,
                            builder: (context, child) {
                              double offsetX = 0;
                              if (_timeLeft <= 5 && _timeLeft > 0) {
                                offsetX = sin(_timeLeft * 10) * 3;
                              }
                              double opacity = 1.0;
                              if (_timeLeft <= 5 && _timeLeft > 0) {
                                opacity = (_timeLeft % 2 == 0) ? 0.4 : 1.0;
                              }
                              return Transform.translate(
                                offset: Offset(offsetX, 0),
                                child: Opacity(
                                  opacity: opacity,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: _getTimerColor().withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: _getTimerColor(), width: 2),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(Icons.timer, color: _getTimerColor(), size: 18),
                                        const SizedBox(width: 4),
                                        Text(
                                          '$_timeLeft',
                                          style: TextStyle(
                                            color: _getTimerColor(),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          )
                        else
                          const SizedBox(width: 60),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      question.original.question,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    ...List.generate(_currentOptions.length, (idx) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6.0),
                        child: Center(
                          child: SizedBox(
                            width: 300,
                            child: AnswerButton(
                              index: idx,
                              text: _currentOptions[idx].text,
                              isCorrect: _currentOptions[idx].isCorrect,
                              isSelected: _selectedOptionIndex == idx,
                              answered: _answered,
                              onTap: () => _selectOption(idx),
                            ),
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 12),
                    if (!_answered && !_gameOver)
                      Wrap(
                        spacing: 12,
                        runSpacing: 8,
                        alignment: WrapAlignment.center,
                        children: [
                          if (_bonusXPAdicional > 0)
                            Tooltip(
                              message: '+$_bonusXPAdicional XP por acerto',
                              child: _buildPassiveBadge(
                                icon: Icons.flash_on,
                                color: Colors.amber,
                              ),
                            ),
                          if (_regenerationThreshold < 100)
                            Tooltip(
                              message: 'Regenera 1 vida a cada $_regenerationThreshold acertos',
                              child: _buildPassiveBadge(
                                icon: Icons.autorenew,
                                color: Colors.blue,
                              ),
                            ),
                          if (_removeOneCount > 0)
                            _buildConsumableBadge(
                              icon: Icons.remove_circle_outline,
                              count: _removeOneCount,
                              color: Colors.orange,
                              onTap: _useRemoveOne,
                              tooltip: 'Remover 1 alternativa errada',
                            ),
                          if (_removeTwoCount > 0)
                            _buildConsumableBadge(
                              icon: Icons.remove_circle,
                              count: _removeTwoCount,
                              color: Colors.red,
                              onTap: _useRemoveTwo,
                              tooltip: 'Remover 2 alternativas erradas',
                            ),
                          if (_skipCount > 0)
                            _buildConsumableBadge(
                              icon: Icons.skip_next,
                              count: _skipCount,
                              color: Colors.blueAccent,
                              onTap: _useSkip,
                              tooltip: 'Pular pergunta',
                            ),
                          if (_secondChanceCount > 0)
                            _buildConsumableBadge(
                              icon: Icons.shield,
                              count: _secondChanceCount,
                              color: Colors.green,
                              onTap: null,
                              tooltip: 'Segunda chance',
                            ),
                        ],
                      ),
                    const SizedBox(height: 8),
                    if (_answered && !_gameOver)
                      Center(
                        child: SizedBox(
                          width: 200,
                          child: ElevatedButton(
                            onPressed: _nextQuestion,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text(
                              _currentIndex == total - 1 ? 'Ver resultado' : 'Próxima pergunta',
                              style: const TextStyle(fontSize: 18, color: Colors.white),
                            ),
                          ),
                        ),
                      )
                    else if (!_gameOver)
                      const SizedBox(height: 50),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 20),
              color: Colors.grey[900],
              child: Center(
                child: FractionallySizedBox(
                  widthFactor: 0.25,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'XP',
                        style: TextStyle(color: Colors.grey[400], fontSize: 12),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: _xp / _xpMax,
                            backgroundColor: Colors.grey[800],
                            valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                            minHeight: 10,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '$_xp/$_xpMax',
                        style: TextStyle(color: Colors.grey[400], fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPassiveBadge({
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        shape: BoxShape.circle,
        border: Border.all(color: color.withOpacity(0.5), width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Icon(
        icon,
        color: color,
        size: 24,
      ),
    );
  }

  Widget _buildConsumableBadge({
    required IconData icon,
    required int count,
    required Color color,
    VoidCallback? onTap,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          GestureDetector(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey[850],
                shape: BoxShape.circle,
                border: Border.all(color: color.withOpacity(0.5), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.2),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
          ),
          if (count > 1)
            Positioned(
              top: -6,
              right: -6,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  count.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ============================================================================
// AnswerButton (sem alterações)
// ============================================================================
class AnswerButton extends StatefulWidget {
  final int index;
  final String text;
  final bool isCorrect;
  final bool isSelected;
  final bool answered;
  final VoidCallback onTap;

  const AnswerButton({
    super.key,
    required this.index,
    required this.text,
    required this.isCorrect,
    required this.isSelected,
    required this.answered,
    required this.onTap,
  });

  @override
  State<AnswerButton> createState() => _AnswerButtonState();
}

class _AnswerButtonState extends State<AnswerButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
  }

  @override
  void didUpdateWidget(AnswerButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.answered && !oldWidget.answered && widget.isSelected) {
      _controller.forward(from: 0.0);
    }
    if (!widget.answered && oldWidget.answered) {
      _controller.reset();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color? backgroundColor;
    if (widget.answered) {
      if (widget.isCorrect) backgroundColor = Colors.green;
      else if (widget.isSelected && !widget.isCorrect) backgroundColor = Colors.red;
      else backgroundColor = Colors.grey[800];
    } else {
      backgroundColor = widget.isSelected ? Colors.blue[700] : Colors.grey[800];
    }

    Widget button = ElevatedButton(
      onPressed: widget.answered ? null : widget.onTap,
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(backgroundColor),
        foregroundColor: MaterialStateProperty.all(Colors.white),
        padding: MaterialStateProperty.all(const EdgeInsets.symmetric(vertical: 16, horizontal: 20)),
        shape: MaterialStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(
              color: widget.isSelected && !widget.answered ? Colors.blue : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        elevation: MaterialStateProperty.all(0),
      ),
      child: Row(
        children: [
          Text(String.fromCharCode(65 + widget.index), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(width: 16),
          Expanded(child: Text(widget.text, style: const TextStyle(fontSize: 16))),
          if (widget.answered && widget.isCorrect)
            const Icon(Icons.check_circle, color: Colors.white)
          else if (widget.answered && widget.isSelected && !widget.isCorrect)
            const Icon(Icons.cancel, color: Colors.white)
        ],
      ),
    );

    if (widget.answered && widget.isSelected) {
      if (widget.isCorrect) {
        button = AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final scale = 1.0 + 0.08 * _controller.value;
            return Transform.scale(
              scale: scale,
              child: Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.3 * _controller.value),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: child,
              ),
            );
          },
          child: button,
        );
      } else {
        button = AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final shakeX = sin(_controller.value * 20 * pi) * 5;
            return Transform.translate(offset: Offset(shakeX, 0), child: child);
          },
          child: button,
        );
      }
    }
    return button;
  }
}