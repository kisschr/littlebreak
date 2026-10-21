import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui';

import 'package:path_drawing/path_drawing.dart';

import '../../core/dates.dart';
import '../../core/seeded_random.dart';
import '../../domain/models.dart';

/// The crayon box shared by coloring and pixel art.
const List<Color> kCrayons = [
  Color(0xFFE5484D), // red
  Color(0xFFF2994A), // orange
  Color(0xFFF4BE4F), // yellow
  Color(0xFF7BC67E), // light green
  Color(0xFF2E8B57), // green
  Color(0xFF5DADE2), // light blue
  Color(0xFF2F5DA8), // blue
  Color(0xFF9B6ACB), // purple
  Color(0xFFF49AC1), // pink
  Color(0xFF8B5A3C), // brown
  Color(0xFF9AA0A6), // grey
  Color(0xFF2B1A10), // dark
  Color(0xFFFFFFFF), // white
];

/// Crayon indices by name, so motifs read like a recipe.
abstract final class Crayon {
  static const red = 0, orange = 1, yellow = 2, lightGreen = 3, green = 4, lightBlue = 5, blue = 6,
      purple = 7, pink = 8, brown = 9, grey = 10, dark = 11, white = 12;
}

/// One fillable area of a motif. [crayon] is the intended colour, used for
/// paint by numbers, pixel art and the thumbnail.
class MotifRegion {
  const MotifRegion(this.path, this.crayon);

  final Path path;
  final int crayon;
}

/// A line drawing on a 100×100 canvas made of fillable regions. Regions are
/// painted in order, so later ones lie on top (and win hit tests).
class Motif {
  const Motif(this.id, this.regions, {this.details = const []});

  final String id;
  final List<MotifRegion> regions;

  /// Extra lines that are drawn but not fillable (veins, smiles).
  final List<Path> details;

  static const double size = 100;

  /// Index of the top-most region at [p] (canvas units), or null.
  int? regionAt(Offset p) {
    for (var i = regions.length - 1; i >= 0; i--) {
      if (regions[i].path.contains(p)) return i;
    }
    return null;
  }

  /// Samples the motif on an [n]×[n] grid: crayon index per cell, null for
  /// background. Used by pixel art.
  List<int?> rasterize(int n) {
    final step = size / n;
    return [
      for (var r = 0; r < n; r++)
        for (var c = 0; c < n; c++)
          () {
            final i = regionAt(Offset((c + 0.5) * step, (r + 0.5) * step));
            return i == null ? null : regions[i].crayon;
          }(),
    ];
  }
}

// ---------------------------------------------------------------------------
// Shape helpers (all in 0–100 canvas units).

Path _ellipse(double cx, double cy, double rx, double ry, [double rotationDeg = 0]) {
  final p = Path()..addOval(Rect.fromCenter(center: Offset.zero, width: rx * 2, height: ry * 2));
  return _place(p, cx, cy, rotationDeg);
}

Path _circle(double cx, double cy, double r) => _ellipse(cx, cy, r, r);

Path _rect(double x, double y, double w, double h, [double radius = 0]) =>
    Path()..addRRect(RRect.fromRectAndRadius(Rect.fromLTWH(x, y, w, h), Radius.circular(radius)));

Path _poly(List<double> xy) {
  final p = Path()..moveTo(xy[0], xy[1]);
  for (var i = 2; i < xy.length; i += 2) {
    p.lineTo(xy[i], xy[i + 1]);
  }
  return p..close();
}

Path _svg(String d) => parseSvgPathData(d);

Path _star(double cx, double cy, double outer, double inner, {int points = 5, double rotationDeg = -90}) {
  final xy = <double>[];
  for (var i = 0; i < points * 2; i++) {
    final r = i.isEven ? outer : inner;
    final a = (rotationDeg + i * 180 / points) * math.pi / 180;
    xy..add(cx + r * math.cos(a))..add(cy + r * math.sin(a));
  }
  return _poly(xy);
}

Path _place(Path p, double cx, double cy, double rotationDeg) {
  final a = rotationDeg * math.pi / 180;
  final c = math.cos(a), s = math.sin(a);
  return p.transform(Float64List.fromList([c, s, 0, 0, -s, c, 0, 0, 0, 0, 1, 0, cx, cy, 0, 1]));
}

