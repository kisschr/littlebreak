import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../app/app_state.dart';
import '../../design/components.dart';
import '../../design/icons.dart';
import '../../design/palette.dart';
import '../../domain/models.dart';
import '../../games/coloring/motif_painter.dart';
import '../../games/coloring/motifs.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../l10n/texts.dart';
import '../../widgets/game_thumbnail.dart';
import '../../widgets/page.dart';
import '../play/how_to_sheet.dart';
import '../play/play_flow.dart';
import '../profile_screen.dart';
import 'parental_gate.dart';

/// "Hallo Mia!" — today's game in big, friendly type, with read-aloud.
class KidsTodayScreen extends StatelessWidget {
  const KidsTodayScreen({super.key});

  /// Stickers needed to fill a month's page.
  static const stickersPerPage = 10;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final palette = KpPalette.of(context);
    final state = context.watch<AppState>();
    final profile = state.activeProfile!;
    final today = state.today;
    final plan = state.planFor(today);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final creative = plan.type == GameType.coloring || plan.type == GameType.pixelArt;
    final title = creative ? l.motifName(Motifs.idFor(plan)) : l.gameName(plan.type);
    final prompt = l.kidPrompt(plan.type);
    final monthStickers = state.stats.monthProgress(today.year, today.month, today).played;
    final left = stickersPerPage - monthStickers;
    final monthName = DateFormat.MMMM(locale).format(today);
    return KpScrollBody(
      withTabBar: true,
      children: [
        Row(
          children: [
            KpAvatar(
              initial: profile.initial,
              color: kpAvatarColors[profile.colorIndex % kpAvatarColors.length],
              size: 56,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l.kidsHello(profile.name), style: KpText.display(palette.ink, size: 30).copyWith(height: 1)),
                  Text(DateFormat.EEEE(locale).format(today), style: KpText.label(palette.inkSoft, size: 15)),
                ],
              ),
            ),
            KpGlassButton(
              pill: true,
              semanticLabel: l.parents,
              onPressed: () async {
                if (await ParentalGate.ask(context) && context.mounted) {
                  await Navigator.of(context).push(ProfileScreen.route());
                }
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  KpIcon(KpIcons.lock, size: 16, color: palette.ink, strokeWidth: 2.5),
                  const SizedBox(width: 6),
                  Text(l.parents, style: KpText.label(palette.ink, size: 13, weight: FontWeight.w900)),
                ],
              ),
            ),
          ],
        ),
        KpGlassCard(
          radius: 36,
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: KpChip(
                        label: l.gameName(plan.type),
                        background: Colors.white.withValues(alpha: 0.7),
                        fontSize: 15,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _LevelChip(profile: profile),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                height: 200,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(26)),
                alignment: Alignment.center,
                child: creative
                    ? AspectRatio(
                        aspectRatio: 1,
                        child: CustomPaint(
                          painter: MotifPainter(
                            motif: Motifs.byId(Motifs.idFor(plan)),
                            fills: const [],
                            lineColor: palette.ink,
                            lineWidth: 1.6,
                          ),
                        ),
                      )
                    : GameThumbnail(plan: plan, size: 160, tilt: false),
              ),
              const SizedBox(height: 14),
              Text(title, style: KpText.title(palette.ink, size: 28)),
              const SizedBox(height: 2),
              Text(prompt, style: KpText.label(palette.inkSoft, size: 16, weight: FontWeight.w700)),
              const SizedBox(height: 14),
              Row(
                children: [
                  SpeakButton(text: '$title. $prompt'),
                  const SizedBox(width: 10),
                  Expanded(
                    child: KpPrimaryButton(
                      label: l.letsGo,
                      height: 72,
                      fontSize: 24,
                      icon: const KpPlayGlyph(size: 22),
                      onPressed: () => PlayFlow.openDay(context, today),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        KpGlassCard(
          radius: 28,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              SizedBox(
                width: 96,
                height: 40,
                child: Stack(
                  children: [
                    for (var i = 0; i < 3; i++)
                      Positioned(
                        left: i * 28.0,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: [palette.highlight, palette.blobs[2], palette.successSoft][i],
                            border: Border.all(color: Colors.white, width: 3),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l.stickersCollected(state.stats.totalPlayedDays),
                      style: KpText.label(palette.ink, size: 17, weight: FontWeight.w900),
                    ),
                    Text(
                      left > 0 ? l.stickersToPage(left, monthName) : l.stickerPageDone(monthName),
                      style: KpText.label(palette.inkSoft, size: 14, weight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// The gold level chip; tapping cycles Einfach → Standard → Fortgeschritten.
class _LevelChip extends StatelessWidget {
  const _LevelChip({required this.profile});

  final Profile profile;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final palette = KpPalette.of(context);
    final next = Difficulty.values[(profile.lastDifficulty.index + 1) % Difficulty.values.length];
    return Semantics(
      button: true,
      label: l.levelChipLabel(l.difficultyName(profile.lastDifficulty)),
      excludeSemantics: true,
      child: GestureDetector(
        onTap: () => context.read<AppState>().updateProfile(profile.copyWith(lastDifficulty: next)),
        child: KpChip(
          label: l.difficultyName(profile.lastDifficulty),
          background: palette.highlight,
          fontSize: 15,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        ),
      ),
    );
  }
}
