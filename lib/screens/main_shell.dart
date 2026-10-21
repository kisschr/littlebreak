import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

import '../design/components.dart';
import '../design/icons.dart';
import '../design/palette.dart';
import '../l10n/generated/app_localizations.dart';
import 'calendar_screen.dart';
import 'gallery_screen.dart';
import 'profile_screen.dart';
import 'today_screen.dart';

/// The adults' app: Heute, Kalender, Galerie, Profil in a glass tab bar.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int tab = 0;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final palette = KpPalette.of(context);
    return GlassScaffold(
      settings: KpGlassStyle.of(context),
      background: KpBackground(variant: tab),
      bottomBar: KpTabBar(
        selectedIndex: tab,
        onTabSelected: (i) => setState(() => tab = i),
        items: [
          (KpIcons.sun, l.tabToday),
          (KpIcons.calendar, l.tabCalendar),
          (KpIcons.gallery, l.tabGallery),
          (KpIcons.person, l.tabProfile),
        ],
        palette: palette,
      ),
      body: IndexedStack(
        index: tab,
        children: [
          TodayScreen(onOpenProfile: () => setState(() => tab = 3)),
          const CalendarScreen(),
          const GalleryScreen(),
          const ProfileScreen(),
        ],
      ),
    );
  }
}

/// GlassTabBar.bottom styled like the designs (copper selected, soft ink
/// otherwise); kids get a taller bar with bigger icons.
class KpTabBar extends StatelessWidget {
  const KpTabBar({
    super.key,
    required this.selectedIndex,
    required this.onTabSelected,
    required this.items,
    required this.palette,
    this.large = false,
  });

  final int selectedIndex;
  final ValueChanged<int> onTabSelected;
  final List<(KpIcons, String)> items;
  final KpPalette palette;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final iconSize = large ? 28.0 : 22.0;
    final selectedColor = large ? palette.successText : palette.accent;
    return GlassTabBar.bottom(
      selectedIndex: selectedIndex,
      onTabSelected: onTabSelected,
      barHeight: large ? 80 : 68,
      iconSize: iconSize,
      labelFontSize: large ? 14 : 12,
      settings: large ? KpGlassStyle.kidsSurface : KpGlassStyle.surface,
      indicatorColor: Colors.white.withValues(alpha: large ? 0.75 : 0.65),
      selectedIconColor: selectedColor,
      unselectedIconColor: palette.inkSoft,
      selectedLabelColor: selectedColor,
      unselectedLabelColor: palette.inkSoft,
      selectedLabelStyle: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w900, fontSize: large ? 14 : 12),
      unselectedLabelStyle: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: large ? 14 : 12),
      tabs: [
        for (var i = 0; i < items.length; i++)
          GlassTab(
            icon: KpIcon(items[i].$1, size: iconSize, color: palette.inkSoft),
            activeIcon: KpIcon(items[i].$1, size: iconSize, color: selectedColor),
            label: items[i].$2,
          ),
      ],
    );
  }
}
