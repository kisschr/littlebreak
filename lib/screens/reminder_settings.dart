import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app/app_state.dart';
import '../design/components.dart';
import '../design/palette.dart';
import '../l10n/generated/app_localizations.dart';
import '../widgets/sheet.dart';
import '../widgets/dialog.dart';

/// "8:00" / "8:00 AM" in the user's locale.
String formatTime(BuildContext context, int hour, int minute) =>
    MaterialLocalizations.of(context).formatTimeOfDay(TimeOfDay(hour: hour, minute: minute));

/// Daily reminder: on/off and time.
Future<void> showReminderSettings(BuildContext context) => showKpSheet<void>(
      context: context,
      halfSize: 0.42,
      builder: (_) => const Material(type: MaterialType.transparency, child: SingleChildScrollView(child: ReminderPanel())),
    );

class ReminderPanel extends StatelessWidget {
  const ReminderPanel({super.key});

  Future<void> _set(BuildContext context, {required bool enabled, int? hour, int? minute}) async {
    final l = AppLocalizations.of(context);
    final ok = await context.read<AppState>().setReminder(
          enabled: enabled,
          hour: hour,
          minute: minute,
          title: l.reminderTitle,
          body: l.reminderBody,
        );
    if (!ok && context.mounted) {
      await KpDialog.show<void>(
        context: context,
        title: l.reminderDeniedTitle,
        message: l.reminderDeniedBody,
        actions: [KpDialogAction(label: l.ok, isPrimary: true, onPressed: () => Navigator.of(context).pop())],
      );
    }
  }

  Future<void> _pickTime(BuildContext context) async {
    final s = context.read<AppState>().settings;
    final picked = await showTimePicker(context: context, initialTime: TimeOfDay(hour: s.reminderHour, minute: s.reminderMinute));
    if (picked != null && context.mounted) {
      await _set(context, enabled: true, hour: picked.hour, minute: picked.minute);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final palette = KpPalette.of(context);
    final settings = context.watch<AppState>().settings;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l.reminderSettingTitle, style: KpText.title(palette.ink, size: 28)),
          const SizedBox(height: 6),
          Text(l.reminderExplain, style: KpText.body(palette.inkSoft)),
          const SizedBox(height: 16),
          OpaqueRow(
            title: l.reminderDaily,
            trailing: Switch(
              value: settings.reminderEnabled,
              activeTrackColor: palette.accent,
              onChanged: (v) => _set(context, enabled: v),
            ),
          ),
          const SizedBox(height: 10),
          OpaqueRow(
            title: l.reminderTime,
            onTap: () => _pickTime(context),
            trailing: Text(
              formatTime(context, settings.reminderHour, settings.reminderMinute),
              style: KpText.label(palette.accent, size: 17, weight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }
}

/// White settings row for use inside glass sheets.
class OpaqueRow extends StatelessWidget {
  const OpaqueRow({super.key, required this.title, this.subtitle, this.trailing, this.onTap, this.leading});

  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final palette = KpPalette.of(context);
    return Semantics(
      button: onTap != null,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 60),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.75), borderRadius: BorderRadius.circular(20)),
          child: Row(
            children: [
              if (leading != null) ...[leading!, const SizedBox(width: 12)],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(title, style: KpText.label(palette.ink, size: 16, weight: FontWeight.w900)),
                    if (subtitle != null)
                      Text(subtitle!, style: KpText.label(palette.inkSoft, size: 13, weight: FontWeight.w700)),
                  ],
                ),
              ),
              ?trailing,
            ],
          ),
        ),
      ),
    );
  }
}
