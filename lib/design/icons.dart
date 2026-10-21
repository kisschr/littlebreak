import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// The stroke icons of the UI designs, drawn from their original SVG paths.
///
/// Each icon is a 24×24 path set that is coloured via [KpIcon.color]
/// (`currentColor` in the markup).
enum KpIcons {
  sun(
      '<circle cx="12" cy="12" r="4"/><path d="M12 2v2M12 20v2M4.9 4.9l1.4 1.4M17.7 17.7l1.4 1.4M2 12h2M20 12h2M4.9 19.1l1.4-1.4M17.7 6.3l1.4-1.4"/>'),
  calendar('<rect x="3" y="5" width="18" height="16" rx="3"/><path d="M3 10h18M8 3v4M16 3v4"/>'),
  gallery('<rect x="3" y="4" width="18" height="16" rx="3"/><circle cx="9" cy="10" r="2"/><path d="M21 16l-5-5-9 9"/>'),
  person('<circle cx="12" cy="8" r="4"/><path d="M4 21c1-4 4-6 8-6s7 2 8 6"/>'),
  flame('<path d="M12 3c1 3 4 5 4 9a4 4 0 0 1-8 0c0-2 1-3 2-4 0 2 1 3 2 3 0-3-1-5 0-8z"/>'),
  lock('<rect x="5" y="11" width="14" height="9" rx="2"/><path d="M8 11V8a4 4 0 0 1 8 0v3"/>'),
  chevronRight('<path d="M9 6l6 6-6 6"/>'),
  chevronLeft('<path d="M15 6l-6 6 6 6"/>'),
  close('<path d="M6 6l12 12M18 6L6 18"/>'),
  clock('<circle cx="12" cy="12" r="9"/><path d="M12 7v5l3 2"/>'),
  check('<path d="M5 12l5 5 9-10"/>'),
  info('<circle cx="12" cy="12" r="9"/><path d="M12 8v5M12 16h.01"/>'),
  bulb('<path d="M9 18h6M10 21h4M12 3a6 6 0 0 0-4 10.5c.7.7 1 1.5 1 2.5h6c0-1 .3-1.8 1-2.5A6 6 0 0 0 12 3z"/>'),
  erase('<path d="M20 20H9L4 15l10-10 6 6-7 7"/>'),
  pencil('<path d="M4 20l4-1 11-11-3-3L5 16z"/>'),
  share('<path d="M12 15V3M7 8l5-5 5 5M5 13v6a2 2 0 0 0 2 2h10a2 2 0 0 0 2-2v-6"/>'),
  crown('<path d="M3 8l4 4 5-7 5 7 4-4-2 11H5z"/>'),
  speaker('<path d="M4 9v6h4l5 4V5L8 9z"/><path d="M16 8.5a5 5 0 0 1 0 7M19 6a9 9 0 0 1 0 12"/>'),
  star('<path d="M12 3l2.7 5.6 6.1.9-4.4 4.3 1 6.1L12 17l-5.4 2.9 1-6.1L3.2 9.5l6.1-.9z"/>'),
  kid(
      '<circle cx="12" cy="13" r="7"/><circle cx="9.5" cy="12" r="0.8"/><circle cx="14.5" cy="12" r="0.8"/><path d="M9.5 15.5c1.5 1.2 3.5 1.2 5 0M7 7L5 4M17 7l2-3"/>'),
  bell('<path d="M6 16V11a6 6 0 0 1 12 0v5l2 2H4z"/><path d="M10 20a2 2 0 0 0 4 0"/>'),
  globe('<circle cx="12" cy="12" r="9"/><path d="M3 12h18M12 3c3 3 3 15 0 18M12 3c-3 3-3 15 0 18"/>'),
  vibrate('<rect x="8" y="4" width="8" height="16" rx="2"/><path d="M4 9v6M20 9v6"/>'),
  swap('<path d="M7 7h12l-4-4M17 17H5l4 4"/>'),
  trash('<path d="M4 7h16M9 7V4h6v3M6 7l1 13h10l1-13"/>'),
  refresh('<path d="M20 11a8 8 0 1 0-2.3 5.7M20 4v7h-7"/>'),
  plus('<path d="M12 5v14M5 12h14"/>'),
  arrowUp('<path d="M12 19V5M6 11l6-6 6 6"/>'),
  arrowDown('<path d="M12 5v14M6 13l6 6 6-6"/>'),
  arrowLeft('<path d="M19 12H5M11 6l-6 6 6 6"/>'),
  arrowRight('<path d="M5 12h14M13 6l6 6-6 6"/>'),
  flag('<path d="M5 21V4M5 4h11l-2 4 2 4H5"/>'),
  undo('<path d="M9 14L4 9l5-5"/><path d="M4 9h10a6 6 0 0 1 0 12h-3"/>'),
  palette('<path d="M12 3a9 9 0 0 0 0 18c1.5 0 2-1 2-2s-1-1.5-1-2.5S14 15 15 15h2a4 4 0 0 0 4-4c0-4.4-4-8-9-8z"/><circle cx="7.5" cy="11" r="1"/><circle cx="10" cy="7" r="1"/><circle cx="15" cy="7.5" r="1"/>'),
  sparkle('<path d="M12 3v4M12 17v4M3 12h4M17 12h4M6 6l2.5 2.5M15.5 15.5L18 18M6 18l2.5-2.5M15.5 8.5L18 6"/>');

