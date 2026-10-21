import 'dart:convert';

import 'package:flutter/services.dart';

/// A statement for "Wahr oder falsch".
class Fact {
  const Fact(this.statement, this.isTrue);

  final String statement;
  final bool isTrue;
}

/// A word search / memory theme of one month.
class WordTheme {
  const WordTheme(this.name, this.words);

  final String name;
  final List<String> words;
}

/// All bundled, language specific game content.
///
/// Content lives in `assets/content/<lang>/` as JSON so editors can extend
/// it without touching code. A new language only needs a new folder.
class GameContent {
  const GameContent({
    required this.languageCode,
    required this.wordsByLength,
    required this.kidWords,
    required this.themes,
    required this.facts,
    required this.quotes,
  });

  static const supportedLanguages = ['de', 'en'];

  final String languageCode;

  /// Upper-case words grouped by length (4–8).
  final Map<int, List<String>> wordsByLength;

  /// Short, simple words for kids' word games.
  final List<String> kidWords;

  /// Month (1–12) to themed word list.
  final Map<int, WordTheme> themes;

  final List<Fact> facts;

  /// Bundled QuizQuiz questions in the API's JSON shape, used offline.
  final List<Map<String, Object?>> quotes;

  List<String> words(int length) => wordsByLength[length] ?? const [];

  /// The letters a keyboard for this language needs.
  List<String> get alphabet => languageCode == 'de'
      ? 'QWERTZUIOPÜASDFGHJKLÖÄYXCVBNM'.split('')
      : 'QWERTYUIOPASDFGHJKLZXCVBNM'.split('');

  static String resolveLanguage(String code) =>
      supportedLanguages.contains(code) ? code : 'en';

  static Future<GameContent> load(String languageCode, {AssetBundle? bundle}) async {
    final lang = resolveLanguage(languageCode);
    final assets = bundle ?? rootBundle;
    Future<Object?> json(String file) async =>
        jsonDecode(await assets.loadString('assets/content/$lang/$file'));

    final words = (await json('words.json'))! as Map<String, Object?>;
    final themes = (await json('themes.json'))! as Map<String, Object?>;
    final facts = (await json('facts.json'))! as List<Object?>;
    final quotes = (await json('quotes.json'))! as List<Object?>;

    return GameContent(
      languageCode: lang,
      wordsByLength: {
        for (final e in words.entries)
          if (int.tryParse(e.key) != null)
            int.parse(e.key): (e.value! as List<Object?>).cast<String>(),
      },
      kidWords: (words['kids'] as List<Object?>? ?? const []).cast<String>(),
      themes: {
        for (final e in themes.entries)
          int.parse(e.key): WordTheme(
            (e.value! as Map<String, Object?>)['name']! as String,
            ((e.value! as Map<String, Object?>)['words']! as List<Object?>).cast<String>(),
          ),
      },
      facts: [
        for (final f in facts.cast<Map<String, Object?>>())
          Fact(f['s']! as String, f['a']! as bool),
      ],
      quotes: quotes.cast<Map<String, Object?>>(),
    );
  }
}
