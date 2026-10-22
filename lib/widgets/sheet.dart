import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

import '../design/components.dart';

/// Height (pt) of the phone the sheet sizes were tuned on.
const double _referenceHeight = 932;

/// Shows a floating glass sheet the way every sheet of the app looks.
///
/// [full] opens a full-height sheet (for text input: its content sits at the
/// top, clear of the keyboard); otherwise the sheet floats above the system
/// navigation bar, [halfSize] tall on a 932 pt phone and as tall in points on
/// shorter phones and tablets, so its content fits everywhere.
Future<T?> showKpSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  double halfSize = 0.45,
  bool full = false,
  GlassMorphAnchor? morphFrom,
}) {
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
