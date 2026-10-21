import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../app/app_state.dart';
import '../../core/dates.dart';
import '../../design/components.dart';
import '../../design/icons.dart';
import '../../design/palette.dart';
import '../../domain/models.dart';
import '../../games/game_framework.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../l10n/texts.dart';
import '../../widgets/ads.dart';
import '../premium_sheet.dart';
import '../reminder_settings.dart';
import 'game_screen.dart';

/// What the result screen shows about the finished level.
class GameSummary {
  const GameSummary({
    required this.plan,
    required this.difficulty,
    required this.stars,
    required this.seconds,
    required this.stat,
    required this.statValue,
  });

  final DayPlan plan;
  final Difficulty difficulty;
  final int stars;
  final int seconds;
  final GameStat stat;
  final int statValue;
}

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key, required this.summary});

  final GameSummary summary;

  static Route<void> route(GameSummary summary) => PageRouteBuilder<void>(
    settings: const RouteSettings(name: 'result'),
    transitionDuration: const Duration(milliseconds: 380),
    pageBuilder: (_, _, _) => ResultScreen(summary: summary),
    transitionsBuilder: (_, animation, _, child) => FadeTransition(opacity: animation, child: child),
  );

  /// The next unsolved level after this one, if any.
  Difficulty? _nextLevel(DayRecord? record) {
    for (final d in Difficulty.values.skip(summary.difficulty.index + 1)) {
      if (record?.levels[d] == null) return d;
    }
    return null;
  }

  void _share(BuildContext context) {
    final l = AppLocalizations.of(context);
    final stars = '★' * summary.stars + '☆' * (3 - summary.stars);
    final text = l.shareText(
      l.dayNumber(summary.plan.dayNumber),
      '${l.gameName(summary.plan.type)} ${l.difficultyName(summary.difficulty)}',
      stars,
      formatDuration(summary.seconds),
    );
    final box = context.findRenderObject() as RenderBox?;
    SharePlus.instance.share(
      ShareParams(text: text, sharePositionOrigin: box == null ? null : box.localToGlobal(Offset.zero) & box.size),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final palette = KpPalette.of(context);
    final state = context.watch<AppState>();
    final kid = state.audience == Audience.kid;
    final next = _nextLevel(state.recordFor(summary.plan.date));
    final tomorrow = state.planFor(addDays(state.today, 1));
    final insets = MediaQuery.paddingOf(context);
    final title = switch (summary.stars) {
      3 => l.resultGreat,
      2 => l.resultDone,
      _ => l.resultGood,
    };

    final statLabel = switch (summary.stat) {
      GameStat.mistakes => l.statMistakes,
      GameStat.moves => l.statMoves,
      GameStat.score => l.statScore,
      GameStat.attempts => l.statAttempts,
    };

    return GlassScaffold(
      settings: KpGlassStyle.of(context),
      background: const KpBackground(variant: 3),
      body: Stack(
        children: [
          const Positioned.fill(child: _Confetti()),
          ListView(
            padding: EdgeInsets.fromLTRB(18, insets.top + 12, 18, insets.bottom + 24),
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: KpGlassButton(
                  semanticLabel: l.close,
                  onPressed: () => Navigator.of(context).pop(),
                  child: const KpCloseIcon(),
                ),
              ),
              const SizedBox(height: 8),
              Semantics(
                label: l.starsOf(summary.stars),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    for (var i = 0; i < 3; i++) ...[
                      if (i > 0) const SizedBox(width: 6),
                      _PopStar(
                        filled: i < summary.stars,
                        size: i == 1 ? 72 : 56,
                        delay: Duration(milliseconds: 150 + i * 160),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(title, textAlign: TextAlign.center, style: KpText.display(palette.ink, size: 34)),
              const SizedBox(height: 6),
              Text(
                '${l.gameName(summary.plan.type)} ${l.difficultyName(summary.difficulty)} · ${l.dayNumber(summary.plan.dayNumber)}',
                textAlign: TextAlign.center,
                style: KpText.label(palette.inkSoft, size: 16, weight: FontWeight.w700),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  if (kid) ...[
                    Expanded(
                      child: _StatCard(value: '${state.stats.totalPlayedDays}', label: l.statStickers),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _StatCard(value: '${state.stats.totalStars}', label: l.statStars),
                    ),
                  ] else ...[
                    Expanded(
                      child: _StatCard(value: formatDuration(summary.seconds), label: l.statTime),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _StatCard(value: '${summary.statValue}', label: statLabel),
                    ),
                  ],
                  const SizedBox(width: 10),
                  Expanded(
                    child: _StatCard(value: '${state.streak}', label: l.statStreak),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: Builder(
                      builder: (context) => _ShareButton(label: l.share, onTap: () => _share(context)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: KpPrimaryButton(
                      height: 54,
                      fontSize: 16,
                      label: next == null ? l.done : l.nextLevelQuestion(l.difficultyName(next)),
                      onPressed: next == null
                          ? () => Navigator.of(context).pop()
                          : () =>
                                Navigator.of(context)
                                    .pushReplacement(GameScreen.route(plan: summary.plan, difficulty: next)),
                    ),
                  ),
                ],
              ),
              if (!kid && !state.isPremium) ...[
                const SizedBox(height: 14),
                AdSlot(service: context.read<AdService>(), onRemoveAds: () => showPremiumSheet(context)),
              ],
              const SizedBox(height: 14),
              KpGlassCard(
                radius: 22,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                onTap: () => showReminderSettings(context),
                semanticLabel: l.tomorrowWaits(l.categoryName(tomorrow.type.category)),
                child: Row(
                  children: [
                    const _RoundIcon(icon: KpIcons.calendar),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l.tomorrowWaits(kid ? l.gameName(tomorrow.type) : l.categoryName(tomorrow.type.category)),
                            style: KpText.label(palette.ink),
                          ),
                          Text(
                            state.settings.reminderEnabled
                                ? l.reminderAt(
                                    formatTime(context, state.settings.reminderHour, state.settings.reminderMinute),
                                  )
                                : l.reminderOff,
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
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final palette = KpPalette.of(context);
    return KpGlassCard(
      radius: 22,
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          FittedBox(
            child: Text(
              value,
              style: KpText.title(palette.ink, size: 24).copyWith(fontFeatures: const [FontFeature.tabularFigures()]),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: KpText.label(palette.inkSoft, size: 13, weight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _ShareButton extends StatelessWidget {
  const _ShareButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = KpPalette.of(context);
    return KpGlassButton(
      height: 54,
      width: double.infinity,
      semanticLabel: label,
      onPressed: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          KpIcon(KpIcons.share, size: 18, color: palette.ink),
          const SizedBox(width: 8),
          Text(label, style: KpText.label(palette.ink, size: 16, weight: FontWeight.w900)),
        ],
      ),
    );
  }
}

class _RoundIcon extends StatelessWidget {
  const _RoundIcon({required this.icon});

  final KpIcons icon;

  @override
  Widget build(BuildContext context) => Container(
    width: 40,
    height: 40,
    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.6), shape: BoxShape.circle),
    alignment: Alignment.center,
    child: KpIcon(icon, size: 18, color: KpPalette.of(context).inkSoft),
  );
}

/// A star that pops in after [delay].
class _PopStar extends StatelessWidget {
  const _PopStar({required this.filled, required this.size, required this.delay});

  final bool filled;
  final double size;
  final Duration delay;

  @override
  Widget build(BuildContext context) {
    final palette = KpPalette.of(context);
    final reduce = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    final star = KpStar(filled: filled, size: size, fill: palette.highlight, stroke: palette.accent);
    if (reduce) return star;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: delay + const Duration(milliseconds: 420),
      curve: Interval(delay.inMilliseconds / (delay.inMilliseconds + 420), 1, curve: Curves.elasticOut),
      builder: (context, t, child) => Transform.scale(scale: t, child: child),
      child: star,
    );
  }
}

/// The confetti of the result design, falling a little once.
class _Confetti extends StatelessWidget {
  const _Confetti();

  static const _pieces = [
    (40.0, 70.0, 0, 25.0),
    (110.0, 120.0, 1, -30.0),
    (200.0, 60.0, 2, 60.0),
    (280.0, 110.0, 3, -15.0),
    (340.0, 56.0, 4, 40.0),
    (160.0, 170.0, 5, 80.0),
    (310.0, 180.0, 1, 10.0),
  ];

  @override
  Widget build(BuildContext context) {
    final palette = KpPalette.of(context);
    final colors = [palette.accent, palette.highlight, palette.successSoft, ...palette.blobs];
    final reduce = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    final width = MediaQuery.sizeOf(context).width;
    return IgnorePointer(
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: reduce ? 1 : 0, end: 1),
        duration: const Duration(milliseconds: 1400),
        curve: Curves.easeOutCubic,
        builder: (context, t, _) => Stack(
          children: [
            for (final (x, y, c, angle) in _pieces)
              Positioned(
                left: x / 390 * width,
                top: y - 60 * (1 - t),
                child: Opacity(
                  opacity: t,
                  child: Transform.rotate(
                    angle: (angle + 90 * (1 - t)) * math.pi / 180,
                    child: Container(
                      width: 10,
                      height: 16,
                      decoration: BoxDecoration(
                        color: colors[c % colors.length],
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
