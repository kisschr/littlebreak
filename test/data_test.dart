import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:kleine_pause/core/dates.dart';
import 'package:kleine_pause/core/seeded_random.dart';
import 'package:kleine_pause/data/content.dart';
import 'package:kleine_pause/data/quote_quiz.dart';
import 'package:kleine_pause/data/repositories.dart';
import 'package:kleine_pause/domain/models.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<JsonStore> _store() async {
  SharedPreferences.setMockInitialValues({});
  return JsonStore(await SharedPreferences.getInstance());
}

Map<String, Object?> _item(String uuid, String quote, {String? date, String correct = '1'}) => {
      'uuid': uuid,
      'quote': quote,
      'answer1': 'Autor A',
      'answer2': 'Autor B',
      'correct_answer': correct,
      'date': date,
    };

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('QuoteQuestion', () {
    test('parses API items and unescapes HTML', () {
      final q = QuoteQuestion.fromApi({
        'uuid': 'x',
        'quote': '&bdquo;Carpe diem&ldquo; &amp; mehr&#8230;',
        'answer1': 'Horaz',
        'answer2': 'Cicero',
        'correct_answer': '1',
        'date': '2026-10-15',
      })!;
      expect(q.quote, '„Carpe diem“ & mehr…');
      expect(q.correctAnswer, 'Horaz');
      expect(q.date, DateTime(2026, 10, 15));
    });

    test('rejects incomplete items', () {
      expect(QuoteQuestion.fromApi({'quote': 'x', 'answer1': 'a', 'answer2': 'b', 'correct_answer': '3'}), isNull);
      expect(QuoteQuestion.fromApi({'quote': '', 'answer1': 'a', 'answer2': 'b', 'correct_answer': '1'}), isNull);
    });

    test('extra answers keep the correct one', () {
      final q = QuoteQuestion.fromApi(_item('1', 'Zitat'))!;
      final four = q.withAnswerCount(4, ['C', 'D', 'E', 'Autor A'], SeededRandom(1));
      expect(four.answers.length, 4);
      expect(four.answers.toSet().length, 4);
      expect(four.correctAnswer, 'Autor A');
    });
  });

  group('QuoteQuizApi and repository', () {
    test('calls the Zitat des Tages endpoint with the language', () async {
      Uri? requested;
      final api = QuoteQuizApi(
        client: MockClient((request) async {
          requested = request.url;
          return http.Response.bytes(utf8.encode(jsonEncode([_item('1', 'Ä')])), 200);
        }),
      );
      final items = await api.fetchQuestions('de');
      expect(requested!.host, 'api.zitatdestages.net');
      expect(requested!.path, '/quotes/questions');
      expect(requested!.queryParameters['l'], 'de');
      expect(items.single['quote'], 'Ä');
    });

    test('refresh caches questions and never throws offline', () async {
      final store = await _store();
      final online = QuoteQuizRepository(
        api: QuoteQuizApi(client: MockClient((_) async => http.Response(jsonEncode([
              _item('a', 'Heute', date: '2026-10-15'),
              _item('b', 'Gestern', date: '2026-10-14'),
              _item('c', 'Morgen', date: '2026-10-16'),
            ]), 200))),
        store: store,
      );
      expect(await online.refresh('de'), isTrue);
      expect(online.cached('de').length, 3);
      // Second call inside the interval does not hit the network again.
      expect(await online.refresh('de'), isFalse);

      final offline = QuoteQuizRepository(
        api: QuoteQuizApi(client: MockClient((_) async => throw http.ClientException('offline'))),
        store: await _store(),
      );
      expect(await offline.refresh('de'), isFalse);
    });

    test('questions of a day: that day first, never the future, bundled as filler', () async {
      final store = await _store();
      final repo = QuoteQuizRepository(
        api: QuoteQuizApi(client: MockClient((_) async => http.Response(jsonEncode([
              _item('a', 'Heute', date: '2026-10-15'),
              _item('b', 'Gestern', date: '2026-10-14'),
              _item('c', 'Morgen', date: '2026-10-16'),
            ]), 200))),
        store: store,
      );
      await repo.refresh('de');
      final questions = repo.questionsFor(
        date: DateTime(2026, 10, 15),
        lang: 'de',
        count: 4,
        bundled: [_item('x', 'Offline 1'), _item('y', 'Offline 2')],
      );
      expect(questions.map((q) => q.quote).take(2), ['Heute', 'Gestern']);
      expect(questions.map((q) => q.quote), isNot(contains('Morgen')));
      expect(questions.length, 4);
    });
  });

  group('repositories', () {
    test('progress, gallery and tutorials round trip and delete', () async {
      final repo = ProgressRepository(await _store());
      final day = DateTime(2026, 10, 15);
      final record = DayRecord(dateKey: dateKey(day), gameId: 'sudoku').withResult(
        Difficulty.easy,
        LevelResult(stars: 3, seconds: 42, mistakes: 0, completedAt: day),
      );
      await repo.saveRecords('p1', {record.dateKey: record});
      await repo.saveGallery('p1', [
        const GalleryItem(dateKey: '2026-10-15', gameId: 'coloring', motif: 'leaf', difficulty: Difficulty.easy, colors: [0xFF00FF00, null]),
      ]);
      await repo.saveSeenTutorials('p1', {'sudoku'});
      expect(repo.loadRecords('p1')[record.dateKey]!.levels[Difficulty.easy]!.seconds, 42);
      expect(repo.loadGallery('p1').single.colors, [0xFF00FF00, null]);
      expect(repo.loadSeenTutorials('p1'), {'sudoku'});
      expect(repo.loadRecords('p2'), isEmpty);
      await repo.deleteProfileData('p1');
      expect(repo.loadRecords('p1'), isEmpty);
      expect(repo.loadGallery('p1'), isEmpty);
    });

    test('profiles and active id', () async {
      final repo = ProfileRepository(await _store());
      final profile = Profile(
        id: '1',
        name: 'Anna',
        audience: Audience.adult,
        createdAt: DateTime(2026, 1, 1),
        lastDifficulty: Difficulty.standard,
        colorIndex: 0,
      );
      await repo.saveAll([profile]);
      await repo.setActiveId('1');
      expect(repo.loadAll().single.name, 'Anna');
      expect(repo.activeId, '1');
      await repo.setActiveId(null);
      expect(repo.activeId, isNull);
    });
  });

  group('bundled content', () {
    for (final lang in GameContent.supportedLanguages) {
      test('$lang content loads and is usable', () async {
        final c = await GameContent.load(lang);
        for (final length in [4, 5, 6, 7, 8]) {
          expect(c.words(length).length, greaterThanOrEqualTo(15), reason: '$lang $length');
          for (final w in c.words(length)) {
            expect(w.length, length, reason: w);
            expect(w, w.toUpperCase());
            for (final ch in w.split('')) {
              expect(c.alphabet, contains(ch), reason: '$lang $w');
            }
          }
        }
        expect(c.kidWords, isNotEmpty);
        expect(c.themes.keys.toSet(), {for (var m = 1; m <= 12; m++) m});
        expect(c.facts.length, greaterThanOrEqualTo(30));
        final quotes = c.quotes.map(QuoteQuestion.fromApi).whereType<QuoteQuestion>();
        expect(quotes.length, greaterThanOrEqualTo(25));
      });
    }

    test('unknown languages fall back to English', () {
      expect(GameContent.resolveLanguage('fr'), 'en');
      expect(GameContent.resolveLanguage('de'), 'de');
    });
  });
}
