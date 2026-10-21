import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/dates.dart';
import '../core/seeded_random.dart';
import 'repositories.dart';

/// One "Wer hat es gesagt?" question from the Zitat des Tages API.
class QuoteQuestion {
  const QuoteQuestion({
    required this.uuid,
    required this.quote,
    required this.answers,
    required this.correctIndex,
    this.date,
  });

  /// Parses an item of `GET /quotes/questions` (same shape as the bundled
  /// fallback file). Returns null for incomplete items.
  static QuoteQuestion? fromApi(Map<String, Object?> json) {
    final quote = htmlUnescape((json['quote'] ?? '').toString()).trim();
    final a1 = htmlUnescape((json['answer1'] ?? '').toString()).trim();
    final a2 = htmlUnescape((json['answer2'] ?? '').toString()).trim();
    final correct = int.tryParse((json['correct_answer'] ?? '').toString());
    if (quote.isEmpty || a1.isEmpty || a2.isEmpty || (correct != 1 && correct != 2)) {
      return null;
    }
    final rawDate = json['date']?.toString();
    return QuoteQuestion(
      uuid: (json['uuid'] ?? quote.hashCode).toString(),
      quote: quote,
      answers: [a1, a2],
      correctIndex: correct! - 1,
      date: rawDate == null ? null : DateTime.tryParse(rawDate),
    );
  }

  final String uuid;
  final String quote;
  final List<String> answers;
  final int correctIndex;
  final DateTime? date;

  String get correctAnswer => answers[correctIndex];

  /// Returns a copy with [count] answers: the original two plus distractor
  /// authors from [pool], shuffled deterministically.
  QuoteQuestion withAnswerCount(int count, List<String> pool, SeededRandom random) {
    final answers = List<String>.of(this.answers);
    final candidates = random.shuffle(
      pool.where((a) => !answers.contains(a)).toSet().toList()..sort(),
    );
    for (final c in candidates) {
      if (answers.length >= count) break;
      answers.add(c);
    }
    final correct = correctAnswer;
    random.shuffle(answers);
    return QuoteQuestion(
      uuid: uuid,
      quote: quote,
      answers: answers,
      correctIndex: answers.indexOf(correct),
      date: date,
    );
  }

  Map<String, Object?> toApiJson() => {
        'uuid': uuid,
        'quote': quote,
        'answer1': answers[0],
        'answer2': answers[1],
        'correct_answer': '${correctIndex + 1}',
        'date': date?.toIso8601String(),
      };
}

/// Decodes the HTML entities the API uses (`&quot;`, `&#8222;`, ...).
String htmlUnescape(String input) {
  if (!input.contains('&')) return input;
  const named = {
    'amp': '&',
    'lt': '<',
    'gt': '>',
    'quot': '"',
    'apos': "'",
    'nbsp': ' ',
    'bdquo': '„',
    'ldquo': '“',
    'rdquo': '”',
    'lsquo': '‘',
    'rsquo': '’',
    'sbquo': '‚',
    'hellip': '…',
    'ndash': '–',
    'mdash': '—',
    'auml': 'ä',
    'ouml': 'ö',
    'uuml': 'ü',
    'Auml': 'Ä',
    'Ouml': 'Ö',
    'Uuml': 'Ü',
    'szlig': 'ß',
    'laquo': '«',
    'raquo': '»',
  };
  return input.replaceAllMapped(RegExp(r'&(#x?[0-9a-fA-F]+|[a-zA-Z]+);'), (m) {
    final entity = m.group(1)!;
    if (entity.startsWith('#x') || entity.startsWith('#X')) {
      final code = int.tryParse(entity.substring(2), radix: 16);
      return code == null ? m.group(0)! : String.fromCharCode(code);
    }
    if (entity.startsWith('#')) {
      final code = int.tryParse(entity.substring(1));
      return code == null ? m.group(0)! : String.fromCharCode(code);
    }
    return named[entity] ?? m.group(0)!;
  });
}

/// Talks to the Zitat des Tages API (the same endpoint the Zitat des Tages
/// app uses for its QuizQuiz).
class QuoteQuizApi {
  QuoteQuizApi({http.Client? client, this.timeout = const Duration(seconds: 8)})
      : _client = client ?? http.Client();

  final http.Client _client;
  final Duration timeout;

  static const host = 'api.zitatdestages.net';

