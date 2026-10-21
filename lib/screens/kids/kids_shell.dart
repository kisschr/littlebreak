import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

import '../../design/components.dart';
import '../../design/icons.dart';
import '../../design/palette.dart';
import '../../l10n/generated/app_localizations.dart';
import '../calendar_screen.dart';
import '../main_shell.dart';
import 'kids_today_screen.dart';
import 'stickers_screen.dart';

/// The kids' app: Heute, Kalender, Sticker with bigger targets.
class KidsShell extends StatefulWidget {
  const KidsShell({super.key});

  @override
  State<KidsShell> createState() => _KidsShellState();
}

class _KidsShellState extends State<KidsShell> {
  int tab = 0;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return GlassScaffold(
      settings: KpGlassStyle.of(context),
      background: KpBackground(variant: tab == 0 ? 2 : tab),
      bottomBar: KpTabBar(
        large: true,
        selectedIndex: tab,
        onTabSelected: (i) => setState(() => tab = i),
        palette: KpPalette.of(context),
        items: [(KpIcons.sun, l.tabToday), (KpIcons.calendar, l.tabCalendar), (KpIcons.star, l.tabStickers)],
      ),
      body: IndexedStack(index: tab, children: const [KidsTodayScreen(), CalendarScreen(), StickersScreen()]),
    );
  }
}
