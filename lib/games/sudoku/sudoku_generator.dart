import '../../core/seeded_random.dart';

/// A Sudoku of size 4, 6 or 9 with a unique solution.
class SudokuPuzzle {
  SudokuPuzzle({required this.size, required this.boxRows, required this.boxCols, required this.givens, required this.solution});

  final int size;
  final int boxRows;
  final int boxCols;

  /// Row-major, 0 = empty.
  final List<int> givens;
  final List<int> solution;

  int get clueCount => givens.where((v) => v != 0).length;
}

/// Seeded generator: full grid by randomised backtracking, then cells are
/// removed one by one as long as the solution stays unique.
class SudokuGenerator {
  const SudokuGenerator();

  static (int, int) boxShape(int size) => switch (size) {
        4 => (2, 2),
        6 => (2, 3),
        9 => (3, 3),
        _ => throw ArgumentError('Unsupported size $size'),
      };

  SudokuPuzzle generate({required int size, required int targetClues, required SeededRandom random}) {
    final (boxRows, boxCols) = boxShape(size);
    final solver = _Solver(size, boxRows, boxCols);
    final solution = List<int>.filled(size * size, 0);
    solver.fill(solution, random);

    final puzzle = List<int>.of(solution);
    final order = random.shuffle(List<int>.generate(size * size, (i) => i));
    var clues = size * size;
    for (final cell in order) {
      if (clues <= targetClues) break;
      final backup = puzzle[cell];
      puzzle[cell] = 0;
      if (solver.countSolutions(List<int>.of(puzzle), limit: 2) != 1) {
        puzzle[cell] = backup;
      } else {
        clues--;
      }
    }
    return SudokuPuzzle(size: size, boxRows: boxRows, boxCols: boxCols, givens: puzzle, solution: solution);
  }
}

class _Solver {
  _Solver(this.size, this.boxRows, this.boxCols);

  final int size;
  final int boxRows;
  final int boxCols;

  int _candidates(List<int> g, int index) {
    final r = index ~/ size;
    final c = index % size;
    var used = 0;
    for (var i = 0; i < size; i++) {
      used |= 1 << g[r * size + i];
      used |= 1 << g[i * size + c];
    }
    final br = (r ~/ boxRows) * boxRows;
    final bc = (c ~/ boxCols) * boxCols;
    for (var dr = 0; dr < boxRows; dr++) {
      for (var dc = 0; dc < boxCols; dc++) {
        used |= 1 << g[(br + dr) * size + bc + dc];
      }
    }
    final all = ((1 << (size + 1)) - 1) & ~1;
    return all & ~used;
  }

  /// Index of the empty cell with the fewest candidates, or -1 when full.
  (int, int) _bestCell(List<int> g) {
    var best = -1;
    var bestMask = 0;
    var bestCount = 99;
    for (var i = 0; i < g.length; i++) {
      if (g[i] != 0) continue;
      final mask = _candidates(g, i);
      final count = _bitCount(mask);
      if (count < bestCount) {
        best = i;
        bestMask = mask;
        bestCount = count;
        if (count <= 1) break;
      }
    }
    return (best, bestMask);
  }

  bool fill(List<int> g, SeededRandom random) {
    final (cell, mask) = _bestCell(g);
    if (cell == -1) return true;
    final values = [for (var v = 1; v <= size; v++) if (mask & (1 << v) != 0) v];
    random.shuffle(values);
    for (final v in values) {
      g[cell] = v;
      if (fill(g, random)) return true;
    }
    g[cell] = 0;
    return false;
  }

  int countSolutions(List<int> g, {int limit = 2}) {
    final (cell, mask) = _bestCell(g);
    if (cell == -1) return 1;
    var count = 0;
    for (var v = 1; v <= size; v++) {
      if (mask & (1 << v) == 0) continue;
      g[cell] = v;
      count += countSolutions(g, limit: limit - count);
      if (count >= limit) break;
    }
    g[cell] = 0;
    return count;
  }

  static int _bitCount(int v) {
    var n = 0;
    while (v != 0) {
      v &= v - 1;
      n++;
    }
    return n;
  }
}

/// True when [grid] is a complete, valid Sudoku.
bool isValidSolution(List<int> grid, int size) {
  final (boxRows, boxCols) = SudokuGenerator.boxShape(size);
  bool unique(Iterable<int> values) {
    final list = values.toList();
    return list.toSet().length == size && list.every((v) => v >= 1 && v <= size);
  }

  for (var i = 0; i < size; i++) {
    if (!unique([for (var c = 0; c < size; c++) grid[i * size + c]])) return false;
    if (!unique([for (var r = 0; r < size; r++) grid[r * size + i]])) return false;
  }
  for (var br = 0; br < size; br += boxRows) {
    for (var bc = 0; bc < size; bc += boxCols) {
      if (!unique([
        for (var r = br; r < br + boxRows; r++)
          for (var c = bc; c < bc + boxCols; c++) grid[r * size + c],
      ])) {
        return false;
      }
    }
  }
  return true;
}
