import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

import 'icons.dart';
import 'palette.dart';

/// Design tokens and the few wrappers around liquid_glass_widgets that every
/// screen uses. Keeping the package behind these wrappers means a package
/// update touches this file only.
abstract final class KpGlassStyle {
  /// Matches the designs' CSS glass: white at 28 % over a strong blur.
  /// Settings for a page's glass layer. Grouped glass (cards, buttons) on
  /// the page inherits them; per-widget settings only apply with own layers.
  static LiquidGlassSettings of(BuildContext context) =>
      KpPalette.of(context) == KpPalette.kids ? kidsSurface : surface;

  static const LiquidGlassSettings surface = LiquidGlassSettings(
    glassColor: Color(0x47FFFFFF),
    blur: 14,
    thickness: 18,
    lightIntensity: 0.6,
    saturation: 1.7,
    refractiveIndex: 1.15,
    ambientStrength: 0.25,
  );

  /// Slightly brighter glass for the kids profile (32 %).
  static const LiquidGlassSettings kidsSurface = LiquidGlassSettings(
    glassColor: Color(0x52FFFFFF),
    blur: 14,
    thickness: 18,
    lightIntensity: 0.6,
    saturation: 1.7,
    refractiveIndex: 1.15,
    ambientStrength: 0.25,
  );

  /// The bright sheet glass of the level picker (rgba(255,248,240,.62)).
  /// Corner radius of the floating sheets in the designs (all four corners;
  /// the package would otherwise follow the device's screen corners).
  static const double sheetRadius = 40;

  static const LiquidGlassSettings sheet = LiquidGlassSettings(
    glassColor: Color(0x9EFFF8F0),
    blur: 18,
    thickness: 22,
    lightIntensity: 0.6,
    saturation: 1.6,
  );

  /// Dialogs: the sheet glass, but nearly opaque so text reads over anything.
  static const LiquidGlassSettings dialog = LiquidGlassSettings(
    glassColor: Color(0xE0FFF8F0),
    blur: 18,
    thickness: 22,
    lightIntensity: 0.6,
    saturation: 1.6,
  );
}

/// Side margin that keeps content at most [maxWidth] wide and centred, so
/// phone layouts stay phone-sized on tablets; [base] on phones.
double kpSideInset(BuildContext context, double base, {double maxWidth = kpContentWidth}) =>
    math.max(base, (MediaQuery.sizeOf(context).width - maxWidth) / 2);

/// Widest column of content on tablets.
const double kpContentWidth = 620;

/// Text styles of the designs (Nunito, heavy weights).
abstract final class KpText {
  static TextStyle display(Color color, {double size = 36}) => TextStyle(
    fontFamily: 'Nunito',
    fontSize: size,
    fontWeight: FontWeight.w900,
    letterSpacing: -0.5,
    height: 1.05,
    color: color,
  );

  static TextStyle title(Color color, {double size = 22}) =>
      TextStyle(fontFamily: 'Nunito', fontSize: size, fontWeight: FontWeight.w900, color: color, height: 1.15);

  static TextStyle label(Color color, {double size = 15, FontWeight weight = FontWeight.w800}) =>
      TextStyle(fontFamily: 'Nunito', fontSize: size, fontWeight: weight, color: color, height: 1.25);

  static TextStyle body(Color color, {double size = 16, FontWeight weight = FontWeight.w600}) =>
      TextStyle(fontFamily: 'Nunito', fontSize: size, fontWeight: weight, color: color, height: 1.4);
}

/// The coloured background with soft, slowly drifting blobs.
class KpBackground extends StatefulWidget {
  const KpBackground({super.key, this.variant = 0});

  /// Selects one of the blob layouts of the designs.
  final int variant;

  @override
  State<KpBackground> createState() => _KpBackgroundState();
}

