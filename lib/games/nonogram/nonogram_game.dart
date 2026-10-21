import 'package:flutter/material.dart';

import '../../core/seeded_random.dart';
import '../../design/icons.dart';
import '../../design/palette.dart';
import '../../domain/models.dart';
import '../../l10n/generated/app_localizations.dart';
import '../game_framework.dart';
import '../game_widgets.dart';

class NonogramDefinition extends GameDefinition {
  const NonogramDefinition();

  @override
  GameType get type => GameType.nonogram;

  static int sizeFor(Difficulty d) => switch (d) {
        Difficulty.easy => 5,
        Difficulty.standard => 8,
        Difficulty.advanced => 10,
      };

  @override
  int minutes(Difficulty d) => switch (d) {
        Difficulty.easy => 2,
        Difficulty.standard => 6,
        Difficulty.advanced => 12,
      };

  @override
  String levelDetail(AppLocalizations l, Difficulty d) {
    final s = sizeFor(d);
    return l.detailGrid('$s×$s', minutes(d));
  }

  @override
  bool get usesHints => true;

  @override
  Widget build(BuildContext context, GameSession session) => NonogramGame(session: session);
}

/// A mirror-symmetric pixel picture and its row/column clues.
class NonogramPuzzle {
  NonogramPuzzle(this.size, this.cells)
      : rowClues = [for (var r = 0; r < size; r++) clueFor([for (var c = 0; c < size; c++) cells[r * size + c]])],
        colClues = [for (var c = 0; c < size; c++) clueFor([for (var r = 0; r < size; r++) cells[r * size + c]])];

  factory NonogramPuzzle.generate(int size, SeededRandom random) {
    final cells = List.filled(size * size, false);
    final half = (size + 1) ~/ 2;
    for (var r = 0; r < size; r++) {
      for (var c = 0; c < half; c++) {
        final on = random.nextBool(0.58);
        cells[r * size + c] = on;
        cells[r * size + size - 1 - c] = on;
      }
    }
    // Every row and column gets at least one filled cell so no clue is empty.
    for (var r = 0; r < size; r++) {
      if (!List.generate(size, (c) => cells[r * size + c]).contains(true)) {
        final c = random.nextInt(half);
        cells[r * size + c] = true;
        cells[r * size + size - 1 - c] = true;
      }
    }
    for (var c = 0; c < size; c++) {
      if (!List.generate(size, (r) => cells[r * size + c]).contains(true)) {
        final r = random.nextInt(size);
        cells[r * size + c] = true;
        cells[r * size + size - 1 - c] = true;
      }
    }
    return NonogramPuzzle(size, cells);
  }

  final int size;
  final List<bool> cells;
  final List<List<int>> rowClues;
  final List<List<int>> colClues;

  static List<int> clueFor(List<bool> line) {
    final clue = <int>[];
    var run = 0;
    for (final on in line) {
      if (on) {
        run++;
      } else if (run > 0) {
        clue.add(run);
        run = 0;
      }
    }
    if (run > 0) clue.add(run);
    return clue.isEmpty ? [0] : clue;
  }
}

enum _Mark { empty, filled, crossed }

class NonogramGame extends StatefulWidget {
  const NonogramGame({super.key, required this.session});

  final GameSession session;

  @override
  State<NonogramGame> createState() => _NonogramGameState();
}

class _NonogramGameState extends State<NonogramGame> {
  late final NonogramPuzzle puzzle =
      NonogramPuzzle.generate(NonogramDefinition.sizeFor(widget.session.difficulty), widget.session.random());
  late final List<_Mark> marks = List.filled(puzzle.size * puzzle.size, _Mark.empty);
  bool crossMode = false;

  GameController get controller => widget.session.controller;

  @override
  void initState() {
    super.initState();
    controller.setHintHandler(_hint);
  }

  void _apply(int i) {
    if (controller.paused || controller.finished) return;
    if (marks[i] == _Mark.filled && puzzle.cells[i]) return;
    setState(() {
      if (crossMode) {
        marks[i] = marks[i] == _Mark.crossed ? _Mark.empty : _Mark.crossed;
        return;
      }
      if (puzzle.cells[i]) {
        marks[i] = _Mark.filled;
      } else {
        marks[i] = _Mark.crossed;
        controller.reportMistake();
      }
    });
    _check();
  }

