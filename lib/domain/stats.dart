import '../core/dates.dart';
import 'models.dart';

/// Derived numbers for the UI: streak, week progress, month progress.
class ProgressStats {
  const ProgressStats(this.records);

  /// Day records keyed by [dateKey].
  final Map<String, DayRecord> records;

  bool playedOn(DateTime day) => records[dateKey(day)]?.played ?? false;

  /// Days in a row with a solved game, ending today (or yesterday while
  /// today is still open). One missed day per calendar week is forgiven by a
  /// joker, so a single gap does not break the streak. [since] is the first
  /// day the profile existed; the streak never reaches further back.
  int streak({required DateTime today, required DateTime since}) {
    final first = dayOnly(since);
    var day = dayOnly(today);
    if (!playedOn(day)) day = addDays(day, -1);
    var count = 0;
    final jokerUsedInWeek = <String>{};
    while (!day.isBefore(first)) {
      if (playedOn(day)) {
        count++;
      } else {
        final week = dateKey(startOfWeek(day));
        // A joker may only bridge to an earlier played day.
        final previous = addDays(day, -1);
        if (jokerUsedInWeek.contains(week) ||
            previous.isBefore(first) ||
            !playedOn(previous)) {
          break;
        }
        jokerUsedInWeek.add(week);
      }
      day = addDays(day, -1);
    }
    return count;
  }

  /// Played days in the Monday–Sunday week containing [today].
  int playedThisWeek(DateTime today) {
    final monday = startOfWeek(today);
    var n = 0;
    for (var i = 0; i < 7; i++) {
      if (playedOn(addDays(monday, i))) n++;
    }
    return n;
  }

  /// Played days in [month] of [year], counted up to and including [today].
  ({int played, int available}) monthProgress(int year, int month, DateTime today) {
    final now = dayOnly(today);
    var played = 0;
    var available = 0;
    for (var d = 1; d <= daysInMonth(year, month); d++) {
      final day = DateTime(year, month, d);
      if (day.isAfter(now)) break;
      available++;
      if (playedOn(day)) played++;
    }
    return (played: played, available: available);
  }

  /// Past days of [month] not played since the profile started.
  int missedInMonth(int year, int month, DateTime today, DateTime since) {
    final now = dayOnly(today);
    final first = dayOnly(since);
    var missed = 0;
    for (var d = 1; d <= daysInMonth(year, month); d++) {
      final day = DateTime(year, month, d);
      if (!day.isBefore(now)) break;
      if (day.isBefore(first)) continue;
      if (!playedOn(day)) missed++;
    }
    return missed;
  }

  int get totalPlayedDays => records.values.where((r) => r.played).length;
  int get goldDays => records.values.where((r) => r.isGold).length;
  int get totalStars => records.values.fold(0, (s, r) => s + r.totalStars);
  int get solvedLevels => records.values.fold(0, (s, r) => s + r.levels.length);
}