class _KpBackgroundState extends State<KpBackground> with SingleTickerProviderStateMixin {
  late final AnimationController _drift = AnimationController(vsync: this, duration: const Duration(seconds: 24));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    // Every drift frame re-renders all glass above the blobs. While a sheet
    // or dialog covers the screen that is wasted work and makes the sheet
    // stutter, so the blobs rest until their screen is on top again.
    final covered = !(ModalRoute.of(context)?.isCurrent ?? true);
    if (reduceMotion || covered) {
      _drift.stop();
    } else if (!_drift.isAnimating) {
      _drift.repeat();
    }
  }

  @override
  void dispose() {
    _drift.dispose();
    super.dispose();
  }

  // Blob layouts copied from the artboards: (left/right, top/bottom, size).
  static const _layouts = <List<_Blob>>[
    [
      _Blob(left: -130, top: -90, size: 360, color: 0),
      _Blob(right: -170, top: 210, size: 400, color: 1),
      _Blob(left: -110, bottom: -130, size: 380, color: 2),
      _Blob(right: -70, bottom: 60, size: 280, color: 3),
    ],
    [
      _Blob(right: -150, top: -100, size: 380, color: 0),
      _Blob(left: -180, top: 260, size: 400, color: 1),
      _Blob(right: -90, bottom: 40, size: 300, color: 3),
    ],
    [
      _Blob(left: -160, top: -120, size: 420, color: 0),
      _Blob(right: -150, top: 300, size: 380, color: 3),
      _Blob(left: -100, bottom: -110, size: 360, color: 1),
    ],
    [
      _Blob(left: -120, top: -140, size: 420, color: 1),
      _Blob(right: -160, top: 120, size: 380, color: 0),
      _Blob(left: -90, bottom: 40, size: 300, color: 3),
    ],
  ];

  @override
  Widget build(BuildContext context) {
    final palette = KpPalette.of(context);
    final blobs = _layouts[widget.variant % _layouts.length];
    return RepaintBoundary(
      child: ColoredBox(
        color: palette.background,
        child: AnimatedBuilder(
          animation: _drift,
          builder: (context, _) {
            final t = _drift.value * 2 * math.pi;
            return Stack(
              fit: StackFit.expand,
              children: [
                for (var i = 0; i < blobs.length; i++)
                  blobs[i].build(
                    palette.blobs[blobs[i].color % palette.blobs.length],
                    Offset(math.sin(t + i * 1.7) * 18, math.cos(t + i * 1.3) * 14),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Blob {
  const _Blob({this.left, this.right, this.top, this.bottom, required this.size, required this.color});

  final double? left;
  final double? right;
  final double? top;
  final double? bottom;
  final double size;
  final int color;

  Widget build(Color c, Offset drift) => Positioned(
    left: left == null ? null : left! + drift.dx,
    right: right == null ? null : right! - drift.dx,
    top: top == null ? null : top! + drift.dy,
    bottom: bottom == null ? null : bottom! - drift.dy,
    width: size,
    height: size,
    child: DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [c, c.withValues(alpha: 0)], stops: const [0, 0.7]),
      ),
    ),
  );
}

/// A glass platter (GlassCard) with the designs' radius and padding.
///
/// Only text, icons and opaque controls go inside; free glass buttons live
/// outside (liquid_glass_widgets: "glass is a platter, not a wrapper").
class KpGlassCard extends StatelessWidget {
  const KpGlassCard({
    super.key,
    required this.child,
    this.radius = 26,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    this.semanticLabel,
    this.settings,
  });

  final Widget child;
  final double radius;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final String? semanticLabel;
  final LiquidGlassSettings? settings;

  @override
  Widget build(BuildContext context) {
    final isKids = KpPalette.of(context) == KpPalette.kids;
    Widget card = GlassCard(
      shape: LiquidRoundedSuperellipse(borderRadius: radius),
      padding: padding,
      settings: settings ?? (isKids ? KpGlassStyle.kidsSurface : KpGlassStyle.surface),
      child: child,
    );
    if (onTap != null) {
      card = Semantics(
        button: true,
        label: semanticLabel,
        child: _Pressable(onTap: onTap!, child: card),
      );
    }
    return card;
  }
}

/// Scale-down feedback for tappable surfaces without their own glass physics.
class _Pressable extends StatefulWidget {
  const _Pressable({required this.onTap, required this.child});

  final VoidCallback onTap;
  final Widget child;

  @override
  State<_Pressable> createState() => _PressableState();
}

class _PressableState extends State<_Pressable> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _down = true),
      onTapCancel: () => setState(() => _down = false),
      onTapUp: (_) => setState(() => _down = false),
      onTap: () {
        HapticFeedback.selectionClick();
        widget.onTap();
      },
      child: AnimatedScale(scale: _down ? 0.97 : 1, duration: const Duration(milliseconds: 120), child: widget.child),
    );
  }
}

/// Opaque primary button (copper in October, teal for kids).
class KpPrimaryButton extends StatelessWidget {
  const KpPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.height = 58,
    this.fontSize = 19,
    this.color,
    this.expand = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final Widget? icon;
  final double height;
  final double fontSize;
  final Color? color;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final palette = KpPalette.of(context);
    final bg = color ?? palette.accent;
    final enabled = onPressed != null;
    final child = Container(
      height: height,
      width: expand ? double.infinity : null,
      padding: EdgeInsets.symmetric(horizontal: height / 2.4),
      decoration: BoxDecoration(
        color: enabled ? bg : bg.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(height / 2),
        boxShadow: enabled
            ? [BoxShadow(color: bg.withValues(alpha: 0.35), blurRadius: 20, offset: const Offset(0, 8))]
            : null,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color.lerp(bg, Colors.white, 0.08)!, bg],
          stops: const [0, 0.06],
        ),
      ),
      alignment: Alignment.center,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            IconTheme(
              data: const IconThemeData(color: Colors.white),
              child: icon!,
            ),
            const SizedBox(width: 10),
          ],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: KpText.title(Colors.white, size: fontSize),
            ),
          ),
        ],
      ),
    );
    return Semantics(
      button: true,
      enabled: enabled,
      child: enabled ? _Pressable(onTap: onPressed!, child: child) : child,
    );
  }
}

