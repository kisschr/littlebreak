import 'dart:async';

import 'package:flutter/material.dart';

import '../../data/content.dart';
import '../../design/components.dart';
import '../../design/palette.dart';
import '../../domain/models.dart';
import '../../l10n/generated/app_localizations.dart';
import '../game_framework.dart';
import '../game_widgets.dart';

class TrueFalseDefinition extends GameDefinition {
  const TrueFalseDefinition();

  @override
  GameType get type => GameType.trueFalse;

  static int countFor(Difficulty d) => switch (d) {
        Difficulty.easy => 5,
        Difficulty.standard => 8,
        Difficulty.advanced => 12,
      };

  /// Seconds per statement; null = no clock.
  static int? secondsFor(Difficulty d) => d == Difficulty.advanced ? 10 : null;

  @override
  int minutes(Difficulty d) => switch (d) {
        Difficulty.easy => 1,
        Difficulty.standard => 2,
        Difficulty.advanced => 3,
      };

  @override
  String levelDetail(AppLocalizations l, Difficulty d) =>
      l.detailStatements(countFor(d), minutes(d));

  @override
  Widget build(BuildContext context, GameSession session) => TrueFalseGame(session: session);
}

class TrueFalseGame extends StatefulWidget {
  const TrueFalseGame({super.key, required this.session});

  final GameSession session;

  @override
  State<TrueFalseGame> createState() => _TrueFalseGameState();
}

class _TrueFalseGameState extends State<TrueFalseGame> {
  late final List<Fact> facts;
  late final int? seconds = TrueFalseDefinition.secondsFor(widget.session.difficulty);
  int index = 0;
  bool? chosen;
  bool timedOut = false;
  int correct = 0;
  int left = 0;
  Timer? _timer;

  GameController get controller => widget.session.controller;

  @override
  void initState() {
    super.initState();
    final all = widget.session.content.facts;
    facts = widget.session.random().sample(all, TrueFalseDefinition.countFor(widget.session.difficulty).clamp(0, all.length));
    _startClock();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startClock() {
    _timer?.cancel();
    final s = seconds;
    if (s == null || widget.session.isKid) return;
    left = s;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (controller.paused || chosen != null || timedOut) return;
      setState(() => left--);
      if (left <= 0) {
        _timer?.cancel();
        setState(() => timedOut = true);
        controller.reportMistake();
      }
    });
  }

  void _answer(bool value) {
    if (chosen != null || timedOut || controller.paused) return;
    _timer?.cancel();
    setState(() => chosen = value);
    if (value == facts[index].isTrue) {
      correct++;
    } else {
      controller.reportMistake();
    }
  }

  void _next() {
    if (index == facts.length - 1) {
      final ratio = facts.isEmpty ? 1 : correct / facts.length;
      controller.complete(GameOutcome(stars: ratio >= 1 ? 3 : ratio >= 0.7 ? 2 : 1));
      return;
    }
    setState(() {
      index++;
      chosen = null;
      timedOut = false;
    });
    _startClock();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final palette = KpPalette.of(context);
    if (facts.isEmpty) {
      return Center(child: Text(l.quizUnavailable, style: KpText.body(palette.ink)));
    }
    final fact = facts[index];
    final answered = chosen != null || timedOut;
    final right = chosen == fact.isTrue;

    AnswerState stateFor(bool value) {
      if (!answered) return AnswerState.idle;
      if (value == fact.isTrue) return AnswerState.correct;
      if (value == chosen) return AnswerState.wrong;
      return AnswerState.dimmed;
    }

    return Column(
      children: [
        GameStatusLine(parts: [
          l.questionOf(index + 1, facts.length),
          if (seconds != null && !widget.session.isKid) l.secondsLeft(left),
        ]),
        const SizedBox(height: 6),
        Text(l.trueOrFalse, style: KpText.title(palette.ink, size: 26)),
        const SizedBox(height: 14),
        GameBoard(
          padding: const EdgeInsets.fromLTRB(22, 26, 22, 26),
          child: SizedBox(
            width: double.infinity,
            child: Text(
              fact.statement,
              textAlign: TextAlign.center,
              style: KpText.body(palette.ink, size: 21, weight: FontWeight.w800),
            ),
          ),
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(child: AnswerButton(label: l.answerTrue, onTap: answered ? null : () => _answer(true), state: stateFor(true), minHeight: 72)),
            const SizedBox(width: 12),
            Expanded(child: AnswerButton(label: l.answerFalse, onTap: answered ? null : () => _answer(false), state: stateFor(false), minHeight: 72)),
          ],
        ),
        const SizedBox(height: 16),
        if (answered) ...[
          Text(
            timedOut ? l.timeUp : (right ? l.answerRight : l.answerWrongPlain),
            textAlign: TextAlign.center,
            style: KpText.title(right && !timedOut ? palette.successText : kpErrorColor, size: 18),
          ),
          const SizedBox(height: 12),
          KpPrimaryButton(label: index == facts.length - 1 ? l.finish : l.next, onPressed: _next),
        ],
      ],
    );
  }
}
