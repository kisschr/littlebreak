import 'package:flutter/material.dart';

import '../../core/seeded_random.dart';
import '../../design/palette.dart';
import '../../domain/models.dart';
import '../../l10n/generated/app_localizations.dart';
import '../game_framework.dart';

class SlidePuzzleDefinition extends GameDefinition {
  const SlidePuzzleDefinition();

  @override
  GameType get type => GameType.slidePuzzle;

  static int sizeFor(Difficulty d) => switch (d) {
        Difficulty.easy => 3,
        Difficulty.standard => 4,
        Difficulty.advanced => 5,
      };

  @override
  int minutes(Difficulty d) => switch (d) {
        Difficulty.easy => 3,
        Difficulty.standard => 8,
        Difficulty.advanced => 15,
      };

  @override
  String levelDetail(AppLocalizations l, Difficulty d) {
    final s = sizeFor(d);
    return l.detailGrid('$s×$s', minutes(d));
  }

  @override
  GameStat get stat => GameStat.moves;

  @override
  Widget build(BuildContext context, GameSession session) => SlidePuzzleGame(session: session);
}

/// Board logic: tiles[i] is the tile number at position i, 0 = gap.
class SlideBoard {
  SlideBoard(this.size) : tiles = [for (var i = 1; i < size * size; i++) i, 0];

  final int size;
  final List<int> tiles;

  int get gap => tiles.indexOf(0);

  bool get solved {
    for (var i = 0; i < tiles.length - 1; i++) {
      if (tiles[i] != i + 1) return false;
    }
    return true;
  }

  List<int> neighboursOfGap() {
    final g = gap;
    final r = g ~/ size;
    final c = g % size;
    return [
      if (r > 0) g - size,
      if (r < size - 1) g + size,
      if (c > 0) g - 1,
      if (c < size - 1) g + 1,
    ];
  }

  /// Slides the tile at [index] (and every tile between it and the gap, if
  /// they share a row or column). Returns the number of tiles moved.
  int slide(int index) {
    final g = gap;
    final r = index ~/ size, c = index % size;
    final gr = g ~/ size, gc = g % size;
    if (r != gr && c != gc) return 0;
    if (index == g) return 0;
    final step = r == gr ? (c < gc ? 1 : -1) : (r < gr ? size : -size);
    var pos = g;
    var moved = 0;
    while (pos != index) {
      tiles[pos] = tiles[pos - step];
      pos -= step;
      moved++;
    }
    tiles[index] = 0;
    return moved;
  }

  /// Shuffles by legal random moves, so the board is always solvable.
  void shuffle(SeededRandom random, int moves) {
    var last = -1;
    var done = 0;
    while (done < moves || solved) {
      final options = neighboursOfGap()..remove(last);
      final pick = random.pick(options);
      last = gap;
      slide(pick);
      done++;
    }
  }
}

class SlidePuzzleGame extends StatefulWidget {
  const SlidePuzzleGame({super.key, required this.session});

  final GameSession session;

  @override
  State<SlidePuzzleGame> createState() => _SlidePuzzleGameState();
}

class _SlidePuzzleGameState extends State<SlidePuzzleGame> {
  late final SlideBoard board;
  late final int shuffleMoves;

  GameController get controller => widget.session.controller;

  @override
  void initState() {
    super.initState();
    final size = SlidePuzzleDefinition.sizeFor(widget.session.difficulty);
    shuffleMoves = widget.session.byLevel(30, 80, 160);
    board = SlideBoard(size)..shuffle(widget.session.random(), shuffleMoves);
  }