/// Opaque light button used inside glass cards (e.g. the close button).
class KpSoftButton extends StatelessWidget {
  const KpSoftButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.size = 44,
    this.semanticLabel,
    this.opacity = 0.7,
  });

  final Widget child;
  final VoidCallback? onPressed;
  final double size;
  final String? semanticLabel;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    final body = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: opacity),
        borderRadius: BorderRadius.circular(size / 2),
      ),
      alignment: Alignment.center,
      child: child,
    );
    return Semantics(
      button: true,
      label: semanticLabel,
      child: onPressed == null ? body : _Pressable(onTap: onPressed!, child: body),
    );
  }
}

/// A free-standing glass pill or circle (GlassButton.custom).
class KpGlassButton extends StatelessWidget {
  const KpGlassButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.width,
    this.height = 44,
    this.semanticLabel,
    this.pill = false,
  });

  final Widget child;
  final VoidCallback? onPressed;
  final double? width;
  final double height;
  final String? semanticLabel;

  /// Sizes to the child (with horizontal padding) instead of a circle.
  final bool pill;

  @override
  Widget build(BuildContext context) {
    final isKids = KpPalette.of(context) == KpPalette.kids;
    return Semantics(
      label: semanticLabel,
      button: true,
      excludeSemantics: semanticLabel != null,
      child: GlassButton.custom(
        onTap: onPressed ?? () {},
        enabled: onPressed != null,
        width: pill ? width : width ?? height,
        height: height,
        shape: LiquidRoundedSuperellipse(borderRadius: height / 2),
        settings: isKids ? KpGlassStyle.kidsSurface : KpGlassStyle.surface,
        label: semanticLabel ?? '',
        child: pill ? Padding(padding: const EdgeInsets.symmetric(horizontal: 14), child: child) : child,
      ),
    );
  }
}

/// Small rounded label on a card, e.g. "Tag 288 · Logik".
class KpChip extends StatelessWidget {
  const KpChip({
    super.key,
    required this.label,
    this.icon,
    this.background,
    this.foreground,
    this.fontSize = 14,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
  });

