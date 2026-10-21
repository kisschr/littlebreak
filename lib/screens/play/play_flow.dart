import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:provider/provider.dart';

import '../../app/app_state.dart';
import '../../design/components.dart';
import '../../domain/access.dart';
import '../../domain/models.dart';
import '../premium_sheet.dart';
import 'game_screen.dart';
import 'level_sheet.dart';

/// The way from a calendar day to a running game, shared by Today, the
/// calendar and the kids' screens.
abstract final class PlayFlow {
  /// Checks access, asks for the level (adults) and starts the game.
  static Future<void> openDay(BuildContext context, DateTime date, {GlassMorphAnchor? anchor}) async {
    final state = context.read<AppState>();
    switch (state.accessFor(date)) {
      case DayAccess.locked:
        return;
      case DayAccess.needsPremiumPast:
      case DayAccess.needsPremiumAhead:
        await showPremiumSheet(context);
        return;
      case DayAccess.playable:
        break;
    }
    if (!context.mounted) return;
    final plan = state.planFor(date);
    final profile = state.activeProfile!;
    final Difficulty? difficulty;
    if (profile.isKid) {
      // Kids pick the level on the day card; no extra step before playing.
      difficulty = profile.lastDifficulty;
    } else {
      difficulty = await chooseLevel(context, plan, anchor: anchor);
    }
    if (difficulty == null || !context.mounted) return;
    await start(context, plan, difficulty);
  }

  static Future<Difficulty?> chooseLevel(BuildContext context, DayPlan plan, {GlassMorphAnchor? anchor}) {
    final state = context.read<AppState>();
    return GlassModalSheet.show<Difficulty>(
      context: context,
      topBorderRadius: KpGlassStyle.sheetRadius,
      bottomBorderRadius: KpGlassStyle.sheetRadius,
      morphFrom: anchor,
      settings: KpGlassStyle.sheet,
      halfSize: 0.6,
      detents: const {GlassSheetDetent.medium},
      builder: (_) => SingleChildScrollView(
        child: LevelSheet(
          plan: plan,
          initial: state.activeProfile?.lastDifficulty ?? Difficulty.standard,
          record: state.recordFor(plan.date),
        ),
      ),
    );
  }

  static Future<void> start(BuildContext context, DayPlan plan, Difficulty difficulty) =>
      Navigator.of(context).push(GameScreen.route(plan: plan, difficulty: difficulty));
}
