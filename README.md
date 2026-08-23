# 🧠 Quiz Nerd

Um jogo de perguntas e respostas com temática nerd, desenvolvido em **Flutter** e **Dart**.

A ideia é simples: escolher uma categoria, responder às perguntas e tentar conseguir a maior pontuação possível.

## 🎮 Categorias

Atualmente o jogo conta com:

* 🎮 Games
* 🎬 Filmes
* 🍥 Animes
* 🎲 Todas as Categorias — mistura perguntas dos três temas

Cada categoria possui perguntas divididas entre **fácil, médio e difícil**.

## ⭐ Sistema de progressão

O Quiz Nerd não se limita a responder perguntas e ver uma nota no final.

Durante a partida, o jogador pode:

* ganhar **XP** ao acertar perguntas;
* subir de **nível**;
* escolher **vantagens** para montar sua própria build;
* usar diferentes estratégias dependendo das vantagens escolhidas;
* acompanhar sua pontuação;
* disputar o **ranking**.

As vantagens são apresentadas durante a partida, fazendo com que cada jogo possa ter uma combinação diferente.

## 📚 Perguntas

As perguntas são armazenadas em arquivos **JSON**, o que facilita bastante a adição de novos conteúdos sem precisar alterar diretamente o código do aplicativo.

Cada pergunta possui:

* categoria;
* dificuldade;
* pergunta;
* 6 alternativas;
* resposta correta.

Durante a partida, o jogo seleciona 4 alternativas e embaralha sua ordem. As perguntas também são embaralhadas, evitando que as partidas sejam sempre iguais.

## 🛠️ Tecnologias

* Flutter
* Dart
* JSON
* Git
* GitHub

## 🚧 Status

**Em desenvolvimento.**

O projeto ainda recebe novas perguntas, melhorias na interface, ajustes de balanceamento e novas mecânicas.

## ▶️ Executando o projeto

É necessário ter o Flutter instalado.

```bash
flutter pub get
flutter run
```

Para verificar o ambiente:

```bash
flutter doctor
```

## 🎯 Objetivo

A ideia é transformar o Quiz Nerd em um jogo de perguntas com bastante variedade e progressão, mantendo o projeto simples de expandir com novas categorias, perguntas e mecânicas.