Path _line(String d) => _svg(d);

MotifRegion _r(Path p, int crayon) => MotifRegion(p, crayon);

// ---------------------------------------------------------------------------
// The motif library.

abstract final class Motifs {
  static final Map<String, Motif Function()> _builders = {
    'pumpkin': _pumpkin,
    'heart': _heart,
    'flower': _flower,
    'star': _starMotif,
    'tree': _tree,
    'christmas': _tree,
    'lantern': _lantern,
    'mask': _mask,
    'easter': _egg,
    'egg': _egg,
    'leaf': _leaf,
    'mushroom': _mushroom,
    'house': _house,
    'fish': _fish,
    'snowman': _snowman,
    'sun': _sun,
    'butterfly': _butterfly,
    'hedgehog': _hedgehog,
    'icecream': _icecream,
    'sailboat': _sailboat,
    'umbrella': _umbrella,
  };

  static final Map<String, Motif> _cache = {};

  /// Seasonal motifs per month for days without a special motif.
  static const Map<int, List<String>> byMonth = {
    1: ['snowman', 'star', 'house'],
    2: ['heart', 'snowman', 'fish'],
    3: ['flower', 'butterfly', 'house'],
    4: ['egg', 'umbrella', 'flower'],
    5: ['flower', 'butterfly', 'mushroom'],
    6: ['sun', 'fish', 'sailboat'],
    7: ['icecream', 'sun', 'sailboat'],
    8: ['icecream', 'fish', 'butterfly'],
    9: ['leaf', 'mushroom', 'hedgehog'],
    10: ['leaf', 'pumpkin', 'hedgehog'],
    11: ['lantern', 'leaf', 'mushroom'],
    12: ['tree', 'star', 'snowman'],
  };

  static Iterable<String> get ids => _builders.keys;

  static Motif byId(String id) => _cache[id] ??= (_builders[id] ?? _flower)();

  /// The motif of a day: the special day's motif, else a seasonal one. The
  /// same on every level, so thumbnail, game and gallery agree.
  static String idFor(DayPlan plan) {
    final planned = plan.motif;
    if (planned != null && _builders.containsKey(planned)) return planned;
    return SeededRandom.fromParts([dateKey(plan.date), 'motif']).pick(byMonth[plan.date.month]!);
  }

  static Motif _pumpkin() => Motif('pumpkin', [
        _r(_rect(46, 12, 8, 16, 3), Crayon.brown),
        _r(_ellipse(64, 20, 12, 6, -20), Crayon.green),
        _r(_ellipse(32, 60, 22, 28), Crayon.orange),
        _r(_ellipse(68, 60, 22, 28), Crayon.orange),
        _r(_ellipse(50, 60, 18, 30), Crayon.yellow),
        _r(_poly([34, 50, 44, 50, 39, 40]), Crayon.dark),
        _r(_poly([56, 50, 66, 50, 61, 40]), Crayon.dark),
        _r(_poly([32, 66, 40, 72, 46, 66, 50, 72, 54, 66, 60, 72, 68, 66, 62, 78, 38, 78]), Crayon.dark),
      ]);

  static Motif _heart() {
    Path heart(double cx, double cy, double s) => _place(
          _svg('M0 10 C-14 -2 -26 -14 -14 -24 C-8 -29 -2 -26 0 -20 C2 -26 8 -29 14 -24 C26 -14 14 -2 0 10 Z'),
          cx,
          cy,
          0,
        ).transform(_scaleAbout(cx, cy, s));
    return Motif('heart', [
      _r(heart(50, 60, 1.8), Crayon.red),
      _r(heart(50, 60, 0.9), Crayon.pink),
      _r(_circle(16, 20, 6), Crayon.pink),
      _r(_circle(84, 18, 5), Crayon.purple),
      _r(_circle(86, 84, 6), Crayon.pink),
      _r(_star(16, 82, 7, 3), Crayon.yellow),
    ]);
  }

