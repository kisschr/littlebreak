import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

import '../design/components.dart';

/// Height (pt) of the phone the sheet sizes were tuned on.
const double _referenceHeight = 932;

/// Screens at least this wide on their short side are tablets.
const double _tabletShortestSide = 600;

/// Shows a floating glass sheet the way every sheet of the app looks.
///
/// [full] opens a full-height sheet (for text input: its content sits at the
/// top, clear of the keyboard); otherwise the sheet floats above the system
/// navigation bar, [halfSize] tall on a 932 pt phone and as tall in points on
/// shorter phones, so its content fits everywhere.
///
/// On tablets the same content opens as a centred card instead, like a
/// form sheet on iPadOS.
Future<T?> showKpSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  double halfSize = 0.45,
  bool full = false,
  GlassMorphAnchor? morphFrom,
}) {
  if (MediaQuery.sizeOf(context).shortestSide >= _tabletShortestSide) {
    return _showCentred<T>(context, builder);
  }
  return GlassModalSheet.show<T>(
    context: context,
    topBorderRadius: KpGlassStyle.sheetRadius,
    bottomBorderRadius: KpGlassStyle.sheetRadius,
    settings: KpGlassStyle.sheet,
    // The package defaults sheets to premium glass, which stutters on
    // mid-range Android phones while the sheet slides in.
    quality: GlassQuality.standard,
    halfSize: (halfSize * _referenceHeight / MediaQuery.sizeOf(context).height).clamp(0.3, 0.9),
    initialState: full ? GlassSheetState.full : GlassSheetState.half,
    detents: {full ? GlassSheetDetent.large : GlassSheetDetent.medium},
    // The sheet itself ignores the navigation bar; float it above.
    bottomMargin: 8 + MediaQuery.paddingOf(context).bottom,
    horizontalMargin: kpSideInset(context, 8, maxWidth: kpContentWidth),
    morphFrom: morphFrom,
    builder: builder,
  );
}

Future<T?> _showCentred<T>(BuildContext context, WidgetBuilder builder) {
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: GlassDefaults.barrierColor,
    transitionDuration: const Duration(milliseconds: 240),
    pageBuilder: (context, _, _) => _CentredSheet(builder: builder),
    transitionBuilder: (_, animation, _, child) {
      final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
      return FadeTransition(
        opacity: curved,
        child: ScaleTransition(scale: Tween(begin: 0.95, end: 1.0).animate(curved), child: child),
      );
    },
  );
}

class _CentredSheet extends StatelessWidget {
  const _CentredSheet({required this.builder});

  final WidgetBuilder builder;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    // Moves up out of the keyboard's way, like a form sheet.
    return AnimatedPadding(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 540, maxHeight: size.height * 0.8),
          child: Material(
            type: MaterialType.transparency,
            child: GlassCard(
              useOwnLayer: true,
              quality: GlassQuality.standard,
              settings: KpGlassStyle.sheet,
              shape: const LiquidRoundedSuperellipse(borderRadius: KpGlassStyle.sheetRadius),
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Builder(builder: builder),
            ),
          ),
        ),
      ),
    );
  }
}
