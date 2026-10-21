import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'app/app_state.dart';
import 'data/device_services.dart';
import 'data/premium.dart';
import 'data/quote_quiz.dart';
import 'data/repositories.dart';
import 'widgets/ads.dart';

/// Purchases succeed without a store in debug builds, or when built with
/// `--dart-define=SIMULATE_PURCHASES=true`, until a store is wired in.
const bool _simulatePurchases = bool.fromEnvironment('SIMULATE_PURCHASES', defaultValue: kDebugMode);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LiquidGlassWidgets.initialize();
  final store = JsonStore(await SharedPreferences.getInstance());
  final state = AppState(
    profiles: ProfileRepository(store),
    progress: ProgressRepository(store),
    settings: SettingsRepository(store),
    purchases: LocalPurchaseService(store, simulatePurchases: _simulatePurchases),
    reminders: LocalReminderService(),
    speech: TtsSpeechService(),
    quotes: QuoteQuizRepository(api: QuoteQuizApi(), store: store),
  )..load();
  runApp(
    LiquidGlassWidgets.wrap(
      brightnessResolver: Theme.maybeBrightnessOf,
      child: KleinePauseApp(state: state, ads: const HouseAdService()),
    ),
  );
}
