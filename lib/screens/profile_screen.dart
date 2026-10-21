import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:provider/provider.dart';

import '../app/app_state.dart';
import '../design/components.dart';
import '../design/icons.dart';
import '../design/palette.dart';
import '../domain/models.dart';
import '../l10n/generated/app_localizations.dart';
import '../widgets/page.dart';
import 'premium_sheet.dart';
import 'profile_picker_screen.dart';
import 'reminder_settings.dart';

/// Profile, statistics and settings. Also the parents' area of a kids
/// profile (opened behind the parental gate, with a close button).
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key, this.standalone = false});

  /// Pushed as its own page (kids' parents area) instead of a tab.
  final bool standalone;

  static Route<void> route() => MaterialPageRoute<void>(builder: (_) => const ProfileScreen(standalone: true));

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final palette = KpPalette.of(context);
    final state = context.watch<AppState>();
    final profile = state.activeProfile;
    if (profile == null) return const SizedBox.shrink();
    final stats = state.stats;
    final children = [
      KpHeader(
        overline: profile.isKid ? l.parentsArea : l.tabProfile,
        title: profile.name,
        actions: [
          if (standalone)
            KpGlassButton(
              semanticLabel: l.close,
              onPressed: () => Navigator.of(context).pop(),
              child: const KpCloseIcon(),
            ),
        ],
      ),
      Row(
        children: [
          Expanded(
            child: _Stat(value: '${state.streak}', label: l.statStreak),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _Stat(value: '${stats.totalPlayedDays}', label: l.statPlayed),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _Stat(value: '${stats.goldDays}', label: l.statGold),
          ),
        ],
      ),
      _Section(
        title: l.settings,
        children: [
          _Tile(
            icon: KpIcons.globe,
            title: l.language,
            value: switch (state.settings.localeCode) {
              'de' => l.languageGerman,
              'en' => l.languageEnglish,
              _ => l.languageSystem,
            },
            onTap: () => _pickLanguage(context),
          ),
          _Tile(
            icon: KpIcons.bell,
            title: l.reminderSettingTitle,
            value: state.settings.reminderEnabled
                ? formatTime(context, state.settings.reminderHour, state.settings.reminderMinute)
                : l.off,
            onTap: () => showReminderSettings(context),
          ),
          _Tile(
            icon: KpIcons.vibrate,
            title: l.haptics,
            trailing: Switch(
              value: state.settings.haptics,
              activeTrackColor: palette.accent,
              onChanged: (v) => context.read<AppState>().setHaptics(v),
            ),
          ),
        ],
      ),
      _Section(
        title: l.premiumSection,
        children: [
          _Tile(
            icon: KpIcons.crown,
            title: l.premiumTitle,
            value: state.isPremium ? l.premiumActiveShort : l.premiumUnlock,
            onTap: () => showPremiumSheet(context),
          ),
          if (kDebugMode)
            _Tile(
              icon: KpIcons.sparkle,
              title: l.premiumDebug,
              trailing: Switch(
                value: state.isPremium,
                activeTrackColor: palette.accent,
                onChanged: (v) => context.read<AppState>().setPremiumForTesting(v),
              ),
            ),
        ],
      ),
      _Section(
        title: l.profileSection,
        children: [
          _Tile(
            icon: KpIcons.swap,
            title: l.switchProfile,
            onTap: () {
              if (standalone) Navigator.of(context).pop();
              context.read<AppState>().selectProfile(null);
            },
          ),
          _Tile(icon: KpIcons.pencil, title: l.renameProfile, onTap: () => _rename(context, profile)),
          _Tile(icon: KpIcons.trash, title: l.deleteProfile, destructive: true, onTap: () => _delete(context, profile)),
        ],
      ),
      Text(
        l.aboutLine,
        textAlign: TextAlign.center,
        style: KpText.label(palette.inkSoft, size: 12, weight: FontWeight.w700),
      ),
    ];
    if (!standalone) return KpScrollBody(withTabBar: true, children: children);
    return GlassScaffold(
      settings: KpGlassStyle.of(context),
      background: const KpBackground(variant: 2),
      body: KpScrollBody(children: children),
    );
  }

  Future<void> _pickLanguage(BuildContext context) {
    final l = AppLocalizations.of(context);
    final state = context.read<AppState>();
    return GlassModalSheet.show<void>(
      context: context,
      topBorderRadius: KpGlassStyle.sheetRadius,
      bottomBorderRadius: KpGlassStyle.sheetRadius,
      settings: KpGlassStyle.sheet,
      halfSize: 0.45,
      detents: const {GlassSheetDetent.medium},
      builder: (context) {
        final palette = KpPalette.of(context);
        Widget option(String? code, String label) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: OpaqueRow(
            title: label,
            onTap: () {
              state.setLocale(code);
              Navigator.of(context).pop();
            },
            trailing: state.settings.localeCode == code
                ? KpIcon(KpIcons.check, size: 22, color: palette.accent, strokeWidth: 2.5)
                : null,
          ),
        );
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(l.language, style: KpText.title(palette.ink, size: 28)),
                const SizedBox(height: 14),
                option(null, l.languageSystem),
                option('de', l.languageGerman),
                option('en', l.languageEnglish),
                Text(l.languageMore, style: KpText.label(palette.inkSoft, size: 13, weight: FontWeight.w700)),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _rename(BuildContext context, Profile profile) {
    final l = AppLocalizations.of(context);
    final state = context.read<AppState>();
    final controller = TextEditingController(text: profile.name);
    return GlassModalSheet.show<void>(
      context: context,
      topBorderRadius: KpGlassStyle.sheetRadius,
      bottomBorderRadius: KpGlassStyle.sheetRadius,
      settings: KpGlassStyle.sheet,
      initialState: GlassSheetState.full,
      detents: const {GlassSheetDetent.large},
      builder: (context) {
        final palette = KpPalette.of(context);
        void save() {
          final name = controller.text.trim();
          if (name.isEmpty) return;
          state.updateProfile(profile.copyWith(name: name));
          Navigator.of(context).pop();
        }

        return Material(
          type: MaterialType.transparency,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(l.renameProfile, style: KpText.title(palette.ink, size: 28)),
                const SizedBox(height: 16),
                KpTextField(controller: controller, hint: l.profileNameHint, onSubmitted: (_) => save()),
                const SizedBox(height: 18),
                KpPrimaryButton(label: l.save, onPressed: save),
              ],
            ),
          ),
        );
      },
    ).whenComplete(controller.dispose);
  }

  Future<void> _delete(BuildContext context, Profile profile) {
    final l = AppLocalizations.of(context);
    final state = context.read<AppState>();
    final navigator = Navigator.of(context);
    return GlassDialog.show<void>(
      context: context,
      title: l.deleteProfileTitle(profile.name),
      message: l.deleteProfileBody,
      actions: [
        GlassDialogAction(label: l.cancel, isPrimary: true, onPressed: () => Navigator.of(context).pop()),
        GlassDialogAction(
          label: l.delete,
          isDestructive: true,
          onPressed: () {
            Navigator.of(context).pop();
            if (standalone) navigator.pop();
            state.deleteProfile(profile.id);
          },
        ),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});

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
          Text(value, style: KpText.title(palette.ink, size: 24)),
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

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final palette = KpPalette.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 6, bottom: 8),
          child: Text(title, style: KpText.label(palette.inkSoft, size: 14, weight: FontWeight.w900)),
        ),
        KpGlassCard(
          radius: 26,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Column(
            children: [
              for (var i = 0; i < children.length; i++) ...[
                if (i > 0) Divider(height: 1, color: palette.inkSoft.withValues(alpha: 0.15)),
                children[i],
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.icon,
    required this.title,
    this.value,
    this.trailing,
    this.onTap,
    this.destructive = false,
  });

  final KpIcons icon;
  final String title;
  final String? value;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final palette = KpPalette.of(context);
    final color = destructive ? const Color(0xFFB3261E) : palette.ink;
    return Semantics(
      button: onTap != null,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 56),
          child: Row(
            children: [
              KpIcon(icon, size: 22, color: destructive ? color : palette.accent),
              const SizedBox(width: 14),
              Expanded(child: Text(title, style: KpText.label(color, size: 16))),
              if (value != null) Text(value!, style: KpText.label(palette.inkSoft, size: 15, weight: FontWeight.w700)),
              ?trailing,
              if (onTap != null && trailing == null) ...[
                const SizedBox(width: 6),
                KpIcon(KpIcons.chevronRight, size: 18, color: palette.inkSoft, strokeWidth: 2.5),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
