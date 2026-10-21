import 'package:flutter/material.dart';

import '../design/components.dart';
import '../design/icons.dart';
import '../design/palette.dart';
import '../l10n/generated/app_localizations.dart';

/// Source of the banner shown after a game for Freemium players.
///
/// The app ships with [HouseAdService], which promotes Premium and needs no
/// SDK, consent dialog or network. An AdMob implementation only has to
/// return its banner widget here and be handed to the app in `main.dart`.
abstract class AdService {
  const AdService();

  /// Banner content for the ad slot; [onRemoveAds] opens Premium.
  Widget banner(BuildContext context, {required VoidCallback onRemoveAds});
}

class HouseAdService extends AdService {
  const HouseAdService();

  @override
  Widget banner(BuildContext context, {required VoidCallback onRemoveAds}) {
    final l = AppLocalizations.of(context);
    final palette = KpPalette.of(context);
    return GestureDetector(
      onTap: onRemoveAds,
      child: Container(
        height: 96,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            KpIcon(KpIcons.crown, size: 34, color: palette.accent),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l.houseAdTitle, style: KpText.label(palette.ink, size: 16, weight: FontWeight.w900)),
                  const SizedBox(height: 2),
                  Text(l.houseAdBody, style: KpText.label(palette.inkSoft, size: 13, weight: FontWeight.w700)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The dashed "ANZEIGE · NACH DEM SPIEL" frame of the result screen.
class AdSlot extends StatelessWidget {
  const AdSlot({super.key, required this.service, required this.onRemoveAds});

  final AdService service;
  final VoidCallback onRemoveAds;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final palette = KpPalette.of(context);
    return Semantics(
      container: true,
      label: l.adLabel,
      child: CustomPaint(
        painter: DashedRRectPainter(color: palette.inkSoft.withValues(alpha: 0.55), radius: 22),
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      l.adHeader,
                      style: KpText.label(palette.inkSoft, size: 12, weight: FontWeight.w900).copyWith(letterSpacing: 0.5),
                    ),
                  ),
                  GestureDetector(
                    onTap: onRemoveAds,
                    child: Text(l.adRemove, style: KpText.label(palette.accent, size: 13)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              service.banner(context, onRemoveAds: onRemoveAds),
            ],
          ),
        ),
      ),
    );
  }
}
