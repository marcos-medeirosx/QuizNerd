class Question {
  final int id;
  final String category;
  final String difficulty;
  final String question;
  final List<String> answers;
  final int correctAnswer; // índice da resposta correta na lista original
  final String explanation;

  const Question({
    required this.id,
    required this.category,
    required this.difficulty,
    required this.question,
    required this.answers,
    required this.correctAnswer,
    required this.explanation,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'],
      category: json['category'],
      difficulty: json['difficulty'],
      question: json['question'],
      answers: List<String>.from(json['answers']),
      correctAnswer: json['correctAnswer'],
      explanation: json['explanation'],
    );
  }
}

// Representa uma opção de resposta já processada (para exibição)
class AnswerOption {
  final String text;
  final bool isCorrect;

  const AnswerOption({required this.text, required this.isCorrect});
}

// Representa uma pergunta já processada para o quiz (com apenas 4 alternativas)
class ProcessedQuestion {
  final Question original;
  final List<AnswerOption> options; // sempre 4 opções, embaralhadas

  const ProcessedQuestion({required this.original, required this.options});

  // Obtém a opção correta (para verificar após resposta)
  AnswerOption get correctOption => options.firstWhere((opt) => opt.isCorrect);
}