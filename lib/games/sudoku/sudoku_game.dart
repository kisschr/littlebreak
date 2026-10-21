import 'package:flutter/material.dart';

import '../../design/icons.dart';
import '../../design/palette.dart';
import '../../domain/models.dart';
import '../../l10n/generated/app_localizations.dart';
import '../game_framework.dart';
import '../game_widgets.dart';
import 'sudoku_generator.dart';

class SudokuDefinition extends GameDefinition {
  const SudokuDefinition();

  @override
  GameType get type => GameType.sudoku;

  static int sizeFor(Difficulty d) => switch (d) {
        Difficulty.easy => 4,
        Difficulty.standard => 6,
        Difficulty.advanced => 9,
      };

  static int cluesFor(Difficulty d) => switch (d) {
        Difficulty.easy => 6,
        Difficulty.standard => 16,
        Difficulty.advanced => 30,
      };

  @override
  int minutes(Difficulty d) => switch (d) {
        Difficulty.easy => 2,
        Difficulty.standard => 6,
        Difficulty.advanced => 15,
      };

  @override
  String levelDetail(AppLocalizations l, Difficulty d) =>
      l.detailGrid('${sizeFor(d)}×${sizeFor(d)}', minutes(d));

  @override
  bool get usesHints => true;

  @override
  Widget build(BuildContext context, GameSession session) => SudokuGame(session: session);
}

class SudokuGame extends StatefulWidget {
  const SudokuGame({super.key, required this.session});

  final GameSession session;

  @override
  State<SudokuGame> createState() => _SudokuGameState();
}

class _SudokuGameState extends State<SudokuGame> {
  late final SudokuPuzzle puzzle;
  late final List<int> entries;
  late final List<Set<int>> notes;
  final List<(int, int, Set<int>)> _history = [];
  int selected = 0;
  bool notesMode = false;

  GameController get controller => widget.session.controller;
  int get size => puzzle.size;

  @override
  void initState() {
    super.initState();
    final d = widget.session.difficulty;
    puzzle = const SudokuGenerator().generate(
      size: SudokuDefinition.sizeFor(d),
      targetClues: SudokuDefinition.cluesFor(d),
      random: widget.session.random(),
    );
    entries = List<int>.of(puzzle.givens);
    notes = List.generate(size * size, (_) => <int>{});
    selected = entries.indexWhere((v) => v == 0);
    controller.setHintHandler(_hint);
  }

  bool _isGiven(int i) => puzzle.givens[i] != 0;

  void _select(int i) => setState(() => selected = i);

  void _enter(int value) {
    if (selected < 0 || _isGiven(selected)) return;
    setState(() {
      _history.add((selected, entries[selected], Set.of(notes[selected])));
      if (notesMode && value != 0) {
        if (!notes[selected].remove(value)) notes[selected].add(value);
        return;
      }
      entries[selected] = value;
      notes[selected].clear();
      if (value != 0) {
        if (value != puzzle.solution[selected]) {
          controller.reportMistake();
        } else {
          _clearNotesFor(selected, value);
        }
      }
    });
    _checkSolved();
  }

  void _clearNotesFor(int index, int value) {
    final r = index ~/ size;
    final c = index % size;
    for (var i = 0; i < size * size; i++) {
      final rr = i ~/ size;
      final cc = i % size;
      final sameBox = rr ~/ puzzle.boxRows == r ~/ puzzle.boxRows && cc ~/ puzzle.boxCols == c ~/ puzzle.boxCols;
      if (rr == r || cc == c || sameBox) notes[i].remove(value);
    }
  }

  void _undo() {
    if (_history.isEmpty) return;
    setState(() {
      final (index, value, oldNotes) = _history.removeLast();
      entries[index] = value;
      notes[index]
        ..clear()
        ..addAll(oldNotes);
      selected = index;
    });
  }

  bool _hint() {
    var target = selected;
    if (target < 0 || _isGiven(target) || entries[target] == puzzle.solution[target]) {
      target = -1;
      for (var i = 0; i < entries.length; i++) {
        if (entries[i] != puzzle.solution[i]) {
          target = i;
          break;
        }
      }
    }
    if (target < 0) return false;
    setState(() {
      entries[target] = puzzle.solution[target];
      notes[target].clear();
      selected = target;
      _clearNotesFor(target, entries[target]);
    });
    _checkSolved();
    return true;
  }

