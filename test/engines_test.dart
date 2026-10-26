import 'package:flutter_test/flutter_test.dart';
import 'package:kleine_pause/core/seeded_random.dart';
import 'package:kleine_pause/domain/models.dart';
import 'package:kleine_pause/games/anagram/anagram_game.dart';
import 'package:kleine_pause/games/coloring/motif_painter.dart';
import 'package:kleine_pause/games/coloring/motifs.dart';
import 'package:kleine_pause/games/game_2048/game_2048.dart';
import 'package:kleine_pause/games/game_framework.dart';
import 'package:kleine_pause/games/game_registry.dart';
import 'package:kleine_pause/games/hanoi/hanoi_game.dart';
import 'package:kleine_pause/games/lights_out/lights_out_game.dart';
import 'package:kleine_pause/games/maze/maze_game.dart';
import 'package:kleine_pause/games/minesweeper/minesweeper_game.dart';
import 'package:kleine_pause/games/nonogram/nonogram_game.dart';
import 'package:kleine_pause/games/number_pyramid/number_pyramid_game.dart';
import 'package:kleine_pause/games/slide_puzzle/slide_puzzle_game.dart';
import 'package:kleine_pause/games/sudoku/sudoku_generator.dart';
import 'package:kleine_pause/games/word_guess/word_guess_game.dart';
import 'package:kleine_pause/games/word_search/word_search_game.dart';

/// Independent brute force solution counter for small Sudokus.
int _countSolutions(List<int> grid, int size, int boxRows, int boxCols, {int limit = 2}) {
  final i = grid.indexOf(0);
  if (i == -1) return 1;
  final r = i ~/ size, c = i % size;
  var count = 0;
  for (var v = 1; v <= size && count < limit; v++) {
    var ok = true;
    for (var k = 0; k < size && ok; k++) {
      if (grid[r * size + k] == v || grid[k * size + c] == v) ok = false;
    }
    final br = r - r % boxRows, bc = c - c % boxCols;
    for (var rr = br; rr < br + boxRows && ok; rr++) {
      for (var cc = bc; cc < bc + boxCols && ok; cc++) {
        if (grid[rr * size + cc] == v) ok = false;
      }
    }
    if (!ok) continue;
    grid[i] = v;
    count += _countSolutions(grid, size, boxRows, boxCols, limit: limit - count);
    grid[i] = 0;
  }
  return count;
}

