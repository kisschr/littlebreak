import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:provider/provider.dart';

import '../app/app_state.dart';
import '../core/dates.dart';
import '../data/repositories.dart';
import '../design/components.dart';
import '../design/icons.dart';
import '../design/palette.dart';
import '../l10n/generated/app_localizations.dart';
import '../l10n/texts.dart';
import '../widgets/artwork_view.dart';
import '../widgets/page.dart';

/// Every finished coloring and pixel picture of the profile.
class GalleryScreen extends StatelessWidget {
  const GalleryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final palette = KpPalette.of(context);
    final items = context.watch<AppState>().gallery.reversed.toList();
    return KpScrollBody(
      withTabBar: true,
      children: [
        KpHeader(overline: l.galleryCount(items.length), title: l.tabGallery),
        if (items.isEmpty)
          KpGlassCard(
            radius: 28,
            padding: const EdgeInsets.all(22),
            child: Column(
              children: [
                KpIcon(KpIcons.palette, size: 40, color: palette.accent),
                const SizedBox(height: 10),
                Text(l.galleryEmptyTitle, textAlign: TextAlign.center, style: KpText.title(palette.ink)),
                const SizedBox(height: 6),
                Text(l.galleryEmptyBody, textAlign: TextAlign.center, style: KpText.body(palette.inkSoft)),
              ],
            ),
          )
        else
          LayoutBuilder(
            builder: (context, c) {
              const gap = 12.0;
              final w = (c.maxWidth - gap) / 2;
              return Wrap(
                spacing: gap,
                runSpacing: gap,
                children: [for (final item in items) SizedBox(width: w, child: _GalleryTile(item: item))],
              );
            },
          ),
      ],
    );
  }
}

class _GalleryTile extends StatelessWidget {
  const _GalleryTile({required this.item});

  final GalleryItem item;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final palette = KpPalette.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final caption = DateFormat.MMMd(locale).format(parseDateKey(item.dateKey));
    return KpGlassCard(
      radius: 24,
      padding: const EdgeInsets.all(10),
      onTap: () => _open(context),
      semanticLabel: '${l.motifName(item.motif)}, $caption',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: ColoredBox(
              color: Colors.white,
              child: Padding(padding: const EdgeInsets.all(6), child: ArtworkView(item: item)),
            ),
          ),
          const SizedBox(height: 8),
          Text(l.motifName(item.motif), style: KpText.label(palette.ink, size: 14, weight: FontWeight.w900)),
          Text('$caption · ${l.difficultyName(item.difficulty)}', style: KpText.label(palette.inkSoft, size: 12, weight: FontWeight.w700)),
        ],
      ),
    );
  }

  void _open(BuildContext context) {
    final l = AppLocalizations.of(context);
    GlassModalSheet.show<void>(
      context: context,
      topBorderRadius: KpGlassStyle.sheetRadius,
      bottomBorderRadius: KpGlassStyle.sheetRadius,
      settings: KpGlassStyle.sheet,
      initialState: GlassSheetState.full,
      detents: const {GlassSheetDetent.large},
      builder: (context) {
        final palette = KpPalette.of(context);
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(child: Text(l.motifName(item.motif), style: KpText.title(palette.ink, size: 26))),
                  KpSoftButton(semanticLabel: l.close, onPressed: () => Navigator.of(context).pop(), child: const KpCloseIcon()),
                ],
              ),
              const SizedBox(height: 14),
              ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: ColoredBox(
                  color: Colors.white,
                  child: Padding(padding: const EdgeInsets.all(14), child: ArtworkView(item: item)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
