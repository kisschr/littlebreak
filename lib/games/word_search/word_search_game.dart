import 'package:flutter/material.dart';

import '../../core/seeded_random.dart';
import '../../design/palette.dart';
import '../../domain/models.dart';
import '../../l10n/generated/app_localizations.dart';
import '../game_framework.dart';

class WordSearchDefinition extends GameDefinition {
  const WordSearchDefinition();

  @override
  GameType get type => GameType.wordSearch;

  static (int size, int words) layout(Difficulty d) => switch (d) {
        Difficulty.easy => (7, 4),
        Difficulty.standard => (9, 6),
        Difficulty.advanced => (11, 8),
      };

  @override
  int minutes(Difficulty d) => switch (d) {
        Difficulty.easy => 2,
        Difficulty.standard => 4,
        Difficulty.advanced => 7,
      };

  @override
  String levelDetail(AppLocalizations l, Difficulty d) => l.detailWords(layout(d).$2, minutes(d));

  @override
  bool get usesHints => true;

  @override
  Widget build(BuildContext context, GameSession session) => WordSearchGame(session: session);
}

class PlacedWord {
  const PlacedWord(this.word, this.cells);

  final String word;
  final List<int> cells;
}

class WordSearchPuzzle {
  WordSearchPuzzle(this.size, this.letters, this.words);

  final int size;
  final List<String> letters;
  final List<PlacedWord> words;

  static WordSearchPuzzle generate({
    required int size,
    required List<String> candidates,
    required int count,
    required List<(int, int)> directions,
    required List<String> alphabet,
    required SeededRandom random,
  }) {
    final grid = List<String>.filled(size * size, '');
    final placed = <PlacedWord>[];
    final pool = random.shuffle(
      candidates.map((w) => w.toUpperCase().replaceAll(RegExp(r'[^A-ZÄÖÜ]'), '')).where((w) => w.length >= 3 && w.length <= size).toSet().toList(),
    );
    for (final word in pool) {
      if (placed.length >= count) break;
      for (var attempt = 0; attempt < 120; attempt++) {
        final (dr, dc) = random.pick(directions);
        final r0 = random.nextInt(size), c0 = random.nextInt(size);
        final rEnd = r0 + dr * (word.length - 1), cEnd = c0 + dc * (word.length - 1);
        if (rEnd < 0 || rEnd >= size || cEnd < 0 || cEnd >= size) continue;
        final cells = [for (var k = 0; k < word.length; k++) (r0 + dr * k) * size + c0 + dc * k];
        var fits = true;
        for (var k = 0; k < word.length; k++) {
          final existing = grid[cells[k]];
          if (existing.isNotEmpty && existing != word[k]) {
            fits = false;
            break;
          }
        }
        if (!fits) continue;
        for (var k = 0; k < word.length; k++) {
          grid[cells[k]] = word[k];
        }
        placed.add(PlacedWord(word, cells));
        break;
      }
    }
    for (var i = 0; i < grid.length; i++) {
      if (grid[i].isEmpty) grid[i] = random.pick(alphabet);
    }
    return WordSearchPuzzle(size, grid, placed);
  }
}

class WordSearchGame extends StatefulWidget {
  const WordSearchGame({super.key, required this.session});

  final GameSession session;

  @override
  State<WordSearchGame> createState() => _WordSearchGameState();
}

class _WordSearchGameState extends State<WordSearchGame> {
  late final WordSearchPuzzle puzzle;
  final Set<String> found = {};
  int? start;
  int? end;
  String? hintWord;

  GameController get controller => widget.session.controller;

  @override
  void initState() {
    super.initState();
    final s = widget.session;
    final (size, count) = WordSearchDefinition.layout(s.difficulty);
    final theme = s.content.themes[s.plan.date.month];
    final dirs = <(int, int)>[
      (0, 1),
      (1, 0),
      if (s.difficulty != Difficulty.easy) ...[(1, 1), (-1, 1)],
      if (s.difficulty == Difficulty.advanced) ...[(0, -1), (-1, 0), (-1, -1), (1, -1)],
    ];
    puzzle = WordSearchPuzzle.generate(
      size: size,
      candidates: [...?theme?.words, ...s.content.words(5), ...s.content.words(4)],
      count: count,
      directions: dirs,
      alphabet: s.content.alphabet.where((c) => !'ÄÖÜ'.contains(c)).toList(),
      random: s.random(),
    );
    controller.setHintHandler(_hint);
  }

