import 'dart:collection';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/seeded_random.dart';
import '../../design/icons.dart';
import '../../design/palette.dart';
import '../../domain/models.dart';
import '../../l10n/generated/app_localizations.dart';
import '../game_framework.dart';
import '../game_widgets.dart';

class MazeDefinition extends GameDefinition {
  const MazeDefinition();

  @override
  GameType get type => GameType.maze;

  static int sizeFor(Difficulty d) => switch (d) {
        Difficulty.easy => 7,
        Difficulty.standard => 10,
        Difficulty.advanced => 14,
      };

  @override
  int minutes(Difficulty d) => switch (d) {
        Difficulty.easy => 2,
        Difficulty.standard => 4,
        Difficulty.advanced => 7,
      };

  @override
  String levelDetail(AppLocalizations l, Difficulty d) {
    final s = sizeFor(d);
    return l.detailGrid('$s×$s', minutes(d));
  }

  @override
  GameStat get stat => GameStat.moves;

  @override
  Widget build(BuildContext context, GameSession session) => MazeGame(session: session);
}

/// Perfect maze (exactly one path between two cells) on a square grid.
class Maze {
  Maze(this.size) : _open = List.generate(size * size, (_) => <int>{});

  final int size;

  /// Neighbour cells reachable from each cell.
  final List<Set<int>> _open;

  static const directions = [(-1, 0), (1, 0), (0, -1), (0, 1)];

  factory Maze.generate(int size, SeededRandom random) {
    final maze = Maze(size);
    final visited = List.filled(size * size, false);
    final stack = <int>[0];
    visited[0] = true;
    while (stack.isNotEmpty) {
      final cell = stack.last;
      final r = cell ~/ size, c = cell % size;
      final options = <int>[
        for (final (dr, dc) in directions)
          if (r + dr >= 0 && r + dr < size && c + dc >= 0 && c + dc < size && !visited[(r + dr) * size + c + dc])
            (r + dr) * size + c + dc,
      ];
      if (options.isEmpty) {
        stack.removeLast();
        continue;
      }
      final next = random.pick(options);
      maze._open[cell].add(next);
      maze._open[next].add(cell);
      visited[next] = true;
      stack.add(next);
    }
    return maze;
  }

  bool canMove(int from, int to) => _open[from].contains(to);

  bool hasWall(int cell, int dr, int dc) {
    final r = cell ~/ size + dr, c = cell % size + dc;
    if (r < 0 || c < 0 || r >= size || c >= size) return true;
    return !_open[cell].contains(r * size + c);
  }

  int get goal => size * size - 1;

  int shortestPath() {
    final dist = List.filled(size * size, -1);
    final queue = Queue<int>()..add(0);
    dist[0] = 0;
    while (queue.isNotEmpty) {
      final cell = queue.removeFirst();
      for (final n in _open[cell]) {
        if (dist[n] == -1) {
          dist[n] = dist[cell] + 1;
          queue.add(n);
        }
      }
    }
    return dist[goal];
  }
}

class MazeGame extends StatefulWidget {
  const MazeGame({super.key, required this.session});

  final GameSession session;

  @override
  State<MazeGame> createState() => _MazeGameState();
}

class _MazeGameState extends State<MazeGame> {
  late final Maze maze = Maze.generate(MazeDefinition.sizeFor(widget.session.difficulty), widget.session.random());
  late final int shortest = maze.shortestPath();
  int position = 0;
  final Set<int> trail = {0};
  Offset _drag = Offset.zero;

  GameController get controller => widget.session.controller;

  void _move(int dr, int dc) {
    if (controller.paused || controller.finished) return;
    final r = position ~/ maze.size + dr, c = position % maze.size + dc;
    if (r < 0 || c < 0 || r >= maze.size || c >= maze.size) return;
    final next = r * maze.size + c;
    if (!maze.canMove(position, next)) return;
    setState(() {
      position = next;
      trail.add(next);
    });
    controller.reportMove();
    if (position == maze.goal) {
      final m = controller.moves;
      controller.complete(GameOutcome(stars: m <= shortest * 1.3 ? 3 : m <= shortest * 2.2 ? 2 : 1));
    }
  }

