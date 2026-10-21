import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../design/icons.dart';
import '../../design/palette.dart';
import '../../domain/models.dart';
import '../../l10n/generated/app_localizations.dart';
import '../game_framework.dart';

class WordGuessDefinition extends GameDefinition {
  const WordGuessDefinition();

  @override
  GameType get type => GameType.wordGuess;

  static int lengthFor(Difficulty d) => switch (d) {
        Difficulty.easy => 4,
        Difficulty.standard => 5,
        Difficulty.advanced => 6,
      };

  static const maxTries = 6;

  @override
  int minutes(Difficulty d) => switch (d) {
        Difficulty.easy => 2,
        Difficulty.standard => 4,
        Difficulty.advanced => 5,
      };

  @override
  String levelDetail(AppLocalizations l, Difficulty d) => l.detailLetters(lengthFor(d), minutes(d));

  @override
  GameStat get stat => GameStat.attempts;

  @override
  Widget build(BuildContext context, GameSession session) => WordGuessGame(session: session);
}

enum LetterResult { correct, present, absent }

/// Wordle-style scoring that handles repeated letters correctly.
List<LetterResult> scoreGuess(String guess, String solution) {
  final result = List.filled(guess.length, LetterResult.absent);
  final remaining = <String, int>{};
  for (var i = 0; i < solution.length; i++) {
    if (guess[i] == solution[i]) {
      result[i] = LetterResult.correct;
    } else {
      remaining[solution[i]] = (remaining[solution[i]] ?? 0) + 1;
    }
  }
  for (var i = 0; i < guess.length; i++) {
    if (result[i] == LetterResult.correct) continue;
    final left = remaining[guess[i]] ?? 0;
    if (left > 0) {
      result[i] = LetterResult.present;
      remaining[guess[i]] = left - 1;
    }
  }
  return result;
}

class WordGuessGame extends StatefulWidget {
  const WordGuessGame({super.key, required this.session});

  final GameSession session;

  @override
  State<WordGuessGame> createState() => _WordGuessGameState();
}

class _WordGuessGameState extends State<WordGuessGame> {
  late final int length = WordGuessDefinition.lengthFor(widget.session.difficulty);
  late final String solution;
  final List<String> guesses = [];
  String current = '';
  bool lost = false;
  bool _shake = false;

  GameController get controller => widget.session.controller;

  @override
  void initState() {
    super.initState();
    final words = widget.session.content.words(length);
    solution = words.isEmpty ? 'PAUSE'.substring(0, length.clamp(1, 5)) : widget.session.random().pick(words);
  }

  void _type(String letter) {
    if (controller.paused || controller.finished || current.length >= length) return;
    setState(() => current += letter);
  }

  void _delete() {
    if (current.isEmpty) return;
    setState(() => current = current.substring(0, current.length - 1));
  }

  void _submit() {
    if (controller.finished) return;
    if (current.length < length) {
      setState(() => _shake = !_shake);
      return;
    }
    setState(() {
      guesses.add(current);
      current = '';
    });
    controller.reportMove();
    if (guesses.last == solution) {
      final tries = guesses.length;
      controller.complete(GameOutcome(stars: tries <= 3 ? 3 : tries <= 5 ? 2 : 1));
    } else if (guesses.length >= WordGuessDefinition.maxTries) {
      setState(() => lost = true);
      Future<void>.delayed(const Duration(milliseconds: 1600), () {
        controller.complete(const GameOutcome(stars: 1));
      });
    }
  }