  List<int> _line(int a, int b) {
    final n = puzzle.size;
    final ar = a ~/ n, ac = a % n, br = b ~/ n, bc = b % n;
    final dr = (br - ar).sign, dc = (bc - ac).sign;
    final len = (br - ar).abs() > (bc - ac).abs() ? (br - ar).abs() : (bc - ac).abs();
    if (!(ar == br || ac == bc || (br - ar).abs() == (bc - ac).abs())) return [a];
    return [for (var k = 0; k <= len; k++) (ar + dr * k) * n + ac + dc * k];
  }

  int _cellAt(Offset local, double cell) {
    final n = puzzle.size;
    final c = (local.dx / cell).floor().clamp(0, n - 1);
    final r = (local.dy / cell).floor().clamp(0, n - 1);
    return r * n + c;
  }

  void _finishSelection() {
    if (start == null || end == null) return;
    final cells = _line(start!, end!);
    final text = cells.map((i) => puzzle.letters[i]).join();
    final reversed = text.split('').reversed.join();
    PlacedWord? match;
    for (final w in puzzle.words) {
      if (found.contains(w.word)) continue;
      if ((w.word == text || w.word == reversed) && _sameCells(w.cells, cells)) match = w;
    }
    setState(() {
      if (match != null) {
        found.add(match.word);
        if (hintWord == match.word) hintWord = null;
      } else if (cells.length > 2) {
        controller.reportMistake();
      }
      start = null;
      end = null;
    });
    if (found.length == puzzle.words.length) controller.complete();
  }

  static bool _sameCells(List<int> a, List<int> b) =>
      a.length == b.length && (a.toSet().containsAll(b));

  bool _hint() {
    final open = puzzle.words.where((w) => !found.contains(w.word) && w.word != hintWord).toList();
    if (open.isEmpty) return false;
    setState(() => hintWord = open.first.word);
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final palette = KpPalette.of(context);
    final n = puzzle.size;
    final selection = start == null || end == null ? <int>{} : _line(start!, end!).toSet();
    final foundCells = {for (final w in puzzle.words) if (found.contains(w.word)) ...w.cells};
    final hintCell = hintWord == null ? null : puzzle.words.firstWhere((w) => w.word == hintWord).cells.first;
    return Column(
      children: [
        GameBoard(
          padding: const EdgeInsets.all(10),
          child: AspectRatio(
            aspectRatio: 1,
            child: LayoutBuilder(builder: (context, c) {
              final cell = c.maxWidth / n;
              return GestureDetector(
                onPanStart: (d) => setState(() => start = end = _cellAt(d.localPosition, cell)),
                onPanUpdate: (d) => setState(() => end = _cellAt(d.localPosition, cell)),
                onPanEnd: (_) => _finishSelection(),
                onTapUp: (d) {
                  final i = _cellAt(d.localPosition, cell);
                  if (start == null) {
                    setState(() => start = end = i);
                  } else {
                    setState(() => end = i);
                    _finishSelection();
                  }
                },
                child: Semantics(
                  label: l.wordSearchLabel(n),
                  child: Stack(
                    children: [
                      for (var i = 0; i < n * n; i++)
                        Positioned(
                          left: (i % n) * cell,
                          top: (i ~/ n) * cell,
                          width: cell,
                          height: cell,
                          child: Container(
                            margin: const EdgeInsets.all(1.5),
                            decoration: BoxDecoration(
                              color: selection.contains(i)
                                  ? palette.highlight
                                  : foundCells.contains(i)
                                      ? palette.successSoft.withValues(alpha: 0.55)
                                      : Colors.transparent,
                              borderRadius: BorderRadius.circular(cell / 3),
                              border: hintCell == i ? Border.all(color: palette.accent, width: 2) : null,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              puzzle.letters[i],
                              style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: cell * 0.5, color: palette.ink),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 14),
        GameStatusLine(parts: [l.wordsFound(found.length, puzzle.words.length)]),
        const SizedBox(height: 12),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final w in puzzle.words)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: found.contains(w.word) ? palette.success : Colors.white.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  w.word,
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: found.contains(w.word) ? Colors.white : palette.ink,
                    decoration: found.contains(w.word) ? TextDecoration.lineThrough : null,
                    decorationColor: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