  void _onPanEnd(DragEndDetails _) {
    final d = _drag;
    _drag = Offset.zero;
    if (d.distance < 12) return;
    if (d.dx.abs() > d.dy.abs()) {
      _move(0, d.dx > 0 ? 1 : -1);
    } else {
      _move(d.dy > 0 ? 1 : -1, 0);
    }
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
              child: Semantics(
                label: l.mazeLabel,
                child: CustomPaint(
                  painter: _MazePainter(maze: maze, position: position, trail: trail, palette: palette),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        ListenableBuilder(
          listenable: controller,
          builder: (context, _) => GameStatusLine(parts: [l.movesCount(controller.moves)]),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: 200,
          child: Column(
            children: [
              GlassKey(height: 56, width: 72, semanticLabel: l.directionUp, onTap: () => _move(-1, 0), child: KpIcon(KpIcons.arrowUp, color: palette.ink)),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GlassKey(height: 56, width: 72, semanticLabel: l.directionLeft, onTap: () => _move(0, -1), child: KpIcon(KpIcons.arrowLeft, color: palette.ink)),
                  GlassKey(height: 56, width: 72, semanticLabel: l.directionRight, onTap: () => _move(0, 1), child: KpIcon(KpIcons.arrowRight, color: palette.ink)),
                ],
              ),
              const SizedBox(height: 8),
              GlassKey(height: 56, width: 72, semanticLabel: l.directionDown, onTap: () => _move(1, 0), child: KpIcon(KpIcons.arrowDown, color: palette.ink)),
            ],
          ),
        ),
      ],
    );
  }
}

class _MazePainter extends CustomPainter {
  _MazePainter({required this.maze, required this.position, required this.trail, required this.palette});

  final Maze maze;
  final int position;
  final Set<int> trail;
  final KpPalette palette;

  @override
  void paint(Canvas canvas, Size size) {
    final n = maze.size;
    final cell = size.width / n;
    final trailPaint = Paint()..color = palette.highlight.withValues(alpha: 0.45);
    for (final t in trail) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH((t % n) * cell + 2, (t ~/ n) * cell + 2, cell - 4, cell - 4), Radius.circular(cell / 4)),
        trailPaint,
      );
    }
    final wall = Paint()
      ..color = palette.ink
      ..strokeWidth = n > 12 ? 2.5 : 3.5
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < n * n; i++) {
      final x = (i % n) * cell, y = (i ~/ n) * cell;
      if (maze.hasWall(i, -1, 0)) canvas.drawLine(Offset(x, y), Offset(x + cell, y), wall);
      if (maze.hasWall(i, 0, -1)) canvas.drawLine(Offset(x, y), Offset(x, y + cell), wall);
      if (i % n == n - 1) canvas.drawLine(Offset(x + cell, y), Offset(x + cell, y + cell), wall);
      if (i ~/ n == n - 1) canvas.drawLine(Offset(x, y + cell), Offset(x + cell, y + cell), wall);
    }
    final g = maze.goal;
    _star(canvas, Offset((g % n + 0.5) * cell, (g ~/ n + 0.5) * cell), cell * 0.36);
    canvas.drawCircle(
      Offset((position % n + 0.5) * cell, (position ~/ n + 0.5) * cell),
      cell * 0.3,
      Paint()..color = palette.accent,
    );
  }

  void _star(Canvas canvas, Offset center, double r) {
    final path = Path();
    for (var i = 0; i < 10; i++) {
      final radius = i.isEven ? r : r * 0.45;
      final a = -math.pi / 2 + i * math.pi / 5;
      final p = center + Offset(radius * math.cos(a), radius * math.sin(a));
      i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
    }
    path.close();
    canvas.drawPath(path, Paint()..color = palette.highlight);
    canvas.drawPath(path, Paint()
      ..color = palette.accent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5);
  }

  @override
  bool shouldRepaint(_MazePainter old) => old.position != position || old.trail.length != trail.length || old.palette != palette;
}
