import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../data/repositories.dart';
import '../design/palette.dart';
import '../domain/models.dart';
import '../games/coloring/motif_painter.dart';
import '../games/coloring/motifs.dart';

/// Renders a saved gallery picture (coloring or pixel art) on white.
class ArtworkView extends StatelessWidget {
  const ArtworkView({super.key, required this.item});

  final GalleryItem item;

  @override
  Widget build(BuildContext context) {
    final palette = KpPalette.of(context);
    final colors = [for (final c in item.colors) c == null ? null : Color(c)];
    return AspectRatio(
      aspectRatio: 1,
      child: CustomPaint(
        painter: item.gameId == GameType.pixelArt.id
            ? _PixelArtworkPainter(colors)
            : MotifPainter(motif: Motifs.byId(item.motif), fills: colors, lineColor: palette.ink, lineWidth: 1.6),
      ),
    );
  }
}

class _PixelArtworkPainter extends CustomPainter {
  _PixelArtworkPainter(this.colors);

  final List<Color?> colors;

  @override
  void paint(Canvas canvas, Size size) {
    final n = math.sqrt(colors.length).round();
    if (n == 0) return;
    final cell = size.width / n;
    final paint = Paint();
    for (var i = 0; i < colors.length; i++) {
      final c = colors[i];
      if (c == null) continue;
      // Slight overlap avoids hairline seams between cells.
      canvas.drawRect(Rect.fromLTWH((i % n) * cell, (i ~/ n) * cell, cell + 0.5, cell + 0.5), paint..color = c);
    }
  }

  @override
  bool shouldRepaint(_PixelArtworkPainter old) => old.colors != colors;
}
