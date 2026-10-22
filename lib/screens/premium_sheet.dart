import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:provider/provider.dart';

import '../app/app_state.dart';
import '../data/premium.dart';
import '../design/components.dart';
import '../design/icons.dart';
import '../design/palette.dart';
import '../domain/models.dart';
import '../l10n/generated/app_localizations.dart';
import 'kids/parental_gate.dart';
import '../widgets/dialog.dart';

/// Opens "Kleine Pause Premium" as a full page, like the design. Kids
/// profiles pass the parental gate first.
Future<void> showPremiumSheet(BuildContext context) async {
  final state = context.read<AppState>();
  if (state.audience == Audience.kid && !await ParentalGate.ask(context)) return;
  if (!context.mounted) return;
  await Navigator.of(context).push(PremiumPage.route());
}

class PremiumPage extends StatelessWidget {
  const PremiumPage({super.key});

  static Route<void> route() => PageRouteBuilder<void>(
    fullscreenDialog: true,
    settings: const RouteSettings(name: 'premium'),
    transitionDuration: const Duration(milliseconds: 360),
    reverseTransitionDuration: const Duration(milliseconds: 260),
    pageBuilder: (_, _, _) => const PremiumPage(),
    transitionsBuilder: (_, animation, _, child) => SlideTransition(
      position: Tween(
        begin: const Offset(0, 1),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
      child: child,
    ),
  );

  @override
  Widget build(BuildContext context) => GlassScaffold(
    settings: KpGlassStyle.of(context),
    background: const KpBackground(variant: 4),
    body: const SafeArea(child: SingleChildScrollView(child: PremiumPanel())),
  );
}

class PremiumPanel extends StatefulWidget {
  const PremiumPanel({super.key});

  @override
  State<PremiumPanel> createState() => _PremiumPanelState();
}

class _PremiumPanelState extends State<PremiumPanel> {
  PremiumPlan plan = PremiumPlan.yearly;
  bool busy = false;

  Future<void> _message(String title, String body) {
    final l = AppLocalizations.of(context);
    return KpDialog.show<void>(
      context: context,
      title: title,
      message: body,
      actions: [KpDialogAction(label: l.ok, isPrimary: true, onPressed: () => Navigator.of(context).pop())],
    );
  }

  Future<void> _buy() async {
    final l = AppLocalizations.of(context);
    setState(() => busy = true);
    final outcome = await context.read<AppState>().buyPremium(plan);
    if (!mounted) return;
    setState(() => busy = false);
    switch (outcome) {
      case PurchaseOutcome.success:
        Navigator.of(context).pop();
      case PurchaseOutcome.cancelled:
        break;
      case PurchaseOutcome.unavailable:
        await _message(l.purchaseUnavailableTitle, l.purchaseUnavailableBody);
    }
  }

  Future<void> _restore() async {
    final l = AppLocalizations.of(context);
    final found = await context.read<AppState>().restorePurchases();
    if (!mounted) return;
    if (found) {
      Navigator.of(context).pop();
    } else {
      await _message(l.restoreNoneTitle, l.restoreNoneBody);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final palette = KpPalette.of(context);
    final state = context.watch<AppState>();
    final perks = [
      (l.perkNoAds, l.perkNoAdsBody),
      (l.perkPast, l.perkPastBody),
      (l.perkAhead, l.perkAheadBody),
      (l.perkProfiles, l.perkProfilesBody),
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: KpSoftButton(
              semanticLabel: l.close,
              onPressed: () => Navigator.of(context).pop(),
              child: const KpCloseIcon(),
            ),
          ),
          Center(
            child: Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(26),
              ),
              alignment: Alignment.center,
              child: KpIcon(KpIcons.crown, size: 38, color: palette.accent),
            ),
          ),
          const SizedBox(height: 8),
          Text(l.premiumTitle, textAlign: TextAlign.center, style: KpText.display(palette.ink, size: 32)),
          const SizedBox(height: 8),
          Text(l.premiumSubtitle, textAlign: TextAlign.center, style: KpText.body(palette.inkSoft)),
          const SizedBox(height: 16),
          KpGlassCard(
            radius: 28,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                for (var i = 0; i < perks.length; i++)
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      border: i == perks.length - 1
                          ? null
                          : Border(bottom: BorderSide(color: palette.inkSoft.withValues(alpha: 0.15))),
                    ),
                    child: Row(
                      children: [
                        KpIcon(KpIcons.check, size: 24, color: palette.accent, strokeWidth: 2.5),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(perks[i].$1, style: KpText.label(palette.ink, size: 16, weight: FontWeight.w900)),
                              Text(
                                perks[i].$2,
                                style: KpText.label(palette.inkSoft, size: 13, weight: FontWeight.w700),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (state.isPremium)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: palette.successSoft.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Text(
                l.premiumActive,
                textAlign: TextAlign.center,
                style: KpText.label(palette.successText, size: 16, weight: FontWeight.w900),
              ),
            )
          else ...[
            Row(
              children: [
                for (final p in PremiumPlan.values) ...[
                  if (p != PremiumPlan.values.first) const SizedBox(width: 10),
                  Expanded(
                    child: _PlanTile(
                      name: p == PremiumPlan.yearly ? l.planYearly : l.planOnce,
                      price: p == PremiumPlan.yearly
                          ? l.pricePerYear(state.purchases.priceFor(p) ?? '–')
                          : state.purchases.priceFor(p) ?? '–',
                      note: p == PremiumPlan.yearly ? l.planYearlyNote : l.planOnceNote,
                      selected: plan == p,
                      onTap: () => setState(() => plan = p),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),
            KpPrimaryButton(label: l.premiumStart, onPressed: busy ? null : _buy),
          ],
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _Link(label: l.restorePurchases, onTap: _restore),
              const SizedBox(width: 18),
              _Link(label: l.terms, onTap: () => _message(l.terms, l.termsBody)),
            ],
          ),
        ],
      ),
    );
  }
}

class _PlanTile extends StatelessWidget {
  const _PlanTile({
    required this.name,
    required this.price,
    required this.note,
    required this.selected,
    required this.onTap,
  });

  final String name;
  final String price;
  final String note;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = KpPalette.of(context);
    return Semantics(
      inMutuallyExclusiveGroup: true,
      checked: selected,
      button: true,
      label: '$name, $price, $note',
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: selected ? 0.9 : 0.45),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: selected ? palette.accent : Colors.white.withValues(alpha: 0.6), width: 2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: KpText.label(palette.inkSoft, size: 13)),
              FittedBox(child: Text(price, style: KpText.title(palette.ink, size: 20))),
              Text(note, style: KpText.label(palette.success, size: 12)),
            ],
          ),
        ),
      ),
    );
  }
}

class _Link extends StatelessWidget {
  const _Link({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    link: true,
    child: GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(label, style: KpText.label(KpPalette.of(context).accent, size: 13)),
      ),
    ),
  );
}
