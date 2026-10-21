import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../design/components.dart';
import '../../design/palette.dart';
import '../../domain/models.dart';
import '../../l10n/generated/app_localizations.dart';
import '../game_framework.dart';

class BreathingDefinition extends GameDefinition {
  const BreathingDefinition();

  @override
  GameType get type => GameType.breathing;

  static int breathsFor(Difficulty d) => switch (d) {
        Difficulty.easy => 4,
        Difficulty.standard => 8,
        Difficulty.advanced => 12,
      };

  /// Seconds for in, hold, out.
  static (int, int, int) rhythmFor(Difficulty d) => switch (d) {
        Difficulty.easy => (4, 1, 5),
        Difficulty.standard => (4, 2, 6),
        Difficulty.advanced => (4, 4, 6),
      };

  @override
  int minutes(Difficulty d) {
    final (a, b, c) = rhythmFor(d);
    return ((a + b + c) * breathsFor(d) / 60).ceil();
  }

  @override
  String levelDetail(AppLocalizations l, Difficulty d) => l.detailBreaths(breathsFor(d), minutes(d));

  @override
  bool get showsTimer => false;

  @override
  Widget build(BuildContext context, GameSession session) => BreathingGame(session: session);
}

enum BreathPhase { inhale, hold, exhale }

class BreathingGame extends StatefulWidget {
  const BreathingGame({super.key, required this.session});

  final GameSession session;

  @override
  State<BreathingGame> createState() => _BreathingGameState();
}

class _BreathingGameState extends State<BreathingGame> with SingleTickerProviderStateMixin {
  late final Ticker _ticker = createTicker(_tick);
  late final (int, int, int) rhythm = BreathingDefinition.rhythmFor(widget.session.difficulty);
  late final int breaths = BreathingDefinition.breathsFor(widget.session.difficulty);
  double elapsed = 0;
  Duration _last = Duration.zero;
  bool running = false;

  GameController get controller => widget.session.controller;

  int get cycle => rhythm.$1 + rhythm.$2 + rhythm.$3;

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _start() {
    setState(() => running = true);
    _ticker.start();
  }

  void _tick(Duration now) {
    final dt = (now - _last).inMicroseconds / 1e6;
    _last = now;
    if (controller.paused) return;
    setState(() => elapsed += dt);
    if (elapsed >= cycle * breaths) {
      _ticker.stop();
      controller.complete(const GameOutcome(stars: 3));
    }
  }

  (BreathPhase, double) get _phase {
    final t = elapsed % cycle;
    if (t < rhythm.$1) return (BreathPhase.inhale, t / rhythm.$1);
    if (t < rhythm.$1 + rhythm.$2) return (BreathPhase.hold, 1);
    return (BreathPhase.exhale, 1 - (t - rhythm.$1 - rhythm.$2) / rhythm.$3);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final palette = KpPalette.of(context);
    final (phase, scale) = _phase;
    final current = (elapsed ~/ cycle + 1).clamp(1, breaths);
    final label = switch (phase) {
      BreathPhase.inhale => l.breatheIn,
      BreathPhase.hold => l.breatheHold,
      BreathPhase.exhale => l.breatheOut,
    };
    return Column(
      children: [
        GameBoard(
          child: SizedBox(
            height: 380,
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: palette.boardRelated),
                  ),
                  Container(
                    width: 120 + 180 * (running ? Curves.easeInOut.transform(scale) : 0.3),
                    height: 120 + 180 * (running ? Curves.easeInOut.transform(scale) : 0.3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(colors: [palette.highlight, palette.blobs[0]]),
                      boxShadow: [BoxShadow(color: palette.blobs[0].withValues(alpha: 0.5), blurRadius: 40)],
                    ),
                  ),
                  Semantics(
                    liveRegion: true,
                    child: Text(running ? label : l.breatheReady, style: KpText.title(palette.ink, size: 26)),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 18),
        GameStatusLine(parts: [l.breathOf(current, breaths)]),
        const SizedBox(height: 18),
        if (!running) KpPrimaryButton(label: l.start, onPressed: _start),
      ],
    );
  }
}
