import 'package:flutter/material.dart';

import '../../core/dates.dart';
import '../../data/repositories.dart';
import '../../design/components.dart';
import '../../design/icons.dart';
import '../../design/palette.dart';
import '../../domain/models.dart';
import '../../l10n/generated/app_localizations.dart';
import '../game_framework.dart';
import '../game_widgets.dart';
import 'motif_painter.dart';
import 'motifs.dart';

class ColoringDefinition extends GameDefinition {
  const ColoringDefinition();

  @override
  GameType get type => GameType.coloring;

  /// Crayons offered in the free modes.
  static List<int> crayonsFor(Difficulty d) => switch (d) {
        Difficulty.easy => const [Crayon.red, Crayon.orange, Crayon.yellow, Crayon.green, Crayon.blue, Crayon.pink],
        _ => [for (var i = 0; i < kCrayons.length; i++) i],
      };

  @override
  int minutes(Difficulty d) => switch (d) {
        Difficulty.easy => 3,
        Difficulty.standard => 5,
        Difficulty.advanced => 6,
      };

  @override
  String levelDetail(AppLocalizations l, Difficulty d) => d == Difficulty.advanced
      ? l.detailPaintByNumbers(minutes(d))
      : l.detailColoring(crayonsFor(d).length, minutes(d));

  @override
  bool get usesHints => true;

  @override
  bool get showsTimer => false;

  @override
  Widget build(BuildContext context, GameSession session) => ColoringGame(session: session);
}

class ColoringGame extends StatefulWidget {
  const ColoringGame({super.key, required this.session});

  final GameSession session;

  @override
  State<ColoringGame> createState() => _ColoringGameState();
}

class _ColoringGameState extends State<ColoringGame> {
  late final Motif motif;
  late final bool byNumbers = widget.session.difficulty == Difficulty.advanced;

  /// Crayon index per region; null = empty.
  late List<int?> fills;
  final List<List<int?>> _history = [];

  /// The crayons on offer; in paint-by-numbers mode their position + 1 is
  /// the number printed in the regions.
  late final List<int> crayons;
  late int selected;

  GameController get controller => widget.session.controller;

  @override
  void initState() {
    super.initState();
    final s = widget.session;
    motif = Motifs.byId(Motifs.pageFor(s.plan, s.audience));
    fills = List<int?>.filled(motif.regions.length, null);
    crayons = byNumbers
        ? (motif.regions.map((r) => r.crayon).toSet().toList()..sort())
        : ColoringDefinition.crayonsFor(s.difficulty);
    selected = crayons.first;
    controller.setHintHandler(_hint);
  }

  int? _numberOf(int region) => crayons.indexOf(motif.regions[region].crayon) + 1;

  bool get _allFilled => fills.skip(motif.optional).every((f) => f != null);

  void _paint(Offset local, double side) {
    if (controller.paused || controller.finished) return;
    final region = motif.regionAt(local / side * Motif.size);
    if (region == null || fills[region] == selected) return;
    if (byNumbers && motif.regions[region].crayon != selected) {
      controller.reportMistake();
      return;
    }
    setState(() {
      _history.add(List.of(fills));
      fills[region] = selected;
    });
    if (byNumbers && _allFilled) _finish();
  }

  bool _hint() {
    // Colours one empty region the way the motif intends.
    final i = fills.indexWhere((f) => f == null, motif.optional);
    if (i < 0) return false;
    setState(() {
      _history.add(List.of(fills));
      fills[i] = motif.regions[i].crayon;
    });
    if (byNumbers && _allFilled) _finish();
    return true;
  }

  void _undo() {
    if (_history.isEmpty) return;
    setState(() => fills = _history.removeLast());
  }

  void _finish() {
    final s = widget.session;
    controller.complete(GameOutcome(
      stars: byNumbers ? null : 3,
      artwork: GalleryItem(
        dateKey: dateKey(s.plan.date),
        gameId: s.plan.type.id,
        motif: motif.id,
        difficulty: s.difficulty,
        colors: [for (final f in fills) f == null ? null : kCrayons[f].toARGB32()],
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final palette = KpPalette.of(context);
    final colors = [for (final f in fills) f == null ? null : kCrayons[f]];
    return Column(
      children: [
        GameBoard(
          padding: const EdgeInsets.all(14),
          child: AspectRatio(
            aspectRatio: 1,
            child: LayoutBuilder(
              builder: (context, c) {
                final page = GestureDetector(
                  onTapUp: (d) => _paint(d.localPosition, c.maxWidth),
                  child: Semantics(
                    label: l.coloringLabel,
                    child: CustomPaint(
                      size: Size.square(c.maxWidth),
                      painter: MotifPainter(
                        motif: motif,
                        fills: colors,
                        lineColor: palette.ink,
                        numbers: byNumbers ? [for (var i = 0; i < fills.length; i++) _numberOf(i)] : null,
                        numberColor: palette.inkSoft,
                      ),
                    ),
                  ),
                );
                // Detailed pages have small areas: pinch to zoom in.
                return motif.fine ? InteractiveViewer(maxScale: 5, child: page) : page;
              },
            ),
          ),
        ),
        const SizedBox(height: 16),
        // The full box of 13 crayons fits as 7 + 6 on a phone.
        Wrap(
          alignment: WrapAlignment.center,
          spacing: crayons.length > 6 ? 8 : 10,
          runSpacing: 10,
          children: [
            for (var k = 0; k < crayons.length; k++)
              CrayonDot(
                size: crayons.length > 6 ? 40 : 44,
                color: kCrayons[crayons[k]],
                selected: selected == crayons[k],
                label: byNumbers ? '${k + 1}' : null,
                semanticLabel: l.colorNumber(k + 1),
                onTap: () => setState(() => selected = crayons[k]),
              ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: GlassActionPill(icon: KpIcons.undo, label: l.undo, onTap: _history.isEmpty ? null : _undo),
            ),
            if (!byNumbers) ...[
              const SizedBox(width: 10),
              Expanded(
                child: GlassActionPill(
                  icon: KpIcons.check,
                  label: l.done,
                  onTap: _allFilled ? _finish : null,
                  active: _allFilled,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 10),
        ListenableBuilder(
          listenable: controller,
          builder: (context, _) => GameStatusLine(
            parts: [
              l.areasColored(fills.where((f) => f != null).length, fills.length),
              if (byNumbers) l.mistakesCount(controller.mistakes),
            ],
          ),
        ),
      ],
    );
  }
}

/// A round crayon swatch; selected = ring in ink.
class CrayonDot extends StatelessWidget {
  const CrayonDot({
    super.key,
    required this.color,
    required this.selected,
    required this.onTap,
    required this.semanticLabel,
    this.label,
    this.size = 44,
  });

  final Color color;
  final bool selected;
  final VoidCallback onTap;
  final String semanticLabel;
  final String? label;
  final double size;

  @override
  Widget build(BuildContext context) {
    final palette = KpPalette.of(context);
    final light = color.computeLuminance() > 0.55;
    return Semantics(
      button: true,
      selected: selected,
      label: semanticLabel,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: size,
          height: size,
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: selected ? palette.ink : Colors.white.withValues(alpha: 0.7),
              width: selected ? 3 : 2,
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: color == Colors.white || light ? Border.all(color: palette.boardLine) : null,
            ),
            alignment: Alignment.center,
            child: label == null
                ? null
                : Text(
                    label!,
                    style: KpText.label(light ? palette.ink : Colors.white, size: 16, weight: FontWeight.w900),
                  ),
          ),
        ),
      ),
    );
  }
}
