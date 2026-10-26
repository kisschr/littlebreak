import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui';

import '../../core/seeded_random.dart';
import 'motifs.dart';

/// Turns a simple motif into a detailed colouring page for adults.
///
/// Every visible area of the motif gets echo bands along its outline (a
/// scalloped one for round shapes) and large areas a field of dots; behind
/// it lie a tiled frame and a diamond lattice. The result has disjoint
/// regions (each one fully visible and fillable), finer outlines and the
/// motif's silhouette as a strong contour.
abstract final class MotifDetailer {
  static Motif detail(Motif base) {
    final random = SeededRandom.fromParts(['detail', base.id]);
    final regions = <MotifRegion>[];

    // What can be seen of each region: itself minus everything on top.
    final visible = List<Path?>.filled(base.regions.length, null);
    Path? above;
    for (var i = base.regions.length - 1; i >= 0; i--) {
      final own = base.regions[i].path;
      visible[i] = above == null ? own : Path.combine(PathOperation.difference, own, above);
      above = above == null ? own : Path.combine(PathOperation.union, above, own);
    }
    final motifShape = above ?? Path();

    regions.addAll(_background(motifShape, base, random));
    final optional = regions.length;
    for (var i = 0; i < base.regions.length; i++) {
      regions.addAll(_split(visible[i]!, base.regions[i].crayon, random));
    }
    return Motif(
      '${Motifs.detailedPrefix}${base.id}',
      regions,
      details: base.details,
      fine: true,
      contour: motifShape,
      optional: optional,
    );
  }

  /// Splits one visible area into echo bands that follow its outline, with
  /// a field of dots in the core of large areas. Small areas and dark
  /// features (eyes, mouths) stay whole so the motif keeps its face.
  static List<MotifRegion> _split(Path area, int crayon, SeededRandom random) {
    final sample = _Sample.of(area);
    if (sample.area < 70 || crayon == Crayon.dark) return [MotifRegion(area, crayon)];
    final partner = _partner(crayon);
    final c = sample.centroid;
    final out = <MotifRegion>[];

    final inner = Path.combine(PathOperation.intersect, area, area.transform(_scaleAbout(c, 0.74)));
    final band = Path.combine(PathOperation.difference, area, inner);
    final innerSample = _Sample.of(inner);
    // Round shapes get a scalloped band, long ones a plain one.
    final b = sample.bounds;
    final round = b.shortestSide / b.longestSide > 0.6 && sample.area / (b.width * b.height) > 0.6;
    if (round && sample.area > 160) {
      final n = (math.sqrt(sample.area) / 2.2).round().clamp(8, 18);
      out.addAll(_wedges(band, c, n, random.nextDouble() * math.pi, crayon, partner));
    } else {
      out.add(MotifRegion(band, crayon));
    }
    if (innerSample.area < 40) {
      if (innerSample.area > 2) out.add(MotifRegion(inner, partner));
      return out;
    }

    final core = Path.combine(PathOperation.intersect, inner, inner.transform(_scaleAbout(innerSample.centroid, 0.62)));
    final middle = Path.combine(PathOperation.difference, inner, core);
    out.add(MotifRegion(middle, partner));
    final coreSample = _Sample.of(core);
    if (coreSample.area < 2) return out;
    if (coreSample.area < 120) {
      out.add(MotifRegion(core, crayon));
      return out;
    }
    // Dots on a hex grid, only where they fit wholly inside the core.
    const spacing = 6.4, radius = 1.9;
    var dotted = core;
    final dotsFrom = out.length;
    final cb = core.getBounds();
    var row = 0;
    for (var y = cb.top + spacing / 2; y < cb.bottom; y += spacing * 0.87, row++) {
      for (var x = cb.left + (row.isOdd ? spacing / 2 : 0) + spacing / 2; x < cb.right; x += spacing) {
        final p = Offset(x, y);
        final fits = [
          for (var k = 0; k < 8; k++) p + Offset(math.cos(k * math.pi / 4), math.sin(k * math.pi / 4)) * (radius + 0.8),
        ].every(core.contains);
        if (!fits) continue;
        final dot = Path()..addOval(Rect.fromCircle(center: p, radius: radius));
        out.add(MotifRegion(dot, partner));
        dotted = Path.combine(PathOperation.difference, dotted, dot);
      }
    }
    // The dotted core goes below its dots, so the dots win hit tests.
    return [...out.take(dotsFrom), MotifRegion(dotted, crayon), ...out.skip(dotsFrom)];
  }

  /// [area] cut into [n] wedges around [c], alternating two crayons.
  static Iterable<MotifRegion> _wedges(Path area, Offset c, int n, double offset, int a, int b) sync* {
    for (var k = 0; k < n; k++) {
      final from = offset + k * 2 * math.pi / n;
      final to = offset + (k + 1) * 2 * math.pi / n;
      final piece = Path.combine(PathOperation.intersect, area, _wedge(c, from, to));
      if (_Sample.of(piece).area >= 2.5) yield MotifRegion(piece, k.isEven ? a : b);
    }
  }

