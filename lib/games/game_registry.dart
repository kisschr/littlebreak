import '../domain/models.dart';
import 'anagram/anagram_game.dart';
import 'breathing/breathing_game.dart';
import 'coloring/coloring_game.dart';
import 'game_2048/game_2048.dart';
import 'game_framework.dart';
import 'hanoi/hanoi_game.dart';
import 'lights_out/lights_out_game.dart';
import 'maze/maze_game.dart';
import 'memory/memory_game.dart';
import 'minesweeper/minesweeper_game.dart';
import 'nonogram/nonogram_game.dart';
import 'number_pyramid/number_pyramid_game.dart';
import 'pixel_art/pixel_art_game.dart';
import 'quote_quiz/quote_quiz_game.dart';
import 'simon/simon_game.dart';
import 'slide_puzzle/slide_puzzle_game.dart';
import 'stacking/stacking_game.dart';
import 'sudoku/sudoku_game.dart';
import 'true_false/true_false_game.dart';
import 'word_guess/word_guess_game.dart';
import 'word_search/word_search_game.dart';

/// Maps every [GameType] to its engine.
abstract final class GameRegistry {
  static const Map<GameType, GameDefinition> _definitions = {
    GameType.coloring: ColoringDefinition(),
    GameType.pixelArt: PixelArtDefinition(),
    GameType.wordGuess: WordGuessDefinition(),
    GameType.anagram: AnagramDefinition(),
    GameType.wordSearch: WordSearchDefinition(),
    GameType.quoteQuiz: QuoteQuizDefinition(),
    GameType.trueFalse: TrueFalseDefinition(),
    GameType.sudoku: SudokuDefinition(),
    GameType.nonogram: NonogramDefinition(),
    GameType.lightsOut: LightsOutDefinition(),
    GameType.hanoi: HanoiDefinition(),
    GameType.maze: MazeDefinition(),
    GameType.stacking: StackingDefinition(),
    GameType.minesweeper: MinesweeperDefinition(),
    GameType.game2048: Game2048Definition(),
    GameType.numberPyramid: NumberPyramidDefinition(),
    GameType.memory: MemoryDefinition(),
    GameType.simon: SimonDefinition(),
    GameType.slidePuzzle: SlidePuzzleDefinition(),
    GameType.breathing: BreathingDefinition(),
  };

  static GameDefinition of(GameType type) => _definitions[type]!;

  static Iterable<GameDefinition> get all => _definitions.values;
}
