import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:provider/provider.dart';

import '../app/app_state.dart';
import '../core/dates.dart';
import '../design/components.dart';
import '../design/icons.dart';
import '../design/palette.dart';
import '../domain/models.dart';
import '../games/game_registry.dart';
import '../l10n/generated/app_localizations.dart';
import '../l10n/texts.dart';
import '../widgets/game_thumbnail.dart';
import '../widgets/page.dart';
import 'play/play_flow.dart';
import 'premium_sheet.dart';
import '../widgets/dialog.dart';

/// "Heute": the day card with today's game, this week and tomorrow.
class TodayScreen extends StatelessWidget {
  const TodayScreen({super.key, required this.onOpenProfile});

  final VoidCallback onOpenProfile;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final state = context.watch<AppState>();
    final profile = state.activeProfile!;
    final today = state.today;
    final locale = Localizations.localeOf(context).toLanguageTag();
    return KpScrollBody(
      withTabBar: true,
      children: [
        KpHeader(
          overline: DateFormat.MMMMEEEEd(locale).format(today),
          title: l.tabToday,
          actions: [
            StreakButton(days: state.streak),
            KpGlassButton(
              semanticLabel: l.profileOf(profile.name),
              onPressed: onOpenProfile,
              child: Text(profile.initial, style: KpText.title(KpPalette.of(context).ink, size: 17)),
            ),
          ],
        ),
        DayCard(plan: state.planFor(today), record: state.recordFor(today), lastDifficulty: profile.lastDifficulty),
        WeekCard(today: today),
        _TomorrowCard(plan: state.planFor(addDays(today, 1)), premium: state.isPremium),
      ],
    );
  }
}

/// Flame + "15 Tage" in a free glass pill; explains the streak on tap.
class StreakButton extends StatelessWidget {
  const StreakButton({super.key, required this.days});

  final int days;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final palette = KpPalette.of(context);
    return KpGlassButton(
      pill: true,
      semanticLabel: l.streakDays(days),
      onPressed: () => KpDialog.show<void>(
        context: context,
        title: l.streakDays(days),
        message: l.streakExplain,
        actions: [KpDialogAction(label: l.ok, isPrimary: true, onPressed: () => Navigator.of(context).pop())],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          KpIcon(KpIcons.flame, size: 20, color: palette.accent),
          const SizedBox(width: 6),
          Text(l.streakDays(days), style: KpText.label(palette.ink, size: 16)),
        ],
      ),
    );
  }
}

/// The big glass card with the day's game.
class DayCard extends StatelessWidget {
  const DayCard({super.key, required this.plan, required this.record, required this.lastDifficulty});

  final DayPlan plan;
  final DayRecord? record;
  final Difficulty lastDifficulty;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final palette = KpPalette.of(context);
    final definition = GameRegistry.of(plan.type);
    final solved = record?.levels.length ?? 0;
    final subtitle = l.specialDayName(plan.specialId) ?? l.monthEdition(plan.date.month);
    final button = switch (solved) {
      0 => l.openDoor,
      3 => l.playAgain,
      _ => l.continuePlaying,
    };
    return KpGlassCard(
      radius: 32,
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    KpChip(
                      label: '${l.dayNumber(plan.dayNumber)} · ${l.categoryName(plan.type.category)}',
                      background: Colors.white.withValues(alpha: 0.55),
                      foreground: palette.inkSoft,
                      fontSize: 13,
                      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      l.gameName(plan.type),
                      // Long names ("Wahr oder falsch") get two lines, not three.
                      style: KpText.display(palette.ink, size: l.gameName(plan.type).length > 11 ? 34 : 42)
                          .copyWith(letterSpacing: -1, height: 1.05),
                    ),
                    const SizedBox(height: 6),
                    Text(subtitle, style: KpText.body(palette.inkSoft)),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              GameThumbnail(plan: plan),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              KpChip(
                icon: KpIcon(KpIcons.clock, size: 16, color: palette.ink),
                label: l.aboutMinutes(definition.minutes(lastDifficulty)),
              ),
              KpChip(label: solved == 0 ? l.threeLevels : l.levelsSolved(solved)),
              KpChip(label: l.lastLevel(l.difficultyName(lastDifficulty))),
            ],
          ),
          const SizedBox(height: 16),
          GlassMorphTrigger(
            builder: (context, anchor) => KpPrimaryButton(
              label: button,
              icon: const KpPlayGlyph(),
              onPressed: () => PlayFlow.openDay(context, plan.date, anchor: anchor),
            ),
          ),
        ],
      ),
    );
  }
}

