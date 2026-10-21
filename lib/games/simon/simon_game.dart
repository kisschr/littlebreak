import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../design/components.dart';
import '../../design/palette.dart';
import '../../domain/models.dart';
import '../../l10n/generated/app_localizations.dart';
import '../game_framework.dart';

class SimonDefinition extends GameDefinition {
  const SimonDefinition();

  @override
  GameType get type => GameType.simon;

  static int lengthFor(Difficulty d) => switch (d) {
        Difficulty.easy => 5,
        Difficulty.standard => 8,
        Difficulty.advanced => 12,
      };

  @override
  int minutes(Difficulty d) => switch (d) {
        Difficulty.easy => 1,
        Difficulty.standard => 3,
        Difficulty.advanced => 5,
      };

  @override
  String levelDetail(AppLocalizations l, Difficulty d) => l.detailSequence(lengthFor(d), minutes(d));

  @override
  Widget build(BuildContext context, GameSession session) => SimonGame(session: session);
}

class SimonGame extends StatefulWidget {
  const SimonGame({super.key, required this.session});

  final GameSession session;

  @override
  State<SimonGame> createState() => _SimonGameState();
}

class _SimonGameState extends State<SimonGame> {
  late final List<int> sequence;
  int round = 1;
  int inputIndex = 0;
  int? lit;
  bool playing = false;
  bool started = false;
  Timer? _timer;

  GameController get controller => widget.session.controller;

  @override
  void initState() {
    super.initState();
    final length = SimonDefinition.lengthFor(widget.session.difficulty);
    final random = widget.session.random();
    sequence = List.generate(length, (_) => random.nextInt(4));
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _playRound() async {
    setState(() {
      playing = true;
      started = true;
      inputIndex = 0;
    });
    final speed = widget.session.byLevel(650, 520, 420);
    await Future<void>.delayed(const Duration(milliseconds: 500));
    for (var i = 0; i < round; i++) {
      if (!mounted) return;
      while (controller.paused) {
        await Future<void>.delayed(const Duration(milliseconds: 200));
        if (!mounted) return;
      }
      setState(() => lit = sequence[i]);
      await Future<void>.delayed(Duration(milliseconds: speed));
      if (!mounted) return;
      setState(() => lit = null);
      await Future<void>.delayed(const Duration(milliseconds: 180));
    }
    if (mounted) setState(() => playing = false);
  }

  void _press(int pad) {
    if (playing || !started || controller.paused || controller.finished) return;
    HapticFeedback.selectionClick();
    setState(() => lit = pad);
    _timer?.cancel();
    _timer = Timer(const Duration(milliseconds: 220), () {
      if (mounted) setState(() => lit = null);
    });
    if (sequence[inputIndex] != pad) {
      controller.reportMistake();
      _playRound();
      return;
    }
    inputIndex++;
    if (inputIndex == round) {
      if (round == sequence.length) {
        controller.complete();
      } else {
        round++;
        _playRound();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final palette = KpPalette.of(context);
    final colors = [palette.accent, palette.highlight, palette.success, palette.blobs[3]];
    return Column(
      children: [
        GameBoard(
          padding: const EdgeInsets.all(14),
          child: AspectRatio(
            aspectRatio: 1,
            child: GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                for (var i = 0; i < 4; i++)
                  Semantics(
                    button: true,
                    label: l.simonPad(i + 1),
                    child: GestureDetector(
                      onTap: () => _press(i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 120),
                        decoration: BoxDecoration(
                          color: lit == i ? colors[i] : colors[i].withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: lit == i ? [BoxShadow(color: colors[i].withValues(alpha: 0.7), blurRadius: 24)] : null,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        GameStatusLine(parts: [l.roundOf(round, sequence.length), l.mistakesCount(controller.mistakes)]),
        const SizedBox(height: 14),
        if (!started)
          KpPrimaryButton(label: l.start, onPressed: _playRound)
        else
          Text(
            playing ? l.simonWatch : l.simonYourTurn,
            style: KpText.title(palette.ink, size: 20),
          ),
      ],
    );
  }
}
