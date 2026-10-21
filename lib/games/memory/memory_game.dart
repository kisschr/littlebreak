import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../design/palette.dart';
import '../../domain/models.dart';
import '../../l10n/generated/app_localizations.dart';
import '../game_framework.dart';

class MemoryDefinition extends GameDefinition {
  const MemoryDefinition();

  @override
  GameType get type => GameType.memory;

  static (int pairs, int columns) layout(Difficulty d) => switch (d) {
        Difficulty.easy => (6, 3),
        Difficulty.standard => (8, 4),
        Difficulty.advanced => (12, 4),
      };

  @override
  int minutes(Difficulty d) => switch (d) {
        Difficulty.easy => 2,
        Difficulty.standard => 4,
        Difficulty.advanced => 6,
      };

  @override
  String levelDetail(AppLocalizations l, Difficulty d) => l.detailPairs(layout(d).$1, minutes(d));

  @override
  GameStat get stat => GameStat.moves;

  @override
  Widget build(BuildContext context, GameSession session) => MemoryGame(session: session);
}

/// Picture symbols for the cards. Themed sets for special days come first.
const _symbols = <IconData>[
  Icons.eco,
  Icons.local_florist,
  Icons.park,
  Icons.wb_sunny,
  Icons.ac_unit,
  Icons.favorite,
  Icons.star,
  Icons.pets,
  Icons.cake,
  Icons.beach_access,
  Icons.sailing,
  Icons.music_note,
  Icons.anchor,
  Icons.rocket_launch,
  Icons.cloud,
  Icons.bolt,
  Icons.emoji_nature,
  Icons.spa,
  Icons.icecream,
  Icons.directions_bike,
  Icons.nightlight,
  Icons.local_cafe,
  Icons.menu_book,
  Icons.cruelty_free,
];

const _themedSymbols = <String, List<IconData>>{
  'easter': [Icons.egg, Icons.cruelty_free, Icons.local_florist, Icons.eco, Icons.wb_sunny, Icons.emoji_nature],
  'christmas': [Icons.park, Icons.ac_unit, Icons.star, Icons.card_giftcard, Icons.cake, Icons.nightlight],
};

class MemoryGame extends StatefulWidget {
  const MemoryGame({super.key, required this.session});

  final GameSession session;

  @override
  State<MemoryGame> createState() => _MemoryGameState();
}

class _MemoryGameState extends State<MemoryGame> {
  late final int pairs;
  late final int columns;
  late final List<int> cards; // symbol index per card
  late final List<IconData> symbols;
  final Set<int> matched = {};
  final List<int> open = [];
  Timer? _flipBack;

  GameController get controller => widget.session.controller;

  @override
  void initState() {
    super.initState();
    final (p, c) = MemoryDefinition.layout(widget.session.difficulty);
    pairs = p;
    columns = c;
    final random = widget.session.random();
    final themed = _themedSymbols[widget.session.plan.motif] ?? const <IconData>[];
    final pool = [...themed, ..._symbols.where((s) => !themed.contains(s))];
    symbols = [...themed.take(pairs), ...random.sample(pool.skip(themed.length).toList(), pairs - math.min(themed.length, pairs))];
    cards = random.shuffle([for (var i = 0; i < pairs; i++) ...[i, i]]);
  }

  @override
  void dispose() {
    _flipBack?.cancel();
    super.dispose();
  }

  void _tap(int index) {
    if (matched.contains(index) || open.contains(index) || controller.paused) return;
    if (open.length == 2) {
      _flipBack?.cancel();
      open.clear();
    }
    setState(() => open.add(index));
    if (open.length == 2) {
      controller.reportMove();
      final a = open[0];
      final b = open[1];
      if (cards[a] == cards[b]) {
        setState(() {
          matched.addAll([a, b]);
          open.clear();
        });
        if (matched.length == cards.length) {
          final moves = controller.moves;
          final stars = moves <= pairs * 1.5 ? 3 : moves <= pairs * 2.2 ? 2 : 1;
          controller.complete(GameOutcome(stars: stars));
        }
      } else {
        _flipBack = Timer(const Duration(milliseconds: 800), () {
          if (mounted) setState(open.clear);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final palette = KpPalette.of(context);
    final colors = [palette.accent, palette.success, palette.blobs[3], palette.blobs[0], palette.highlight, palette.accentDark];
    final rows = cards.length ~/ columns;
    return Column(
      children: [
        GameBoard(
          padding: const EdgeInsets.all(12),
          child: AspectRatio(
            aspectRatio: columns / rows,
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
              ),
              itemCount: cards.length,
              itemBuilder: (context, i) {
                final faceUp = matched.contains(i) || open.contains(i);
                return Semantics(
                  button: true,
                  label: faceUp ? l.memoryCardOpen(i + 1) : l.memoryCardClosed(i + 1),
                  child: GestureDetector(
                    onTap: () => _tap(i),
                    child: _FlipCard(
                      faceUp: faceUp,
                      matched: matched.contains(i),
                      icon: symbols[cards[i]],
                      color: colors[cards[i] % colors.length],
                      back: palette.accent,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 18),
        ListenableBuilder(
          listenable: controller,
          builder: (context, _) => GameStatusLine(parts: [
            l.pairsFound(matched.length ~/ 2, pairs),
            l.movesCount(controller.moves),
          ]),
        ),
      ],
    );
  }
}

class _FlipCard extends StatelessWidget {
  const _FlipCard({required this.faceUp, required this.matched, required this.icon, required this.color, required this.back});

  final bool faceUp;
  final bool matched;
  final IconData icon;
  final Color color;
  final Color back;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(end: faceUp ? 1 : 0),
      duration: const Duration(milliseconds: 260),
      builder: (context, t, _) {
        final showFace = t >= 0.5;
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(math.pi * t),
          child: Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()..rotateY(showFace ? math.pi : 0),
            child: Container(
              decoration: BoxDecoration(
                color: showFace ? (matched ? color.withValues(alpha: 0.16) : Colors.white) : back,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: showFace ? color.withValues(alpha: 0.5) : back, width: 2),
              ),
              alignment: Alignment.center,
              child: showFace
                  ? Icon(icon, color: color, size: 30)
                  : Icon(Icons.auto_awesome, color: Colors.white.withValues(alpha: 0.35), size: 22),
            ),
          ),
        );
      },
    );
  }
}