  static Motif _flower() => Motif('flower', [
        _r(_rect(47, 50, 6, 44, 3), Crayon.green),
        _r(_ellipse(36, 74, 12, 5, -30), Crayon.lightGreen),
        _r(_ellipse(64, 80, 12, 5, 30), Crayon.lightGreen),
        for (var i = 0; i < 6; i++)
          _r(
            _ellipse(50 + 17 * math.cos(i * math.pi / 3), 34 + 17 * math.sin(i * math.pi / 3), 12, 9, i * 60),
            i.isEven ? Crayon.pink : Crayon.purple,
          ),
        _r(_circle(50, 34, 10), Crayon.yellow),
      ]);

  static Motif _starMotif() => Motif('star', [
        _r(_star(50, 54, 40, 17), Crayon.yellow),
        _r(_star(50, 54, 20, 9), Crayon.orange),
        _r(_star(14, 16, 8, 3, points: 4, rotationDeg: 0), Crayon.lightBlue),
        _r(_star(86, 14, 7, 3, points: 4, rotationDeg: 0), Crayon.purple),
        _r(_star(88, 86, 8, 3, points: 4, rotationDeg: 0), Crayon.lightBlue),
        _r(_star(12, 86, 6, 2.5, points: 4, rotationDeg: 0), Crayon.pink),
      ]);

  static Motif _tree() => Motif('tree', [
        _r(_rect(43, 80, 14, 14, 2), Crayon.brown),
        _r(_poly([50, 40, 82, 82, 18, 82]), Crayon.green),
        _r(_poly([50, 28, 74, 62, 26, 62]), Crayon.lightGreen),
        _r(_poly([50, 14, 66, 42, 34, 42]), Crayon.green),
        _r(_star(50, 12, 9, 4), Crayon.yellow),
        _r(_circle(36, 72, 4), Crayon.red),
        _r(_circle(62, 70, 4), Crayon.blue),
        _r(_circle(44, 52, 3.5), Crayon.purple),
        _r(_circle(58, 50, 3.5), Crayon.red),
        _r(_circle(50, 36, 3), Crayon.orange),
      ]);

  static Motif _lantern() => Motif('lantern', [
        _r(_rect(18, 6, 4, 60, 2), Crayon.brown),
        _r(_svg('M22 10 Q50 0 50 26 L48 26 Q48 6 22 14 Z'), Crayon.dark),
        _r(_rect(38, 26, 24, 6, 2), Crayon.dark),
        _r(_rect(28, 32, 44, 50, 14), Crayon.orange),
        _r(_rect(36, 82, 28, 6, 2), Crayon.dark),
        _r(_circle(50, 54, 12), Crayon.yellow),
        _r(_star(39, 42, 4, 1.8), Crayon.white),
        _r(_star(62, 70, 4, 1.8), Crayon.white),
      ]);

  static Motif _mask() => Motif('mask', [
        _r(_rect(70, 56, 4, 40, 2), Crayon.brown),
        _r(_ellipse(30, 22, 6, 18, -25), Crayon.green),
        _r(_ellipse(50, 18, 6, 18), Crayon.blue),
        _r(_ellipse(70, 22, 6, 18, 25), Crayon.purple),
        _r(_svg('M10 44 Q12 36 26 36 Q42 36 50 44 Q58 36 74 36 Q88 36 90 44 Q90 66 70 66 Q56 66 50 56 Q44 66 30 66 Q10 66 10 44 Z'), Crayon.pink),
        _r(_ellipse(31, 49, 9, 6), Crayon.white),
        _r(_ellipse(69, 49, 9, 6), Crayon.white),
        _r(_circle(50, 40, 3), Crayon.yellow),
      ]);

  static Motif _egg() => Motif('egg', [
        _r(_rect(10, 84, 80, 10, 5), Crayon.lightGreen),
        _r(_svg('M50 8 C74 8 84 46 84 62 C84 82 68 92 50 92 C32 92 16 82 16 62 C16 46 26 8 50 8 Z'), Crayon.lightBlue),
        _r(_poly([20, 46, 30, 38, 40, 46, 50, 38, 60, 46, 70, 38, 80, 46, 82, 54, 70, 46, 60, 54, 50, 46, 40, 54, 30, 46, 18, 54]), Crayon.pink),
        _r(_rect(17, 64, 66, 8, 2), Crayon.yellow),
        _r(_circle(36, 26, 4), Crayon.purple),
        _r(_circle(56, 22, 4), Crayon.orange),
        _r(_circle(40, 82, 4), Crayon.purple),
        _r(_circle(60, 82, 4), Crayon.orange),
      ]);

