// lib/screens/quiz/quiz_screen.dart

import 'dart:math';
import 'package:flutter/material.dart';
import '../../models/question.dart';

class QuizScreen extends StatefulWidget {
  final List<ProcessedQuestion> questions;

  const QuizScreen({super.key, required this.questions});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  int _score = 0;
  bool _answered = false;
  int? _selectedOptionIndex;

  void _selectOption(int index) {
    if (_answered) return;
    setState(() {
      _selectedOptionIndex = index;
      _answered = true;
      if (widget.questions[_currentIndex].options[index].isCorrect) {
        _score++;
      }
    });
  }

  void _nextQuestion() {
    if (_currentIndex < widget.questions.length - 1) {
      setState(() {
        _currentIndex++;
        _answered = false;
        _selectedOptionIndex = null;
      });
    } else {
      _showResultDialog();
    }
  }

  void _showResultDialog() {
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

  @override
  Widget build(BuildContext context) {
    final question = widget.questions[_currentIndex];
    final total = widget.questions.length;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text('Pergunta ${_currentIndex + 1}/$total'),
        centerTitle: true,
      ),
      body: SafeArea(
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
                  Text(
                    'Dificuldade: ${question.original.difficulty}',
                    style: TextStyle(color: Colors.grey[500], fontSize: 14),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                question.original.question,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              ...List.generate(question.options.length, (idx) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6.0),
                  child: Center(
                    child: SizedBox(
                      width: 300,
                      child: AnswerButton(
                        index: idx,
                        text: question.options[idx].text,
                        isCorrect: question.options[idx].isCorrect,
                        isSelected: _selectedOptionIndex == idx,
                        answered: _answered,
                        onTap: () => _selectOption(idx),
                      ),
                    ),
                  ),
                );
              }),
              const Spacer(),
              if (_answered)
                Center(
                  child: SizedBox(
                    width: 200,
                    child: ElevatedButton(
                      onPressed: _nextQuestion,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        _currentIndex == total - 1
                            ? 'Ver resultado'
                            : 'Próxima pergunta',
                        style: const TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ),
                )
              else
                const SizedBox(height: 60),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// Widget personalizado para cada opção de resposta com animações
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
    // Define a cor de fundo com base no estado
    Color? backgroundColor;
    if (widget.answered) {
      if (widget.isCorrect) {
        backgroundColor = Colors.green; // verde vivo
      } else if (widget.isSelected && !widget.isCorrect) {
        backgroundColor = Colors.red; // vermelho vivo
      } else {
        backgroundColor = Colors.grey[800];
      }
    } else {
      backgroundColor = widget.isSelected ? Colors.blue[700] : Colors.grey[800];
    }

    // Cria o botão com estilo explícito usando ButtonStyle para garantir a cor
    Widget button = ElevatedButton(
      onPressed: widget.answered ? null : widget.onTap,
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(backgroundColor),
        foregroundColor: MaterialStateProperty.all(Colors.white),
        padding: MaterialStateProperty.all(
          const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        ),
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
          Text(
            String.fromCharCode(65 + widget.index),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              widget.text,
              style: const TextStyle(fontSize: 16),
            ),
          ),
          if (widget.answered && widget.isCorrect)
            const Icon(Icons.check_circle, color: Colors.white)
          else if (widget.answered && widget.isSelected && !widget.isCorrect)
            const Icon(Icons.cancel, color: Colors.white)
        ],
      ),
    );

    // Aplica animações apenas se a resposta foi dada e este botão foi selecionado
    if (widget.answered && widget.isSelected) {
      if (widget.isCorrect) {
        // Efeito de escala + brilho suave
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
        // Efeito de tremor (shake)
        button = AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final shakeX = sin(_controller.value * 20 * pi) * 5;
            return Transform.translate(
              offset: Offset(shakeX, 0),
              child: child,
            );
          },
          child: button,
        );
      }
    }

    return button;
  }
}