  Map<String, LetterResult> get _keyStates {
    final states = <String, LetterResult>{};
    for (final g in guesses) {
      final score = scoreGuess(g, solution);
      for (var i = 0; i < g.length; i++) {
        final prev = states[g[i]];
        if (prev == LetterResult.correct) continue;
        if (prev == LetterResult.present && score[i] == LetterResult.absent) continue;
        states[g[i]] = score[i];
      }
    }
    return states;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final palette = KpPalette.of(context);
    final keys = _keyStates;
    final alphabet = widget.session.content.alphabet;
    final rowSplit = widget.session.languageCode == 'de' ? [11, 22] : [10, 19];
    final rows = [
      alphabet.sublist(0, rowSplit[0]),
      alphabet.sublist(rowSplit[0], rowSplit[1]),
      alphabet.sublist(rowSplit[1]),
    ];

    Color tileColor(LetterResult r) => switch (r) {
          LetterResult.correct => palette.success,
          LetterResult.present => palette.highlight,
          LetterResult.absent => palette.inkSoft.withValues(alpha: 0.55),
        };

    return Column(
      children: [
        GameBoard(
          padding: const EdgeInsets.all(14),
          child: Column(
            children: [
              for (var row = 0; row < WordGuessDefinition.maxTries; row++)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: TweenAnimationBuilder<double>(
                    key: ValueKey('row$row$_shake'),
                    tween: Tween(begin: row == guesses.length ? 1 : 0, end: 0),
                    duration: const Duration(milliseconds: 300),
                    builder: (context, t, child) => Transform.translate(offset: Offset(math.sin(t * math.pi * 4) * 8 * t, 0), child: child),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for (var i = 0; i < length; i++) _tile(row, i, palette, tileColor),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 24,
          child: lost
              ? Text(l.wordWas(solution), style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w900, fontSize: 16, color: palette.accent))
              : GameStatusLine(parts: [l.attemptOf(guesses.length, WordGuessDefinition.maxTries)]),
        ),
        const SizedBox(height: 10),
        for (var r = 0; r < rows.length; r++)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: [
                if (r == 2) _actionKey(KpIcons.check, l.check, _submit, palette, flex: 3),
                for (final letter in rows[r])
                  Expanded(
                    flex: 2,
                    child: _Key(
                      label: letter,
                      color: keys[letter] == null ? Colors.white.withValues(alpha: 0.75) : tileColor(keys[letter]!),
                      textColor: keys[letter] == null ? palette.ink : Colors.white,
                      onTap: () => _type(letter),
                    ),
                  ),
                if (r == 2) _actionKey(KpIcons.erase, l.erase, _delete, palette, flex: 3),
              ],
            ),
          ),
      ],
    );
  }

  Widget _actionKey(KpIcons icon, String label, VoidCallback onTap, KpPalette palette, {int flex = 3}) => Expanded(
        flex: flex,
        child: _Key(label: label, icon: icon, color: palette.accent, textColor: Colors.white, onTap: onTap),
      );

  Widget _tile(int row, int i, KpPalette palette, Color Function(LetterResult) color) {
    String letter = '';
    Color bg = Colors.white;
    Color fg = palette.ink;
    Color border = palette.boardLine;
    if (row < guesses.length) {
      letter = guesses[row][i];
      final r = scoreGuess(guesses[row], solution)[i];
      bg = color(r);
      fg = Colors.white;
      border = bg;
    } else if (row == guesses.length && i < current.length) {
      letter = current[i];
      border = palette.inkSoft;
    }
    final size = length >= 6 ? 46.0 : 52.0;
    return Container(
      width: size,
      height: size,
      margin: const EdgeInsets.symmetric(horizontal: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12), border: Border.all(color: border, width: 2)),
      alignment: Alignment.center,
      child: Text(letter, style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w900, fontSize: 24, color: fg)),
    );
  }
}

class _Key extends StatelessWidget {
  const _Key({required this.label, required this.color, required this.textColor, required this.onTap, this.icon});

  final String label;
  final KpIcons? icon;
  final Color color;
  final Color textColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Semantics(
        button: true,
        label: label,
        excludeSemantics: true,
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            height: 50,
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10)),
            alignment: Alignment.center,
            child: icon != null
                ? KpIcon(icon!, size: 20, color: textColor)
                : Text(label, style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 17, color: textColor)),
          ),
        ),
      ),
    );
  }
}