void main() {
  test('every game type has a definition', () {
    for (final t in GameType.values) {
      final def = GameRegistry.of(t);
      expect(def.type, t);
      for (final d in Difficulty.values) {
        expect(def.minutes(d), greaterThan(0));
      }
    }
  });

  group('Sudoku', () {
    for (final (size, clues) in [(4, 6), (6, 14), (9, 30)]) {
      test('$size×$size has a valid, unique solution', () {
        for (var seed = 0; seed < 4; seed++) {
          final p = const SudokuGenerator().generate(size: size, targetClues: clues, random: SeededRandom(seed));
          expect(isValidSolution(p.solution, size), isTrue);
          for (var i = 0; i < p.givens.length; i++) {
            if (p.givens[i] != 0) expect(p.givens[i], p.solution[i]);
          }
          expect(p.clueCount, lessThan(size * size));
          if (size < 9) {
            expect(_countSolutions(List.of(p.givens), size, p.boxRows, p.boxCols), 1);
          }
        }
      });
    }

    test('same seed, same puzzle', () {
      final a = const SudokuGenerator().generate(size: 9, targetClues: 30, random: SeededRandom(5));
      final b = const SudokuGenerator().generate(size: 9, targetClues: 30, random: SeededRandom(5));
      expect(a.givens, b.givens);
    });
  });

  test('lights out presses are their own inverse', () {
    final board = LightsOutBoard(5);
    for (final i in [0, 7, 12, 24]) {
      board.press(i);
    }
    expect(board.solved, isFalse);
    for (final i in [24, 12, 7, 0]) {
      board.press(i);
    }
    expect(board.solved, isTrue);
  });

  test('slide puzzle shuffles into a solvable, unsolved board', () {
    final board = SlideBoard(4)..shuffle(SeededRandom(3), 80);
    expect(board.solved, isFalse);
    expect(board.tiles.toSet(), {for (var i = 0; i < 16; i++) i});
    // Solvability via inversion parity for an even width.
    final tiles = board.tiles.where((t) => t != 0).toList();
    var inversions = 0;
    for (var i = 0; i < tiles.length; i++) {
      for (var j = i + 1; j < tiles.length; j++) {
        if (tiles[i] > tiles[j]) inversions++;
      }
    }
    final gapRowFromBottom = 4 - board.gap ~/ 4;
    expect((inversions + gapRowFromBottom).isOdd, isTrue);
    expect(SlideBoard(3).slide(6), 2);
  });

  test('maze is perfect and the goal is reachable', () {
    final maze = Maze.generate(9, SeededRandom(11));
    var passages = 0;
    for (var cell = 0; cell < 81; cell++) {
      for (final (dr, dc) in Maze.directions) {
        if (!maze.hasWall(cell, dr, dc)) passages++;
      }
    }
    expect(passages ~/ 2, 81 - 1);
    expect(maze.shortestPath(), greaterThanOrEqualTo(16));
  });

  test('nonogram clues match the picture and no line is empty', () {
    final p = NonogramPuzzle.generate(10, SeededRandom(2));
    expect(NonogramPuzzle.clueFor([true, true, false, true]), [2, 1]);
    expect(NonogramPuzzle.clueFor([false, false]), [0]);
    for (final clue in [...p.rowClues, ...p.colClues]) {
      expect(clue, isNot([0]));
    }
  });

  test('number pyramid sums up and stays solvable', () {
    final p = Pyramid.generate(rows: 5, maxBase: 9, hidden: 8, random: SeededRandom(9));
    for (var r = 0; r < p.rows - 1; r++) {
      for (var i = 0; i <= r; i++) {
        expect(p.values[r][i], p.values[r + 1][i] + p.values[r + 1][i + 1]);
      }
    }
    expect(Pyramid.solvable(p.known), isTrue);
    expect(p.known.expand((row) => row).where((k) => !k).length, 8);
  });

  test('2048 merges each pair once', () {
    final board = Board2048(SeededRandom(1));
    board.cells
      ..fillRange(0, 16, 0)
      ..setAll(0, [2, 2, 2, 2]);
    expect(board.move(SwipeDirection.left), isTrue);
    expect(board.cells.sublist(0, 4), [4, 4, 0, 0]);
    expect(board.score, 8);
    expect(board.cells.where((v) => v != 0).length, 3);
  });

  test('word guess scoring handles repeated letters', () {
    const c = LetterResult.correct, p = LetterResult.present, a = LetterResult.absent;
    expect(scoreGuess('LAMPE', 'LAMPE'), [c, c, c, c, c]);
    expect(scoreGuess('EELLE', 'LEBEN'), [p, c, p, a, a]);
    expect(scoreGuess('ABBBB', 'BAAAA'), [p, p, a, a, a]);
  });

  test('anagrams never show the word itself', () {
    final random = SeededRandom(4);
    for (final w in ['HAUS', 'BAUM', 'APFEL', 'AB']) {
      final s = scramble(w, random);
      expect(s, isNot(w));
      expect((s.split('')..sort()).join(), (w.split('')..sort()).join());
    }
  });

  test('hanoi only allows smaller discs on top', () {
    final h = HanoiState(3);
    expect(h.move(0, 2), isTrue);
    expect(h.move(0, 2), isFalse);
    expect(h.optimalMoves, 7);
  });

  test('minesweeper keeps the first tap safe', () {
    final field = MineField(9, 10)..place(40, SeededRandom(8));
    expect(field.mines.where((m) => m).length, 10);
    expect(field.mines[40], isFalse);
    expect(field.reveal(40), isTrue);
    expect(field.revealed.where((r) => r).length, greaterThan(1));
  });

  test('word search places words along their cells', () {
    final p = WordSearchPuzzle.generate(
      size: 8,
      candidates: ['HAUS', 'BAUM', 'APFEL', 'KATZE', 'MAUS', 'BLUME'],
      count: 5,
      directions: const [(0, 1), (1, 0)],
      alphabet: 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.split(''),
      random: SeededRandom(6),
    );
    expect(p.words, isNotEmpty);
    for (final w in p.words) {
      expect(w.cells.map((i) => p.letters[i]).join(), w.word);
    }
  });

  group('motifs', () {
    test('every motif has regions and rasterises', () {
      for (final id in Motifs.ids) {
        final m = Motifs.byId(id);
        expect(m.regions, isNotEmpty, reason: id);
        final pixels = m.rasterize(12);
        expect(pixels.whereType<int>().length, greaterThan(10), reason: id);
      }
    });

    test('detailed pages: every region can be tapped where its number sits', () {
      for (final id in Motifs.ids) {
        final m = Motifs.byId('${Motifs.detailedPrefix}$id');
        expect(m.fine, isTrue);
        expect(m.regions.length, greaterThan(Motifs.byId(id).regions.length * 4), reason: id);
        expect(m.optional, inInclusiveRange(1, m.regions.length - 1), reason: id);
        final anchors = MotifAnchors.of(m);
        for (var i = 0; i < m.regions.length; i++) {
          expect(m.regionAt(anchors[i].center), i, reason: '$id region $i');
        }
      }
    });

    test('adults colour the detailed page, kids the simple one', () {
      final plan = DayPlan(date: DateTime(2026, 10, 31), type: GameType.coloring, dayNumber: 304, motif: 'pumpkin');
      expect(Motifs.pageFor(plan, Audience.adult), 'detailed:pumpkin');
      expect(Motifs.pageFor(plan, Audience.kid), 'pumpkin');
      expect(Motifs.baseId('detailed:pumpkin'), 'pumpkin');
    });

    test('all levels of a day share the motif', () {
      final plan = DayPlan(date: DateTime(2026, 10, 12), type: GameType.coloring, dayNumber: 285);
      expect(Motifs.byMonth[10], contains(Motifs.idFor(plan)));
      final special = DayPlan(date: DateTime(2026, 10, 31), type: GameType.coloring, dayNumber: 304, motif: 'pumpkin');
      expect(Motifs.idFor(special), 'pumpkin');
    });
  });

  group('GameController', () {
    test('stars from slips, kids never below two', () {
      final c = GameController();
      expect(c.starsFor(const GameOutcome(), isKid: false), 3);
      for (var i = 0; i < 4; i++) {
        c.reportMistake();
      }
      expect(c.starsFor(const GameOutcome(), isKid: false), 1);
      expect(c.starsFor(const GameOutcome(), isKid: true), 2);
    });

    test('hints are limited and finishing happens once', () {
      var finished = 0;
      final c = GameController(maxHints: 2, onFinished: (_) => finished++);
      expect(c.requestHint(), isFalse);
      c.setHintHandler(() => true);
      expect(c.requestHint(), isTrue);
      expect(c.requestHint(), isTrue);
      expect(c.requestHint(), isFalse);
      c
        ..complete()
        ..complete();
      expect(finished, 1);
    });
  });
}
