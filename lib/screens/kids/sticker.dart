import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

import '../../core/seeded_random.dart';
import '../../design/components.dart';
import '../../design/icons.dart';
import '../../design/palette.dart';
import '../../games/coloring/coloring_game.dart';
import '../../games/coloring/motif_painter.dart';
import '../../games/coloring/motifs.dart';
import '../../games/game_framework.dart';
import '../../games/game_widgets.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../l10n/texts.dart';
import '../../widgets/dialog.dart';

/// The picture on a day's sticker: every other one a seasonal motif of the
/// month, the rest from the whole set, always the same for the same day.
abstract final class Stickers {
  static const _all = [
    'pumpkin', 'heart', 'flower', 'star', 'tree', 'lantern', 'mask', 'egg', 'leaf', 'mushroom', 'house', //
    'fish', 'snowman', 'sun', 'butterfly', 'hedgehog', 'icecream', 'sailboat', 'umbrella',
  ];

  static String motifFor(DateTime day) {
    final random = SeededRandom.fromParts(['sticker', day.year, day.month, day.day]);
    final seasonal = Motifs.byMonth[day.month] ?? _all;
    return random.nextBool() ? seasonal[random.nextInt(seasonal.length)] : _all[random.nextInt(_all.length)];
  }

  /// The motif fully coloured the way it is meant to be.
  static List<Color?> colorsOf(Motif motif) => [for (final r in motif.regions) kCrayons[r.crayon]];

  static Color backgroundFor(DateTime day, KpPalette palette) {
    final colors = [palette.highlight, palette.blobs[2], palette.successSoft, palette.blobs[3], palette.accent];
    return Color.lerp(colors[day.day % colors.length], Colors.white, 0.55)!;
  }
}

/// A round sticker with its motif; tapping it opens [showSticker].
class StickerBadge extends StatelessWidget {
  const StickerBadge({super.key, required this.day, this.size = 48, this.onTap});

  final DateTime day;
  final double size;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final palette = KpPalette.of(context);
    final motif = Motifs.byId(Stickers.motifFor(day));
    final badge = Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(size * 0.14),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Stickers.backgroundFor(day, palette),
        border: Border.all(color: Colors.white, width: size * 0.065),
        boxShadow: [
          BoxShadow(
            color: palette.ink.withValues(alpha: 0.12),
            blurRadius: size * 0.12,
            offset: Offset(0, size * 0.04),
          ),
        ],
      ),
      child: CustomPaint(
        painter: MotifPainter(
          motif: motif,
          fills: Stickers.colorsOf(motif),
          lineColor: palette.ink,
          lineWidth: size < 80 ? 3.2 : 1.8,
        ),
      ),
    );
    if (onTap == null) return badge;
    return GestureDetector(behavior: HitTestBehavior.opaque, onTap: onTap, child: badge);
  }
}

/// Shows a sticker big, with a little wiggle, and offers to colour it in.
Future<void> showSticker(BuildContext context, DateTime day) {
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: const Color(0x52000000),
    transitionDuration: const Duration(milliseconds: 420),
    pageBuilder: (_, _, _) => _StickerView(day: day),
    transitionBuilder: (_, animation, _, child) => FadeTransition(
      opacity: CurvedAnimation(parent: animation, curve: const Interval(0, 0.5)),
      child: ScaleTransition(
        scale: Tween(begin: 0.6, end: 1.0).animate(CurvedAnimation(parent: animation, curve: Curves.elasticOut)),
        child: child,
      ),
    ),
  );
}

class _StickerView extends StatefulWidget {
  const _StickerView({required this.day});

  final DateTime day;

  @override
  State<_StickerView> createState() => _StickerViewState();
}

