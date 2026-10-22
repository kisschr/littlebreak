// Renders the store screenshots for every device size and language.
//
//   flutter test test/store --dart-define=STORE_SHOTS=true
//
// The PNGs land in build/store_screenshots/<device>/<language>/. Without the
// define the test is skipped, so the normal test run stays fast.
//
// Widget tests draw without the liquid glass shaders, so the glass shows as
// its frosted fallback; layout, type and colours are the app's own.
@TestOn('vm')
library;

import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:kleine_pause/app/app.dart';
import 'package:kleine_pause/app/app_state.dart';
import 'package:kleine_pause/core/dates.dart';
import 'package:kleine_pause/data/device_services.dart';
import 'package:kleine_pause/data/premium.dart';
import 'package:kleine_pause/data/quote_quiz.dart';
import 'package:kleine_pause/data/repositories.dart';
import 'package:kleine_pause/domain/models.dart';
import 'package:kleine_pause/games/coloring/motifs.dart';
import 'package:kleine_pause/games/game_framework.dart';
import 'package:kleine_pause/l10n/generated/app_localizations.dart';
import 'package:kleine_pause/screens/kids/sticker.dart';
import 'package:kleine_pause/screens/kids/stickers_screen.dart';
import 'package:kleine_pause/screens/main_shell.dart';
import 'package:kleine_pause/screens/play/game_screen.dart';
import 'package:kleine_pause/screens/play/play_flow.dart';
import 'package:kleine_pause/screens/play/result_screen.dart';
import 'package:kleine_pause/widgets/ads.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _enabled = bool.fromEnvironment('STORE_SHOTS');

/// A store slot: pixel size, density and the system bars it reserves.
class _Device {
  const _Device(this.name, this.size, this.ratio, this.top, this.bottom);

  final String name;
  final Size size;
  final double ratio;
  final double top;
  final double bottom;
}

const _devices = [
  // Google Play phone (9:16, 1080 × 1920).
  _Device('android_phone', Size(1080, 1920), 2.625, 24, 16),
  // App Store iPhone 6.9" (1320 × 2868), the one size Apple requires.
  _Device('iphone_6_9', Size(1320, 2868), 3, 62, 34),
  // App Store iPad 13" (2064 × 2752).
  _Device('ipad_13', Size(2064, 2752), 2, 24, 20),
];

/// Thursday 22 October 2026: a logic day, with three weeks of history.
final _today = DateTime(2026, 10, 22, 10);

void main() {
  for (final device in _devices) {
    for (final lang in ['de', 'en']) {
      testWidgets('${device.name} $lang', skip: !_enabled, (tester) async {
        final shots = _Shots(tester, device, lang);
        final state = await _seededState(lang);
        await tester.runAsync(() => state.contentFor(lang));
        await shots.pumpApp(state);

        await shots.take('01_today');

        final shell = tester.element(find.byType(MainShell));
        final plan = state.planFor(_today);
        unawaited(PlayFlow.chooseLevel(shell, plan));
        await shots.settle();
        await shots.take('02_level');
        Navigator.of(shell).pop();
        await shots.settle();

        unawaited(Navigator.of(shell).push(GameScreen.route(plan: plan, difficulty: Difficulty.standard)));
        await shots.settle();
        // The content future completed outside the fake clock; let it deliver.
        await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
        await shots.settle();
        await shots.take('03_game');
        Navigator.of(shell).pop();
        await shots.settle();

        unawaited(
          Navigator.of(shell).push(
            ResultScreen.route(
              GameSummary(
                plan: state.planFor(_today.subtract(const Duration(days: 1))),
                difficulty: Difficulty.standard,
                stars: 3,
                seconds: 194,
                stat: GameStat.mistakes,
                statValue: 0,
              ),
            ),
          ),
        );
        await shots.settle();
        await shots.take('04_result');
        Navigator.of(shell).pop();
        await shots.settle();

        final l = lookupAppLocalizations(Locale(lang));
        await shots.tapTab(l.tabCalendar);
        await shots.take('05_calendar');
        await shots.tapTab(l.tabGallery);
        await shots.take('06_gallery');

        await state.selectProfile(state.profiles.firstWhere((p) => p.isKid).id);
        await shots.settle();
        await shots.take('07_kids');

        await shots.tapTab(l.tabStickers);
        await shots.take('08_stickers');
        final stickerContext = tester.element(find.byType(StickersScreen));
        unawaited(showSticker(stickerContext, DateTime(_today.year, _today.month, 5)));
        await shots.settle();
        await shots.take('09_sticker');
        Navigator.of(stickerContext).pop();
        await shots.settle();
        unawaited(Navigator.of(stickerContext).push(FreeColoringScreen.route('hedgehog')));
        await shots.settle();
        await shots.take('10_free_coloring');
      });
    }
  }
}

