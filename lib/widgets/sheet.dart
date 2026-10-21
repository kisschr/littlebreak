import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

import '../design/components.dart';

/// Shows a floating glass sheet the way every sheet of the app looks.
///
/// [full] opens a full-height sheet (for text input: its content sits at the
/// top, clear of the keyboard); otherwise the sheet floats at [halfSize] of
/// the screen above the system navigation bar.
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
    halfSize: halfSize,
    initialState: full ? GlassSheetState.full : GlassSheetState.half,
    detents: {full ? GlassSheetDetent.large : GlassSheetDetent.medium},
    // The sheet itself ignores the navigation bar; float it above.
    bottomMargin: 8 + MediaQuery.paddingOf(context).bottom,
    morphFrom: morphFrom,
    builder: builder,
  );
}
