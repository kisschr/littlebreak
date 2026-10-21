import 'package:flutter/material.dart';

import '../../core/seeded_random.dart';
import '../../design/palette.dart';
import '../../domain/models.dart';
import '../../l10n/generated/app_localizations.dart';
import '../game_framework.dart';

class Game2048Definition extends GameDefinition {
  const Game2048Definition();

  @override
  GameType get type => GameType.game2048;

  static int targetFor(Difficulty d) => switch (d) {
        Difficulty.easy => 128,
        Difficulty.standard => 256,
        Difficulty.advanced => 512,
      };

  @override
  int minutes(Difficulty d) => switch (d) {
        Difficulty.easy => 2,
        Difficulty.standard => 4,
        Difficulty.advanced => 8,
      };

  @override
  String levelDetail(AppLocalizations l, Difficulty d) => l.detailTarget('${targetFor(d)}', minutes(d));

  @override
  GameStat get stat => GameStat.score;

  @override
  Widget build(BuildContext context, GameSession session) => Game2048(session: session);
}

enum SwipeDirection { up, down, left, right }

/// 4×4 board logic with seeded tile spawns.
class Board2048 {
  Board2048(this.random) {
    spawn();
    spawn();
  }

  final SeededRandom random;
  final List<int> cells = List.filled(16, 0);
  int score = 0;

  int get maxTile => cells.reduce((a, b) => a > b ? a : b);

  void spawn() {
    final empty = [for (var i = 0; i < 16; i++) if (cells[i] == 0) i];
    if (empty.isEmpty) return;
    cells[random.pick(empty)] = random.nextBool(0.9) ? 2 : 4;
  }

  /// Applies a move. Returns whether anything changed.
  bool move(SwipeDirection dir) {
    var changed = false;
    for (var line = 0; line < 4; line++) {
      final idx = [for (var k = 0; k < 4; k++) _index(dir, line, k)];
      final values = [for (final i in idx) if (cells[i] != 0) cells[i]];
      final merged = <int>[];
      for (var k = 0; k < values.length; k++) {
        if (k + 1 < values.length && values[k] == values[k + 1]) {
          merged.add(values[k] * 2);
          score += values[k] * 2;
          k++;
        } else {
          merged.add(values[k]);
        }
      }
      while (merged.length < 4) {
        merged.add(0);
      }
      for (var k = 0; k < 4; k++) {
        if (cells[idx[k]] != merged[k]) changed = true;
        cells[idx[k]] = merged[k];
      }
    }
    if (changed) spawn();
    return changed;
  }

  /// Cell index of position [k] (0 = the side tiles move towards) in [line].
  static int _index(SwipeDirection dir, int line, int k) => switch (dir) {
        SwipeDirection.left => line * 4 + k,
        SwipeDirection.right => line * 4 + 3 - k,
        SwipeDirection.up => k * 4 + line,
        SwipeDirection.down => (3 - k) * 4 + line,
      };

  bool get canMove {
    if (cells.contains(0)) return true;
    for (var i = 0; i < 16; i++) {
      if (i % 4 < 3 && cells[i] == cells[i + 1]) return true;
      if (i < 12 && cells[i] == cells[i + 4]) return true;
    }
    return false;
  }
}

class Game2048 extends StatefulWidget {
  const Game2048({super.key, required this.session});

  final GameSession session;

  @override
  State<Game2048> createState() => _Game2048State();
}

class _Game2048State extends State<Game2048> {
  late Board2048 board;
  late final int target = Game2048Definition.targetFor(widget.session.difficulty);
  int attempt = 1;
  bool stuck = false;
  Offset _drag = Offset.zero;

  GameController get controller => widget.session.controller;

  @override
  void initState() {
    super.initState();
    board = Board2048(widget.session.random('try1'));
  }

  void _swipe(SwipeDirection dir) {
    if (controller.paused || controller.finished || stuck) return;
    if (!board.move(dir)) return;
    controller.reportMove();
    setState(() {});
    if (board.maxTile >= target) {
      controller.complete(GameOutcome(stars: attempt == 1 ? 3 : attempt == 2 ? 2 : 1, score: board.score));
    } else if (!board.canMove) {
      setState(() => stuck = true);
    }
  }

  void _retry() {
    controller.reportMistake();
    setState(() {
      attempt++;
      stuck = false;
      board = Board2048(widget.session.random('try$attempt'));
    });
  }

  void _onPanEnd(DragEndDetails _) {
    final d = _drag;
    _drag = Offset.zero;
    if (d.distance < 16) return;
    if (d.dx.abs() > d.dy.abs()) {
      _swipe(d.dx > 0 ? SwipeDirection.right : SwipeDirection.left);
    } else {
      _swipe(d.dy > 0 ? SwipeDirection.down : SwipeDirection.up);
    }
  }

  Color _tileColor(int v, KpPalette p) {
    if (v == 0) return p.boardRelated;
    final steps = [p.blobs[3], p.highlight, p.blobs[1], p.blobs[0], p.blobs[2], p.accent, p.accentDark, p.success, p.successText];
    var i = 0;
    var x = v;
    while (x > 2) {
      x ~/= 2;
      i++;
    }
    return Color.lerp(Colors.white, steps[i.clamp(0, steps.length - 1)], 0.35 + 0.65 * (i / steps.length).clamp(0, 1))!;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final palette = KpPalette.of(context);
    return Column(
      children: [
        GestureDetector(
          onPanUpdate: (d) => _drag += d.delta,
          onPanEnd: _onPanEnd,
          child: GameBoard(
            padding: const EdgeInsets.all(12),
            child: AspectRatio(
              aspectRatio: 1,
              child: Stack(
                children: [
                  GridView.count(
                    crossAxisCount: 4,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      for (final v in board.cells)
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 120),
                          decoration: BoxDecoration(color: _tileColor(v, palette), borderRadius: BorderRadius.circular(14)),
                          alignment: Alignment.center,
                          child: v == 0
                              ? null
                              : FittedBox(
                                  child: Padding(
                                    padding: const EdgeInsets.all(6),
                                    child: Text(
                                      '$v',
                                      style: TextStyle(
                                        fontFamily: 'Nunito',
                                        fontWeight: FontWeight.w900,
                                        fontSize: 30,
                                        color: v >= 64 ? Colors.white : palette.ink,
                                      ),
                                    ),
                                  ),
                                ),
                        ),
                    ],
                  ),
                  if (stuck)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: palette.board.withValues(alpha: 0.88),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(l.game2048Stuck, textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w900, fontSize: 20, color: palette.ink)),
                            const SizedBox(height: 12),
                            FilledButton(
                              style: FilledButton.styleFrom(backgroundColor: palette.accent),
                              onPressed: _retry,
                              child: Text(l.tryAgain, style: const TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w900)),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        ListenableBuilder(
          listenable: controller,
          builder: (context, _) => GameStatusLine(parts: [
            l.target('$target'),
            l.scoreCount(board.score),
          ]),
        ),
        const SizedBox(height: 8),
        Text(l.swipeHint, textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w700, color: palette.inkSoft)),
      ],
    );
  }
}