  static Motif _leaf() => Motif(
        'leaf',
        [
          _r(_rect(48, 76, 4, 20, 2), Crayon.brown),
          _r(_svg('M50 6 C22 20 14 50 26 70 C34 82 46 82 50 80 Z'), Crayon.orange),
          _r(_svg('M50 6 C78 20 86 50 74 70 C66 82 54 82 50 80 Z'), Crayon.red),
        ],
        details: [_line('M50 10 L50 80 M50 34 L34 26 M50 34 L66 26 M50 52 L30 46 M50 52 L70 46 M50 68 L36 64 M50 68 L64 64')],
      );

  static Motif _mushroom() => Motif('mushroom', [
        _r(_rect(4, 84, 92, 12, 6), Crayon.lightGreen),
        _r(_svg('M40 50 L60 50 Q64 70 62 88 L38 88 Q36 70 40 50 Z'), Crayon.white),
        _r(_svg('M10 52 Q10 14 50 12 Q90 14 90 52 Q50 60 10 52 Z'), Crayon.red),
        _r(_circle(30, 34, 6), Crayon.white),
        _r(_circle(52, 26, 7), Crayon.white),
        _r(_circle(72, 38, 5), Crayon.white),
        _r(_circle(48, 72, 3), Crayon.dark),
      ]);

  static Motif _house() => Motif('house', [
        _r(_rect(64, 14, 10, 22), Crayon.brown),
        _r(_rect(20, 46, 60, 46), Crayon.yellow),
        _r(_poly([10, 50, 50, 16, 90, 50]), Crayon.red),
        _r(_rect(42, 64, 16, 28, 3), Crayon.brown),
        _r(_rect(26, 56, 12, 12, 2), Crayon.lightBlue),
        _r(_rect(62, 56, 12, 12, 2), Crayon.lightBlue),
        _r(_circle(16, 16, 8), Crayon.orange),
      ]);

  static Motif _fish() => Motif('fish', [
        _r(_poly([70, 50, 94, 30, 94, 70]), Crayon.orange),
        _r(_ellipse(44, 50, 34, 22), Crayon.lightBlue),
        _r(_poly([34, 30, 50, 14, 58, 30]), Crayon.blue),
        _r(_svg('M40 30 Q48 50 40 70 L32 68 Q38 50 32 32 Z'), Crayon.yellow),
        _r(_svg('M56 30 Q64 50 56 70 L50 71 Q56 50 50 29 Z'), Crayon.yellow),
        _r(_circle(22, 46, 4), Crayon.dark),
        _r(_circle(84, 16, 4), Crayon.lightBlue),
        _r(_circle(76, 88, 3), Crayon.lightBlue),
      ]);

  static Motif _snowman() => Motif('snowman', [
        _r(_circle(50, 72, 22), Crayon.white),
        _r(_circle(50, 40, 16), Crayon.white),
        _r(_rect(34, 50, 32, 8, 4), Crayon.red),
        _r(_rect(60, 50, 8, 18, 3), Crayon.red),
        _r(_rect(38, 14, 24, 14, 2), Crayon.dark),
        _r(_rect(32, 26, 36, 5, 2), Crayon.dark),
        _r(_poly([50, 40, 64, 43, 50, 46]), Crayon.orange),
        _r(_circle(50, 66, 3), Crayon.dark),
        _r(_circle(50, 78, 3), Crayon.dark),
      ]);

  static Motif _sun() => Motif('sun', [
        for (var i = 0; i < 8; i++)
          _r(
            _place(_poly([-6, -30, 6, -30, 0, -46]), 50, 50, i * 45),
            i.isEven ? Crayon.orange : Crayon.yellow,
          ),
        _r(_circle(50, 50, 26), Crayon.yellow),
        _r(_circle(41, 46, 3), Crayon.dark),
        _r(_circle(59, 46, 3), Crayon.dark),
        _r(_svg('M40 58 Q50 68 60 58 Q50 63 40 58 Z'), Crayon.red),
      ]);

