import 'package:flutter/material.dart';

import 'motifs.dart';

/// Draws a [Motif] scaled to the widget, with one fill per region.
///
/// Shared by the coloring game, the gallery and the day thumbnails.
class MotifPainter extends CustomPainter {
  MotifPainter({
    required this.motif,
    required this.fills,
    required this.lineColor,
    this.numbers,
    this.numberColor,
    this.emptyColor = Colors.white,
    this.lineWidth = 1.3,
  });

  final Motif motif;

  /// Fill per region; null = empty.
  final List<Color?> fills;
  final Color lineColor;

  /// Paint-by-numbers labels per region (null = no label).
  final List<int?>? numbers;
  final Color? numberColor;
  final Color emptyColor;
  final double lineWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.shortestSide / Motif.size;
    canvas
      ..save()
      ..scale(scale);
    final fill = Paint()..style = PaintingStyle.fill;
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = lineWidth
      ..strokeJoin = StrokeJoin.round
      ..color = lineColor;
    for (var i = 0; i < motif.regions.length; i++) {
      final path = motif.regions[i].path;
      canvas
        ..drawPath(path, fill..color = (i < fills.length ? fills[i] : null) ?? emptyColor)
        ..drawPath(path, stroke);
    }
    for (final d in motif.details) {
      canvas.drawPath(d, stroke);
    }
    final labels = numbers;
    if (labels != null) {
      final anchors = MotifAnchors.of(motif);
      for (var i = 0; i < motif.regions.length; i++) {
        final n = labels[i];
        if (n == null || (i < fills.length && fills[i] != null)) continue;
        final a = anchors[i];
        final tp = TextPainter(
          text: TextSpan(
            text: '$n',
            style: TextStyle(
              fontFamily: 'Nunito',
              fontWeight: FontWeight.w800,
              fontSize: a.size,
              color: numberColor ?? lineColor,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas, a.center - Offset(tp.width / 2, tp.height / 2));
      }
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(MotifPainter old) =>
      old.motif != motif || old.fills != fills || old.numbers != numbers || old.lineColor != lineColor;
}

/// Where to print a region's number: a visible point near the middle of
/// what can be seen of the region, with a font size that fits.
class MotifAnchors {
  const MotifAnchors(this.center, this.size);

  final Offset center;
  final double size;

  static final Map<String, List<MotifAnchors>> _cache = {};

  static List<MotifAnchors> of(Motif motif) => _cache[motif.id] ??= _compute(motif);

  static List<MotifAnchors> _compute(Motif motif) {
    const step = 1.0;
    final visible = List.generate(motif.regions.length, (_) => <Offset>[]);
    for (var y = step / 2; y < Motif.size; y += step) {
      for (var x = step / 2; x < Motif.size; x += step) {
        final p = Offset(x, y);
        final i = motif.regionAt(p);
        if (i != null) visible[i].add(p);
      }
    }
    return [
      for (final points in visible)
        if (points.isEmpty)
          const MotifAnchors(Offset(-100, -100), 0)
        else
          _anchor(points),
    ];
  }

  static MotifAnchors _anchor(List<Offset> points) {
    var sx = 0.0, sy = 0.0;
    for (final p in points) {
      sx += p.dx;
      sy += p.dy;
    }
    final mean = Offset(sx / points.length, sy / points.length);
    // The point furthest inside (most neighbours) among those close to the
    // mean keeps labels off the outlines of thin or curved regions.
    final set = {for (final p in points) _key(p)};
    Offset best = points.first;
    var bestScore = double.negativeInfinity;
    for (final p in points) {
      final score = _depth(p, set) * 2 - (p - mean).distance * 0.35;
      if (score > bestScore) {
        bestScore = score;
        best = p;
      }
    }
    final depth = _depth(best, set);
    return MotifAnchors(best, (depth * 1.6).clamp(3.2, 9.0));
  }

  static int _depth(Offset p, Set<int> set) {
    var d = 0;
    while (d < 12 &&
        set.contains(_key(p + Offset(d + 1.0, 0))) &&
        set.contains(_key(p - Offset(d + 1.0, 0))) &&
        set.contains(_key(p + Offset(0, d + 1.0))) &&
        set.contains(_key(p - Offset(0, d + 1.0)))) {
      d++;
    }
    return d;
  }

  static int _key(Offset p) => p.dx.floor() * 1000 + p.dy.floor();
}
