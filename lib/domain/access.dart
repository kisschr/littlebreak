import '../core/dates.dart';

/// Whether a calendar day can be opened right now.
enum DayAccess {
  /// Today, or a past/upcoming day unlocked by Premium.
  playable,

  /// A past day of this year; Freemium players need Premium to catch up.
  needsPremiumPast,

  /// One of the next [AccessPolicy.daysAhead] days; Premium only.
  needsPremiumAhead,

  /// Too far in the future, or before 1 January of the current year.
  locked,
}

/// The business rules from the concept: everyone plays today, Premium plays
/// every past day since 1 January and up to three days ahead.
class AccessPolicy {
  const AccessPolicy();

  static const int daysAhead = 3;

  DayAccess accessFor(DateTime date, {required DateTime today, required bool premium}) {
    final day = dayOnly(date);
    final now = dayOnly(today);
    final diff = daysBetween(now, day);
    if (diff == 0) return DayAccess.playable;
    if (diff < 0) {
      if (day.year != now.year) return DayAccess.locked;
      return premium ? DayAccess.playable : DayAccess.needsPremiumPast;
    }
    if (diff <= daysAhead) {
      return premium ? DayAccess.playable : DayAccess.needsPremiumAhead;
    }
    return DayAccess.locked;
  }
}
