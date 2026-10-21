import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../app/app_state.dart';
import '../../core/dates.dart';
import '../../design/components.dart';
import '../../design/icons.dart';
import '../../design/palette.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../widgets/page.dart';
import 'kids_today_screen.dart';

/// One sticker page per month: every played day earns a sticker.
class StickersScreen extends StatelessWidget {
  const StickersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final palette = KpPalette.of(context);
    final state = context.watch<AppState>();
    final today = state.today;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final colors = [palette.highlight, palette.blobs[2], palette.successSoft, palette.blobs[3], palette.accent];
    return KpScrollBody(
      withTabBar: true,
      children: [
        KpHeader(overline: l.stickersCollected(state.stats.totalPlayedDays), title: l.tabStickers),
        for (var m = today.month; m >= 1; m--)
          Builder(builder: (context) {
            final days = [
              for (var d = 1; d <= daysInMonth(today.year, m); d++)
                if (state.stats.playedOn(DateTime(today.year, m, d))) DateTime(today.year, m, d),
            ];
            final slots = days.length > KidsTodayScreen.stickersPerPage ? days.length : KidsTodayScreen.stickersPerPage;
            return KpGlassCard(
              radius: 28,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(DateFormat.MMMM(locale).format(DateTime(today.year, m)), style: KpText.title(palette.ink)),
                      ),
                      if (days.length >= KidsTodayScreen.stickersPerPage)
                        KpIcon(KpIcons.crown, size: 24, color: palette.accent),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (var i = 0; i < slots; i++)
                        i < days.length
                            ? Semantics(
                                label: l.stickerFor(DateFormat.MMMMd(locale).format(days[i])),
                                child: Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: colors[days[i].day % colors.length],
                                    border: Border.all(color: Colors.white, width: 3),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text('${days[i].day}', style: KpText.label(palette.ink, size: 16, weight: FontWeight.w900)),
                                ),
                              )
                            : Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.35)),
                              ),
                    ],
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }
}
