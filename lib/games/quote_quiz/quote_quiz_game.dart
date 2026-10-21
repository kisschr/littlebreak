import 'package:flutter/material.dart';

import '../../data/quote_quiz.dart';
import '../../design/components.dart';
import '../../design/palette.dart';
import '../../domain/models.dart';
import '../../l10n/generated/app_localizations.dart';
import '../game_framework.dart';
import '../game_widgets.dart';

class QuoteQuizDefinition extends GameDefinition {
  const QuoteQuizDefinition();

  @override
  GameType get type => GameType.quoteQuiz;

  static (int questions, int answers) layout(Difficulty d) => switch (d) {
        Difficulty.easy => (3, 2),
        Difficulty.standard => (5, 3),
        Difficulty.advanced => (7, 4),
      };

  @override
  int minutes(Difficulty d) => switch (d) {
        Difficulty.easy => 1,
        Difficulty.standard => 3,
        Difficulty.advanced => 4,
      };

  @override
  String levelDetail(AppLocalizations l, Difficulty d) {
    final (q, a) = layout(d);
    return l.detailQuiz(q, a, minutes(d));
  }

  @override
  Widget build(BuildContext context, GameSession session) => QuoteQuizGame(session: session);
}

class QuoteQuizGame extends StatefulWidget {
  const QuoteQuizGame({super.key, required this.session});

  final GameSession session;

  @override
  State<QuoteQuizGame> createState() => _QuoteQuizGameState();
}

class _QuoteQuizGameState extends State<QuoteQuizGame> {
  late List<QuoteQuestion> questions;
  int index = 0;
  int? chosen;
  int correct = 0;

  GameController get controller => widget.session.controller;

  @override
  void initState() {
    super.initState();
    _build();
    // Fetch fresh questions in the background; the next session uses them.
    widget.session.quotes.refresh(widget.session.languageCode);
  }

  void _build() {
    final s = widget.session;
    final (count, answers) = QuoteQuizDefinition.layout(s.difficulty);
    final bundled = s.content.quotes;
    final pool = s.quotes.authorPool(s.languageCode, bundled);
    final random = s.random();
    questions = s.quotes
        .questionsFor(date: s.plan.date, lang: s.languageCode, count: count, bundled: bundled)
        .map((q) => q.withAnswerCount(answers, pool, random))
        .toList();
  }

  void _answer(int i) {
    if (chosen != null || controller.paused) return;
    setState(() => chosen = i);
    if (i == questions[index].correctIndex) {
      correct++;
    } else {
      controller.reportMistake();
    }
  }

  void _next() {
    if (index == questions.length - 1) {
      final ratio = correct / questions.length;
      controller.complete(GameOutcome(stars: ratio >= 1 ? 3 : ratio >= 0.6 ? 2 : 1));
      return;
    }
    setState(() {
      index++;
      chosen = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final palette = KpPalette.of(context);
    if (questions.isEmpty) {
      return Center(child: Text(l.quizUnavailable, style: KpText.body(palette.ink)));
    }
    final q = questions[index];
    return Column(
      children: [
        Text(l.questionOf(index + 1, questions.length), style: KpText.label(palette.inkSoft, size: 14)),
        const SizedBox(height: 6),
        Text(l.whoSaidIt, style: KpText.title(palette.ink, size: 26)),
        const SizedBox(height: 14),
        GameBoard(
          padding: const EdgeInsets.fromLTRB(22, 22, 22, 26),
          child: SizedBox(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('“', style: TextStyle(fontFamily: 'Nunito', fontSize: 56, height: 0.8, fontWeight: FontWeight.w900, color: palette.accent)),
                Text(q.quote, style: KpText.body(palette.ink, size: 20, weight: FontWeight.w700)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 18),
        for (var i = 0; i < q.answers.length; i++) ...[
          AnswerButton(
            label: q.answers[i],
            onTap: chosen == null ? () => _answer(i) : null,
            state: chosen == null
                ? AnswerState.idle
                : i == q.correctIndex
                    ? AnswerState.correct
                    : i == chosen
                        ? AnswerState.wrong
                        : AnswerState.dimmed,
          ),
          const SizedBox(height: 10),
        ],
        const SizedBox(height: 6),
        if (chosen != null) ...[
          Text(
            chosen == q.correctIndex ? l.answerRight : l.answerWrong(q.correctAnswer),
            textAlign: TextAlign.center,
            style: KpText.title(chosen == q.correctIndex ? palette.successText : kpErrorColor, size: 18),
          ),
          const SizedBox(height: 12),
          KpPrimaryButton(label: index == questions.length - 1 ? l.finish : l.next, onPressed: _next),
        ],
        const SizedBox(height: 16),
        Text(l.quoteSource, textAlign: TextAlign.center, style: KpText.label(palette.inkSoft, size: 12, weight: FontWeight.w700)),
      ],
    );
  }
}
