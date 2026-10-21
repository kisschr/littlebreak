import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

import '../../design/palette.dart';
import '../../domain/models.dart';
import '../../l10n/generated/app_localizations.dart';
import '../game_framework.dart';

class StackingDefinition extends GameDefinition {
  const StackingDefinition();

  @override
  GameType get type => GameType.stacking;

  static int heightFor(Difficulty d) => switch (d) {
        Difficulty.easy => 8,
        Difficulty.standard => 12,
        Difficulty.advanced => 16,
      };

  @override
  int minutes(Difficulty d) => switch (d) {
        Difficulty.easy => 1,
        Difficulty.standard => 2,
        Difficulty.advanced => 3,
      };

  @override
  String levelDetail(AppLocalizations l, Difficulty d) => l.detailBlocks(heightFor(d), minutes(d));

  @override
  Widget build(BuildContext context, GameSession session) => StackingGame(session: session);
}

/// Tower logic in board units (board width = 1.0).
class Tower {
  Tower({this.baseWidth = 0.6}) {
    blocks.add((left: (1 - baseWidth) / 2, width: baseWidth));
  }

  final double baseWidth;
  final List<({double left, double width})> blocks = [];

  /// Drops a block at [left] with the width of the top block. Returns the
  /// overlap width (0 = missed). A drop within [snap] of perfect counts as
  /// perfect and keeps the full width.
  double drop(double left, {double snap = 0.015}) {
    final top = blocks.last;
    if ((left - top.left).abs() <= snap) {
      blocks.add((left: top.left, width: top.width));
      return top.width;
    }
    final start = math.max(left, top.left);
    final end = math.min(left + top.width, top.left + top.width);
    final overlap = end - start;
    if (overlap <= 0) return 0;
    blocks.add((left: start, width: overlap));
    return overlap;
  }

  /// Placed blocks above the base.
  int get height => blocks.length - 1;
}

class StackingGame extends StatefulWidget {
  const StackingGame({super.key, required this.session});

  final GameSession session;

  @override
  State<StackingGame> createState() => _StackingGameState();
}

class _StackingGameState extends State<StackingGame> with SingleTickerProviderStateMixin {
  late final int target = StackingDefinition.heightFor(widget.session.difficulty);
  late Tower tower;
  late final Ticker _ticker;
  Duration _last = Duration.zero;
  double position = 0;
  double direction = 1;

  GameController get controller => widget.session.controller;

  double get _speed {
    final base = widget.session.byLevel(0.42, 0.55, 0.7) * (widget.session.isKid ? 0.75 : 1);
    return base + tower.height * 0.025;
  }

  @override
  void initState() {
    super.initState();
    tower = Tower(baseWidth: widget.session.isKid ? 0.7 : 0.6);
    _ticker = createTicker(_tick)..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _tick(Duration elapsed) {
    final dt = (elapsed - _last).inMicroseconds / 1e6;
    _last = elapsed;
    if (controller.paused || controller.finished) return;
    final width = tower.blocks.last.width;
    setState(() {
      position += direction * _speed * dt;
      if (position + width >= 1) {
        position = 1 - width;
        direction = -1;
      } else if (position <= 0) {
        position = 0;
        direction = 1;
      }
    });
  }

  void _drop() {
    if (controller.paused || controller.finished) return;
    final overlap = tower.drop(position, snap: widget.session.isKid ? 0.03 : 0.015);
    if (overlap <= 0.02) {
      HapticFeedback.heavyImpact();
      controller.reportMistake();
      setState(() => tower = Tower(baseWidth: tower.baseWidth));
    } else {
      HapticFeedback.lightImpact();
      controller.reportMove();
      setState(() {
        position = direction > 0 ? 0 : 1 - tower.blocks.last.width;
      });
      if (tower.height >= target) controller.complete();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final palette = KpPalette.of(context);
    return Column(
      children: [
        Semantics(
          button: true,
          label: l.stackingHint,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: (_) => _drop(),
            child: GameBoard(
              padding: EdgeInsets.zero,
              child: SizedBox(
                height: 440,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: CustomPaint(
                    size: Size.infinite,
                    painter: _TowerPainter(tower: tower, moving: position, target: target, palette: palette),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        GameStatusLine(parts: [l.heightOf(tower.height, target), l.mistakesCount(controller.mistakes)]),
        const SizedBox(height: 8),
        Text(l.stackingHint, textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w700, color: palette.inkSoft)),
      ],
    );
  }
}

class _TowerPainter extends CustomPainter {
  _TowerPainter({required this.tower, required this.moving, required this.target, required this.palette});

  final Tower tower;
  final double moving;
  final int target;
  final KpPalette palette;

  @override
  void paint(Canvas canvas, Size size) {
    const blockH = 30.0;
    final sky = Offset.zero & size;
    canvas.drawRect(
      sky,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [palette.blobs[3].withValues(alpha: 0.45), palette.board],
        ).createShader(sky),
    );
    final visibleRows = (size.height / blockH).floor() - 3;
    final scroll = math.max(0, tower.blocks.length - visibleRows) * blockH;
    double yFor(int index) => size.height - (index + 1) * blockH + scroll;

    // Target line.
    final ty = yFor(target);
    if (ty > 0) {
      final dash = Paint()
        ..color = palette.accent.withValues(alpha: 0.5)
        ..strokeWidth = 2;
      for (var x = 8.0; x < size.width; x += 16) {
        canvas.drawLine(Offset(x, ty + blockH), Offset(x + 8, ty + blockH), dash);
      }
    }

    final colors = [palette.accent, palette.highlight, palette.success, palette.blobs[0], palette.blobs[3]];
    for (var i = 0; i < tower.blocks.length; i++) {
      final b = tower.blocks[i];
      final y = yFor(i);
      if (y > size.height || y < -blockH) continue;
      _block(canvas, Rect.fromLTWH(b.left * size.width, y, b.width * size.width, blockH - 3), i == 0 ? palette.inkSoft : colors[i % colors.length]);
    }
    final top = tower.blocks.last;
    _block(
      canvas,
      Rect.fromLTWH(moving * size.width, yFor(tower.blocks.length), top.width * size.width, blockH - 3),
      colors[tower.blocks.length % colors.length],
    );
  }

  void _block(Canvas canvas, Rect rect, Color color) {
    final r = RRect.fromRectAndRadius(rect, const Radius.circular(8));
    canvas.drawRRect(r, Paint()..color = color);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(rect.left + 3, rect.top + 3, rect.width - 6, 4), const Radius.circular(2)),
      Paint()..color = Colors.white.withValues(alpha: 0.35),
    );
  }

  @override
  bool shouldRepaint(_TowerPainter old) => true;
}
