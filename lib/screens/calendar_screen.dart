import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:provider/provider.dart';

import '../app/app_state.dart';
import '../core/dates.dart';
import '../design/components.dart';
import '../design/icons.dart';
import '../design/palette.dart';
import '../domain/access.dart';
import '../l10n/generated/app_localizations.dart';
import '../l10n/texts.dart';
import '../widgets/page.dart';
import 'play/play_flow.dart';
import 'premium_sheet.dart';

/// The year as a calendar: month grid with played, gold, catch-up and
/// play-ahead days, or the whole year at a glance.
class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  int view = 0; // 0 = month, 1 = year
  int? month;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final palette = KpPalette.of(context);
    final state = context.watch<AppState>();
    final today = state.today;
    final lastMonth = addDays(today, AccessPolicy.daysAhead).year == today.year
        ? addDays(today, AccessPolicy.daysAhead).month
        : 12;
    final shown = (month ?? today.month).clamp(1, lastMonth);
    return KpScrollBody(
      withTabBar: true,
      spacing: 14,
      children: [
        KpHeader(
          overline: '${today.year} · ${l.monthTheme(view == 0 ? shown : today.month)}',
          title: l.tabCalendar,
          actions: [
            SizedBox(
              width: 150,
              child: GlassSegmentedControl(
                segments: [GlassSegment(label: l.viewMonth), GlassSegment(label: l.viewYear)],
                selectedIndex: view,
                onSegmentSelected: (i) => setState(() => view = i),
                selectedTextStyle: KpText.label(palette.accent, size: 13, weight: FontWeight.w900),
                unselectedTextStyle: KpText.label(palette.inkSoft, size: 13, weight: FontWeight.w900),
              ),
            ),
          ],
        ),
        if (view == 0) ...[
          _MonthCard(
            year: today.year,
            month: shown,
            canGoBack: shown > 1,
            canGoForward: shown < lastMonth,
            onMonth: (m) => setState(() => month = m),
          ),
          const _Legend(),
          if (!state.isPremium) _MissedBanner(year: today.year, month: shown),
        ] else
          _YearGrid(
            year: today.year,
            lastMonth: lastMonth,
            onPick: (m) => setState(() {
              month = m;
              view = 0;
            }),
          ),
      ],
    );
  }
}

class _MonthCard extends StatelessWidget {
  const _MonthCard({
    required this.year,
    required this.month,
    required this.canGoBack,
    required this.canGoForward,
    required this.onMonth,
  });