  void _checkSolved() {
    for (var i = 0; i < entries.length; i++) {
      if (entries[i] != puzzle.solution[i]) return;
    }
    controller.complete();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final palette = KpPalette.of(context);
    final selRow = selected < 0 ? -1 : selected ~/ size;
    final selCol = selected < 0 ? -1 : selected % size;
    final selValue = selected < 0 ? 0 : entries[selected];
    final digitSize = size == 9 ? 22.0 : size == 6 ? 26.0 : 34.0;

    return Column(
      children: [
        GameBoard(
          child: AspectRatio(
            aspectRatio: 1,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: palette.ink, width: 2.5),
                borderRadius: BorderRadius.circular(12),
              ),
              clipBehavior: Clip.antiAlias,
              child: Semantics(
                label: l.sudokuGridLabel(size),
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: size),
                  itemCount: size * size,
                  itemBuilder: (context, i) {
                    final r = i ~/ size;
                    final c = i % size;
                    final value = entries[i];
                    final isSel = i == selected;
                    final related = r == selRow || c == selCol;
                    final sameValue = value != 0 && value == selValue;
                    final wrong = value != 0 && !_isGiven(i) && value != puzzle.solution[i];
                    var bg = palette.board;
                    if (related || sameValue) bg = palette.boardRelated;
                    if (isSel) bg = palette.highlight;
                    final thickRight = (c + 1) % puzzle.boxCols == 0 && c != size - 1;
                    final thickBottom = (r + 1) % puzzle.boxRows == 0 && r != size - 1;
                    return Semantics(
                      button: true,
                      selected: isSel,
                      label: l.cellLabel(r + 1, c + 1, value == 0 ? l.cellEmpty : '$value'),
                      excludeSemantics: true,
                      child: GestureDetector(
                        onTap: () => _select(i),
                        child: Container(
                          decoration: BoxDecoration(
                            color: bg,
                            border: Border(
                              right: c == size - 1
                                  ? BorderSide.none
                                  : BorderSide(color: thickRight ? palette.ink : palette.boardLine, width: thickRight ? 2.5 : 1),
                              bottom: r == size - 1
                                  ? BorderSide.none
                                  : BorderSide(color: thickBottom ? palette.ink : palette.boardLine, width: thickBottom ? 2.5 : 1),
                            ),
                          ),
                          alignment: Alignment.center,
                          child: value != 0
                              ? Text(
                                  '$value',
                                  style: boardDigitStyle(palette, given: _isGiven(i), size: digitSize)
                                      .copyWith(color: wrong ? kpErrorColor : null),
                                )
                              : notes[i].isEmpty
                                  ? null
                                  : _NotesView(notes: notes[i], size: size, color: palette.inkSoft),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 18),
        ListenableBuilder(
          listenable: controller,
          builder: (context, _) => GameStatusLine(parts: [
            l.mistakesCount(controller.mistakes),
            l.hintsCount(controller.hintsUsed, controller.maxHints),
          ]),
        ),
        const SizedBox(height: 18),
        _DigitPad(size: size, onDigit: _enter),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: GlassActionPill(icon: KpIcons.erase, label: l.erase, onTap: () => _enter(0))),
            const SizedBox(width: 8),
            Expanded(
              child: GlassActionPill(
                icon: KpIcons.pencil,
                label: l.notes,
                active: notesMode,
                onTap: () => setState(() => notesMode = !notesMode),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(child: GlassActionPill(icon: KpIcons.refresh, label: l.undo, onTap: _history.isEmpty ? null : _undo)),
          ],
        ),
      ],
    );
  }
}

class _DigitPad extends StatelessWidget {
  const _DigitPad({required this.size, required this.onDigit});

  final int size;
  final ValueChanged<int> onDigit;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    Widget key(int n) => Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: GlassKey(
              height: size == 9 ? 54 : 64,
              semanticLabel: l.numberLabel(n),
              onTap: () => onDigit(n),
              child: Text('$n'),
            ),
          ),
        );
    if (size <= 6) {
      return Row(children: [for (var n = 1; n <= size; n++) key(n)]);
    }
    return Column(
      children: [
        Row(children: [for (var n = 1; n <= 5; n++) key(n)]),
        const SizedBox(height: 8),
        Row(children: [for (var n = 6; n <= 9; n++) key(n), const Expanded(child: SizedBox())]),
      ],
    );
  }
}

class _NotesView extends StatelessWidget {
  const _NotesView({required this.notes, required this.size, required this.color});

  final Set<int> notes;
  final int size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final cols = size == 4 ? 2 : 3;
    final rows = (size / cols).ceil();
    return Padding(
      padding: const EdgeInsets.all(2),
      child: Column(
        children: [
          for (var r = 0; r < rows; r++)
            Expanded(
              child: Row(
                children: [
                  for (var c = 0; c < cols; c++)
                    Expanded(
                      child: Center(
                        child: FittedBox(
                          child: Text(
                            notes.contains(r * cols + c + 1) ? '${r * cols + c + 1}' : '',
                            style: TextStyle(fontFamily: 'Nunito', fontSize: 10, fontWeight: FontWeight.w700, color: color),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