  Uri questionsUri(String languageCode) => Uri.https(host, '/quotes/questions', {
        't': '',
        'a': '',
        'date': '',
        'seed': '',
        'l': languageCode,
        'ct': 'all',
        'search': '',
        'search_operator': 'contains',
        'api': 'api',
        'version': 'quotes',
        'ctid': 'all',
        'language': 'all',
      });

  /// Downloads all published questions for [languageCode].
  /// Throws on network or format errors.
  Future<List<Map<String, Object?>>> fetchQuestions(String languageCode) async {
    final response = await _client.get(questionsUri(languageCode)).timeout(timeout);
    if (response.statusCode != 200) {
      throw http.ClientException('HTTP ${response.statusCode}', response.request?.url);
    }
    final body = jsonDecode(utf8.decode(response.bodyBytes));
    if (body is! List) throw const FormatException('Expected a JSON list');
    return body.whereType<Map<Object?, Object?>>().map((m) => m.cast<String, Object?>()).toList();
  }
}

/// Offline-first question source: questions downloaded from the API are kept
/// on the device; without network the bundled questions are used.
class QuoteQuizRepository {
  QuoteQuizRepository({required this._api, required this._store});

  final QuoteQuizApi _api;
  final JsonStore _store;
  final Map<String, Future<bool>> _inFlight = {};

  String _cacheKey(String lang) => 'quotequiz.cache.v1.$lang';
  String _syncedKey(String lang) => 'quotequiz.synced.v1.$lang';

  List<QuoteQuestion> cached(String lang) {
    final raw = _store.read(_cacheKey(lang));
    if (raw is! List) return [];
    return raw
        .whereType<Map<Object?, Object?>>()
        .map((m) => QuoteQuestion.fromApi(m.cast<String, Object?>()))
        .whereType<QuoteQuestion>()
        .toList();
  }

  DateTime? lastSync(String lang) => DateTime.tryParse(_store.readString(_syncedKey(lang)) ?? '');

  /// Refreshes the cache at most every [minInterval]. Never throws; returns
  /// whether new data was stored.
  Future<bool> refresh(String lang, {Duration minInterval = const Duration(hours: 6)}) {
    final last = lastSync(lang);
    if (last != null && DateTime.now().difference(last) < minInterval) {
      return Future.value(false);
    }
    // The callback must not return the removed future: whenComplete would
    // then wait for the very future it belongs to.
    return _inFlight[lang] ??= _refresh(lang).whenComplete(() {
      _inFlight.remove(lang);
    });
  }

  Future<bool> _refresh(String lang) async {
    try {
      final items = await _api.fetchQuestions(lang);
      final byUuid = {for (final q in cached(lang)) q.uuid: q.toApiJson()};
      for (final item in items) {
        final q = QuoteQuestion.fromApi(item);
        if (q != null) byUuid[q.uuid] = q.toApiJson();
      }
      await _store.write(_cacheKey(lang), byUuid.values.toList());
      await _store.writeString(_syncedKey(lang), DateTime.now().toIso8601String());
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Questions for one day's QuizQuiz: the question of that date first, then
  /// the most recent earlier ones, then bundled questions as filler. Future
  /// questions are never shown before their date.
  List<QuoteQuestion> questionsFor({
    required DateTime date,
    required String lang,
    required int count,
    required List<Map<String, Object?>> bundled,
  }) {
    final day = dayOnly(date);
    final fromApi = cached(lang)
        .where((q) => q.date == null || !dayOnly(q.date!).isAfter(day))
        .toList()
      ..sort((a, b) {
        final da = a.date ?? DateTime(1970);
        final db = b.date ?? DateTime(1970);
        return db.compareTo(da);
      });
    final random = SeededRandom.fromParts(['quote_quiz', dateKey(day), lang]);
    final fallback = random.shuffle(
      bundled.map(QuoteQuestion.fromApi).whereType<QuoteQuestion>().toList(),
    );
    final result = <QuoteQuestion>[];
    final seenQuotes = <String>{};
    for (final q in [...fromApi, ...fallback]) {
      if (result.length >= count) break;
      if (seenQuotes.add(q.quote)) result.add(q);
    }
    return result;
  }

  /// All author names known locally, used for extra answer options.
  List<String> authorPool(String lang, List<Map<String, Object?>> bundled) => {
        for (final q in [
          ...cached(lang),
          ...bundled.map(QuoteQuestion.fromApi).whereType<QuoteQuestion>(),
        ])
          ...q.answers,
      }.toList();
}