Future<AppState> _seededState(String lang) async {
  SharedPreferences.setMockInitialValues({});
  final store = JsonStore(await SharedPreferences.getInstance());
  // Profiles exist since the first of the month, so the streak counts.
  var now = DateTime(_today.year, _today.month);
  final state = AppState(
    profiles: ProfileRepository(store),
    progress: ProgressRepository(store),
    settings: SettingsRepository(store),
    purchases: LocalPurchaseService(store, simulatePurchases: true),
    reminders: SilentReminderService(),
    speech: SilentSpeechService(),
    quotes: QuoteQuizRepository(
      api: QuoteQuizApi(client: MockClient((_) async => http.Response('[]', 200))),
      store: store,
    ),
    clock: () => now,
  )..load();
  await state.setLocale(lang);
  final kid = await state.createProfile(name: lang == 'de' ? 'Lena' : 'Emma', audience: Audience.kid);
  final adult = await state.createProfile(name: lang == 'de' ? 'Christoph' : 'Sam', audience: Audience.adult);
  await state.selectProfile(adult.id);
  now = _today;
  for (final type in GameType.values) {
    await state.markTutorialSeen(type);
  }

  // Three weeks of play: mostly three stars, a few gaps, Today still open.
  for (var d = 1; d < _today.day; d++) {
    if (d == 6 || d == 13) continue;
    final date = DateTime(_today.year, _today.month, d);
    final plan = state.planFor(date);
    await state.recordResult(
      plan,
      Difficulty.standard,
      LevelResult(stars: d % 5 == 0 ? 2 : 3, seconds: 150 + d * 7, mistakes: d % 5 == 0 ? 1 : 0, completedAt: date),
    );
  }

  // The kid has played most days too, for a full sticker row.
  await state.selectProfile(kid.id);
  for (var d = 1; d < _today.day; d++) {
    if (d == 9) continue;
    final date = DateTime(_today.year, _today.month, d);
    await state.recordResult(
      state.planFor(date),
      Difficulty.easy,
      LevelResult(stars: 3, seconds: 120, mistakes: 0, completedAt: date),
    );
  }
  await state.selectProfile(adult.id);

  // Coloured pictures for the gallery.
  for (final (i, id) in ['pumpkin', 'leaf', 'hedgehog', 'mushroom', 'butterfly', 'sun'].indexed) {
    final motif = Motifs.byId(id);
    await state.addToGallery(
      GalleryItem(
        dateKey: dateKey(DateTime(_today.year, _today.month, 19 - i * 7 % 18)),
        gameId: GameType.coloring.id,
        motif: id,
        difficulty: Difficulty.standard,
        colors: [for (final r in motif.regions) kCrayons[r.crayon].toARGB32()],
      ),
    );
  }
  return state;
}

class _Shots {
  _Shots(this.tester, this.device, this.lang);

  final WidgetTester tester;
  final _Device device;
  final String lang;

  Future<void> pumpApp(AppState state) async {
    final pad = FakeViewPadding(top: device.top * device.ratio, bottom: device.bottom * device.ratio);
    tester.view
      ..physicalSize = device.size
      ..devicePixelRatio = device.ratio
      ..padding = pad
      ..viewPadding = pad;
    tester.platformDispatcher
      ..localeTestValue = Locale(lang)
      ..localesTestValue = [Locale(lang)]
      ..accessibilityFeaturesTestValue = const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearAllTestValues);
    await tester.pumpWidget(KleinePauseApp(state: state, ads: const HouseAdService()));
    await settle();
  }

  /// The background keeps animating, so settle with a bounded number of frames.
  Future<void> settle() async {
    for (var i = 0; i < 30; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  Future<void> tapTab(String label) async {
    await tester.tap(find.text(label).last, warnIfMissed: false);
    await settle();
  }

  Future<void> take(String name) async {
    final element = find.byType(MaterialApp).evaluate().single;
    final bytes = await tester.runAsync(() async {
      final image = await captureImage(element);
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      image.dispose();
      return data!.buffer.asUint8List();
    });
    final file = File('build/store_screenshots/${device.name}/$lang/$name.png');
    file.parent.createSync(recursive: true);
    file.writeAsBytesSync(bytes!);
  }
}
