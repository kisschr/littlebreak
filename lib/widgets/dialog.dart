import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

import '../design/components.dart';
import '../design/palette.dart';

/// A button of a [KpDialog].
class KpDialogAction {
  const KpDialogAction({
    required this.label,
    required this.onPressed,
    this.isPrimary = false,
    this.isDestructive = false,
  });

  final String label;
  final VoidCallback onPressed;
  final bool isPrimary;
  final bool isDestructive;
}

/// Alert in the app's own glass and type: bright cream glass with the
/// palette's ink, so the text stays readable over any screen.
/// (GlassDialog draws its message in iOS secondary grey on clear glass.)
class KpDialog extends StatelessWidget {
  const KpDialog({super.key, required this.title, this.message, required this.actions});

  final String title;
  final String? message;
  final List<KpDialogAction> actions;

  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    String? message,
    required List<KpDialogAction> actions,
  }) {
    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: false,
      barrierColor: const Color(0x52000000),
      transitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (_, _, _) => KpDialog(title: title, message: message, actions: actions),
      transitionBuilder: (_, animation, _, child) {
        final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(scale: Tween(begin: 0.94, end: 1.0).animate(curved), child: child),
        );
      },
    );
  }

  static const _destructive = Color(0xFFC0392B);

  @override
  Widget build(BuildContext context) {
    final palette = KpPalette.of(context);
    final buttons = [
      for (final a in actions)
        a.isPrimary && !a.isDestructive
            ? KpPrimaryButton(label: a.label, onPressed: a.onPressed, height: 50, fontSize: 17)
            : _SecondaryButton(action: a, color: a.isDestructive ? _destructive : palette.ink),
    ];
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 340),
          child: Material(
            type: MaterialType.transparency,
            child: GlassCard(
              useOwnLayer: true,
              quality: GlassQuality.standard,
              settings: KpGlassStyle.dialog,
              shape: const LiquidRoundedSuperellipse(borderRadius: 32),
              padding: const EdgeInsets.fromLTRB(22, 24, 22, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(title, textAlign: TextAlign.center, style: KpText.title(palette.ink, size: 22)),
                  if (message != null) ...[
                    const SizedBox(height: 10),
                    Text(message!, textAlign: TextAlign.center, style: KpText.body(palette.ink)),
                  ],
                  const SizedBox(height: 22),
                  if (buttons.length == 2)
                    Row(
                      children: [
                        Expanded(child: buttons[0]),
                        const SizedBox(width: 10),
                        Expanded(child: buttons[1]),
                      ],
                    )
                  else
                    for (var i = 0; i < buttons.length; i++) ...[if (i > 0) const SizedBox(height: 10), buttons[i]],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  const _SecondaryButton({required this.action, required this.color});

  final KpDialogAction action;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: action.label,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: action.onPressed,
        child: Container(
          height: 50,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.75),
            borderRadius: BorderRadius.circular(25),
          ),
          child: Text(action.label, maxLines: 1, overflow: TextOverflow.ellipsis, style: KpText.title(color, size: 17)),
        ),
      ),
    );
  }
}
