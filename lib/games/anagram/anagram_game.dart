import 'package:flutter/material.dart';

import '../../core/seeded_random.dart';
import '../../design/icons.dart';
import '../../design/palette.dart';
import '../../domain/models.dart';
import '../../l10n/generated/app_localizations.dart';
import '../game_framework.dart';
import '../game_widgets.dart';

class AnagramDefinition extends GameDefinition {
  const AnagramDefinition();

  @override
  GameType get type => GameType.anagram;

  static (int words, int length) layout(Difficulty d) => switch (d) {
        Difficulty.easy => (3, 5),
        Difficulty.standard => (4, 6),
        Difficulty.advanced => (5, 7),
      };

  @override
  int minutes(Difficulty d) => switch (d) {
        Difficulty.easy => 2,
        Difficulty.standard => 4,
        Difficulty.advanced => 6,
      };

  @override
  String levelDetail(AppLocalizations l, Difficulty d) {
    final (count, length) = layout(d);
    return l.detailAnagram(count, length, minutes(d));
  }

  @override
  bool get usesHints => true;

  @override
  Widget build(BuildContext context, GameSession session) => AnagramGame(session: session);
}

/// Scrambles [word] so that it never reads as the word itself.
String scramble(String word, SeededRandom random) {
  if (word.length < 2 || word.split('').toSet().length == 1) return word;
  var letters = word.split('');
  do {
    letters = random.shuffle(letters);
  } while (letters.join() == word);
  return letters.join();
}

class AnagramGame extends StatefulWidget {
  const AnagramGame({super.key, required this.session});

  final GameSession session;

  @override
  State<AnagramGame> createState() => _AnagramGameState();
}

class _AnagramGameState extends State<AnagramGame> {
  late final List<String> words;
  late final SeededRandom random = widget.session.random('scramble');
  int index = 0;
  late List<String> pool; // scrambled letters, '' when used
  final List<int> picked = []; // indices into pool
  int revealed = 0; // letters fixed by hints

  GameController get controller => widget.session.controller;
  String get word => words[index];

  @override
  void initState() {
    super.initState();
    final s = widget.session;
    final (count, length) = AnagramDefinition.layout(s.difficulty);
    var candidates = s.isKid
        ? s.content.kidWords.where((w) => w.length <= 5).toList()
        : s.content.words(length);
    if (candidates.length < count) candidates = s.content.words(5);
    words = s.random().sample(candidates, count);
    _load();
    controller.setHintHandler(_hint);
  }

  void _load() {
    pool = scramble(word, random).split('');
    picked.clear();
    revealed = 0;
  }

  String get answer => picked.map((i) => pool[i]).join();

  void _pick(int i) {
    if (picked.contains(i) || picked.length >= word.length || controller.paused) return;
    setState(() => picked.add(i));
    if (picked.length == word.length) _check();
  }

  void _unpick(int position) {
    if (position < revealed) return;
    setState(() => picked.removeRange(position, picked.length));
  }

  void _check() {
    if (answer == word) {
      if (index == words.length - 1) {
        controller.complete();
      } else {
        Future<void>.delayed(const Duration(milliseconds: 450), () {
          if (!mounted) return;
          setState(() {
            index++;
            _load();
          });
        });
      }
    } else {
      controller.reportMistake();
      Future<void>.delayed(const Duration(milliseconds: 450), () {
        if (mounted) setState(() => picked.removeRange(revealed, picked.length));
      });
    }
  }

  bool _hint() {
    if (revealed >= word.length - 1) return false;
    setState(() {
      picked.removeRange(revealed, picked.length);
      final needed = word[revealed];
      final i = [for (var k = 0; k < pool.length; k++) k].firstWhere((k) => pool[k] == needed && !picked.contains(k));
      picked.add(i);
      revealed++;
    });
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final palette = KpPalette.of(context);
    final solvedWord = answer == word && picked.length == word.length;
    final tileSize = word.length >= 7 ? 40.0 : 46.0;
    return Column(
      children: [
        GameBoard(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 22),
          child: Column(
            children: [
              Text(l.wordOf(index + 1, words.length), style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, color: palette.inkSoft)),
              const SizedBox(height: 16),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 6,
                children: [
                  for (var p = 0; p < word.length; p++)
                    GestureDetector(
                      onTap: p < picked.length ? () => _unpick(p) : null,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 160),
                        width: tileSize,
                        height: tileSize + 6,
                        decoration: BoxDecoration(
                          color: solvedWord ? palette.success : (p < revealed ? palette.boardRelated : Colors.white),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: p < picked.length ? palette.accent : palette.boardLine, width: 2),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          p < picked.length ? pool[picked[p]] : '',
                          style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w900, fontSize: 24, color: solvedWord ? Colors.white : palette.ink),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: [
            for (var i = 0; i < pool.length; i++)
              Opacity(
                opacity: picked.contains(i) ? 0.25 : 1,
                child: GlassKey(
                  width: 54,
                  height: 58,
                  radius: 18,
                  semanticLabel: pool[i],
                  onTap: picked.contains(i) ? null : () => _pick(i),
                  child: Text(pool[i]),
                ),
              ),
          ],
        ),
        const SizedBox(height: 18),
        ListenableBuilder(
          listenable: controller,
          builder: (context, _) => GameStatusLine(parts: [
            l.mistakesCount(controller.mistakes),
            l.hintsCount(controller.hintsUsed, controller.maxHints),
          ]),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: GlassActionPill(
                icon: KpIcons.swap,
                label: l.shuffle,
                onTap: () => setState(() {
                  final kept = picked.sublist(0, revealed).map((i) => pool[i]).toList();
                  final rest = [for (var i = 0; i < pool.length; i++) if (!picked.sublist(0, revealed).contains(i)) pool[i]];
                  random.shuffle(rest);
                  pool = [...kept, ...rest];
                  picked
                    ..clear()
                    ..addAll(List.generate(revealed, (i) => i));
                }),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: GlassActionPill(
                icon: KpIcons.erase,
                label: l.clear,
                onTap: () => setState(() => picked.removeRange(revealed, picked.length)),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
