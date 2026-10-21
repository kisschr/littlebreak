import 'package:flutter/material.dart';

import '../../design/components.dart';
import '../../design/icons.dart';
import '../../design/palette.dart';
import '../../domain/models.dart';
import '../../games/game_registry.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../l10n/texts.dart';

/// "Wie knifflig?" — the body of the level sheet. Pops with the chosen
/// [Difficulty].
class LevelSheet extends StatefulWidget {
  const LevelSheet({super.key, required this.plan, required this.initial, required this.record});

  final DayPlan plan;
  final Difficulty initial;
  final DayRecord? record;

  @override
  State<LevelSheet> createState() => _LevelSheetState();
}

class _LevelSheetState extends State<LevelSheet> {
  late Difficulty picked = widget.initial;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final palette = KpPalette.of(context);
    final definition = GameRegistry.of(widget.plan.type);
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 22, 18, 22),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${l.gameName(widget.plan.type)} · ${l.dayNumber(widget.plan.dayNumber)}',
                      style: KpText.label(palette.inkSoft, size: 14),
                    ),
                    Text(l.levelQuestion, style: KpText.title(palette.ink, size: 28)),
                  ],
                ),
              ),
              KpSoftButton(
                semanticLabel: l.close,
                onPressed: () => Navigator.of(context).pop(),
                child: const KpCloseIcon(),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Semantics(
            label: l.levelGroup,
            child: Column(
              children: [
                for (final d in Difficulty.values) ...[
                  _LevelRow(
                    name: l.difficultyName(d),
                    detail: definition.levelDetail(l, d),
                    stars: widget.record?.levels[d]?.stars ?? 0,
                    selected: picked == d,
                    onTap: () => setState(() => picked = d),
                  ),
                  if (d != Difficulty.advanced) const SizedBox(height: 10),
                ],
              ],
            ),
          ),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              children: [
                KpIcon(KpIcons.info, size: 18, color: palette.inkSoft),
                const SizedBox(width: 8),
                Expanded(child: Text(l.goldHint, style: KpText.label(palette.inkSoft, size: 14, weight: FontWeight.w700))),
              ],
            ),
          ),
          const SizedBox(height: 14),
          KpPrimaryButton(
            label: l.startLevel(l.difficultyName(picked)),
            onPressed: () => Navigator.of(context).pop(picked),
          ),
        ],
      ),
    );
  }
}

class _LevelRow extends StatelessWidget {
  const _LevelRow({
    required this.name,
    required this.detail,
    required this.stars,
    required this.selected,
    required this.onTap,
  });

  final String name;
  final String detail;
  final int stars;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final palette = KpPalette.of(context);
    return Semantics(
      inMutuallyExclusiveGroup: true,
      checked: selected,
      button: true,
      label: '$name, $detail, ${l.starsOf(stars)}',
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          constraints: const BoxConstraints(minHeight: 72),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: selected ? 0.9 : 0.45),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: selected ? palette.accent : Colors.white.withValues(alpha: 0.6), width: 2),
            boxShadow: selected
                ? [BoxShadow(color: palette.accent.withValues(alpha: 0.18), blurRadius: 18, offset: const Offset(0, 6))]
                : null,
          ),
          child: Row(
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selected ? palette.accent : null,
                  border: selected ? null : Border.all(color: palette.inkSoft.withValues(alpha: 0.45), width: 2),
                ),
                alignment: Alignment.center,
                child: selected
                    ? Container(width: 12, height: 12, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle))
                    : null,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: KpText.label(palette.ink, size: 18, weight: FontWeight.w900)),
                    const SizedBox(height: 2),
                    Text(detail, style: KpText.label(palette.inkSoft, size: 14, weight: FontWeight.w700)),
                  ],
                ),
              ),
              KpStarRow(count: stars),
            ],
          ),
        ),
      ),
    );
  }
}