  void _tap(int index) {
    if (controller.paused || controller.finished) return;
    final moved = board.slide(index);
    if (moved == 0) return;
    setState(() {});
    controller.reportMove();
    if (board.solved) {
      final m = controller.moves;
      final par = board.size * board.size * (board.size - 1);
      controller.complete(GameOutcome(stars: m <= par ? 3 : m <= par * 2 ? 2 : 1));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final palette = KpPalette.of(context);
    final size = board.size;
    return Column(
      children: [
        GameBoard(
          padding: const EdgeInsets.all(10),
          child: AspectRatio(
            aspectRatio: 1,
            child: LayoutBuilder(builder: (context, constraints) {
              final cell = constraints.maxWidth / size;
              return Stack(
                children: [
                  for (var pos = 0; pos < board.tiles.length; pos++)
                    if (board.tiles[pos] != 0)
                      AnimatedPositioned(
                        key: ValueKey(board.tiles[pos]),
                        duration: const Duration(milliseconds: 140),
                        curve: Curves.easeOut,
                        left: (pos % size) * cell,
                        top: (pos ~/ size) * cell,
                        width: cell,
                        height: cell,
                        child: Semantics(
                          button: true,
                          label: l.tileLabel(board.tiles[pos]),
                          excludeSemantics: true,
                          child: GestureDetector(
                            onTap: () => _tap(pos),
                            child: Padding(
                              padding: const EdgeInsets.all(2.5),
                              child: _Tile(number: board.tiles[pos], size: size, palette: palette, showNumber: true),
                            ),
                          ),
                        ),
                      ),
                ],
              );
            }),
          ),
        ),
        const SizedBox(height: 18),
        ListenableBuilder(
          listenable: controller,
          builder: (context, _) => GameStatusLine(parts: [l.movesCount(controller.moves)]),
        ),
        const SizedBox(height: 10),
        Text(l.slideGoal, textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w700, color: palette.inkSoft)),
      ],
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({required this.number, required this.size, required this.palette, required this.showNumber});

  final int number;
  final int size;
  final KpPalette palette;
  final bool showNumber;

  @override
  Widget build(BuildContext context) {
    final home = number - 1;
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: CustomPaint(
        painter: _ScenePainter(palette: palette, size: size, row: home ~/ size, col: home % size),
        child: Align(
          alignment: Alignment.topLeft,
          child: Container(
            margin: const EdgeInsets.all(4),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.8), borderRadius: BorderRadius.circular(8)),
            child: Text('$number', style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w900, fontSize: size >= 5 ? 11 : 14, color: palette.ink)),
          ),
        ),
      ),
    );
  }
}

/// Paints one tile's slice of a small landscape in the month's colours.
class _ScenePainter extends CustomPainter {
  _ScenePainter({required this.palette, required this.size, required this.row, required this.col});

  final KpPalette palette;
  final int size;
  final int row;
  final int col;

  @override
  void paint(Canvas canvas, Size tile) {
    final full = Size(tile.width * size, tile.height * size);
    canvas.save();
    canvas.translate(-col * tile.width, -row * tile.height);
    final rect = Offset.zero & full;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [palette.blobs[3], palette.background],
        ).createShader(rect),
    );
    canvas.drawCircle(Offset(full.width * 0.72, full.height * 0.3), full.width * 0.14, Paint()..color = palette.highlight);
    final hill1 = Path()
      ..moveTo(0, full.height * 0.62)
      ..quadraticBezierTo(full.width * 0.3, full.height * 0.42, full.width * 0.65, full.height * 0.6)
      ..quadraticBezierTo(full.width * 0.85, full.height * 0.7, full.width, full.height * 0.58)
      ..lineTo(full.width, full.height)
      ..lineTo(0, full.height)
      ..close();
    canvas.drawPath(hill1, Paint()..color = palette.blobs[0]);
    final hill2 = Path()
      ..moveTo(0, full.height * 0.8)
      ..quadraticBezierTo(full.width * 0.45, full.height * 0.66, full.width, full.height * 0.82)
      ..lineTo(full.width, full.height)
      ..lineTo(0, full.height)
      ..close();
    canvas.drawPath(hill2, Paint()..color = palette.accent);
    final cloud = Paint()..color = Colors.white.withValues(alpha: 0.85);
    canvas.drawOval(Rect.fromLTWH(full.width * 0.12, full.height * 0.16, full.width * 0.28, full.height * 0.09), cloud);
    canvas.drawOval(Rect.fromLTWH(full.width * 0.2, full.height * 0.11, full.width * 0.16, full.height * 0.1), cloud);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_ScenePainter old) => old.palette != palette || old.row != row || old.col != col;
}
