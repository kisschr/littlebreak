/// Deterministic pseudo random numbers (mulberry32).
///
/// Every generated puzzle is derived from the date, the game and the
/// difficulty, so every player gets the same puzzle on the same day without
/// anything being stored or downloaded. `dart:math` Random is not guaranteed
/// to produce identical sequences across platforms and SDK versions, so we
/// ship our own generator.
class SeededRandom {
  SeededRandom(int seed) : _state = seed & 0xFFFFFFFF;

  /// Builds a seed from any number of string parts (FNV-1a, 32 bit).
  factory SeededRandom.fromParts(List<Object> parts) {
    var hash = 0x811C9DC5;
    for (final unit in parts.join('|').codeUnits) {
      hash ^= unit;
      hash = _imul(hash, 0x01000193);
    }
    return SeededRandom(hash);
  }

  int _state;

  /// Next value in [0, 2^32).
  int nextUint32() {
    _state = (_state + 0x6D2B79F5) & 0xFFFFFFFF;
    var t = _state;
    t = _imul(t ^ (t >>> 15), t | 1);
    t ^= (t + _imul(t ^ (t >>> 7), t | 61)) & 0xFFFFFFFF;
    return (t ^ (t >>> 14)) & 0xFFFFFFFF;
  }

  /// Uniform double in [0, 1).
  double nextDouble() => nextUint32() / 4294967296.0;

  /// Uniform int in [0, max).
  int nextInt(int max) {
    assert(max > 0);
    return (nextDouble() * max).floor();
  }

  /// Uniform int in [min, max] (both inclusive).
  int nextIntInRange(int min, int max) => min + nextInt(max - min + 1);

  bool nextBool([double probability = 0.5]) => nextDouble() < probability;

  T pick<T>(List<T> items) => items[nextInt(items.length)];

  /// Fisher–Yates shuffle in place; returns the same list for chaining.
  List<T> shuffle<T>(List<T> items) {
    for (var i = items.length - 1; i > 0; i--) {
      final j = nextInt(i + 1);
      final tmp = items[i];
      items[i] = items[j];
      items[j] = tmp;
    }
    return items;
  }

  /// Picks [count] distinct items (or all, if there are fewer).
  List<T> sample<T>(List<T> items, int count) {
    final copy = shuffle(List<T>.of(items));
    return copy.take(count).toList();
  }

  static int _imul(int a, int b) {
    final aHi = (a >>> 16) & 0xFFFF;
    final aLo = a & 0xFFFF;
    final bHi = (b >>> 16) & 0xFFFF;
    final bLo = b & 0xFFFF;
    return ((aLo * bLo) + (((aHi * bLo + aLo * bHi) << 16) & 0xFFFFFFFF)) &
        0xFFFFFFFF;
  }
}
