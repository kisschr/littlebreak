import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:provider/provider.dart';

import '../app/app_state.dart';
import '../design/components.dart';
import '../design/icons.dart';
import '../design/palette.dart';
import '../domain/models.dart';
import '../l10n/generated/app_localizations.dart';
import '../l10n/texts.dart';
import '../widgets/page.dart';

/// "Wer spielt heute?" — choose or create a profile.
class ProfilePickerScreen extends StatelessWidget {
  const ProfilePickerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final palette = KpPalette.of(context);
    final state = context.watch<AppState>();
    final profiles = state.profiles;
    return KpPage(
      variant: 2,
      padding: const EdgeInsets.fromLTRB(24, 40, 24, 0),
      spacing: 22,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l.pickerOverline, style: KpText.label(palette.inkSoft)),
            const SizedBox(height: 6),
            Text(profiles.isEmpty ? l.pickerWelcome : l.pickerTitle, style: KpText.display(palette.ink, size: 38)),
            const SizedBox(height: 10),
            Text(l.pickerBody, style: KpText.body(palette.inkSoft)),
          ],
        ),
        for (final p in profiles)
          ProfileCard(
            profile: p,
            subtitle: [
              p.audience == Audience.kid ? l.audienceKids : l.audienceAdults,
              l.difficultyName(p.lastDifficulty),
              l.streakSeries(state.streakOf(p)),
            ].join(' · '),
            onTap: () => context.read<AppState>().selectProfile(p.id),
          ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l.newProfile, style: KpText.label(palette.ink, weight: FontWeight.w900)),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _NewProfileTile(
                    icon: KpIcons.person,
                    iconColor: palette.accent,
                    title: l.audienceAdults,
                    body: l.audienceAdultsBody,
                    onTap: () => showCreateProfileSheet(context, Audience.adult),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _NewProfileTile(
                    icon: KpIcons.kid,
                    iconColor: palette.success,
                    title: l.audienceKids,
                    body: l.audienceKidsBody,
                    onTap: () => showCreateProfileSheet(context, Audience.kid),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

/// A whole-card tappable profile row.
class ProfileCard extends StatelessWidget {
  const ProfileCard({super.key, required this.profile, required this.subtitle, required this.onTap});

  final Profile profile;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = KpPalette.of(context);
    return KpGlassCard(
      radius: 30,
      padding: const EdgeInsets.all(20),
      onTap: onTap,
      semanticLabel: '${profile.name}, $subtitle',
      child: Row(
        children: [
          KpAvatar(initial: profile.initial, color: kpAvatarColors[profile.colorIndex % kpAvatarColors.length]),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(profile.name, style: KpText.title(palette.ink), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 3),
                Text(subtitle, style: KpText.label(palette.inkSoft, size: 14, weight: FontWeight.w700)),
              ],
            ),
          ),
          KpIcon(KpIcons.chevronRight, size: 20, color: palette.inkSoft, strokeWidth: 2.5),
        ],
      ),
    );
  }
}

class _NewProfileTile extends StatelessWidget {
  const _NewProfileTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.body,
    required this.onTap,
  });

  final KpIcons icon;
  final Color iconColor;
  final String title;
  final String body;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = KpPalette.of(context);
    return KpGlassCard(
      radius: 24,
      padding: const EdgeInsets.fromLTRB(14, 18, 14, 18),
      onTap: onTap,
      semanticLabel: title,
      child: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            KpIcon(icon, size: 26, color: iconColor),
            const SizedBox(height: 8),
            Text(title, style: KpText.label(palette.ink, size: 17, weight: FontWeight.w900)),
            const SizedBox(height: 8),
            Text(body, style: KpText.label(palette.inkSoft, size: 13, weight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}

/// Asks for a name and creates the profile.
Future<void> showCreateProfileSheet(BuildContext context, Audience audience) {
  return GlassModalSheet.show<void>(
    context: context,
    topBorderRadius: KpGlassStyle.sheetRadius,
    bottomBorderRadius: KpGlassStyle.sheetRadius,
    settings: KpGlassStyle.sheet,
    detents: const {GlassSheetDetent.large},
    initialState: GlassSheetState.full,
    builder: (_) => _CreateProfileSheet(audience: audience, state: context.read<AppState>()),
  );
}

class _CreateProfileSheet extends StatefulWidget {
  const _CreateProfileSheet({required this.audience, required this.state});

  final Audience audience;
  final AppState state;

  @override
  State<_CreateProfileSheet> createState() => _CreateProfileSheetState();
}

class _CreateProfileSheetState extends State<_CreateProfileSheet> {
  final _name = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    final name = _name.text.trim();
    if (name.isEmpty) return;
    Navigator.of(context).pop();
    await widget.state.createProfile(name: name, audience: widget.audience);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final palette = KpPalette.of(context);
    final kid = widget.audience == Audience.kid;
    return Material(
      type: MaterialType.transparency,
      child: Padding(
      padding: EdgeInsets.fromLTRB(20, 24, 20, 24 + MediaQuery.viewInsetsOf(context).bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(kid ? l.audienceKids : l.audienceAdults, style: KpText.label(palette.inkSoft, size: 14)),
          Text(l.createProfileTitle, style: KpText.title(palette.ink, size: 28)),
          const SizedBox(height: 16),
          KpTextField(controller: _name, hint: l.profileNameHint, onSubmitted: (_) => _create()),
          const SizedBox(height: 10),
          Text(kid ? l.createKidNote : l.createAdultNote, style: KpText.label(palette.inkSoft, size: 14, weight: FontWeight.w700)),
          const SizedBox(height: 18),
          ListenableBuilder(
            listenable: _name,
            builder: (context, _) => KpPrimaryButton(
              label: l.createProfile,
              color: kid ? palette.success : null,
              onPressed: _name.text.trim().isEmpty ? null : _create,
            ),
          ),
        ],
      ),
      ),
    );
  }
}

/// Opaque white text field used inside glass sheets.
class KpTextField extends StatelessWidget {
  const KpTextField({super.key, required this.controller, required this.hint, this.onSubmitted});

  final TextEditingController controller;
  final String hint;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    final palette = KpPalette.of(context);
    return TextField(
      controller: controller,
      autofocus: true,
      maxLength: 20,
      textCapitalization: TextCapitalization.words,
      textInputAction: TextInputAction.done,
      onSubmitted: onSubmitted,
      style: KpText.title(palette.ink, size: 20),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: KpText.title(palette.inkSoft.withValues(alpha: 0.5), size: 20),
        counterText: '',
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.9),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: palette.accent, width: 2),
        ),
      ),
    );
  }
}