  static Motif _butterfly() => Motif('butterfly', [
        _r(_ellipse(30, 34, 20, 16, -30), Crayon.purple),
        _r(_ellipse(70, 34, 20, 16, 30), Crayon.purple),
        _r(_ellipse(34, 66, 14, 12, 30), Crayon.pink),
        _r(_ellipse(66, 66, 14, 12, -30), Crayon.pink),
        _r(_circle(28, 32, 6), Crayon.yellow),
        _r(_circle(72, 32, 6), Crayon.yellow),
        _r(_ellipse(50, 50, 5, 28), Crayon.dark),
        _r(_circle(50, 20, 6), Crayon.dark),
      ], details: [
        _line('M48 15 Q42 4 36 6 M52 15 Q58 4 64 6'),
      ]);

  static Motif _hedgehog() => Motif('hedgehog', [
        _r(_rect(6, 84, 88, 10, 5), Crayon.lightGreen),
        _r(_poly([14, 80, 12, 64, 4, 58, 16, 52, 14, 38, 26, 40, 30, 26, 40, 34, 48, 22, 54, 34, 64, 26, 66, 40, 78, 38, 74, 52, 84, 60, 74, 66, 72, 80]), Crayon.brown),
        _r(_svg('M64 56 Q84 56 94 72 Q86 82 66 80 Z'), Crayon.orange),
        _r(_circle(94, 72, 3), Crayon.dark),
        _r(_circle(78, 66, 2.4), Crayon.dark),
        _r(_circle(36, 70, 9), Crayon.red),
        _r(_rect(35, 57, 2, 5), Crayon.brown),
      ]);

  static Motif _icecream() => Motif('icecream', [
        _r(_poly([30, 52, 70, 52, 50, 96]), Crayon.orange),
        _r(_circle(38, 46, 14), Crayon.pink),
        _r(_circle(62, 46, 14), Crayon.lightGreen),
        _r(_circle(50, 30, 15), Crayon.yellow),
        _r(_circle(50, 12, 6), Crayon.red),
      ], details: [
        _line('M38 60 L58 80 M48 56 L64 72 M62 60 L42 80 M52 56 L36 72'),
      ]);

  static Motif _sailboat() => Motif('sailboat', [
        _r(_circle(82, 18, 10), Crayon.yellow),
        _r(_svg('M0 82 Q12 74 25 82 Q38 90 50 82 Q62 74 75 82 Q88 90 100 82 L100 100 L0 100 Z'), Crayon.blue),
        _r(_rect(48, 14, 4, 56), Crayon.brown),
        _r(_poly([46, 18, 46, 64, 18, 64]), Crayon.white),
        _r(_poly([54, 24, 54, 64, 76, 64]), Crayon.red),
        _r(_svg('M14 68 L86 68 L76 82 L24 82 Z'), Crayon.brown),
      ]);

  static Motif _umbrella() => Motif('umbrella', [
        _r(_svg('M48 50 L52 50 L52 84 Q52 92 44 92 Q36 92 36 84 L40 84 Q40 88 44 88 Q48 88 48 84 Z'), Crayon.dark),
        _r(_svg('M8 52 Q10 14 50 12 Q30 20 28 52 Q18 44 8 52 Z'), Crayon.red),
        _r(_svg('M28 52 Q30 20 50 12 Q70 20 72 52 Q61 44 50 52 Q39 44 28 52 Z'), Crayon.yellow),
        _r(_svg('M72 52 Q70 20 50 12 Q90 14 92 52 Q82 44 72 52 Z'), Crayon.blue),
        _r(_ellipse(16, 76, 3, 5), Crayon.lightBlue),
        _r(_ellipse(82, 72, 3, 5), Crayon.lightBlue),
        _r(_ellipse(70, 90, 3, 5), Crayon.lightBlue),
      ]);
}

Float64List _scaleAbout(double cx, double cy, double s) =>
    Float64List.fromList([s, 0, 0, 0, 0, s, 0, 0, 0, 0, 1, 0, cx - s * cx, cy - s * cy, 0, 1]);
