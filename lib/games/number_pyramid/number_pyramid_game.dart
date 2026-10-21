import 'package:flutter/material.dart';

import '../../core/seeded_random.dart';
import '../../design/icons.dart';
import '../../design/palette.dart';
import '../../domain/models.dart';
import '../../l10n/generated/app_localizations.dart';
import '../game_framework.dart';
import '../game_widgets.dart';

class NumberPyramidDefinition extends GameDefinition {
  const NumberPyramidDefinition();

  @override
  GameType get type => GameType.numberPyramid;

  static int rowsFor(Difficulty d) => switch (d) {
        Difficulty.easy => 3,
        Difficulty.standard => 4,
        Difficulty.advanced => 5,
      };

  @override
  int minutes(Difficulty d) => switch (d) {
        Difficulty.easy => 2,
        Difficulty.standard => 4,
        Difficulty.advanced => 7,
      };

  @override
  String levelDetail(AppLocalizations l, Difficulty d) => l.detailRows(rowsFor(d), minutes(d));

  @override
  bool get usesHints => true;

  @override
  Widget build(BuildContext context, GameSession session) => NumberPyramidGame(session: session);
}

/// Rows from top (1 brick) to bottom; every brick is the sum of the two
/// bricks below it.
class Pyramid {
  Pyramid(this.values, this.known);

  /// values[row][i], row 0 = top.
  final List<List<int>> values;
  final List<List<bool>> known;

  int get rows => values.length;

  factory Pyramid.generate({required int rows, required int maxBase, required int hidden, required SeededRandom random}) {
    final base = List.generate(rows, (_) => random.nextIntInRange(1, maxBase));
    final values = List<List<int>>.filled(rows, const []);
    values[rows - 1] = base;
    for (var r = rows - 2; r >= 0; r--) {
      values[r] = [for (var i = 0; i <= r; i++) values[r + 1][i] + values[r + 1][i + 1]];
    }
    final known = [for (var r = 0; r < rows; r++) List.filled(r + 1, true)];
    final cells = random.shuffle([for (var r = 0; r < rows; r++) for (var i = 0; i <= r; i++) (r, i)]);
    var removed = 0;
    for (final (r, i) in cells) {
      if (removed >= hidden) break;
      known[r][i] = false;
      if (solvable(known)) {
        removed++;
      } else {
        known[r][i] = true;
      }
    }
    return Pyramid(values, known);
  }

  /// Whether constraint propagation alone reveals every brick.
  static bool solvable(List<List<bool>> known) {
    final k = [for (final row in known) List.of(row)];
    var changed = true;
    while (changed) {
      changed = false;
      for (var r = 0; r < k.length - 1; r++) {
        for (var i = 0; i <= r; i++) {
          final top = k[r][i], left = k[r + 1][i], right = k[r + 1][i + 1];
          final count = (top ? 1 : 0) + (left ? 1 : 0) + (right ? 1 : 0);
          if (count == 2) {
            k[r][i] = k[r + 1][i] = k[r + 1][i + 1] = true;
            changed = true;
          }
        }
      }
    }
    return k.every((row) => row.every((v) => v));
  }
}

class NumberPyramidGame extends StatefulWidget {
  const NumberPyramidGame({super.key, required this.session});

  final GameSession session;

  @override
  State<NumberPyramidGame> createState() => _NumberPyramidGameState();
}

class _NumberPyramidGameState extends State<NumberPyramidGame> {
  late final Pyramid pyramid;
  late final List<List<bool>> solved;
  (int, int)? selected;
  String input = '';

  GameController get controller => widget.session.controller;

  @override
  void initState() {
    super.initState();
    final s = widget.session;
    pyramid = Pyramid.generate(
      rows: NumberPyramidDefinition.rowsFor(s.difficulty),
      maxBase: s.byLevel(5, 9, 15),
      hidden: s.byLevel(3, 6, 10),
      random: s.random(),
    );
    solved = [for (final row in pyramid.known) List.of(row)];
    selected = _firstOpen();
    controller.setHintHandler(_hint);
  }

  (int, int)? _firstOpen() {
    for (var r = pyramid.rows - 1; r >= 0; r--) {
      for (var i = 0; i <= r; i++) {
        if (!solved[r][i]) return (r, i);
      }
    }
    return null;
  }

  void _digit(int d) {
    if (selected == null || input.length >= 3) return;
    setState(() => input += '$d');
  }

  void _check() {
    final sel = selected;
    if (sel == null || input.isEmpty) return;
    final (r, i) = sel;
    if (int.parse(input) == pyramid.values[r][i]) {
      setState(() {
        solved[r][i] = true;
        input = '';
        selected = _firstOpen();
      });
      if (selected == null) controller.complete();
    } else {
      controller.reportMistake();
      setState(() => input = '');
    }
  }

  bool _hint() {
    final sel = selected ?? _firstOpen();
    if (sel == null) return false;
    final (r, i) = sel;
    setState(() {
      solved[r][i] = true;
      input = '';
      selected = _firstOpen();
    });
    if (selected == null) controller.complete();
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final palette = KpPalette.of(context);
    return Column(
      children: [
        GameBoard(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 18),
          child: LayoutBuilder(builder: (context, c) {
            final brick = (c.maxWidth / pyramid.rows).clamp(0.0, 76.0);
            return Column(
              children: [
                for (var r = 0; r < pyramid.rows; r++)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (var i = 0; i <= r; i++) _brick(r, i, brick, palette, l),
                    ],
                  ),
              ],
            );
          }),
        ),
        const SizedBox(height: 12),
        Text(l.pyramidGoal, textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w700, color: palette.inkSoft)),
        const SizedBox(height: 8),
        ListenableBuilder(
          listenable: controller,
          builder: (context, _) => GameStatusLine(parts: [l.mistakesCount(controller.mistakes)]),
        ),
        const SizedBox(height: 14),
        for (final row in const [[1, 2, 3, 4, 5], [6, 7, 8, 9, 0]]) ...[
          Row(
            children: [
              for (final d in row)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: GlassKey(height: 54, semanticLabel: l.numberLabel(d), onTap: () => _digit(d), child: Text('$d')),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
        ],
        Row(
          children: [
            Expanded(child: GlassActionPill(icon: KpIcons.erase, label: l.erase, onTap: () => setState(() => input = ''))),
            const SizedBox(width: 10),
            Expanded(child: GlassActionPill(icon: KpIcons.check, label: l.check, onTap: _check)),
          ],
        ),
      ],
    );
  }

  Widget _brick(int r, int i, double size, KpPalette palette, AppLocalizations l) {
    final isSolved = solved[r][i];
    final given = pyramid.known[r][i];
    final isSel = selected == (r, i);
    final text = isSolved ? '${pyramid.values[r][i]}' : (isSel ? input : '');
    return Semantics(
      button: !isSolved,
      selected: isSel,
      label: l.brickLabel(r + 1, i + 1, text.isEmpty ? l.cellEmpty : text),
      excludeSemantics: true,
      child: GestureDetector(
        onTap: isSolved ? null : () => setState(() {
          selected = (r, i);
          input = '';
        }),
        child: Container(
          width: size - 4,
          height: 46,
          margin: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: isSel ? palette.highlight : (given ? palette.boardRelated : Colors.white),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: isSel ? palette.accent : palette.boardLine, width: isSel ? 2.5 : 1.5),
          ),
          alignment: Alignment.center,
          child: FittedBox(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(text, style: boardDigitStyle(palette, given: given, size: 20)),
            ),
          ),
        ),
      ),
    );
  }
}
