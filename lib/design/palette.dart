import 'package:flutter/widgets.dart';

import '../domain/models.dart';

/// Colours of one screen: a warm neutral ink, a monthly accent and the
/// colours of the soft blobs that shimmer through the glass.
///
/// October is the palette of the UI designs (copper on cream); every other
/// month follows the concept's monthly themes (January ice blue, ...).
@immutable
class KpPalette {
  const KpPalette({
    required this.background,
    required this.blobs,
    required this.accent,
    required this.accentDark,
    required this.ink,
    required this.inkSoft,
    required this.highlight,
    required this.success,
    required this.successSoft,
    required this.successText,
    required this.board,
    required this.boardRelated,
    required this.boardLine,
  });

  final Color background;

  /// Four blob colours: top left, right, bottom left, bottom right.
  final List<Color> blobs;

  /// Primary opaque buttons, selected states, played days.
  final Color accent;
  final Color accentDark;

  /// Main text and its softer variant for secondary text.
  final Color ink;
  final Color inkSoft;

  /// Gold: stars, gold days, the selected Sudoku cell.
  final Color highlight;

  /// Teal family: "play ahead" days, savings note, kids.
  final Color success;
  final Color successSoft;
  final Color successText;

  /// Opaque playing field colours.
  final Color board;
  final Color boardRelated;
  final Color boardLine;

  static const _ink = Color(0xFF2B1A10);
  static const _inkSoft = Color(0xFF6B4A35);
  static const _gold = Color(0xFFF4BE4F);
  static const _teal = Color(0xFF1F7A6A);
  static const _tealSoft = Color(0xFF6FC3B2);
  static const _tealText = Color(0xFF14574B);

  static KpPalette _month(
    int bg,
    List<int> blobs,
    int accent,
    int accentDark, {
    int boardRelated = 0xFFFBEBDD,
    int boardLine = 0xFFE3CDB9,
  }) =>
      KpPalette(
        background: Color(bg),
        blobs: blobs.map(Color.new).toList(),
        accent: Color(accent),
        accentDark: Color(accentDark),
        ink: _ink,
        inkSoft: _inkSoft,
        highlight: _gold,
        success: _teal,
        successSoft: _tealSoft,
        successText: _tealText,
        board: const Color(0xFFFFFDF9),
        boardRelated: Color(boardRelated),
        boardLine: Color(boardLine),
      );

  /// Palettes for January (index 0) to December (index 11).
  static final List<KpPalette> months = [
    _month(0xFFE3ECF5, [0xFF8FB8DE, 0xFFC9D9EE, 0xFFA7C7E7, 0xFFE3CFEA], 0xFF2F5D8A, 0xFF22476B,
        boardRelated: 0xFFE6EEF7, boardLine: 0xFFC9D6E4),
    _month(0xFFF8E3E8, [0xFFEE8AA5, 0xFFF4BE4F, 0xFFC98BB9, 0xFF9DB4D8], 0xFFA3304F, 0xFF7E233C,
        boardRelated: 0xFFFBE6EB, boardLine: 0xFFE8C8D0),
    _month(0xFFE8F1DD, [0xFFA8D08D, 0xFFF4D35E, 0xFF8EC5C0, 0xFFF2A7A0], 0xFF4F7A28, 0xFF3B5D1D,
        boardRelated: 0xFFEEF5E4, boardLine: 0xFFD2DFC3),
    _month(0xFFEEF3DC, [0xFFC5E17A, 0xFFF7C6D9, 0xFFFFE08A, 0xFF9DD3C7], 0xFF56751A, 0xFF425A13,
        boardRelated: 0xFFF2F6E2, boardLine: 0xFFD8E0C0),
    _month(0xFFF6E6EF, [0xFFE9A2C6, 0xFFB7D98B, 0xFFF4BE4F, 0xFFA5B8E3], 0xFF8E3B6A, 0xFF6E2C52,
        boardRelated: 0xFFF8E9F1, boardLine: 0xFFE5CCDA),
    _month(0xFFE2F0F4, [0xFF6FC3D8, 0xFFF4BE4F, 0xFF9AD39E, 0xFFF59A6B], 0xFF1F6F8B, 0xFF16566C,
        boardRelated: 0xFFE7F3F6, boardLine: 0xFFC6DDE4),
    _month(0xFFDDF0F3, [0xFF5CC2D6, 0xFFF7D488, 0xFF8FD3C1, 0xFF6FA8DC], 0xFF136A7A, 0xFF0E525E,
        boardRelated: 0xFFE3F3F5, boardLine: 0xFFC3DEE2),
    _month(0xFFF6ECD9, [0xFFF2B266, 0xFF7FB7D6, 0xFFE98A6B, 0xFFA8CF8E], 0xFFA0521D, 0xFF7C3F16),
    _month(0xFFF2EBDD, [0xFFD9A86C, 0xFF9DB4D8, 0xFFC7B46A, 0xFFE58F6A], 0xFF7A5418, 0xFF5E4012),
    _month(0xFFF7E6D4, [0xFFEE8A5B, 0xFFF4BE4F, 0xFFC9785A, 0xFF9DB4D8], 0xFF9E4421, 0xFF7A3216),
    _month(0xFFEFE4DA, [0xFFB98A6E, 0xFFE2B66B, 0xFF9C8BB8, 0xFFC97B63], 0xFF6E3B2A, 0xFF552D20),
    _month(0xFFF3E2DF, [0xFFD9574B, 0xFFF4BE4F, 0xFF6FA88A, 0xFFE8C9C0], 0xFF9E2B25, 0xFF7B211C,
        boardRelated: 0xFFFBE9E6, boardLine: 0xFFE6CBC6),
  ];

  /// The kids palette from the "Heute im Kinderprofil" design.
  static const KpPalette kids = KpPalette(
    background: Color(0xFFE4F4EE),
    blobs: [Color(0xFF6FC3B2), Color(0xFFFFD45C), Color(0xFFF59A6B), Color(0xFF9DD3E8)],
    accent: _teal,
    accentDark: Color(0xFF0E4038),
    ink: Color(0xFF15322C),
    inkSoft: Color(0xFF2F5A51),
    highlight: Color(0xFFFFD45C),
    success: _teal,
    successSoft: _tealSoft,
    successText: _tealText,
    board: Color(0xFFFFFFFF),
    boardRelated: Color(0xFFE8F6F1),
    boardLine: Color(0xFFC9E3DA),
  );

  static KpPalette forMonth(int month) => months[(month - 1).clamp(0, 11)];

  static KpPalette of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<KpPaletteScope>()?.palette ??
      forMonth(10);

  static KpPalette resolve({required DateTime today, required Audience audience}) =>
      audience == Audience.kid ? kids : forMonth(today.month);
}

class KpPaletteScope extends InheritedWidget {
  const KpPaletteScope({super.key, required this.palette, required super.child});

  final KpPalette palette;

  @override
  bool updateShouldNotify(KpPaletteScope oldWidget) => palette != oldWidget.palette;
}
