import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app/app_state.dart';
import '../domain/models.dart';
import 'kids/kids_shell.dart';
import 'main_shell.dart';
import 'profile_picker_screen.dart';

/// Shows the profile picker until a profile is active, then the shell of
/// that profile's audience.
class RootScreen extends StatelessWidget {
  const RootScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profile = context.select<AppState, Profile?>((s) => s.activeProfile);
    final Widget child = switch (profile?.audience) {
      null => const ProfilePickerScreen(),
      Audience.adult => MainShell(key: ValueKey(profile!.id)),
      Audience.kid => KidsShell(key: ValueKey(profile!.id)),
    };
    return AnimatedSwitcher(duration: const Duration(milliseconds: 300), child: child);
  }
}
