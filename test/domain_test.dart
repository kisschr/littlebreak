import 'package:flutter_test/flutter_test.dart';
import 'package:kleine_pause/core/dates.dart';
import 'package:kleine_pause/core/seeded_random.dart';
import 'package:kleine_pause/domain/access.dart';
import 'package:kleine_pause/domain/models.dart';
import 'package:kleine_pause/domain/planner.dart';
import 'package:kleine_pause/domain/stats.dart';

DayRecord _played(DateTime d, [List<Difficulty> levels = const [Difficulty.standard]]) => DayRecord(
      dateKey: dateKey(d),
      gameId: 'sudoku',
      levels: {
        for (final l in levels) l: LevelResult(stars: 3, seconds: 60, mistakes: 0, completedAt: d),
      },
    );

ProgressStats _stats(Iterable<DateTime> days) => ProgressStats({for (final d in days) dateKey(d): _played(d)});

void main() {
  group('dates', () {
    test('day of year and leap years', () {
      expect(dayOfYear(DateTime(2026, 1, 1)), 1);
      expect(dayOfYear(DateTime(2026, 10, 15)), 288);
      expect(dayOfYear(DateTime(2028, 12, 31)), 366);
      expect(isLeapYear(2028), isTrue);
      expect(isLeapYear(2100), isFalse);
      expect(isLeapYear(2000), isTrue);
    });

    test('daysBetween ignores daylight saving', () {
      expect(daysBetween(DateTime(2026, 3, 28), DateTime(2026, 3, 30)), 2);
      expect(daysBetween(DateTime(2026, 10, 24), DateTime(2026, 10, 26)), 2);
      expect(daysBetween(DateTime(2026, 1, 2), DateTime(2026, 1, 1)), -1);
    });

    test('date keys round trip', () {
      final d = DateTime(2026, 3, 7);
      expect(dateKey(d), '2026-03-07');
      expect(parseDateKey(dateKey(d)), d);
      expect(startOfWeek(DateTime(2026, 10, 18)), DateTime(2026, 10, 12));
    });

    test('easter and mothers day', () {
      expect(easterSunday(2026), DateTime(2026, 4, 5));
      expect(easterSunday(2027), DateTime(2027, 3, 28));
      expect(easterSunday(2024), DateTime(2024, 3, 31));
      expect(mothersDay(2026), DateTime(2026, 5, 10));
    });
  });

  group('SeededRandom', () {
    test('is deterministic and in range', () {
      final a = SeededRandom.fromParts(['2026-10-15', 'sudoku']);
      final b = SeededRandom.fromParts(['2026-10-15', 'sudoku']);
      final c = SeededRandom.fromParts(['2026-10-16', 'sudoku']);
      final seqA = [for (var i = 0; i < 20; i++) a.nextInt(1000)];
      expect(seqA, [for (var i = 0; i < 20; i++) b.nextInt(1000)]);
      expect(seqA, isNot([for (var i = 0; i < 20; i++) c.nextInt(1000)]));
      final r = SeededRandom(42);
      for (var i = 0; i < 1000; i++) {
        final v = r.nextDouble();
        expect(v >= 0 && v < 1, isTrue);
        final n = r.nextIntInRange(3, 5);
        expect(n >= 3 && n <= 5, isTrue);
      }
    });

    test('shuffle keeps the elements', () {
      final list = List.generate(30, (i) => i);
      final shuffled = SeededRandom(7).shuffle(List.of(list));
      expect(shuffled.toSet(), list.toSet());
      expect(shuffled, isNot(list));
      expect(SeededRandom(7).sample(list, 5).toSet().length, 5);
    });
  });

  group('DayPlanner', () {
    const planner = DayPlanner();

    test('every day of a year gets a game, numbered from 1 January', () {
      for (final year in [2026, 2027, 2028]) {
        final days = daysInYear(year);
        for (var i = 0; i < days; i++) {
          final d = addDays(DateTime(year, 1, 1), i);
          final adult = planner.planFor(d);
          final kid = planner.planFor(d, audience: Audience.kid);
          expect(adult.dayNumber, i + 1);
          expect(kid.type.kidFriendly, isTrue, reason: '${dateKey(d)} ${kid.type}');
        }
      }
    });

    test('special days override the weekly rhythm', () {
      final halloween = planner.planFor(DateTime(2026, 10, 31));
      expect(halloween.specialId, 'halloween');
      expect(halloween.type, GameType.coloring);
      expect(halloween.motif, 'pumpkin');
      expect(planner.planFor(DateTime(2026, 4, 5)).specialId, 'easter');
      expect(planner.planFor(DateTime(2026, 12, 3)).specialId, 'advent');
      expect(planner.planFor(DateTime(2028, 2, 29)).specialId, 'leap_day');
    });

    test('the plan is stable and uses every engine over a year', () {
      final types = <GameType>{};
      for (var i = 0; i < 365; i++) {
        final d = addDays(DateTime(2026, 1, 1), i);
        expect(planner.planFor(d).type, planner.planFor(d).type);
        types.add(planner.planFor(d).type);
      }
      expect(types.length, greaterThanOrEqualTo(GameType.values.length - 1));
    });
  });

  group('AccessPolicy', () {
    const policy = AccessPolicy();
    final today = DateTime(2026, 10, 15);

    test('free players only play today', () {
      expect(policy.accessFor(today, today: today, premium: false), DayAccess.playable);
      expect(policy.accessFor(DateTime(2026, 10, 1), today: today, premium: false), DayAccess.needsPremiumPast);
      expect(policy.accessFor(DateTime(2026, 10, 16), today: today, premium: false), DayAccess.needsPremiumAhead);
      expect(policy.accessFor(DateTime(2026, 10, 19), today: today, premium: false), DayAccess.locked);
    });

    test('premium plays the whole year so far and three days ahead', () {
      expect(policy.accessFor(DateTime(2026, 1, 1), today: today, premium: true), DayAccess.playable);
      expect(policy.accessFor(DateTime(2026, 10, 18), today: today, premium: true), DayAccess.playable);
      expect(policy.accessFor(DateTime(2026, 10, 19), today: today, premium: true), DayAccess.locked);
      expect(policy.accessFor(DateTime(2025, 12, 31), today: today, premium: true), DayAccess.locked);
    });
  });

  group('ProgressStats', () {
    final today = DateTime(2026, 10, 15); // Thursday
    final since = DateTime(2026, 1, 1);

    test('streak counts back from today or yesterday', () {
      final days = [for (var i = 0; i < 5; i++) addDays(today, -i)];
      expect(_stats(days).streak(today: today, since: since), 5);
      expect(_stats(days.skip(1)).streak(today: today, since: since), 4);
      expect(_stats(const []).streak(today: today, since: since), 0);
    });

    test('one missed day per week is forgiven, two are not', () {
      final oneGap = [today, addDays(today, -1), addDays(today, -3)];
      expect(_stats(oneGap).streak(today: today, since: since), 3);
      final twoGaps = [today, addDays(today, -2), addDays(today, -4)];
      expect(_stats(twoGaps).streak(today: today, since: since), 2);
    });

    test('streak never reaches before the profile existed', () {
      final days = [for (var i = 0; i < 10; i++) addDays(today, -i)];
      expect(_stats(days).streak(today: today, since: addDays(today, -2)), 3);
    });

    test('week and month numbers', () {
      final stats = _stats([DateTime(2026, 10, 12), DateTime(2026, 10, 14), DateTime(2026, 10, 2)]);
      expect(stats.playedThisWeek(today), 2);
      expect(stats.monthProgress(2026, 10, today), (played: 3, available: 15));
      expect(stats.missedInMonth(2026, 10, today, since), 11);
      expect(stats.missedInMonth(2026, 10, today, DateTime(2026, 10, 10)), 3);
    });

    test('gold days and stars', () {
      final gold = _played(today, Difficulty.values);
      final stats = ProgressStats({dateKey(today): gold});
      expect(stats.goldDays, 1);
      expect(stats.totalStars, 9);
      expect(stats.solvedLevels, 3);
    });
  });

  group('models', () {
    test('day records keep the best result and serialise', () {
      final day = DateTime(2026, 10, 15);
      final slow = LevelResult(stars: 2, seconds: 300, mistakes: 2, completedAt: day);
      final fast = LevelResult(stars: 2, seconds: 100, mistakes: 1, completedAt: day);
      final record = DayRecord(dateKey: dateKey(day), gameId: 'sudoku')
          .withResult(Difficulty.easy, slow)
          .withResult(Difficulty.easy, fast);
      expect(record.levels[Difficulty.easy]!.seconds, 100);
      final copy = DayRecord.fromJson(record.toJson());
      expect(copy.levels[Difficulty.easy]!.seconds, 100);
      expect(copy.gameId, 'sudoku');
    });

    test('game ids are unique and resolvable', () {
      final ids = GameType.values.map((t) => t.id).toSet();
      expect(ids.length, GameType.values.length);
      for (final t in GameType.values) {
        expect(GameType.byId(t.id), t);
      }
    });
  });
}
