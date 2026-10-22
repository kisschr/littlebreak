import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../app/app_state.dart';
import '../../core/dates.dart';
import '../../design/components.dart';
import '../../design/icons.dart';
import '../../design/palette.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../data/repositories.dart';
import '../../l10n/texts.dart';
import '../../widgets/artwork_view.dart';
import '../../widgets/page.dart';
import 'kids_today_screen.dart';
import 'sticker.dart';

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
    return KpScrollBody(
      withTabBar: true,
      children: [
        KpHeader(overline: l.stickersCollected(state.stats.totalPlayedDays), title: l.tabStickers),
        if (state.gallery.isNotEmpty) _MyPictures(items: state.gallery.reversed.toList()),
        for (var m = today.month; m >= 1; m--)
          Builder(
            builder: (context) {
              final days = [
                for (var d = 1; d <= daysInMonth(today.year, m); d++)
                  if (state.stats.playedOn(DateTime(today.year, m, d))) DateTime(today.year, m, d),
              ];
              final slots = days.length > KidsTodayScreen.stickersPerPage
                  ? days.length
                  : KidsTodayScreen.stickersPerPage;
              return KpGlassCard(
                radius: 28,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            DateFormat.MMMM(locale).format(DateTime(today.year, m)),
                            style: KpText.title(palette.ink),
                          ),
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
                                  button: true,
                                  label: l.stickerFor(DateFormat.MMMMd(locale).format(days[i])),
                                  excludeSemantics: true,
                                  child: StickerBadge(day: days[i], onTap: () => showSticker(context, days[i])),
                                )
                              : Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white.withValues(alpha: 0.35),
                                  ),
                                ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }
}

/// The child's coloured stickers and daily colouring pages, newest first.
/// Stickers open again to keep colouring.
class _MyPictures extends StatelessWidget {
  const _MyPictures({required this.items});

  final List<GalleryItem> items;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final palette = KpPalette.of(context);
    return KpGlassCard(
      radius: 28,
      padding: const EdgeInsets.fromLTRB(16, 16, 0, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.myPictures, style: KpText.title(palette.ink)),
          const SizedBox(height: 12),
          SizedBox(
            height: 112,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(right: 16),
              itemCount: items.length,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (context, i) {
                final item = items[i];
                final day = parseDateKey(item.dateKey);
                final picture = ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: ColoredBox(
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: ArtworkView(item: item),
                    ),
                  ),
                );
                return Semantics(
                  label: l.motifName(item.motif),
                  button: item.gameId == Stickers.galleryId,
                  child: GestureDetector(
                    onTap: item.gameId == Stickers.galleryId
                        ? () => Navigator.of(context).push(FreeColoringScreen.route(day))
                        : null,
                    child: SizedBox(width: 112, child: picture),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
