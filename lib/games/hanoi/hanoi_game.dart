import 'package:flutter/material.dart';

import '../../design/palette.dart';
import '../../domain/models.dart';
import '../../l10n/generated/app_localizations.dart';
import '../game_framework.dart';

class HanoiDefinition extends GameDefinition {
  const HanoiDefinition();

  @override
  GameType get type => GameType.hanoi;

  static int discsFor(Difficulty d) => switch (d) {
        Difficulty.easy => 3,
        Difficulty.standard => 4,
        Difficulty.advanced => 5,
      };

  @override
  int minutes(Difficulty d) => switch (d) {
        Difficulty.easy => 1,
        Difficulty.standard => 3,
        Difficulty.advanced => 6,
      };

  @override
  String levelDetail(AppLocalizations l, Difficulty d) => l.detailDiscs(discsFor(d), minutes(d));

  @override
  GameStat get stat => GameStat.moves;

  @override
  Widget build(BuildContext context, GameSession session) => HanoiGame(session: session);
}

class HanoiState {
  HanoiState(this.discs) : pegs = [List.generate(discs, (i) => discs - i), <int>[], <int>[]];

  final int discs;
  final List<List<int>> pegs;

  int get optimalMoves => (1 << discs) - 1;

  bool canMove(int from, int to) {
    if (from == to || pegs[from].isEmpty) return false;
    return pegs[to].isEmpty || pegs[to].last > pegs[from].last;
  }

  bool move(int from, int to) {
    if (!canMove(from, to)) return false;
    pegs[to].add(pegs[from].removeLast());
    return true;
  }

  bool get solved => pegs[2].length == discs;
}

class HanoiGame extends StatefulWidget {
  const HanoiGame({super.key, required this.session});

  final GameSession session;

  @override
  State<HanoiGame> createState() => _HanoiGameState();
}

class _HanoiGameState extends State<HanoiGame> {
  late final HanoiState state = HanoiState(HanoiDefinition.discsFor(widget.session.difficulty));
  int? selected;

  GameController get controller => widget.session.controller;

  void _tapPeg(int peg) {
    if (controller.paused || controller.finished) return;
    setState(() {
      if (selected == null) {
        if (state.pegs[peg].isNotEmpty) selected = peg;
        return;
      }
      if (selected == peg) {
        selected = null;
        return;
      }
      if (state.move(selected!, peg)) {
        controller.reportMove();
      } else {
        controller.reportMistake();
      }
      selected = null;
    });
    if (state.solved) {
      final m = controller.moves;
      final o = state.optimalMoves;
      controller.complete(GameOutcome(stars: m <= o ? 3 : m <= (o * 1.5).ceil() ? 2 : 1));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final palette = KpPalette.of(context);
    final discColors = [palette.accent, palette.highlight, palette.success, palette.blobs[3], palette.blobs[0]];
    return Column(
      children: [
        GameBoard(
          padding: const EdgeInsets.fromLTRB(8, 20, 8, 12),
          child: SizedBox(
            height: 260,
            child: Row(
              children: [
                for (var p = 0; p < 3; p++)
                  Expanded(
                    child: Semantics(
                      button: true,
                      selected: selected == p,
                      label: l.hanoiPeg(p + 1, state.pegs[p].length),
                      excludeSemantics: true,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => _tapPeg(p),
                        child: LayoutBuilder(builder: (context, c) {
                          final maxW = c.maxWidth - 8;
                          return Stack(
                            alignment: Alignment.bottomCenter,
                            children: [
                              Positioned(
                                bottom: 0,
                                top: 10,
                                child: Container(
                                  width: 8,
                                  decoration: BoxDecoration(
                                    color: selected == p ? palette.accent : palette.boardLine,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                left: 4,
                                right: 4,
                                child: Container(height: 8, decoration: BoxDecoration(color: palette.inkSoft, borderRadius: BorderRadius.circular(4))),
                              ),
                              Positioned(
                                bottom: 8,
                                left: 0,
                                right: 0,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    for (final disc in state.pegs[p].reversed)
                                      AnimatedContainer(
                                        duration: const Duration(milliseconds: 160),
                                        margin: const EdgeInsets.only(bottom: 3),
                                        transform: Matrix4.translationValues(
                                          0,
                                          selected == p && disc == state.pegs[p].last ? -18 : 0,
                                          0,
                                        ),
                                        width: maxW * (0.3 + 0.7 * disc / state.discs),
                                        height: 26,
                                        decoration: BoxDecoration(
                                          color: discColors[(disc - 1) % discColors.length],
                                          borderRadius: BorderRadius.circular(13),
                                          border: Border.all(color: Colors.white, width: 2),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        }),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 18),
        ListenableBuilder(
          listenable: controller,
          builder: (context, _) => GameStatusLine(parts: [
            l.movesCount(controller.moves),
            l.hanoiOptimal(state.optimalMoves),
          ]),
        ),
        const SizedBox(height: 10),
        Text(l.hanoiGoal, textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w700, color: palette.inkSoft)),
      ],
    );
  }
}
