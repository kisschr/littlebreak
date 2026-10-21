import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/dates.dart';
import '../../data/repositories.dart';
import '../../design/palette.dart';
import '../../domain/models.dart';
import '../../l10n/generated/app_localizations.dart';
import '../coloring/coloring_game.dart';
import '../coloring/motifs.dart';
import '../game_framework.dart';

class PixelArtDefinition extends GameDefinition {
  const PixelArtDefinition();

  @override
  GameType get type => GameType.pixelArt;

  static int sizeFor(Difficulty d) => switch (d) {
        Difficulty.easy => 8,
        Difficulty.standard => 12,
        Difficulty.advanced => 16,
      };

  @override
  int minutes(Difficulty d) => switch (d) {
        Difficulty.easy => 2,
        Difficulty.standard => 4,
        Difficulty.advanced => 7,
      };

  @override
  String levelDetail(AppLocalizations l, Difficulty d) {
    final n = sizeFor(d);
    return l.detailGrid('$n×$n', minutes(d));
  }

  @override
  bool get usesHints => true;

  @override
  Widget build(BuildContext context, GameSession session) => PixelArtGame(session: session);
}

/// A pixel picture: target crayon per cell (null = background).
class PixelPicture {
  PixelPicture(this.size, this.target) : crayons = (target.whereType<int>().toSet().toList()..sort());

  final int size;
  final List<int?> target;

  /// Crayons in the picture; position + 1 is the number shown in cells.
  final List<int> crayons;

  int? numberAt(int cell) {
    final t = target[cell];
    return t == null ? null : crayons.indexOf(t) + 1;
  }

  int get paintable => target.where((t) => t != null).length;
}

class PixelArtGame extends StatefulWidget {
  const PixelArtGame({super.key, required this.session});

  final GameSession session;

  @override
  State<PixelArtGame> createState() => _PixelArtGameState();
}

class _PixelArtGameState extends State<PixelArtGame> {
  late final String motifId;
  late final PixelPicture picture;
  late final List<int?> painted;
  late int selected;
  int done = 0;

  GameController get controller => widget.session.controller;

  @override
  void initState() {
    super.initState();
    final s = widget.session;
    motifId = Motifs.idFor(s.plan);
    final n = PixelArtDefinition.sizeFor(s.difficulty);
    picture = PixelPicture(n, Motifs.byId(motifId).rasterize(n));
    painted = List<int?>.filled(n * n, null);
    selected = picture.crayons.first;
    controller.setHintHandler(_hint);
  }

  int _cellAt(Offset local, double side) {
    final n = picture.size;
    final c = (local.dx / side * n).floor().clamp(0, n - 1);
    final r = (local.dy / side * n).floor().clamp(0, n - 1);
    return r * n + c;
  }

  /// Paints [cell] when it wants the selected crayon. Taps on a wrong cell
  /// count as a mistake; drags just skip them.
  void _paint(int cell, {required bool tap}) {
    if (controller.paused || controller.finished) return;
    final t = picture.target[cell];
    if (t == null || painted[cell] != null) return;
    if (t != selected) {
      if (tap) controller.reportMistake();
      return;
    }
    setState(() {
      painted[cell] = t;
      done++;
    });
    if (done == picture.paintable) _finish();
  }

  bool _hint() {
    // Fills every remaining cell of the selected crayon, or of the next
    // unfinished one.
    final open = [for (var i = 0; i < painted.length; i++) if (picture.target[i] != null && painted[i] == null) i];
    if (open.isEmpty) return false;
    final crayon = open.any((i) => picture.target[i] == selected) ? selected : picture.target[open.first]!;
    setState(() {
      for (final i in open.where((i) => picture.target[i] == crayon)) {
        painted[i] = crayon;
        done++;
      }
      selected = crayon;
    });
    if (done == picture.paintable) _finish();
    return true;
  }

  void _finish() {
    final s = widget.session;
    controller.complete(GameOutcome(
      artwork: GalleryItem(
        dateKey: dateKey(s.plan.date),
        gameId: s.plan.type.id,
        motif: motifId,
        difficulty: s.difficulty,
        colors: [for (final p in painted) p == null ? null : kCrayons[p].toARGB32()],
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final palette = KpPalette.of(context);
    return Column(
      children: [
        GameBoard(
          padding: const EdgeInsets.all(12),
          child: AspectRatio(
            aspectRatio: 1,
            child: LayoutBuilder(
              builder: (context, c) {
                final side = c.maxWidth;
                return GestureDetector(
                  onTapUp: (d) => _paint(_cellAt(d.localPosition, side), tap: true),
                  onPanStart: (d) => _paint(_cellAt(d.localPosition, side), tap: false),
                  onPanUpdate: (d) => _paint(_cellAt(d.localPosition, side), tap: false),
                  child: Semantics(
                    label: l.pixelLabel(picture.size),
                    child: CustomPaint(
                      size: Size.square(side),
                      painter: _PixelPainter(
                        picture: picture,
                        painted: List.of(painted),
                        selected: selected,
                        palette: palette,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 10,
          runSpacing: 10,
          children: [
            for (var k = 0; k < picture.crayons.length; k++)
              CrayonDot(
                color: kCrayons[picture.crayons[k]],
                selected: selected == picture.crayons[k],
                label: '${k + 1}',
                semanticLabel: l.colorNumber(k + 1),
                onTap: () => setState(() => selected = picture.crayons[k]),
              ),
          ],
        ),
        const SizedBox(height: 14),
        ListenableBuilder(
          listenable: controller,
          builder: (context, _) => GameStatusLine(parts: [
            l.pixelsPainted(done, picture.paintable),
            l.mistakesCount(controller.mistakes),
          ]),
        ),
      ],
    );
  }
}

class _PixelPainter extends CustomPainter {
  _PixelPainter({required this.picture, required this.painted, required this.selected, required this.palette});

  final PixelPicture picture;
  final List<int?> painted;
  final int selected;
  final KpPalette palette;

  @override
  void paint(Canvas canvas, Size size) {
    final n = picture.size;
    final cell = size.width / n;
    final fill = Paint();
    final grid = Paint()
      ..color = palette.boardLine
      ..strokeWidth = 1;
    final fontSize = math.max(7.0, cell * 0.42);
    for (var i = 0; i < n * n; i++) {
      final rect = Rect.fromLTWH((i % n) * cell, (i ~/ n) * cell, cell, cell);
      final p = painted[i];
      final t = picture.target[i];
      if (p != null) {
        canvas.drawRect(rect, fill..color = kCrayons[p]);
        continue;
      }
      if (t == null) continue;
      if (t == selected) canvas.drawRect(rect, fill..color = palette.boardRelated);
      final tp = TextPainter(
        text: TextSpan(
          text: '${picture.numberAt(i)}',
          style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: fontSize, color: palette.inkSoft),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, rect.center - Offset(tp.width / 2, tp.height / 2));
    }
    for (var k = 0; k <= n; k++) {
      canvas
        ..drawLine(Offset(k * cell, 0), Offset(k * cell, size.height), grid)
        ..drawLine(Offset(0, k * cell), Offset(size.width, k * cell), grid);
    }
  }

  @override
  bool shouldRepaint(_PixelPainter old) => true;
}
