/// Date helpers. All app logic works on calendar days without a time part,
/// so every date that enters the domain goes through [dayOnly] first.
library;

DateTime dayOnly(DateTime d) => DateTime(d.year, d.month, d.day);

bool isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

bool isLeapYear(int year) =>
    (year % 4 == 0 && year % 100 != 0) || year % 400 == 0;

int daysInYear(int year) => isLeapYear(year) ? 366 : 365;

int daysInMonth(int year, int month) => DateTime(year, month + 1, 0).day;

/// 1-based day of the year (1 January = 1).
int dayOfYear(DateTime d) {
  final start = DateTime.utc(d.year, 1, 1);
  final current = DateTime.utc(d.year, d.month, d.day);
  return current.difference(start).inDays + 1;
}

/// Whole days from [a] to [b] (positive when [b] is later). Uses UTC to be
/// immune to daylight saving jumps.
int daysBetween(DateTime a, DateTime b) {
  final ua = DateTime.utc(a.year, a.month, a.day);
  final ub = DateTime.utc(b.year, b.month, b.day);
  return ub.difference(ua).inDays;
}

DateTime addDays(DateTime d, int days) =>
    DateTime(d.year, d.month, d.day + days);

/// Monday of the week [d] belongs to.
DateTime startOfWeek(DateTime d) => addDays(dayOnly(d), -(d.weekday - 1));

/// Stable storage key, e.g. `2026-10-15`.
String dateKey(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

DateTime parseDateKey(String key) {
  final parts = key.split('-').map(int.parse).toList();
  return DateTime(parts[0], parts[1], parts[2]);
}

/// `MM-DD`, used for fixed special days that repeat every year.
String monthDayKey(DateTime d) =>
    '${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

/// Easter Sunday (Gregorian), anonymous Gregorian algorithm (Meeus/Jones/Butcher).
DateTime easterSunday(int year) {
  final a = year % 19;
  final b = year ~/ 100;
  final c = year % 100;
  final d = b ~/ 4;
  final e = b % 4;
  final f = (b + 8) ~/ 25;
  final g = (b - f + 1) ~/ 3;
  final h = (19 * a + b - d - g + 15) % 30;
  final i = c ~/ 4;
  final k = c % 4;
  final l = (32 + 2 * e + 2 * i - h - k) % 7;
  final m = (a + 11 * h + 22 * l) ~/ 451;
  final month = (h + l - 7 * m + 114) ~/ 31;
  final day = ((h + l - 7 * m + 114) % 31) + 1;
  return DateTime(year, month, day);
}

/// Second Sunday in May.
DateTime mothersDay(int year) {
  var d = DateTime(year, 5, 1);
  while (d.weekday != DateTime.sunday) {
    d = addDays(d, 1);
  }
  return addDays(d, 7);
}
