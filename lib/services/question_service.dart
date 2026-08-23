import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/question.dart';

class QuestionService {
  Future<List<Question>> loadQuestions({required String category, required String difficulty}) async {
    return loadQuestionsByKeys([category], difficulty);
  }

  Future<List<Question>> loadQuestionsByKeys(List<String> categoryKeys, String difficulty) async {
    List<Question> allQuestions = [];

    for (var key in categoryKeys) {
      try {
        String jsonString = await rootBundle.loadString('assets/data/questions/$key.json');
        List<dynamic> jsonList = jsonDecode(jsonString);
        List<Question> questions = jsonList.map((j) => Question.fromJson(j)).toList();
        final filtered = questions.where((q) => q.difficulty == difficulty).toList();
        allQuestions.addAll(filtered);
      } catch (e) {
        print('Erro ao carregar $key.json: $e');
      }
    }

    allQuestions.shuffle();
    return allQuestions;
  }

  List<ProcessedQuestion> prepareQuestions(List<Question> questions) {
    // Não limita mais o número de perguntas
    List<Question> shuffled = List.from(questions)..shuffle();
    return shuffled.map((q) => _processQuestion(q)).toList();
  }

  ProcessedQuestion _processQuestion(Question q) {
    String correctAnswerText = q.answers[q.correctAnswer];
    List<String> incorrects = List.from(q.answers)..removeAt(q.correctAnswer);
    incorrects.shuffle();
    int takeCount = incorrects.length >= 3 ? 3 : incorrects.length;
    List<String> selectedIncorrects = incorrects.sublist(0, takeCount);
    List<String> optionsText = [correctAnswerText, ...selectedIncorrects];
    optionsText.shuffle();
    List<AnswerOption> options = optionsText.map((text) {
      return AnswerOption(text: text, isCorrect: text == correctAnswerText);
    }).toList();
    options.shuffle();
    return ProcessedQuestion(original: q, options: options);
  }
}