  final int year;
  final int month;
  final bool canGoBack;
  final bool canGoForward;
  final ValueChanged<int> onMonth;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final palette = KpPalette.of(context);
    final state = context.watch<AppState>();
    final locale = Localizations.localeOf(context).toLanguageTag();
    final progress = state.stats.monthProgress(year, month, state.today);
    final first = DateTime(year, month);
    final leading = first.weekday - 1;
    final days = daysInMonth(year, month);
    return KpGlassCard(
      radius: 30,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              _Arrow(
                icon: KpIcons.chevronLeft,
                label: l.previousMonth,
                onTap: canGoBack ? () => onMonth(month - 1) : null,
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(DateFormat.MMMM(locale).format(first), style: KpText.title(palette.ink, size: 21)),
                    Text(
                      l.monthPlayed(progress.played, progress.available),
                      style: KpText.label(palette.inkSoft, size: 13, weight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
              _Arrow(
                icon: KpIcons.chevronRight,
                label: l.nextMonth,
                onTap: canGoForward ? () => onMonth(month + 1) : null,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              for (var w = DateTime.monday; w <= DateTime.sunday; w++)
                Expanded(
                  child: Text(
                    l.weekdayShort(w),
                    textAlign: TextAlign.center,
                    style: KpText.label(palette.inkSoft, size: 12),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, c) {
              const gap = 6.0;
              final cell = (c.maxWidth - gap * 6) / 7;
              return Wrap(
                spacing: gap,
                runSpacing: gap,
                children: [
                  for (var i = 0; i < leading; i++) SizedBox(width: cell, height: 44),
                  for (var d = 1; d <= days; d++)
                    SizedBox(width: cell, height: 44, child: CalendarDay(date: DateTime(year, month, d))),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _Arrow extends StatelessWidget {
  const _Arrow({required this.icon, required this.label, required this.onTap});

  final KpIcons icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Opacity(
        opacity: onTap == null ? 0.35 : 1,
        child: KpSoftButton(
          opacity: 0.5,
          semanticLabel: label,
          onPressed: onTap,
          child: KpIcon(icon, size: 18, strokeWidth: 2.5, color: KpPalette.of(context).ink),
        ),
      );
}

/// Visual state of a calendar day.
enum DayState { today, played, gold, catchUp, missedLocked, playAhead, locked }

DayState dayStateOf(AppState state, DateTime date) {
  final record = state.recordFor(date);
  if (record?.isGold ?? false) return DayState.gold;
  if (record?.played ?? false) return DayState.played;
  if (isSameDay(date, state.today)) return DayState.today;
  return switch (state.accessFor(date)) {
    DayAccess.playable => date.isBefore(state.today) ? DayState.catchUp : DayState.playAhead,
    DayAccess.needsPremiumPast => DayState.missedLocked,
    DayAccess.needsPremiumAhead || DayAccess.locked => DayState.locked,
  };
}

/// One day cell of the month grid.
class CalendarDay extends StatelessWidget {
  const CalendarDay({super.key, required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final palette = KpPalette.of(context);
    final state = context.watch<AppState>();
    final s = dayStateOf(state, date);
    final isToday = isSameDay(date, state.today);
    final locale = Localizations.localeOf(context).toLanguageTag();

    Color? bg;
    Color fg = palette.ink;
    BoxBorder? border;
    var dashed = false;
    KpIcons? mark;
    Color? markColor;
    var weight = FontWeight.w800;
    final String status;
    switch (s) {
      case DayState.today:
        bg = Colors.white;
        fg = palette.accent;
        border = Border.all(color: palette.accent, width: 2.5);
        weight = FontWeight.w900;
        status = l.dayToday;
      case DayState.played:
        bg = palette.accent;
        fg = Colors.white;
        mark = KpIcons.star;
        markColor = Colors.white;
        status = l.played;
      case DayState.gold:
        bg = palette.highlight;
        mark = KpIcons.star;
        markColor = palette.accent;
        status = l.dayGold;
      case DayState.catchUp:
        bg = Colors.white.withValues(alpha: 0.6);
        fg = palette.accent;
        dashed = true;
        status = l.dayCatchUp;
      case DayState.missedLocked:
        bg = Colors.white.withValues(alpha: 0.3);
        fg = palette.inkSoft;
        mark = KpIcons.lock;
        markColor = palette.inkSoft;
        status = l.dayMissedPremium;
      case DayState.playAhead:
        bg = palette.successSoft.withValues(alpha: 0.35);
        fg = palette.successText;
        border = Border.all(color: palette.success, width: 2);
        status = l.dayPlayAhead;
      case DayState.locked:
        bg = Colors.white.withValues(alpha: 0.22);
        fg = palette.inkSoft.withValues(alpha: 0.75);
        mark = KpIcons.lock;
        markColor = palette.inkSoft;
        status = l.dayLocked;
    }
    if (isToday && (s == DayState.played || s == DayState.gold)) {
      border = Border.all(color: palette.accentDark, width: 2.5);
    }

    Widget cell = Container(
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(14), border: border),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('${date.day}', style: KpText.label(fg, size: 15, weight: weight).copyWith(height: 1.1)),
          if (mark != null)
            mark == KpIcons.star
                ? KpStar(filled: true, size: 10, fill: markColor, stroke: markColor)
                : KpIcon(mark, size: 10, color: markColor!, strokeWidth: 3),
        ],
      ),
    );
    if (dashed) {
      cell = CustomPaint(foregroundPainter: DashedRRectPainter(color: palette.accent, radius: 14, strokeWidth: 2), child: cell);
    }
    final playable = s != DayState.locked || state.accessFor(date) == DayAccess.needsPremiumAhead;
    return Semantics(
      button: playable,
      label: '${DateFormat.MMMMd(locale).format(date)}, $status',
      excludeSemantics: true,
      child: GestureDetector(
        onTap: playable ? () => PlayFlow.openDay(context, date) : null,
        child: cell,
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final palette = KpPalette.of(context);
    Widget item(Widget swatch, String label) => Row(
          children: [
            SizedBox(width: 18, height: 18, child: swatch),
            const SizedBox(width: 8),
            Expanded(child: Text(label, style: KpText.label(palette.ink, size: 13, weight: FontWeight.w700))),
          ],
        );
    BoxDecoration box(Color c, [BoxBorder? b]) => BoxDecoration(color: c, borderRadius: BorderRadius.circular(6), border: b);
    return Semantics(
      container: true,
      label: l.legend,
      child: KpGlassCard(
        radius: 24,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(child: item(DecoratedBox(decoration: box(palette.accent)), l.legendPlayed)),
                const SizedBox(width: 12),
                Expanded(child: item(DecoratedBox(decoration: box(palette.highlight)), l.legendGold)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: item(
                    CustomPaint(
                      foregroundPainter: DashedRRectPainter(color: palette.accent, radius: 6, strokeWidth: 2, dash: 3, gap: 2),
                      child: DecoratedBox(decoration: box(Colors.white.withValues(alpha: 0.6))),
                    ),
                    l.legendCatchUp,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: item(
                    DecoratedBox(
                      decoration: box(palette.successSoft.withValues(alpha: 0.35), Border.all(color: palette.success, width: 2)),
                    ),
                    l.legendAhead,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MissedBanner extends StatelessWidget {
  const _MissedBanner({required this.year, required this.month});

  final int year;
  final int month;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final palette = KpPalette.of(context);
    final state = context.watch<AppState>();
    final missed = state.stats.missedInMonth(year, month, state.today, state.activeProfile?.createdAt ?? DateTime(year));
    return KpGlassCard(
      radius: 24,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      onTap: () => showPremiumSheet(context),
      semanticLabel: l.premiumTitle,
      child: Row(
        children: [
          KpIcon(KpIcons.crown, size: 22, color: palette.accent),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(missed > 0 ? l.missedDays(missed) : l.premiumTitle, style: KpText.label(palette.ink)),
                Text(l.missedBody, style: KpText.label(palette.inkSoft, size: 13, weight: FontWeight.w700)),
              ],
            ),
          ),
          KpIcon(KpIcons.chevronRight, size: 18, color: palette.inkSoft, strokeWidth: 2.5),
        ],
      ),
    );
  }
}

class _YearGrid extends StatelessWidget {
  const _YearGrid({required this.year, required this.lastMonth, required this.onPick});

  final int year;
  final int lastMonth;
  final ValueChanged<int> onPick;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final palette = KpPalette.of(context);
    final state = context.watch<AppState>();
    final stats = state.stats;
    final locale = Localizations.localeOf(context).toLanguageTag();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l.yearSummary(stats.totalPlayedDays, stats.goldDays),
          style: KpText.label(palette.inkSoft, size: 14, weight: FontWeight.w700),
        ),
        const SizedBox(height: 10),
        LayoutBuilder(
          builder: (context, c) {
            const gap = 10.0;
            final w = (c.maxWidth - gap * 2) / 3;
            return Wrap(
              spacing: gap,
              runSpacing: gap,
              children: [
                for (var m = 1; m <= 12; m++)
                  SizedBox(
                    width: w,
                    child: Opacity(
                      opacity: m <= lastMonth ? 1 : 0.45,
                      child: KpGlassCard(
                        radius: 20,
                        padding: const EdgeInsets.all(10),
                        onTap: m <= lastMonth ? () => onPick(m) : null,
                        semanticLabel: DateFormat.MMMM(locale).format(DateTime(year, m)),
                        child: _MiniMonth(year: year, month: m),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _MiniMonth extends StatelessWidget {
  const _MiniMonth({required this.year, required this.month});

  final int year;
  final int month;

  @override
  Widget build(BuildContext context) {
    final palette = KpPalette.of(context);
    final state = context.watch<AppState>();
    final locale = Localizations.localeOf(context).toLanguageTag();
    final leading = DateTime(year, month).weekday - 1;
    final days = daysInMonth(year, month);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(DateFormat.MMM(locale).format(DateTime(year, month)), style: KpText.label(palette.ink, size: 14, weight: FontWeight.w900)),
        const SizedBox(height: 6),
        LayoutBuilder(
          builder: (context, c) {
            final dot = (c.maxWidth - 6 * 2) / 7;
            return Wrap(
              spacing: 2,
              runSpacing: 2,
              children: [
                for (var i = 0; i < leading; i++) SizedBox(width: dot, height: dot),
                for (var d = 1; d <= days; d++)
                  Container(
                    width: dot,
                    height: dot,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: switch (dayStateOf(state, DateTime(year, month, d))) {
                        DayState.gold => palette.highlight,
                        DayState.played => palette.accent,
                        DayState.today => Colors.white,
                        _ => Colors.white.withValues(alpha: 0.4),
                      },
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}
