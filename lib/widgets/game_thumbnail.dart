import 'package:flutter/material.dart';

import '../design/icons.dart';
import '../design/palette.dart';
import '../domain/models.dart';
import '../games/coloring/motif_painter.dart';
import '../games/coloring/motifs.dart';

/// The tilted preview tile of the day card (108 px in the design): a tiny,
/// recognisable picture of the day's game.
class GameThumbnail extends StatelessWidget {
  const GameThumbnail({super.key, required this.plan, this.size = 108, this.tilt = true});

  final DayPlan plan;
  final double size;
  final bool tilt;

  @override
  Widget build(BuildContext context) {
    final palette = KpPalette.of(context);
    final inner = switch (plan.type) {
      GameType.coloring || GameType.pixelArt => _motif(palette),
      GameType.quoteQuiz => _symbol('“”', palette, fontSize: size * 0.5),
      GameType.breathing => _breath(palette),
      _ => _tiles(_tilesFor(plan.type, palette), palette),
    };
    final tile = Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(size * 0.074),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(size * 0.2),
      ),
      child: inner,
    );
    return ExcludeSemantics(child: tilt ? Transform.rotate(angle: 0.07, child: tile) : tile);
  }

  Widget _motif(KpPalette palette) {
    final motif = Motifs.byId(Motifs.idFor(plan));
    return ClipRRect(
      borderRadius: BorderRadius.circular(size * 0.12),
      child: ColoredBox(
        color: Colors.white,
        child: Padding(
          padding: EdgeInsets.all(size * 0.04),
          child: CustomPaint(
            painter: MotifPainter(
              motif: motif,
              fills: [for (final r in motif.regions) kCrayons[r.crayon]],
              lineColor: palette.ink,
              lineWidth: 2.4,
            ),
          ),
        ),
      ),
    );
  }

  Widget _symbol(String text, KpPalette palette, {required double fontSize}) => Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(size * 0.12)),
        alignment: Alignment.center,
        child: Text(
          text,
          style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w900, fontSize: fontSize, color: palette.accent, height: 1),
        ),
      );

  Widget _breath(KpPalette palette) => Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(size * 0.12)),
        alignment: Alignment.center,
        child: Container(
          width: size * 0.55,
          height: size * 0.55,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: palette.successSoft.withValues(alpha: 0.45),
            border: Border.all(color: palette.success, width: 3),
          ),
          alignment: Alignment.center,
          child: Container(
            width: size * 0.22,
            height: size * 0.22,
            decoration: BoxDecoration(shape: BoxShape.circle, color: palette.success),
          ),
        ),
      );

  Widget _tiles(List<_Tile> tiles, KpPalette palette) {
    final n = tiles.length == 16 ? 4 : 3;
    final gap = size * 0.028;
    final cell = (size * (1 - 0.148) - gap * (n - 1)) / n;
    return Wrap(
      spacing: gap,
      runSpacing: gap,
      children: [
        for (final t in tiles)
          Container(
            width: cell,
            height: cell,
            decoration: BoxDecoration(color: t.color ?? Colors.white, borderRadius: BorderRadius.circular(cell * 0.28)),
            alignment: Alignment.center,
            child: t.icon != null
                ? KpIcon(t.icon!, size: cell * 0.6, color: t.textColor ?? palette.ink, strokeWidth: 2.5)
                : Text(
                    t.text,
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w900,
                      fontSize: cell * (t.text.length > 2 ? 0.34 : 0.56),
                      color: t.textColor ?? palette.ink,
                      height: 1,
                    ),
                  ),
          ),
      ],
    );
  }

  static List<_Tile> _tilesFor(GameType type, KpPalette p) {
    const e = _Tile('');
    _Tile t(String s, [Color? c, Color? fg]) => _Tile(s, color: c, textColor: fg);
    final on = p.highlight;
    final ink = p.ink;
    return switch (type) {
      // The design's mini Sudoku: 4 _ 1 / _ 6 _ / 2 _ 5 with the gold cell.
      GameType.sudoku => [t('4'), e, t('1'), e, t('6', on, p.accent), e, t('2'), e, t('5')],
      GameType.wordGuess => [t('W', p.success, Colors.white), t('O', on), t('R'), t('T', p.success, Colors.white), e, t('E', on), e, e, e],
      GameType.anagram => [t('A'), t('N'), t('A'), t('G'), t('R', on), t('A'), t('M'), e, e],
      GameType.wordSearch => [t('S'), t('U', on), t('N'), t('K', on), t('E'), t('A', on), t('T'), t('L'), t('M', on)],
      GameType.trueFalse => [_Tile('', icon: KpIcons.check, color: p.success, textColor: Colors.white), e, _Tile('', icon: KpIcons.close, color: p.accent, textColor: Colors.white), e, t('?'), e, _Tile('', icon: KpIcons.close, color: p.accent, textColor: Colors.white), e, _Tile('', icon: KpIcons.check, color: p.success, textColor: Colors.white)],
      GameType.nonogram => [t('', ink), t('', ink), e, e, t('', ink), t('', ink), t('', ink), e, t('', ink)],
      GameType.lightsOut => [t('', on), e, t('', on), e, t('', on), e, t('', on), e, t('', on)],
      GameType.hanoi => [e, e, e, t('', on), e, e, t('', p.accent), t('', p.accent), e],
      GameType.maze => [t('', p.success), t('', p.success), e, e, t('', p.success), e, e, t('', p.success), t('', p.accent)],
      GameType.stacking => [e, t('', on), e, t('', p.accent), t('', p.accent), e, t('', ink), t('', ink), t('', ink)],
      GameType.minesweeper => [t('1'), t('1'), t('', p.boardRelated), t('2'), _Tile('', icon: KpIcons.flag, color: on, textColor: p.accent), t('', p.boardRelated), t('1'), t('2'), t('', p.boardRelated)],
      GameType.game2048 => [t('2'), t('4', on), e, e, t('8', p.accent, Colors.white), t('16', p.accent, Colors.white), e, t('2'), t('32', p.accentDark, Colors.white)],
      GameType.numberPyramid => [e, t('9', on), e, t('4'), e, t('5'), t('1'), t('3'), t('2')],
      GameType.memory => [_Tile('', icon: KpIcons.star, color: on, textColor: p.accent), t('', p.accent), t('', p.accent), t('', p.accent), _Tile('', icon: KpIcons.star, color: on, textColor: p.accent), t('', p.accent), t('', p.accent), t('', p.accent), t('', p.accent)],
      GameType.simon => [t('', const Color(0xFFE5484D)), e, t('', const Color(0xFF2F5DA8)), e, t('', on), e, t('', const Color(0xFF2E8B57)), e, t('', p.accent)],
      GameType.slidePuzzle => [t('1'), t('2'), t('3'), t('4'), t('5'), t('6'), t('7'), t('8'), t('', p.boardRelated)],
      _ => [for (var i = 0; i < 9; i++) e],
    };
  }
}

class _Tile {
  const _Tile(this.text, {this.color, this.textColor, this.icon});

  final String text;
  final Color? color;
  final Color? textColor;
  final KpIcons? icon;
}