  final String label;
  final Widget? icon;
  final Color? background;
  final Color? foreground;
  final double fontSize;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final palette = KpPalette.of(context);
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: background ?? Colors.white.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[icon!, const SizedBox(width: 6)],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: KpText.label(foreground ?? palette.ink, size: fontSize, weight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

/// Round avatar with the profile's initial.
class KpAvatar extends StatelessWidget {
  const KpAvatar({super.key, required this.initial, required this.color, this.size = 72});

  final String initial;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color.lerp(color, Colors.white, 0.12)!, color],
          stops: const [0, 0.08],
        ),
      ),
      alignment: Alignment.center,
      child: Text(initial, style: KpText.title(Colors.white, size: size * 0.42)),
    );
  }
}

/// Avatar colours available for profiles.
const List<Color> kpAvatarColors = [
  Color(0xFF9E4421),
  Color(0xFF1F7A6A),
  Color(0xFF2F5D8A),
  Color(0xFF8E3B6A),
  Color(0xFF7A5418),
  Color(0xFF4F7A28),
];

/// Row of 0–3 stars.
class KpStarRow extends StatelessWidget {
  const KpStarRow({super.key, required this.count, this.size = 18, this.spacing = 2});

  final int count;
  final double size;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    final palette = KpPalette.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < 3; i++) ...[
          if (i > 0) SizedBox(width: spacing),
          KpStar(filled: i < count, size: size, stroke: palette.accent, fill: palette.highlight),
        ],
      ],
    );
  }
}

/// Standard close glyph used in glass buttons.
class KpCloseIcon extends StatelessWidget {
  const KpCloseIcon({super.key, this.size = 18});

  final double size;

  @override
  Widget build(BuildContext context) =>
      KpIcon(KpIcons.close, size: size, strokeWidth: 2.5, color: KpPalette.of(context).ink);
}

/// Dashed rounded outline ("Nachholen" days, the ad frame).
class DashedRRectPainter extends CustomPainter {
  DashedRRectPainter({required this.color, required this.radius, this.strokeWidth = 1.5, this.dash = 5, this.gap = 4});

  final Color color;
  final double radius;
  final double strokeWidth;
  final double dash;
  final double gap;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    final inset = strokeWidth / 2;
    final rect = Rect.fromLTWH(inset, inset, size.width - strokeWidth, size.height - strokeWidth);
    final path = Path()..addRRect(RRect.fromRectAndRadius(rect, Radius.circular(radius)));
    for (final metric in path.computeMetrics()) {
      for (var d = 0.0; d < metric.length; d += dash + gap) {
        canvas.drawPath(metric.extractPath(d, d + dash), paint);
      }
    }
  }

  @override
  bool shouldRepaint(DashedRRectPainter old) => old.color != color || old.radius != radius;
}

/// Filled play triangle of the start buttons.
class KpPlayGlyph extends StatelessWidget {
  const KpPlayGlyph({super.key, this.size = 18});

  final double size;

  @override
  Widget build(BuildContext context) => CustomPaint(size: Size.square(size), painter: _PlayPainter());
}

class _PlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 24;
    canvas.drawPath(
      Path()
        ..moveTo(7 * s, 4 * s)
        ..lineTo(20 * s, 12 * s)
        ..lineTo(7 * s, 20 * s)
        ..close(),
      Paint()..color = Colors.white,
    );
  }

  @override
  bool shouldRepaint(_PlayPainter old) => false;
}

/// Big text that never breaks inside a word: when its longest word is wider
/// than the space ("Zahlenpyramide" next to a thumbnail), the font shrinks
/// until that word fits on one line.
class KpFitText extends StatelessWidget {
  const KpFitText(this.text, {super.key, required this.style, this.textAlign});

  final String text;
  final TextStyle style;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final scaler = MediaQuery.textScalerOf(context);
        var widest = 0.0;
        for (final word in text.split(RegExp(r'\s+'))) {
          final painter = TextPainter(
            text: TextSpan(text: word, style: style),
            textDirection: TextDirection.ltr,
            textScaler: scaler,
          )..layout();
          widest = math.max(widest, painter.width);
          painter.dispose();
        }
        final fitted = widest > constraints.maxWidth
            ? style.copyWith(fontSize: (style.fontSize ?? 14) * constraints.maxWidth / widest * 0.98)
            : style;
        return Text(text, style: fitted, textAlign: textAlign);
      },
    );
  }
}
