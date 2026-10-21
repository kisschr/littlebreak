import 'package:flutter/material.dart';

import '../../design/palette.dart';
import '../../domain/models.dart';
import '../../l10n/generated/app_localizations.dart';
import '../game_framework.dart';

class LightsOutDefinition extends GameDefinition {
  const LightsOutDefinition();

  @override
  GameType get type => GameType.lightsOut;

  static (int size, int presses) layout(Difficulty d) => switch (d) {
        Difficulty.easy => (3, 3),
        Difficulty.standard => (4, 5),
        Difficulty.advanced => (5, 8),
      };

  @override
  int minutes(Difficulty d) => switch (d) {
        Difficulty.easy => 1,
        Difficulty.standard => 3,
        Difficulty.advanced => 6,
      };

  @override
  String levelDetail(AppLocalizations l, Difficulty d) {
    final s = layout(d).$1;
    return l.detailGrid('$s×$s', minutes(d));
  }

  @override
  bool get usesHints => true;

  @override
  GameStat get stat => GameStat.moves;

  @override
  Widget build(BuildContext context, GameSession session) => LightsOutGame(session: session);
}

/// Pure board logic, kept separate for tests.
class LightsOutBoard {
  LightsOutBoard(this.size) : lights = List.filled(size * size, false);

  final int size;
  final List<bool> lights;

  void press(int index) {
    final r = index ~/ size;
    final c = index % size;
    void flip(int rr, int cc) {
      if (rr < 0 || cc < 0 || rr >= size || cc >= size) return;
      lights[rr * size + cc] = !lights[rr * size + cc];
    }

    flip(r, c);
    flip(r - 1, c);
    flip(r + 1, c);
    flip(r, c - 1);
    flip(r, c + 1);
  }

  bool get solved => lights.every((on) => !on);
}

class LightsOutGame extends StatefulWidget {
  const LightsOutGame({super.key, required this.session});

  final GameSession session;

  @override
  State<LightsOutGame> createState() => _LightsOutGameState();
}

class _LightsOutGameState extends State<LightsOutGame> {
  late final LightsOutBoard board;

  /// Cells that still have to be pressed (pressing twice cancels out).
  late final Set<int> solution;
  late final int optimal;
  int? _hinted;

  GameController get controller => widget.session.controller;

  @override
  void initState() {
    super.initState();
    final (size, presses) = LightsOutDefinition.layout(widget.session.difficulty);
    board = LightsOutBoard(size);
    final random = widget.session.random();
    solution = random.sample(List.generate(size * size, (i) => i), presses).toSet();
    for (final i in solution) {
      board.press(i);
    }
    if (board.solved) {
      // Extremely unlikely, but never start with a finished board.
      solution.add(0);
      board.press(0);
    }
    optimal = solution.length;
    controller.setHintHandler(_hint);
  }

  void _press(int i) {
    if (controller.paused || controller.finished) return;
    setState(() {
      board.press(i);
      if (!solution.remove(i)) solution.add(i);
      _hinted = null;
    });
    controller.reportMove();
    if (board.solved) {
      final moves = controller.moves;
      controller.complete(GameOutcome(stars: moves <= optimal ? 3 : moves <= optimal * 2 ? 2 : 1));
    }
  }

  bool _hint() {
    if (solution.isEmpty) return false;
    setState(() => _hinted = (solution.toList()..sort()).first);
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final palette = KpPalette.of(context);
    final size = board.size;
    return Column(
      children: [
        GameBoard(
          padding: const EdgeInsets.all(14),
          child: AspectRatio(
            aspectRatio: 1,
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: size,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
              ),
              itemCount: size * size,
              itemBuilder: (context, i) {
                final on = board.lights[i];
                final hinted = _hinted == i;
                return Semantics(
                  button: true,
                  label: l.lightLabel(i ~/ size + 1, i % size + 1, on ? l.lightOn : l.lightOff),
                  excludeSemantics: true,
                  child: GestureDetector(
                    onTap: () => _press(i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      decoration: BoxDecoration(
                        color: on ? palette.highlight : palette.boardRelated,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: hinted ? palette.accent : (on ? palette.highlight : palette.boardLine),
                          width: hinted ? 3 : 1.5,
                        ),
                        boxShadow: on
                            ? [BoxShadow(color: palette.highlight.withValues(alpha: 0.6), blurRadius: 16)]
                            : null,
                      ),
                      child: on
                          ? Icon(Icons.light_mode, color: palette.accent.withValues(alpha: 0.75))
                          : null,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 18),
        ListenableBuilder(
          listenable: controller,
          builder: (context, _) => GameStatusLine(parts: [
            l.lightsLeft(board.lights.where((x) => x).length),
            l.movesCount(controller.moves),
          ]),
        ),
        const SizedBox(height: 10),
        Text(l.lightsGoal, textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w700, color: palette.inkSoft)),
      ],
    );
  }
}
