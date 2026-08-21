import 'package:flutter/material.dart';
import '../../services/question_service.dart';
import '../../models/question.dart';
import '../quiz/quiz_screen.dart';

class DifficultyScreen extends StatelessWidget {
  final String categoryTitle;   // Nome exibido (ex: "Filmes", "Animes", "Mix Nerd")
  final List<String> categoryKeys; // Chaves das categorias (ex: ["movies"] ou ["movies","anime","games"])
  final String subtitle;

  const DifficultyScreen({
    super.key,
    required this.categoryTitle,
    required this.categoryKeys,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          categoryTitle,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.grey[300],
                ),
              ),
              const SizedBox(height: 40),
              Center(
                child: Column(
                  children: [
                    _buildDifficultyButton(
                      context: context,
                      icon: '🟢',
                      label: 'Fácil',
                      description: 'Perguntas para começar',
                      color: Colors.green,
                      difficulty: 'easy',
                    ),
                    const SizedBox(height: 16),
                    _buildDifficultyButton(
                      context: context,
                      icon: '🟡',
                      label: 'Médio',
                      description: 'Agora ficou interessante...',
                      color: Colors.amber,
                      difficulty: 'medium',
                    ),
                    const SizedBox(height: 16),
                    _buildDifficultyButton(
                      context: context,
                      icon: '🔴',
                      label: 'Difícil',
                      description: 'Só para quem manja mesmo!',
                      color: Colors.red,
                      difficulty: 'hard',
                    ),
                  ],
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDifficultyButton({
    required BuildContext context,
    required String icon,
    required String label,
    required String description,
    required Color color,
    required String difficulty,
  }) {
    return SizedBox(
      width: 280,
      child: ElevatedButton(
        onPressed: () {
          _startQuiz(context, difficulty);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey[850],
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: Row(
          children: [
            Text(
              icon,
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[400],
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey[500],
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  void _startQuiz(BuildContext context, String difficulty) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Colors.blue),
      ),
    );

    try {
      final service = QuestionService();
      List<Question> questions = await service.loadQuestionsByKeys(categoryKeys, difficulty);

      Navigator.pop(context); // fecha diálogo

      if (questions.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Nenhuma pergunta disponível para $categoryTitle - $difficulty')),
        );
        return;
      }

      List<ProcessedQuestion> processed = service.prepareQuestions(questions, maxQuestions: 10);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => QuizScreen(questions: processed),
        ),
      );
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar perguntas: $e')),
      );
    }
  }
}