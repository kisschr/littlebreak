import '../core/dates.dart';
import 'models.dart';

/// Decides which game is played on which day.
///
/// Three layers, as in the concept:
/// 1. a weekly rhythm (Monday creative, Tuesday words, ...),
/// 2. a rotation inside each weekday's pool so the same game type does not
///    come back every week,
/// 3. special days that override the rhythm (New Year, Easter, Halloween, ...).
///
/// The plan is a pure function of the date and the audience, so it needs no
/// storage, is identical for everyone and works offline in every year.
class DayPlanner {
  const DayPlanner();

  /// Weekday pools for adults, keyed by [DateTime.weekday].
  static const Map<int, List<GameType>> adultPools = {
    DateTime.monday: [GameType.coloring, GameType.pixelArt],
    DateTime.tuesday: [GameType.wordGuess, GameType.anagram, GameType.wordSearch],
    DateTime.wednesday: [GameType.quoteQuiz, GameType.trueFalse],
    DateTime.thursday: [
      GameType.sudoku,
      GameType.nonogram,
      GameType.lightsOut,
      GameType.numberPyramid,
      GameType.hanoi,
    ],
    DateTime.friday: [GameType.stacking, GameType.game2048, GameType.minesweeper],
    DateTime.saturday: [GameType.memory, GameType.simon],
    DateTime.sunday: [GameType.slidePuzzle, GameType.maze],
  };

  /// Weekday pools for kids: only kid friendly engines, no time pressure.
  static const Map<int, List<GameType>> kidPools = {
    DateTime.monday: [GameType.coloring, GameType.pixelArt],
    DateTime.tuesday: [GameType.wordSearch, GameType.anagram],
    DateTime.wednesday: [GameType.maze, GameType.trueFalse],
    DateTime.thursday: [GameType.sudoku, GameType.lightsOut, GameType.numberPyramid],
    DateTime.friday: [GameType.stacking, GameType.hanoi],
    DateTime.saturday: [GameType.memory, GameType.simon],
    DateTime.sunday: [GameType.slidePuzzle, GameType.coloring, GameType.breathing],
  };

  DayPlan planFor(DateTime date, {Audience audience = Audience.adult}) {
    final day = dayOnly(date);
    final special = SpecialDay.on(day);
    if (special != null &&
        (audience == Audience.adult || special.type.kidFriendly)) {
      return DayPlan(
        date: day,
        type: special.type,
        dayNumber: dayOfYear(day),
        specialId: special.id,
        motif: special.motif,
      );
    }
    final pools = audience == Audience.kid ? kidPools : adultPools;
    final pool = pools[day.weekday]!;
    final week = (dayOfYear(day) - 1) ~/ 7;
    // The year shifts the rotation so the same date gets a different game
    // next year.
    final index = (week + day.year) % pool.length;
    return DayPlan(
      date: day,
      type: pool[index],
      dayNumber: dayOfYear(day),
      specialId: _isAdvent(day) ? 'advent' : null,
    );
  }

  static bool _isAdvent(DateTime d) => d.month == 12 && d.day <= 24;
}

/// A day that overrides the weekly rhythm.
class SpecialDay {
  const SpecialDay(this.id, this.type, {this.motif});

  final String id;
  final GameType type;
  final String? motif;

  static SpecialDay? on(DateTime d) {
    final fixed = _fixed[monthDayKey(d)];
    if (fixed != null) return fixed;
    final easter = easterSunday(d.year);
    final offset = daysBetween(easter, d);
    switch (offset) {
      case -48:
        return const SpecialDay('carnival', GameType.coloring, motif: 'mask');
      case -2:
      case 0:
      case 1:
        return const SpecialDay('easter', GameType.memory, motif: 'easter');
    }
    if (isSameDay(d, mothersDay(d.year))) {
      return const SpecialDay('mothers_day', GameType.coloring, motif: 'flower');
    }
    return null;
  }

  static const Map<String, SpecialDay> _fixed = {
    '01-01': SpecialDay('new_year', GameType.pixelArt, motif: 'star'),
    '02-14': SpecialDay('valentine', GameType.coloring, motif: 'heart'),
    '02-29': SpecialDay('leap_day', GameType.lightsOut),
    '03-14': SpecialDay('pi_day', GameType.numberPyramid),
    '03-20': SpecialDay('spring', GameType.pixelArt, motif: 'flower'),
    '04-01': SpecialDay('april_fools', GameType.slidePuzzle),
    '04-22': SpecialDay('earth_day', GameType.trueFalse),
    '04-23': SpecialDay('book_day', GameType.quoteQuiz),
    '05-01': SpecialDay('may_day', GameType.stacking),
    '06-21': SpecialDay('summer', GameType.sudoku),
    '10-03': SpecialDay('unity_day', GameType.trueFalse),
    '10-31': SpecialDay('halloween', GameType.coloring, motif: 'pumpkin'),
    '11-11': SpecialDay('st_martin', GameType.coloring, motif: 'lantern'),
    '12-24': SpecialDay('christmas_eve', GameType.coloring, motif: 'tree'),
    '12-25': SpecialDay('christmas', GameType.memory, motif: 'christmas'),
    '12-26': SpecialDay('boxing_day', GameType.wordSearch),
    '12-31': SpecialDay('new_years_eve', GameType.breathing),
  };
}