/// "Diese Woche · 3 von 7" with one bubble per weekday.
class WeekCard extends StatelessWidget {
  const WeekCard({super.key, required this.today});

  final DateTime today;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final palette = KpPalette.of(context);
    final stats = context.watch<AppState>().stats;
    final monday = startOfWeek(today);
    return Semantics(
      container: true,
      label: l.thisWeek,
      child: KpGlassCard(
        radius: 26,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(child: Text(l.thisWeek, style: KpText.label(palette.ink, size: 14))),
                Text(l.weekProgress(stats.playedThisWeek(today)), style: KpText.label(palette.inkSoft, size: 14)),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (var i = 0; i < 7; i++)
                  _WeekDay(
                    date: addDays(monday, i),
                    played: stats.playedOn(addDays(monday, i)),
                    isToday: isSameDay(addDays(monday, i), today),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _WeekDay extends StatelessWidget {
  const _WeekDay({required this.date, required this.played, required this.isToday});

  final DateTime date;
  final bool played;
  final bool isToday;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final palette = KpPalette.of(context);
    final Widget bubble;
    if (played) {
      bubble = Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(color: palette.accent, shape: BoxShape.circle),
        alignment: Alignment.center,
        child: const KpIcon(KpIcons.check, size: 16, color: Colors.white, strokeWidth: 3),
      );
    } else if (isToday) {
      bubble = Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.7),
          shape: BoxShape.circle,
          border: Border.all(color: palette.accent, width: 2),
        ),
        alignment: Alignment.center,
        child: Text('${date.day}', style: KpText.label(palette.ink, size: 14, weight: FontWeight.w900)),
      );
    } else {
      bubble = CustomPaint(
        painter: DashedRRectPainter(color: palette.inkSoft.withValues(alpha: 0.5), radius: 18, strokeWidth: 1, dash: 3, gap: 3),
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.35), shape: BoxShape.circle),
        ),
      );
    }
    return Semantics(
      label: '${l.weekdayShort(date.weekday)}${played ? ', ${l.played}' : ''}',
      excludeSemantics: true,
      child: Column(
        children: [
          bubble,
          const SizedBox(height: 4),
          Text(
            l.weekdayShort(date.weekday),
            style: KpText.label(isToday ? palette.ink : palette.inkSoft, size: 12, weight: isToday ? FontWeight.w900 : FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _TomorrowCard extends StatelessWidget {
  const _TomorrowCard({required this.plan, required this.premium});

  final DayPlan plan;
  final bool premium;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final palette = KpPalette.of(context);
    final title = l.tomorrowTeaser(l.categoryName(plan.type.category));
    return KpGlassCard(
      radius: 24,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      semanticLabel: title,
      onTap: () => premium ? PlayFlow.openDay(context, plan.date) : showPremiumSheet(context),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.6), shape: BoxShape.circle),
            alignment: Alignment.center,
            child: KpIcon(premium ? KpIcons.sparkle : KpIcons.lock, size: 18, color: palette.inkSoft),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: KpText.label(palette.ink)),
                Text(
                  premium ? l.tomorrowPlayNow : l.tomorrowWithPremium,
                  style: KpText.label(palette.inkSoft, size: 13, weight: FontWeight.w700),
                ),
              ],
            ),
          ),
          KpIcon(KpIcons.chevronRight, size: 18, color: palette.inkSoft, strokeWidth: 2.5),
        ],
      ),
    );
  }
}