  bool _hint() {
    for (var i = 0; i < marks.length; i++) {
      if (puzzle.cells[i] && marks[i] != _Mark.filled) {
        setState(() => marks[i] = _Mark.filled);
        _check();
        return true;
      }
    }
    return false;
  }

  void _check() {
    for (var i = 0; i < marks.length; i++) {
      if (puzzle.cells[i] && marks[i] != _Mark.filled) return;
    }
    controller.complete();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final palette = KpPalette.of(context);
    final n = puzzle.size;
    final maxRowClue = puzzle.rowClues.map((c) => c.length).reduce((a, b) => a > b ? a : b);
    final maxColClue = puzzle.colClues.map((c) => c.length).reduce((a, b) => a > b ? a : b);
    final clueStyle = TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: n >= 10 ? 11 : 13, height: 1.15, color: palette.ink);

    return Column(
      children: [
        GameBoard(
          padding: const EdgeInsets.all(10),
          child: LayoutBuilder(builder: (context, constraints) {
            final clueW = (maxRowClue * (n >= 10 ? 11.0 : 14.0) + 8).clamp(24.0, 80.0);
            final clueH = (maxColClue * (n >= 10 ? 13.0 : 16.0) + 6).clamp(22.0, 90.0);
            final cell = (constraints.maxWidth - clueW) / n;
            return Column(
              children: [
                Row(
                  children: [
                    SizedBox(width: clueW, height: clueH),
                    for (var c = 0; c < n; c++)
                      SizedBox(
                        width: cell,
                        height: clueH,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [for (final v in puzzle.colClues[c]) Text('$v', style: clueStyle)],
                        ),
                      ),
                  ],
                ),
                for (var r = 0; r < n; r++)
                  Row(
                    children: [
                      SizedBox(
                        width: clueW,
                        height: cell,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: Text(puzzle.rowClues[r].join(' '), textAlign: TextAlign.right, style: clueStyle),
                        ),
                      ),
                      for (var c = 0; c < n; c++) _cell(r * n + c, cell, palette, l),
                    ],
                  ),
              ],
            );
          }),
        ),
        const SizedBox(height: 16),
        ListenableBuilder(
          listenable: controller,
          builder: (context, _) => GameStatusLine(parts: [
            l.mistakesCount(controller.mistakes),
            l.hintsCount(controller.hintsUsed, controller.maxHints),
          ]),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: GlassActionPill(
                icon: KpIcons.pencil,
                label: l.nonogramFill,
                active: !crossMode,
                onTap: () => setState(() => crossMode = false),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: GlassActionPill(
                icon: KpIcons.close,
                label: l.nonogramCross,
                active: crossMode,
                onTap: () => setState(() => crossMode = true),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _cell(int i, double size, KpPalette palette, AppLocalizations l) {
    final n = puzzle.size;
    final r = i ~/ n, c = i % n;
    final mark = marks[i];
    final thickRight = (c + 1) % 5 == 0 && c != n - 1;
    final thickBottom = (r + 1) % 5 == 0 && r != n - 1;
    return Semantics(
      button: true,
      label: l.cellLabel(r + 1, c + 1, switch (mark) {
        _Mark.filled => l.cellFilled,
        _Mark.crossed => l.cellCrossed,
        _Mark.empty => l.cellEmpty,
      }),
      excludeSemantics: true,
      child: GestureDetector(
        onTap: () => _apply(i),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: mark == _Mark.filled ? palette.accent : palette.board,
            border: Border(
              left: c == 0 ? BorderSide(color: palette.ink, width: 2) : BorderSide.none,
              top: r == 0 ? BorderSide(color: palette.ink, width: 2) : BorderSide.none,
              right: BorderSide(color: thickRight || c == n - 1 ? palette.ink : palette.boardLine, width: thickRight || c == n - 1 ? 2 : 1),
              bottom: BorderSide(color: thickBottom || r == n - 1 ? palette.ink : palette.boardLine, width: thickBottom || r == n - 1 ? 2 : 1),
            ),
          ),
          alignment: Alignment.center,
          child: mark == _Mark.crossed ? KpIcon(KpIcons.close, size: size * 0.5, color: palette.inkSoft) : null,
        ),
      ),
    );
  }
}