  /// An ornamental frame and a diamond lattice behind the motif.
  static List<MotifRegion> _background(Path motifShape, Motif base, SeededRandom random) {
    final colors = _backgroundCrayons(base);
    final outer = Path()
      ..addRRect(RRect.fromRectAndRadius(const Rect.fromLTRB(2, 2, 98, 98), const Radius.circular(12)));
    final inner = Path()
      ..addRRect(RRect.fromRectAndRadius(const Rect.fromLTRB(7, 7, 93, 93), const Radius.circular(8)));
    final out = <MotifRegion>[];

    // The frame: a band of alternating tiles.
    final frame = Path.combine(
      PathOperation.difference,
      Path.combine(PathOperation.difference, outer, inner),
      motifShape,
    );
    const tiles = 36;
    for (var k = 0; k < tiles; k++) {
      final piece = Path.combine(
        PathOperation.intersect,
        frame,
        _wedge(
          const Offset(50, 50),
          k * 2 * math.pi / tiles - math.pi / 4,
          (k + 1) * 2 * math.pi / tiles - math.pi / 4,
        ),
      );
      if (_Sample.of(piece).area >= 3) out.add(MotifRegion(piece, colors[k % 2]));
    }

    // Inside: a lattice of diamonds.
    final field = Path.combine(PathOperation.difference, inner, motifShape);
    const cell = 15.0;
    for (var i = -8; i <= 8; i++) {
      for (var j = -8; j <= 8; j++) {
        final cx = 50 + (i - j) * cell / 2;
        final cy = 50 + (i + j) * cell / 2;
        if (cx < -cell || cx > 100 + cell || cy < -cell || cy > 100 + cell) continue;
        final diamond = Path()
          ..moveTo(cx, cy - cell / 2)
          ..lineTo(cx + cell / 2, cy)
          ..lineTo(cx, cy + cell / 2)
          ..lineTo(cx - cell / 2, cy)
          ..close();
        final piece = Path.combine(PathOperation.intersect, field, diamond);
        if (_Sample.of(piece).area >= 3) out.add(MotifRegion(piece, colors[2 + (i + j).abs() % 2]));
      }
    }
    return out;
  }

  /// Frame (two) and lattice (two) crayons the motif itself uses least.
  static List<int> _backgroundCrayons(Motif base) {
    const candidates = [Crayon.lightBlue, Crayon.lightGreen, Crayon.yellow, Crayon.pink, Crayon.purple, Crayon.blue];
    final used = {for (final r in base.regions) r.crayon};
    final free = [...candidates.where((c) => !used.contains(c)), ...candidates.where(used.contains)];
    return [free[2], free[3], free[0], Crayon.white];
  }

  /// A related crayon, so segments alternate in tone.
  static int _partner(int crayon) => switch (crayon) {
        Crayon.red => Crayon.pink,
        Crayon.orange => Crayon.yellow,
        Crayon.yellow => Crayon.orange,
        Crayon.lightGreen => Crayon.green,
        Crayon.green => Crayon.lightGreen,
        Crayon.lightBlue => Crayon.blue,
        Crayon.blue => Crayon.lightBlue,
        Crayon.purple => Crayon.pink,
        Crayon.pink => Crayon.purple,
        Crayon.brown => Crayon.orange,
        Crayon.grey => Crayon.white,
        Crayon.dark => Crayon.grey,
        _ => Crayon.lightBlue,
      };

  static Path _wedge(Offset c, double from, double to) {
    const r = 200.0;
    final path = Path()..moveTo(c.dx, c.dy);
    const steps = 4;
    for (var s = 0; s <= steps; s++) {
      final a = from + (to - from) * s / steps;
      path.lineTo(c.dx + r * math.cos(a), c.dy + r * math.sin(a));
    }
    return path..close();
  }

  static Float64List _scaleAbout(Offset c, double s) =>
      Float64List.fromList([s, 0, 0, 0, 0, s, 0, 0, 0, 0, 1, 0, c.dx - s * c.dx, c.dy - s * c.dy, 0, 1]);
}

/// Area and centroid of a path, estimated on a half-unit grid.
class _Sample {
  const _Sample(this.area, this.centroid, [this.bounds = Rect.zero]);

  final double area;
  final Offset centroid;
  final Rect bounds;

  static _Sample of(Path path) {
    final b = path.getBounds();
    if (b.isEmpty || !b.isFinite) return const _Sample(0, Offset.zero);
    const step = 0.5;
    var n = 0;
    var sx = 0.0, sy = 0.0;
    for (var y = b.top + step / 2; y < b.bottom; y += step) {
      for (var x = b.left + step / 2; x < b.right; x += step) {
        if (path.contains(Offset(x, y))) {
          n++;
          sx += x;
          sy += y;
        }
      }
    }
    if (n == 0) return const _Sample(0, Offset.zero);
    return _Sample(n * step * step, Offset(sx / n, sy / n), b);
  }
}