class _StickerViewState extends State<_StickerView> with TickerProviderStateMixin {
  late final AnimationController _wiggle = AnimationController(vsync: this, duration: const Duration(seconds: 3));
  late final AnimationController _boing = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (reduceMotion) {
      _wiggle.stop();
    } else if (!_wiggle.isAnimating) {
      _wiggle.repeat();
    }
  }

  @override
  void dispose() {
    _wiggle.dispose();
    _boing.dispose();
    super.dispose();
  }

  void _tapSticker() {
    HapticFeedback.lightImpact();
    _boing.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final palette = KpPalette.of(context);
    final motifId = Stickers.motifFor(widget.day);
    final date = DateFormat.MMMMd(Localizations.localeOf(context).toLanguageTag()).format(widget.day);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Material(
            type: MaterialType.transparency,
            child: GlassCard(
              useOwnLayer: true,
              quality: GlassQuality.standard,
              settings: KpGlassStyle.dialog,
              shape: const LiquidRoundedSuperellipse(borderRadius: 36),
              padding: const EdgeInsets.fromLTRB(22, 18, 22, 22),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: KpSoftButton(
                      size: 40,
                      semanticLabel: l.close,
                      onPressed: () => Navigator.of(context).pop(),
                      child: KpIcon(KpIcons.close, size: 18, color: palette.ink, strokeWidth: 2.5),
                    ),
                  ),
                  Semantics(
                    button: true,
                    label: l.motifName(motifId),
                    child: GestureDetector(
                      onTap: _tapSticker,
                      child: AnimatedBuilder(
                        animation: Listenable.merge([_wiggle, _boing]),
                        builder: (context, child) {
                          final t = _wiggle.value * 2 * math.pi;
                          final boing = math.sin(_boing.value * math.pi) * (1 - _boing.value);
                          return Transform.translate(
                            offset: Offset(0, math.sin(t * 2) * 4 - boing * 26),
                            child: Transform.rotate(
                              angle: math.sin(t) * 0.06,
                              child: Transform.scale(scale: 1 + boing * 0.12, child: child),
                            ),
                          );
                        },
                        child: Center(child: StickerBadge(day: widget.day, size: 200)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  KpFitText(
                    l.motifName(motifId),
                    textAlign: TextAlign.center,
                    style: KpText.display(palette.ink, size: 32),
                  ),
                  const SizedBox(height: 4),
                  Text(l.stickerFor(date), textAlign: TextAlign.center, style: KpText.label(palette.inkSoft, size: 16)),
                  const SizedBox(height: 20),
                  KpPrimaryButton(
                    label: l.stickerColorIn,
                    color: palette.success,
                    icon: const KpIcon(KpIcons.palette, size: 22, color: Colors.white),
                    onPressed: () {
                      final navigator = Navigator.of(context)..pop();
                      navigator.push(FreeColoringScreen.route(motifId));
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Free colouring of one motif, outside the daily games: no levels, no
/// score, every crayon of the box.
class FreeColoringScreen extends StatefulWidget {
  const FreeColoringScreen({super.key, required this.motifId});

  final String motifId;

  static Route<void> route(String motifId) =>
      MaterialPageRoute<void>(builder: (_) => FreeColoringScreen(motifId: motifId));

  @override
  State<FreeColoringScreen> createState() => _FreeColoringScreenState();
}

class _FreeColoringScreenState extends State<FreeColoringScreen> {
  late final Motif motif = Motifs.byId(widget.motifId);
  late List<int?> fills = List<int?>.filled(motif.regions.length, null);
  final List<List<int?>> _history = [];
  int selected = 0;

  void _paint(Offset local, double side) {
    final region = motif.regionAt(local / side * Motif.size);
    if (region == null || fills[region] == selected) return;
    HapticFeedback.selectionClick();
    setState(() {
      _history.add(List.of(fills));
      fills[region] = selected;
    });
  }

  void _undo() {
    if (_history.isEmpty) return;
    setState(() => fills = _history.removeLast());
  }

  Future<void> _done() async {
    final l = AppLocalizations.of(context);
    await KpDialog.show<void>(
      context: context,
      title: l.stickerColoredTitle,
      message: l.stickerColoredBody,
      actions: [KpDialogAction(label: l.ok, isPrimary: true, onPressed: () => Navigator.of(context).pop())],
    );
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final palette = KpPalette.of(context);
    final insets = MediaQuery.paddingOf(context);
    final side = kpSideInset(context, 16);
    return GlassScaffold(
      settings: KpGlassStyle.of(context),
      background: const KpBackground(variant: 1),
      body: ListView(
        padding: EdgeInsets.fromLTRB(side, insets.top + 12, side, insets.bottom + 24),
        children: [
          Row(
            children: [
              KpGlassButton(
                semanticLabel: l.close,
                onPressed: () => Navigator.of(context).pop(),
                child: const KpCloseIcon(),
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(l.motifName(widget.motifId), style: KpText.title(palette.ink, size: 24))),
            ],
          ),
          const SizedBox(height: 18),
          GameBoard(
            padding: const EdgeInsets.all(14),
            child: AspectRatio(
              aspectRatio: 1,
              child: LayoutBuilder(
                builder: (context, c) => GestureDetector(
                  onTapUp: (d) => _paint(d.localPosition, c.maxWidth),
                  child: Semantics(
                    label: l.coloringLabel,
                    child: CustomPaint(
                      size: Size.square(c.maxWidth),
                      painter: MotifPainter(
                        motif: motif,
                        fills: [for (final f in fills) f == null ? null : kCrayons[f]],
                        lineColor: palette.ink,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 10,
            children: [
              for (var k = 0; k < kCrayons.length; k++)
                CrayonDot(
                  size: 40,
                  color: kCrayons[k],
                  selected: selected == k,
                  semanticLabel: l.colorNumber(k + 1),
                  onTap: () => setState(() => selected = k),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: GlassActionPill(icon: KpIcons.undo, label: l.undo, onTap: _history.isEmpty ? null : _undo),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GlassActionPill(
                  icon: KpIcons.check,
                  label: l.done,
                  onTap: fills.any((f) => f != null) ? _done : null,
                  active: fills.every((f) => f != null),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