  const KpIcons(this.body);

  final String body;
}

class KpIcon extends StatelessWidget {
  const KpIcon(
    this.icon, {
    super.key,
    this.size = 22,
    this.color,
    this.strokeWidth = 2,
    this.semanticLabel,
  });

  final KpIcons icon;
  final double size;
  final Color? color;
  final double strokeWidth;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final c = color ?? DefaultTextStyle.of(context).style.color ?? const Color(0xFF2B1A10);
    final svg = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" '
        'stroke="black" stroke-width="$strokeWidth" stroke-linecap="round" '
        'stroke-linejoin="round">${icon.body}</svg>';
    final picture = SvgPicture.string(
      svg,
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(c, BlendMode.srcIn),
    );
    if (semanticLabel == null) return ExcludeSemantics(child: picture);
    return Semantics(label: semanticLabel, child: picture);
  }
}

/// Filled star with an outline, as used on the result and level screens.
class KpStar extends StatelessWidget {
  const KpStar({super.key, required this.filled, this.size = 18, this.fill, this.stroke});

  final bool filled;
  final double size;
  final Color? fill;
  final Color? stroke;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _StarPainter(
        fill: filled ? (fill ?? const Color(0xFFF4BE4F)) : const Color(0x99FFFFFF),
        stroke: stroke ?? const Color(0xFF9E4421),
      ),
    );
  }
}

class _StarPainter extends CustomPainter {
  _StarPainter({required this.fill, required this.stroke});

  final Color fill;
  final Color stroke;

  static Path starPath(Size size) {
    final s = size.width / 24;
    return Path()
      ..moveTo(12 * s, 3 * s)
      ..lineTo(14.7 * s, 8.6 * s)
      ..lineTo(20.8 * s, 9.5 * s)
      ..lineTo(16.4 * s, 13.8 * s)
      ..lineTo(17.4 * s, 19.9 * s)
      ..lineTo(12 * s, 17 * s)
      ..lineTo(6.6 * s, 19.9 * s)
      ..lineTo(7.6 * s, 13.8 * s)
      ..lineTo(3.2 * s, 9.5 * s)
      ..lineTo(9.3 * s, 8.6 * s)
      ..close();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final path = starPath(size);
    canvas.drawPath(path, Paint()..color = fill);
    canvas.drawPath(
      path,
      Paint()
        ..color = stroke
        ..style = PaintingStyle.stroke
        ..strokeJoin = StrokeJoin.round
        ..strokeWidth = size.width / 16,
    );
  }

  @override
  bool shouldRepaint(_StarPainter old) => old.fill != fill || old.stroke != stroke;
}
