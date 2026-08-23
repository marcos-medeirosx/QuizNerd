import 'package:flutter/material.dart';
import '../../services/question_service.dart';
import '../../models/question.dart';
import '../quiz/quiz_screen.dart';

class DifficultyScreen extends StatelessWidget {
  final String categoryTitle;
  final List<String> categoryKeys;
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
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/quiz_nerd_bg.png'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.5),
              BlendMode.darken,
            ),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(height: 16),
                Text(
                  categoryTitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 18,
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
                        color: Colors.green.shade600,
                        difficulty: 'easy',
                      ),
                      const SizedBox(height: 16),
                      _buildDifficultyButton(
                        context: context,
                        icon: '🟡',
                        label: 'Médio',
                        description: 'Agora ficou interessante...',
                        color: Colors.orange.shade600,
                        difficulty: 'medium',
                      ),
                      const SizedBox(height: 16),
                      _buildDifficultyButton(
                        context: context,
                        icon: '🔴',
                        label: 'Difícil',
                        description: 'Só para quem manja mesmo!',
                        color: Colors.red.shade600,
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
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 8,
          shadowColor: color.withOpacity(0.5),
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
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.white.withOpacity(0.7),
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

      Navigator.pop(context);

      if (questions.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Nenhuma pergunta disponível para $categoryTitle - $difficulty')),
        );
        return;
      }

      List<ProcessedQuestion> processed = service.prepareQuestions(questions);

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