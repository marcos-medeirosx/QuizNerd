class Question {
  final int id;
  final String category;
  final String difficulty;
  final String question;
  final List<String> answers;
  final int correctAnswer;

  const Question({
    required this.id,
    required this.category,
    required this.difficulty,
    required this.question,
    required this.answers,
    required this.correctAnswer,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'],
      category: json['category'],
      difficulty: json['difficulty'],
      question: json['question'],
      answers: List<String>.from(json['answers']),
      correctAnswer: json['correctAnswer'],
    );
  }
}

class AnswerOption {
  final String text;
  final bool isCorrect;
  const AnswerOption({required this.text, required this.isCorrect});
}

class ProcessedQuestion {
  final Question original;
  final List<AnswerOption> options;
  const ProcessedQuestion({required this.original, required this.options});
}