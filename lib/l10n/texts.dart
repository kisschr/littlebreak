import '../domain/models.dart';
import '../games/coloring/motifs.dart';
import 'generated/app_localizations.dart';

/// Typed access to texts that depend on an enum or an id, so screens never
/// build ARB keys from strings.
extension KpTexts on AppLocalizations {
  String gameName(GameType t) => switch (t) {
        GameType.coloring => gameColoring,
        GameType.pixelArt => gamePixelArt,
        GameType.wordGuess => gameWordGuess,
        GameType.anagram => gameAnagram,
        GameType.wordSearch => gameWordSearch,
        GameType.quoteQuiz => gameQuoteQuiz,
        GameType.trueFalse => gameTrueFalse,
        GameType.sudoku => gameSudoku,
        GameType.nonogram => gameNonogram,
        GameType.lightsOut => gameLightsOut,
        GameType.hanoi => gameHanoi,
        GameType.maze => gameMaze,
        GameType.stacking => gameStacking,
        GameType.minesweeper => gameMinesweeper,
        GameType.game2048 => game2048,
        GameType.numberPyramid => gameNumberPyramid,
        GameType.memory => gameMemory,
        GameType.simon => gameSimon,
        GameType.slidePuzzle => gameSlidePuzzle,
        GameType.breathing => gameBreathing,
      };

  /// "So geht's" text shown before the first game of a type.
  String gameHowTo(GameType t) => switch (t) {
        GameType.coloring => howToColoring,
        GameType.pixelArt => howToPixelArt,
        GameType.wordGuess => howToWordGuess,
        GameType.anagram => howToAnagram,
        GameType.wordSearch => howToWordSearch,
        GameType.quoteQuiz => howToQuoteQuiz,
        GameType.trueFalse => howToTrueFalse,
        GameType.sudoku => howToSudoku,
        GameType.nonogram => howToNonogram,
        GameType.lightsOut => howToLightsOut,
        GameType.hanoi => howToHanoi,
        GameType.maze => howToMaze,
        GameType.stacking => howToStacking,
        GameType.minesweeper => howToMinesweeper,
        GameType.game2048 => howTo2048,
        GameType.numberPyramid => howToNumberPyramid,
        GameType.memory => howToMemory,
        GameType.simon => howToSimon,
        GameType.slidePuzzle => howToSlidePuzzle,
        GameType.breathing => howToBreathing,
      };

  /// One short, read-aloud friendly line for the kids' day card.
  String kidPrompt(GameType t) => switch (t) {
        GameType.coloring => kidColoring,
        GameType.pixelArt => kidPixelArt,
        GameType.anagram => kidAnagram,
        GameType.wordSearch => kidWordSearch,
        GameType.trueFalse => kidTrueFalse,
        GameType.sudoku => kidSudoku,
        GameType.lightsOut => kidLightsOut,
        GameType.hanoi => kidHanoi,
        GameType.maze => kidMaze,
        GameType.stacking => kidStacking,
        GameType.numberPyramid => kidNumberPyramid,
        GameType.memory => kidMemory,
        GameType.simon => kidSimon,
        GameType.slidePuzzle => kidSlidePuzzle,
        GameType.breathing => kidBreathing,
        _ => gameHowTo(t),
      };

  String categoryName(GameCategory c) => switch (c) {
        GameCategory.creative => categoryCreative,
        GameCategory.word => categoryWord,
        GameCategory.quiz => categoryQuiz,
        GameCategory.logic => categoryLogic,
        GameCategory.arcade => categoryArcade,
        GameCategory.memory => categoryMemory,
        GameCategory.numbers => categoryNumbers,
        GameCategory.mindful => categoryMindful,
      };

  String difficultyName(Difficulty d) => switch (d) {
        Difficulty.easy => levelEasy,
        Difficulty.standard => levelStandard,
        Difficulty.advanced => levelAdvanced,
      };

  /// "Herbst & Grusel" — the month's theme from the concept.
  String monthTheme(int month) => switch (month) {
        1 => theme1,
        2 => theme2,
        3 => theme3,
        4 => theme4,
        5 => theme5,
        6 => theme6,
        7 => theme7,
        8 => theme8,
        9 => theme9,
        10 => theme10,
        11 => theme11,
        _ => theme12,
      };

  /// "Herbstlaub-Edition" — subtitle of the day card.
  String monthEdition(int month) => switch (month) {
        1 => edition1,
        2 => edition2,
        3 => edition3,
        4 => edition4,
        5 => edition5,
        6 => edition6,
        7 => edition7,
        8 => edition8,
        9 => edition9,
        10 => edition10,
        11 => edition11,
        _ => edition12,
      };

  String? specialDayName(String? id) => switch (id) {
        'new_year' => specialNewYear,
        'valentine' => specialValentine,
        'leap_day' => specialLeapDay,
        'pi_day' => specialPiDay,
        'spring' => specialSpring,
        'april_fools' => specialAprilFools,
        'earth_day' => specialEarthDay,
        'book_day' => specialBookDay,
        'may_day' => specialMayDay,
        'summer' => specialSummer,
        'unity_day' => specialUnityDay,
        'halloween' => specialHalloween,
        'st_martin' => specialStMartin,
        'christmas_eve' => specialChristmasEve,
        'christmas' => specialChristmas,
        'boxing_day' => specialBoxingDay,
        'new_years_eve' => specialNewYearsEve,
        'carnival' => specialCarnival,
        'easter' => specialEaster,
        'mothers_day' => specialMothersDay,
        'advent' => specialAdvent,
        _ => null,
      };

  String motifName(String id) => switch (Motifs.baseId(id)) {
        'pumpkin' => motifPumpkin,
        'heart' => motifHeart,
        'flower' => motifFlower,
        'star' => motifStar,
        'tree' || 'christmas' => motifTree,
        'lantern' => motifLantern,
        'mask' => motifMask,
        'egg' || 'easter' => motifEgg,
        'leaf' => motifLeaf,
        'mushroom' => motifMushroom,
        'house' => motifHouse,
        'fish' => motifFish,
        'snowman' => motifSnowman,
        'sun' => motifSun,
        'butterfly' => motifButterfly,
        'hedgehog' => motifHedgehog,
        'icecream' => motifIcecream,
        'sailboat' => motifSailboat,
        'umbrella' => motifUmbrella,
        _ => gameColoring,
      };

  String weekdayShort(int weekday) => switch (weekday) {
        DateTime.monday => weekdayMo,
        DateTime.tuesday => weekdayTu,
        DateTime.wednesday => weekdayWe,
        DateTime.thursday => weekdayTh,
        DateTime.friday => weekdayFr,
        DateTime.saturday => weekdaySa,
        _ => weekdaySu,
      };
}
