import 'package:flutter/material.dart';

import '../core/dates.dart';
import '../core/seeded_random.dart';
import '../data/content.dart';
import '../data/quote_quiz.dart';
import '../data/repositories.dart';
import '../design/palette.dart';
import '../domain/models.dart';
import '../l10n/generated/app_localizations.dart';

/// What the second statistic on the result screen counts.
enum GameStat { mistakes, moves, score, attempts }

/// Static description of one engine: how long it takes, what the levels
/// mean, and how to build its playing field.
///
/// Adding a game = one class implementing this, registered in
/// `game_registry.dart`, plus its name and how-to text in the ARB files.
abstract class GameDefinition {
  const GameDefinition();

  GameType get type;

  /// Rough duration per level, shown as "ca. 6 Min".
  int minutes(Difficulty difficulty);

  /// One line per level for the level picker, e.g. "6×6 Felder · ca. 6 Min".
  String levelDetail(AppLocalizations l10n, Difficulty difficulty);

  /// Whether the toolbar shows the hint button.
  bool get usesHints => false;

  /// Timer in the toolbar (always hidden for kids).
  bool get showsTimer => true;

  GameStat get stat => GameStat.mistakes;

  Widget build(BuildContext context, GameSession session);
}

/// Everything an engine needs to run one level of one day.
class GameSession {
  GameSession({
    required this.plan,
    required this.difficulty,
    required this.audience,
    required this.content,
    required this.quotes,
    required this.controller,
  });

  final DayPlan plan;
  final Difficulty difficulty;
  final Audience audience;
  final GameContent content;
  final QuoteQuizRepository quotes;
  final GameController controller;

  bool get isKid => audience == Audience.kid;
  String get languageCode => content.languageCode;

  /// Deterministic random source for this day, game and level. Engines pass
  /// a [salt] when they need independent streams.
  SeededRandom random([String salt = '']) => SeededRandom.fromParts([
        dateKey(plan.date),
        plan.type.id,
        difficulty.name,
        audience.name,
        salt,
      ]);

  /// Picks a value by difficulty.
  T byLevel<T>(T easy, T standard, T advanced) => switch (difficulty) {
        Difficulty.easy => easy,
        Difficulty.standard => standard,
        Difficulty.advanced => advanced,
      };
}

/// Result reported by an engine when the level is solved.
class GameOutcome {
  const GameOutcome({this.stars, this.score, this.artwork});

  /// Explicit stars (1–3); null = derived from mistakes and hints.
  final int? stars;

  /// Points for score-based games (shown instead of mistakes).
  final int? score;

  /// Finished picture for the gallery (coloring, pixel art).
  final GalleryItem? artwork;
}

/// Live state shared between the game screen (toolbar, timer, pause) and
/// the engine (mistakes, moves, hints, completion).
class GameController extends ChangeNotifier {
  GameController({this.maxHints = 3, this.onFinished});

  final int maxHints;
  final void Function(GameOutcome outcome)? onFinished;

  int _mistakes = 0;
  int _moves = 0;
  int _hintsUsed = 0;
  bool _paused = false;
  bool _finished = false;
  bool Function()? _hintHandler;

  int get mistakes => _mistakes;
  int get moves => _moves;
  int get hintsUsed => _hintsUsed;
  bool get paused => _paused;
  bool get finished => _finished;
  bool get hintsAvailable => _hintHandler != null && _hintsUsed < maxHints && !_finished;

  void reportMistake() {
    if (_finished) return;
    _mistakes++;
    notifyListeners();
  }

  void reportMove([int count = 1]) {
    if (_finished) return;
    _moves += count;
    notifyListeners();
  }

  /// The engine registers what a hint does; the handler returns false when
  /// no hint could be given (nothing left to reveal).
  void setHintHandler(bool Function()? handler) {
    _hintHandler = handler;
  }

  bool requestHint() {
    if (!hintsAvailable) return false;
    if (_hintHandler!()) {
      _hintsUsed++;
      notifyListeners();
      return true;
    }
    return false;
  }

  void setPaused(bool value) {
    if (_paused == value) return;
    _paused = value;
    notifyListeners();
  }

  void complete([GameOutcome outcome = const GameOutcome()]) {
    if (_finished) return;
    _finished = true;
    notifyListeners();
    onFinished?.call(outcome);
  }

  /// Default star rule: 3 for a clean solve, 2 for up to three slips
  /// (mistakes + hints), 1 otherwise. Kids never get fewer than 2.
  int starsFor(GameOutcome outcome, {required bool isKid}) {
    final explicit = outcome.stars;
    final slips = _mistakes + _hintsUsed;
    final stars = explicit ?? (slips == 0 ? 3 : slips <= 3 ? 2 : 1);
    return isKid ? stars.clamp(2, 3) : stars.clamp(1, 3);
  }
}

/// The opaque playing field: cream board, rounded, soft shadow — no glass
/// on top of game content.
class GameBoard extends StatelessWidget {
  const GameBoard({super.key, required this.child, this.padding = const EdgeInsets.all(10), this.radius = 24});

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final palette = KpPalette.of(context);
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: palette.board,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(color: palette.ink.withValues(alpha: 0.16), blurRadius: 32, offset: const Offset(0, 12)),
        ],
      ),
      child: child,
    );
  }
}

/// Small status line below a board ("Fehler 0 · Tipps 1 von 3").
class GameStatusLine extends StatelessWidget {
  const GameStatusLine({super.key, required this.parts});

  final List<String> parts;

  @override
  Widget build(BuildContext context) {
    final palette = KpPalette.of(context);
    final style = TextStyle(
      fontFamily: 'Nunito',
      fontSize: 14,
      fontWeight: FontWeight.w700,
      color: palette.inkSoft,
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < parts.length; i++) ...[
          if (i > 0) Padding(padding: const EdgeInsets.symmetric(horizontal: 8), child: Text('·', style: style)),
          Text(parts[i], style: style),
        ],
      ],
    );
  }
}
