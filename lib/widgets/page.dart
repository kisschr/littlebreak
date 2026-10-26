import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

import '../design/components.dart';
import '../design/palette.dart';

/// The frame of a full screen without tab bar: blob background, glass
/// scaffold and a scrolling column with the designs' margins.
class KpPage extends StatelessWidget {
  const KpPage({
    super.key,
    required this.children,
    this.variant = 0,
    this.padding = const EdgeInsets.fromLTRB(20, 16, 20, 0),
    this.spacing = 16,
  });

  final List<Widget> children;
  final int variant;
  final EdgeInsets padding;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      settings: KpGlassStyle.of(context),
      background: KpBackground(variant: variant),
      body: KpScrollBody(padding: padding, spacing: spacing, children: children),
    );
  }
}

/// Scrolling column of a screen; leaves room for a floating tab bar.
class KpScrollBody extends StatelessWidget {
  const KpScrollBody({
    super.key,
    required this.children,
    this.padding = const EdgeInsets.fromLTRB(20, 16, 20, 0),
    this.spacing = 16,
    this.withTabBar = false,
  });

  final List<Widget> children;
  final EdgeInsets padding;
  final double spacing;
  final bool withTabBar;

  @override
  Widget build(BuildContext context) {
    final insets = MediaQuery.paddingOf(context);
    final bottom = insets.bottom + (withTabBar ? 112 : 24);
    return ListView(
      padding: padding.copyWith(
        top: insets.top + padding.top,
        bottom: bottom,
        left: kpSideInset(context, padding.left),
        right: kpSideInset(context, padding.right),
      ),
      children: [
        for (var i = 0; i < children.length; i++) ...[if (i > 0) SizedBox(height: spacing), children[i]],
      ],
    );
  }
}

/// Screen header: small line above a large title, actions on the right.
class KpHeader extends StatelessWidget {
  const KpHeader({
    super.key,
    required this.overline,
    required this.title,
    this.actions = const [],
    this.titleSize = 36,
  });

  final String overline;
  final String title;
  final List<Widget> actions;
  final double titleSize;

  @override
  Widget build(BuildContext context) {
    final palette = KpPalette.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(overline, style: KpText.label(palette.inkSoft, size: 15, weight: FontWeight.w700)),
              Text(title, style: KpText.display(palette.ink, size: titleSize)),
            ],
          ),
        ),
        for (var i = 0; i < actions.length; i++) ...[if (i > 0) const SizedBox(width: 8), actions[i]],
      ],
    );
  }
}
