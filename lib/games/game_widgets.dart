import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

import '../design/components.dart';
import '../design/icons.dart';
import '../design/palette.dart';

/// A free glass key (digit pad, letters, answers). Glass sits directly on
/// the background, never inside a glass card.
class GlassKey extends StatelessWidget {
  const GlassKey({
    super.key,
    required this.child,
    required this.onTap,
    this.height = 64,
    this.width,
    this.radius = 20,
    this.semanticLabel,
    this.selected = false,
  });

  final Widget child;
  final VoidCallback? onTap;
  final double height;
  final double? width;
  final double radius;
  final String? semanticLabel;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final palette = KpPalette.of(context);
    final isKids = palette == KpPalette.kids;
    final base = isKids ? KpGlassStyle.kidsSurface : KpGlassStyle.surface;
    return Semantics(
      button: true,
      selected: selected,
      label: semanticLabel,
      excludeSemantics: semanticLabel != null,
      child: GlassButton.custom(
        onTap: onTap ?? () {},
        enabled: onTap != null,
        width: width,
        height: height,
        shape: LiquidRoundedSuperellipse(borderRadius: radius),
        settings: selected
            ? LiquidGlassSettings(
                glassColor: palette.highlight.withValues(alpha: 0.55),
                blur: base.blur,
                thickness: base.thickness,
                lightIntensity: base.lightIntensity,
                saturation: base.saturation,
              )
            : base,
        label: semanticLabel ?? '',
        child: DefaultTextStyle(
          style: KpText.title(palette.ink, size: 28),
          child: Center(child: child),
        ),
      ),
    );
  }
}

/// Glass action pill with icon and label ("Löschen", "Notizen").
class GlassActionPill extends StatelessWidget {
  const GlassActionPill({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.active = false,
  });

  final KpIcons icon;
  final String label;
  final VoidCallback? onTap;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final palette = KpPalette.of(context);
    final color = active ? palette.accent : palette.ink;
    return GlassKey(
      height: 52,
      radius: 26,
      onTap: onTap,
      selected: active,
      semanticLabel: label,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          KpIcon(icon, size: 18, color: color),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: KpText.label(color, size: 15),
            ),
          ),
        ],
      ),
    );
  }
}

/// Opaque answer button for quiz-like games (white card, accent on select).
class AnswerButton extends StatelessWidget {
  const AnswerButton({
    super.key,
    required this.label,
    required this.onTap,
    this.state = AnswerState.idle,
    this.minHeight = 60,
  });

  final String label;
  final VoidCallback? onTap;
  final AnswerState state;
  final double minHeight;

  @override
  Widget build(BuildContext context) {
    final palette = KpPalette.of(context);
    final (bg, fg, border) = switch (state) {
      AnswerState.idle => (Colors.white.withValues(alpha: 0.85), palette.ink, Colors.white),
      AnswerState.correct => (palette.success, Colors.white, palette.success),
      AnswerState.wrong => (const Color(0xFFB3261E), Colors.white, const Color(0xFFB3261E)),
      AnswerState.dimmed => (Colors.white.withValues(alpha: 0.45), palette.inkSoft, Colors.white.withValues(alpha: 0.6)),
    };
    return Semantics(
      button: true,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          constraints: BoxConstraints(minHeight: minHeight),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: border, width: 2),
          ),
          alignment: Alignment.center,
          child: Text(label, textAlign: TextAlign.center, style: KpText.label(fg, size: 17, weight: FontWeight.w800)),
        ),
      ),
    );
  }
}

enum AnswerState { idle, correct, wrong, dimmed }

/// Text style for cells of opaque boards.
TextStyle boardDigitStyle(KpPalette palette, {required bool given, double size = 26}) => TextStyle(
      fontFamily: 'Nunito',
      fontSize: size,
      fontWeight: given ? FontWeight.w900 : FontWeight.w700,
      color: given ? palette.ink : palette.accent,
      height: 1,
    );

/// Error red used on boards.
const Color kpErrorColor = Color(0xFFB3261E);
