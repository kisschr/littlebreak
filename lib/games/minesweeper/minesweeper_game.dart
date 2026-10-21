import 'package:flutter/material.dart';

import '../../core/seeded_random.dart';
import '../../design/icons.dart';
import '../../design/palette.dart';
import '../../domain/models.dart';
import '../../l10n/generated/app_localizations.dart';
import '../game_framework.dart';
import '../game_widgets.dart';

class MinesweeperDefinition extends GameDefinition {
  const MinesweeperDefinition();

  @override
  GameType get type => GameType.minesweeper;

  static (int size, int mines) layout(Difficulty d) => switch (d) {
        Difficulty.easy => (6, 5),
        Difficulty.standard => (8, 10),
        Difficulty.advanced => (9, 15),
      };

  @override
  int minutes(Difficulty d) => switch (d) {
        Difficulty.easy => 2,
        Difficulty.standard => 4,
        Difficulty.advanced => 7,
      };

  @override
  String levelDetail(AppLocalizations l, Difficulty d) {
    final (s, m) = layout(d);
    return l.detailMines('$s×$s', m, minutes(d));
  }

  @override
  Widget build(BuildContext context, GameSession session) => MinesweeperGame(session: session);
}

class MineField {
  MineField(this.size, this.mineCount);

  final int size;
  final int mineCount;
  late List<bool> mines = List.filled(size * size, false);
  late final List<bool> revealed = List.filled(size * size, false);
  late final List<bool> flagged = List.filled(size * size, false);
  bool placed = false;

  Iterable<int> neighbours(int i) sync* {
    final r = i ~/ size, c = i % size;
    for (var dr = -1; dr <= 1; dr++) {
      for (var dc = -1; dc <= 1; dc++) {
        if (dr == 0 && dc == 0) continue;
        final rr = r + dr, cc = c + dc;
        if (rr >= 0 && cc >= 0 && rr < size && cc < size) yield rr * size + cc;
      }
    }
  }

  /// Places mines so the first tapped cell and its neighbours are safe.
  void place(int firstTap, SeededRandom random) {
    final safe = {firstTap, ...neighbours(firstTap)};
    final candidates = [for (var i = 0; i < size * size; i++) if (!safe.contains(i)) i];
    for (final i in random.sample(candidates, mineCount)) {
      mines[i] = true;
    }
    placed = true;
  }

  int adjacent(int i) => neighbours(i).where((n) => mines[n]).length;

  /// Reveals a cell (flood-filling empty areas). Returns false on a mine.
  bool reveal(int i) {
    if (revealed[i] || flagged[i]) return true;
    if (mines[i]) return false;
    final stack = [i];
    while (stack.isNotEmpty) {
      final cell = stack.removeLast();
      if (revealed[cell]) continue;
      revealed[cell] = true;
      flagged[cell] = false;
      if (adjacent(cell) == 0) {
        stack.addAll(neighbours(cell).where((n) => !revealed[n] && !mines[n]));
      }
    }
    return true;
  }

  bool get cleared {
    for (var i = 0; i < size * size; i++) {
      if (!mines[i] && !revealed[i]) return false;
    }
    return true;
  }
}

class MinesweeperGame extends StatefulWidget {
  const MinesweeperGame({super.key, required this.session});

  final GameSession session;

  @override
  State<MinesweeperGame> createState() => _MinesweeperGameState();
}

class _MinesweeperGameState extends State<MinesweeperGame> {
  late MineField field;
  int attempt = 1;
  bool flagMode = false;
  bool exploded = false;

  GameController get controller => widget.session.controller;

  @override
  void initState() {
    super.initState();
    _newField();
  }

  void _newField() {
    final (s, m) = MinesweeperDefinition.layout(widget.session.difficulty);
    field = MineField(s, m);
  }

  void _tap(int i) {
    if (controller.paused || controller.finished || exploded) return;
    setState(() {
      if (flagMode) {
        if (!field.revealed[i]) field.flagged[i] = !field.flagged[i];
        return;
      }
      if (!field.placed) field.place(i, widget.session.random('try$attempt'));
      if (!field.reveal(i)) {
        exploded = true;
        controller.reportMistake();
      }
    });
    if (field.cleared) {
      controller.complete(GameOutcome(stars: attempt == 1 ? 3 : attempt == 2 ? 2 : 1));
    }
  }

  void _retry() => setState(() {
        attempt++;
        exploded = false;
        _newField();
      });

  static const _numberColors = [
    Color(0xFF2F5D8A),
    Color(0xFF1F7A6A),
    Color(0xFFB3261E),
    Color(0xFF5B2A86),
    Color(0xFF7A3216),
    Color(0xFF14574B),
    Color(0xFF2B1A10),
    Color(0xFF6B4A35),
  ];

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final palette = KpPalette.of(context);
    final n = field.size;
    final flags = field.flagged.where((f) => f).length;
    return Column(
      children: [
        GameBoard(
          padding: const EdgeInsets.all(10),
          child: AspectRatio(
            aspectRatio: 1,
            child: Stack(
              children: [
                GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: n, mainAxisSpacing: 4, crossAxisSpacing: 4),
                  itemCount: n * n,
                  itemBuilder: (context, i) {
                    final open = field.revealed[i] || (exploded && field.mines[i]);
                    final count = field.placed ? field.adjacent(i) : 0;
                    Widget? child;
                    if (open && field.mines[i]) {
                      child = Icon(Icons.brightness_7, color: kpErrorColor, size: n > 8 ? 18 : 22);
                    } else if (open && count > 0) {
                      child = Text('$count', style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w900, fontSize: n > 8 ? 17 : 20, color: _numberColors[count - 1]));
                    } else if (!open && field.flagged[i]) {
                      child = KpIcon(KpIcons.flag, size: n > 8 ? 16 : 20, color: palette.accent);
                    }
                    return Semantics(
                      button: true,
                      label: l.cellLabel(i ~/ n + 1, i % n + 1, open ? (field.mines[i] ? l.mine : '$count') : (field.flagged[i] ? l.flag : l.cellHidden)),
                      excludeSemantics: true,
                      child: GestureDetector(
                        onTap: () => _tap(i),
                        onLongPress: () {
                          if (field.revealed[i] || exploded) return;
                          setState(() => field.flagged[i] = !field.flagged[i]);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: open ? palette.board : palette.boardRelated,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: open ? palette.boardLine : palette.blobs[0].withValues(alpha: 0.4), width: open ? 1 : 1.5),
                          ),
                          alignment: Alignment.center,
                          child: child,
                        ),
                      ),
                    );
                  },
                ),
                if (exploded)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 8,
                    child: Center(
                      child: FilledButton(
                        style: FilledButton.styleFrom(backgroundColor: palette.accent, padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14)),
                        onPressed: _retry,
                        child: Text(l.mineBoom, style: const TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w900, fontSize: 16)),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        GameStatusLine(parts: [l.minesLeft(field.mineCount - flags), l.attemptCount(attempt)]),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: GlassActionPill(icon: KpIcons.sparkle, label: l.reveal, active: !flagMode, onTap: () => setState(() => flagMode = false)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: GlassActionPill(icon: KpIcons.flag, label: l.flag, active: flagMode, onTap: () => setState(() => flagMode = true)),
            ),
          ],
        ),
      ],
    );
  }
}
