/// Core domain types shared by planner, games, persistence and UI.
library;

enum Difficulty {
  easy,
  standard,
  advanced;

  static Difficulty fromName(String? name) => Difficulty.values.firstWhere(
        (d) => d.name == name,
        orElse: () => Difficulty.standard,
      );
}

enum Audience { adult, kid }

/// The eight categories of the concept's game catalogue.
enum GameCategory {
  creative,
  word,
  quiz,
  logic,
  arcade,
  memory,
  numbers,
  mindful,
}

/// Every playable engine. The `id` is persisted (results, gallery, plan),
/// so never rename an existing value; add new ones instead.
enum GameType {
  coloring('coloring', GameCategory.creative, kidFriendly: true),
  pixelArt('pixel_art', GameCategory.creative, kidFriendly: true),
  wordGuess('word_guess', GameCategory.word),
  anagram('anagram', GameCategory.word, kidFriendly: true),
  wordSearch('word_search', GameCategory.word, kidFriendly: true),
  quoteQuiz('quote_quiz', GameCategory.quiz),
  trueFalse('true_false', GameCategory.quiz, kidFriendly: true),
  sudoku('sudoku', GameCategory.logic, kidFriendly: true),
  nonogram('nonogram', GameCategory.logic),
  lightsOut('lights_out', GameCategory.logic, kidFriendly: true),
  hanoi('hanoi', GameCategory.logic, kidFriendly: true),
  maze('maze', GameCategory.logic, kidFriendly: true),
  stacking('stacking', GameCategory.arcade, kidFriendly: true),
  minesweeper('minesweeper', GameCategory.arcade),
  game2048('2048', GameCategory.numbers),
  numberPyramid('number_pyramid', GameCategory.numbers, kidFriendly: true),
  memory('memory', GameCategory.memory, kidFriendly: true),
  simon('simon', GameCategory.memory, kidFriendly: true),
  slidePuzzle('slide_puzzle', GameCategory.logic, kidFriendly: true),
  breathing('breathing', GameCategory.mindful, kidFriendly: true);

  const GameType(this.id, this.category, {this.kidFriendly = false});

  final String id;
  final GameCategory category;
  final bool kidFriendly;

  static GameType? byId(String id) {
    for (final t in GameType.values) {
      if (t.id == id) return t;
    }
    return null;
  }
}

/// One game on one day, as decided by the planner.
class DayPlan {
  const DayPlan({
    required this.date,
    required this.type,
    required this.dayNumber,
    this.specialId,
    this.motif,
  });

  final DateTime date;
  final GameType type;

  /// 1-based day of the year ("Tag 288").
  final int dayNumber;

  /// Id of a special day ("halloween") or null on regular days.
  final String? specialId;

  /// Optional content hint for the engine (e.g. a coloring motif id).
  final String? motif;

  bool get isSpecial => specialId != null;
}

/// Result of finishing one difficulty of one day's game.
class LevelResult {
  const LevelResult({
    required this.stars,
    required this.seconds,
    required this.mistakes,
    required this.completedAt,
  });

  factory LevelResult.fromJson(Map<String, Object?> json) => LevelResult(
        stars: (json['stars'] as num?)?.toInt() ?? 1,
        seconds: (json['seconds'] as num?)?.toInt() ?? 0,
        mistakes: (json['mistakes'] as num?)?.toInt() ?? 0,
        completedAt: DateTime.tryParse(json['at'] as String? ?? '') ??
            DateTime.fromMillisecondsSinceEpoch(0),
      );

  final int stars;
  final int seconds;
  final int mistakes;
  final DateTime completedAt;

  Map<String, Object?> toJson() => {
        'stars': stars,
        'seconds': seconds,
        'mistakes': mistakes,
        'at': completedAt.toIso8601String(),
      };

  /// Keeps the better of two results for the same level.
  LevelResult best(LevelResult other) {
    if (other.stars != stars) return other.stars > stars ? other : this;
    return other.seconds < seconds ? other : this;
  }
}

/// Everything a profile achieved on one calendar day.
class DayRecord {
  const DayRecord({required this.dateKey, required this.gameId, this.levels = const {}});

  factory DayRecord.fromJson(Map<String, Object?> json) {
    final levels = <Difficulty, LevelResult>{};
    final raw = json['levels'];
    if (raw is Map) {
      raw.forEach((key, value) {
        if (value is Map) {
          levels[Difficulty.fromName(key as String)] =
              LevelResult.fromJson(value.cast<String, Object?>());
        }
      });
    }
    return DayRecord(
      dateKey: json['date'] as String? ?? '',
      gameId: json['game'] as String? ?? '',
      levels: levels,
    );
  }

  final String dateKey;
  final String gameId;
  final Map<Difficulty, LevelResult> levels;

  bool get played => levels.isNotEmpty;

  /// All three difficulties solved: the day turns gold in the calendar.
  bool get isGold => Difficulty.values.every(levels.containsKey);

  int get totalStars => levels.values.fold(0, (sum, l) => sum + l.stars);

  DayRecord withResult(Difficulty difficulty, LevelResult result) {
    final previous = levels[difficulty];
    return DayRecord(
      dateKey: dateKey,
      gameId: gameId,
      levels: {
        ...levels,
        difficulty: previous == null ? result : previous.best(result),
      },
    );
  }

  Map<String, Object?> toJson() => {
        'date': dateKey,
        'game': gameId,
        'levels': {for (final e in levels.entries) e.key.name: e.value.toJson()},
      };
}

class Profile {
  const Profile({
    required this.id,
    required this.name,
    required this.audience,
    required this.createdAt,
    this.lastDifficulty = Difficulty.standard,
    this.colorIndex = 0,
  });

  factory Profile.fromJson(Map<String, Object?> json) => Profile(
        id: json['id'] as String,
        name: json['name'] as String? ?? '',
        audience: json['audience'] == 'kid' ? Audience.kid : Audience.adult,
        createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
            DateTime.now(),
        lastDifficulty: Difficulty.fromName(json['lastDifficulty'] as String?),
        colorIndex: (json['color'] as num?)?.toInt() ?? 0,
      );

  final String id;
  final String name;
  final Audience audience;
  final DateTime createdAt;
  final Difficulty lastDifficulty;
  final int colorIndex;

  bool get isKid => audience == Audience.kid;

  String get initial => name.trim().isEmpty
      ? '?'
      : String.fromCharCode(name.trim().runes.first).toUpperCase();

  Profile copyWith({String? name, Difficulty? lastDifficulty, int? colorIndex}) =>
      Profile(
        id: id,
        name: name ?? this.name,
        audience: audience,
        createdAt: createdAt,
        lastDifficulty: lastDifficulty ?? this.lastDifficulty,
        colorIndex: colorIndex ?? this.colorIndex,
      );

  Map<String, Object?> toJson() => {
        'id': id,
        'name': name,
        'audience': audience == Audience.kid ? 'kid' : 'adult',
        'createdAt': createdAt.toIso8601String(),
        'lastDifficulty': lastDifficulty.name,
        'color': colorIndex,
      };
}
