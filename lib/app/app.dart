import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import '../design/palette.dart';
import '../l10n/generated/app_localizations.dart';
import '../screens/root_screen.dart';
import '../widgets/ads.dart';
import 'app_state.dart';

class KleinePauseApp extends StatefulWidget {
  const KleinePauseApp({super.key, required this.state, required this.ads});

  final AppState state;
  final AdService ads;

  @override
  State<KleinePauseApp> createState() => _KleinePauseAppState();
}

class _KleinePauseAppState extends State<KleinePauseApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // A new day may have started while the app was in the background.
    if (state == AppLifecycleState.resumed) widget.state.refreshDay();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AppState>.value(value: widget.state),
        Provider<AdService>.value(value: widget.ads),
      ],
      child: Consumer<AppState>(
        builder: (context, state, _) {
          final code = state.settings.localeCode;
          return MaterialApp(
            title: 'Kleine Pause',
            debugShowCheckedModeBanner: false,
            locale: code == null ? null : Locale(code),
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            localeResolutionCallback: resolveLocale,
            theme: buildTheme(KpPalette.resolve(today: state.today, audience: state.audience)),
            builder: (context, child) => KpPaletteScope(
              palette: KpPalette.resolve(today: state.today, audience: state.audience),
              // Glass scaffolds are not Material; switches, text fields and
              // ink effects on every route need a Material ancestor.
              child: Material(
                type: MaterialType.transparency,
                child: _QuoteRefresher(child: child!),
              ),
            ),
            home: const RootScreen(),
          );
        },
      ),
    );
  }
}

/// Device language if supported, English otherwise.
Locale resolveLocale(Locale? device, Iterable<Locale> supported) {
  for (final l in supported) {
    if (l.languageCode == device?.languageCode) return l;
  }
  return const Locale('en');
}

ThemeData buildTheme(KpPalette palette) => ThemeData(
      useMaterial3: true,
      fontFamily: 'Nunito',
      scaffoldBackgroundColor: palette.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: palette.accent,
        primary: palette.accent,
        surface: palette.board,
        onSurface: palette.ink,
      ),
      textSelectionTheme: TextSelectionThemeData(cursorColor: palette.accent),
      splashFactory: NoSplash.splashFactory,
    );

/// Fetches fresh QuizQuiz questions once the UI language is known.
class _QuoteRefresher extends StatefulWidget {
  const _QuoteRefresher({required this.child});

  final Widget child;

  @override
  State<_QuoteRefresher> createState() => _QuoteRefresherState();
}

class _QuoteRefresherState extends State<_QuoteRefresher> {
  String? _lang;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final lang = Localizations.localeOf(context).languageCode;
    if (lang != _lang) {
      _lang = lang;
      unawaited(context.read<AppState>().quotes.refresh(lang));
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
