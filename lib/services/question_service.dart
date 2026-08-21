import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/question.dart';

class QuestionService {
  // Carrega perguntas de uma única categoria
  Future<List<Question>> loadQuestions({required String category, required String difficulty}) async {
    return loadQuestionsByKeys([category], difficulty);
  }

  // Carrega perguntas de múltiplas categorias (lista de chaves)
  // Se nenhuma chave for fornecida, retorna lista vazia.
  Future<List<Question>> loadQuestionsByKeys(List<String> categoryKeys, String difficulty) async {
    List<Question> allQuestions = [];

    for (var key in categoryKeys) {
      try {
        String jsonString = await rootBundle.loadString('assets/data/questions/$key.json');
        List<dynamic> jsonList = jsonDecode(jsonString);
        List<Question> questions = jsonList.map((j) => Question.fromJson(j)).toList();
        // Filtra por dificuldade (case-sensitive)
        final filtered = questions.where((q) => q.difficulty == difficulty).toList();
        allQuestions.addAll(filtered);
      } catch (e) {
        // Arquivo não encontrado ou erro de parsing - ignora silenciosamente
        // ou você pode logar, mas não interrompe o fluxo.
        print('Erro ao carregar $key.json: $e');
      }
    }

    // Embaralha a lista combinada (para o Mix)
    allQuestions.shuffle();
    return allQuestions;
  }

  // Prepara as perguntas para o quiz:
  // - Embaralha a ordem (já embaralhado se veio do loadQuestionsByKeys)
  // - Seleciona no máximo [maxQuestions] perguntas (ou todas se houver menos)
  // - Para cada pergunta, seleciona 4 alternativas (correta + 3 incorretas) e embaralha
  List<ProcessedQuestion> prepareQuestions(List<Question> questions, {int maxQuestions = 10}) {
    List<Question> shuffled = List.from(questions)..shuffle();
    int count = shuffled.length < maxQuestions ? shuffled.length : maxQuestions;
    List<Question> selected = shuffled.sublist(0, count);
    return selected.map((q) => _processQuestion(q)).toList();
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