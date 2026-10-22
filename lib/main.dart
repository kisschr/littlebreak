import 'dart:async';

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

/// Steps of the start that may touch the platform and could hang on some
/// devices. None of them may keep the app from drawing its first frame.
const Duration _startupStepTimeout = Duration(seconds: 6);

void main() {
  runZonedGuarded(_start, (error, stack) {
    debugPrint('[KleinePause] Uncaught error: $error\n$stack');
  });
}

Future<void> _start() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Draw something right away, so a slow or failing step below can never
  // leave the user in front of an empty launch screen.
  runApp(const _BootScreen());

  try {
    await _step('glass shaders', LiquidGlassWidgets.initialize);
    final prefs = await _step('preferences', SharedPreferences.getInstance);
    final store = JsonStore(prefs);
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
  } catch (error, stack) {
    debugPrint('[KleinePause] Start failed: $error\n$stack');
    runApp(_BootScreen(error: error));
  }
}

/// Runs one start step with a timeout and logs how long it took. A glass
/// warm-up that fails or times out is not fatal: the shaders load lazily.
Future<T> _step<T>(String name, Future<T> Function() run) async {
  final watch = Stopwatch()..start();
  try {
    final result = await run().timeout(_startupStepTimeout);
    debugPrint('[KleinePause] $name ready after ${watch.elapsedMilliseconds} ms');
    return result;
  } catch (error) {
    debugPrint('[KleinePause] $name failed after ${watch.elapsedMilliseconds} ms: $error');
    if (null is T) return null as T;
    rethrow;
  }
}

/// Cream screen shown while starting; shows the reason if the start failed,
/// so a report from a device says what went wrong.
class _BootScreen extends StatelessWidget {
  const _BootScreen({this.error});

  final Object? error;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: ColoredBox(
        color: const Color(0xFFF7E6D4),
        child: error == null
            ? const SizedBox.expand()
            : Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'Kleine Pause konnte nicht starten.\n\n$error',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Color(0xFF2B1A10), fontSize: 16),
                  ),
                ),
              ),
      ),
    );
  }
}
