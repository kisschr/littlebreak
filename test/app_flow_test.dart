import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:kleine_pause/app/app.dart';
import 'package:kleine_pause/app/app_state.dart';
import 'package:kleine_pause/data/device_services.dart';
import 'package:kleine_pause/data/premium.dart';
import 'package:kleine_pause/data/quote_quiz.dart';
import 'package:kleine_pause/data/repositories.dart';
import 'package:kleine_pause/domain/models.dart';
import 'package:kleine_pause/screens/kids/sticker.dart';
import 'package:kleine_pause/screens/play/result_screen.dart';
import 'package:kleine_pause/widgets/ads.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Wednesday 21 October 2026: the adults' game is "Wahr oder falsch".
final _today = DateTime(2026, 10, 21, 10);

Future<AppState> _state() async {
  SharedPreferences.setMockInitialValues({});
  final store = JsonStore(await SharedPreferences.getInstance());
  return AppState(
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
    clock: () => _today,
  )..load();
}

Future<void> _pumpApp(WidgetTester tester, AppState state) async {
  tester.view
    ..physicalSize = const Size(1170, 2532)
    ..devicePixelRatio = 3;
  tester.platformDispatcher
    ..localeTestValue = const Locale('de')
    ..localesTestValue = const [Locale('de')]
    ..accessibilityFeaturesTestValue = const FakeAccessibilityFeatures(disableAnimations: true);
  addTearDown(tester.view.reset);
  addTearDown(tester.platformDispatcher.clearAllTestValues);
  await tester.pumpWidget(KleinePauseApp(state: state, ads: const HouseAdService()));
  await _settle(tester);
}

/// The background keeps animating, so settle with a bounded number of frames.
Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 30; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

Future<void> _tapText(WidgetTester tester, String text) async {
  final finder = find.text(text).last;
  await tester.ensureVisible(finder);
  await tester.pump();
  await tester.tap(finder, warnIfMissed: false);
  await _settle(tester);
}

void main() {
  testWidgets('new adult profile plays today\'s game to the result', (tester) async {
    final state = await _state();
    await _pumpApp(tester, state);

    // Profile picker → create an adult profile.
    expect(find.text('Neues Profil'), findsWidgets);
    await _tapText(tester, 'Erwachsene');
    await tester.enterText(find.byType(EditableText).first, 'Christoph');
    await _tapText(tester, 'Profil anlegen');
    expect(state.activeProfile?.name, 'Christoph');

    // Today → open the day → pick the level → how-to.
    expect(find.text('Wahr oder falsch'), findsWidgets);
    await _tapText(tester, 'Türchen öffnen');
    await _tapText(tester, 'Standard starten');
    await _tapText(tester, 'Los geht’s');

    // Answer all statements.
    for (var i = 0; i < 8; i++) {
      await _tapText(tester, 'Wahr');
      await _tapText(tester, i == 7 ? 'Fertig' : 'Weiter');
    }
    expect(find.byType(ResultScreen), findsOneWidget);
    final record = state.recordFor(_today)!;
    expect(record.levels.keys, [Difficulty.standard]);
    expect(state.streak, 1);

    // Free adults see the ad slot after the game.
    expect(find.byType(AdSlot), findsOneWidget);
    SemanticsBinding.instance.ensureSemantics().dispose();
  });

  testWidgets('kids profile shows the kids home without ads', (tester) async {
    final state = await _state();
    await state.createProfile(name: 'Mia', audience: Audience.kid);
    await _pumpApp(tester, state);
    expect(find.textContaining('Mia'), findsWidgets);
    expect(find.byType(AdSlot), findsNothing);
  });

  testWidgets('a coloured sticker is kept and continues where it was left', (tester) async {
    final state = await _state();
    await state.createProfile(name: 'Mia', audience: Audience.kid);
    await _pumpApp(tester, state);
    final day = DateTime(2026, 10, 5);
    final navigator = tester.state<NavigatorState>(find.byType(Navigator).first);

    unawaited(navigator.push(FreeColoringScreen.route(day)));
    await _settle(tester);
    // Paint the whole board once: every region gets the first crayon.
    final board = find.bySemanticsLabel('Ausmalbild');
    final box = tester.getRect(board);
    for (var y = 0.1; y < 1; y += 0.1) {
      for (var x = 0.1; x < 1; x += 0.1) {
        await tester.tapAt(Offset(box.left + box.width * x, box.top + box.height * y));
      }
    }
    await tester.pump();
    navigator.pop();
    await _settle(tester);

    final saved = state.gallery.singleWhere((g) => g.gameId == Stickers.galleryId);
    expect(saved.dateKey, '2026-10-05');
    final painted = saved.colors.where((c) => c != null).length;
    expect(painted, greaterThan(0));

    unawaited(navigator.push(FreeColoringScreen.route(day)));
    await _settle(tester);
    final restored = tester.state(find.byType(FreeColoringScreen)) as dynamic;
    expect((restored.fills as List).where((f) => f != null).length, painted);
  });
}
