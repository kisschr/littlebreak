// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Kleine Pause';

  @override
  String get tabToday => 'Today';

  @override
  String get tabCalendar => 'Calendar';

  @override
  String get tabGallery => 'Gallery';

  @override
  String get tabProfile => 'Profile';

  @override
  String get tabStickers => 'Stickers';

  @override
  String get close => 'Close';

  @override
  String get ok => 'OK';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get done => 'Done';

  @override
  String get off => 'Off';

  @override
  String get played => 'played';

  @override
  String get pickerOverline => 'Kleine Pause · 366 games';

  @override
  String get pickerTitle => 'Who’s playing today?';

  @override
  String get pickerWelcome => 'Welcome to Kleine Pause';

  @override
  String get pickerBody =>
      'Every profile has its own calendar, streak and gallery.';

  @override
  String get newProfile => 'New profile';

  @override
  String get audienceAdults => 'Adults';

  @override
  String get audienceAdultsBody => 'All games, with timer and best scores';

  @override
  String get audienceKids => 'Kids';

  @override
  String get audienceKidsBody =>
      'No time pressure, read-aloud and parental lock';

  @override
  String get createProfileTitle => 'What’s your name?';

  @override
  String get profileNameHint => 'Name';

  @override
  String get createProfile => 'Create profile';

  @override
  String get createAdultNote =>
      'You start on Standard and can pick the level every day.';

  @override
  String get createKidNote =>
      'Kids profiles play without clock or ads. Purchases and settings sit behind a parental lock.';

  @override
  String streakDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '1 day',
    );
    return '$_temp0';
  }

  @override
  String streakSeries(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count-day streak',
      one: '1-day streak',
    );
    return '$_temp0';
  }

  @override
  String get streakExplain =>
      'That’s how many days in a row you have played. One missed day per week is forgiven.';

  @override
  String profileOf(String name) {
    return 'Profile $name';
  }

  @override
  String dayNumber(int day) {
    return 'Day $day';
  }

  @override
  String aboutMinutes(int minutes) {
    return 'about $minutes min';
  }

  @override
  String get threeLevels => '3 levels';

  @override
  String levelsSolved(int count) {
    return '$count of 3 levels';
  }

  @override
  String lastLevel(String level) {
    return 'Last: $level';
  }

  @override
  String get openDoor => 'Open today’s door';

  @override
  String get continuePlaying => 'Keep playing';

  @override
  String get playAgain => 'Play again';

  @override
  String get thisWeek => 'This week';

  @override
  String weekProgress(int count) {
    return '$count of 7';
  }

  @override
  String tomorrowTeaser(String category) {
    return 'Tomorrow: $category';
  }

  @override
  String get tomorrowWithPremium => 'Play it today with Premium';

  @override
  String get tomorrowPlayNow => 'Play ahead now';

  @override
  String get weekdayMo => 'Mo';

  @override
  String get weekdayTu => 'Tu';

  @override
  String get weekdayWe => 'We';

  @override
  String get weekdayTh => 'Th';

  @override
  String get weekdayFr => 'Fr';

  @override
  String get weekdaySa => 'Sa';

  @override
  String get weekdaySu => 'Su';

  @override
  String get levelEasy => 'Easy';

  @override
  String get levelStandard => 'Standard';

  @override
  String get levelAdvanced => 'Advanced';

  @override
  String get levelQuestion => 'How tricky?';

  @override
  String get levelGroup => 'Level';

  @override
  String get goldHint =>
      'Solve all three levels and the day turns gold in the calendar.';

  @override
  String startLevel(String level) {
    return 'Start $level';
  }

  @override
  String starsOf(int count) {
    return '$count of 3 stars';
  }

  @override
  String levelChipLabel(String level) {
    return 'Level $level, tap to change';
  }

  @override
  String get leaveGame => 'Leave game';

  @override
  String get hint => 'Hint';

  @override
  String get pause => 'Pause';

  @override
  String get pausedTitle => 'Paused';

  @override
  String get pausedBody => 'The clock stops until you continue.';

  @override
  String get resume => 'Continue';

  @override
  String get leaveTitle => 'Leave the game?';

  @override
  String get leaveBody => 'Your progress on this level will be lost.';

  @override
  String get keepPlaying => 'Keep playing';

  @override
  String get leave => 'Leave';

  @override
  String get howToTitle => 'How to play';

  @override
  String get letsGo => 'Let’s go';

  @override
  String get readAloud => 'Read aloud';

  @override
  String get resultGreat => 'Brilliant!';

  @override
  String get resultDone => 'Well done!';

  @override
  String get resultGood => 'Nicely played!';

  @override
  String get statTime => 'Time';

  @override
  String get statMistakes => 'Mistakes';

  @override
  String get statMoves => 'Moves';

  @override
  String get statScore => 'Points';

  @override
  String get statAttempts => 'Tries';

  @override
  String get statStreak => 'Day streak';

  @override
  String get statStars => 'Stars';

  @override
  String get statStickers => 'Stickers';

  @override
  String get statPlayed => 'Days played';

  @override
  String get statGold => 'Gold days';

  @override
  String get share => 'Share';

  @override
  String nextLevelQuestion(String level) {
    return '$level?';
  }

  @override
  String shareText(String day, String game, String stars, String time) {
    return 'Kleine Pause · $day\n$game $stars in $time';
  }

  @override
  String get adHeader => 'AD · AFTER THE GAME';

  @override
  String get adRemove => 'Ad-free with Premium';

  @override
  String get adLabel => 'Advertisement';

  @override
  String get houseAdTitle => 'Play every day of the year';

  @override
  String get houseAdBody => 'Catch up on missed days with Premium, ad-free.';

  @override
  String tomorrowWaits(String what) {
    return 'Tomorrow: $what';
  }

  @override
  String reminderAt(String time) {
    return 'Reminder at $time';
  }

  @override
  String get reminderOff => 'Turn on a reminder';

  @override
  String get reminderSettingTitle => 'Reminder';

  @override
  String get reminderExplain =>
      'A gentle nudge for your little break, same time every day.';

  @override
  String get reminderDaily => 'Remind me daily';

  @override
  String get reminderTime => 'Time';

  @override
  String get reminderTitle => 'Time for a little break';

  @override
  String get reminderBody => 'Today’s game is waiting for you.';

  @override
  String get reminderDeniedTitle => 'Notifications are off';

  @override
  String get reminderDeniedBody =>
      'Allow notifications for Kleine Pause in your device settings.';

  @override
  String get viewMonth => 'Month';

  @override
  String get viewYear => 'Year';

  @override
  String get previousMonth => 'Previous month';

  @override
  String get nextMonth => 'Next month';

  @override
  String monthPlayed(int played, int available) {
    return '$played of $available played';
  }

  @override
  String get dayToday => 'today';

  @override
  String get dayGold => 'played, gold';

  @override
  String get dayCatchUp => 'catch up';

  @override
  String get dayMissedPremium => 'missed, Premium only';

  @override
  String get dayPlayAhead => 'play ahead';

  @override
  String get dayLocked => 'locked';

  @override
  String get legend => 'Legend';

  @override
  String get legendPlayed => 'Played';

  @override
  String get legendGold => 'Gold: all 3 levels';

  @override
  String get legendCatchUp => 'Catch up';

  @override
  String get legendAhead => 'Play ahead';

  @override
  String missedDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days missed',
      one: '1 day missed',
    );
    return '$_temp0';
  }

  @override
  String get missedBody => 'Catch up with Premium and play 3 days ahead';

  @override
  String yearSummary(int played, int gold) {
    return '$played days played · $gold gold days';
  }

  @override
  String galleryCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pictures',
      one: '1 picture',
      zero: 'No pictures yet',
    );
    return '$_temp0';
  }

  @override
  String get galleryEmptyTitle => 'Your gallery';

  @override
  String get galleryEmptyBody =>
      'Your coloured pictures and pixel art end up here.';

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get languageSystem => 'Device language';

  @override
  String get languageGerman => 'Deutsch';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageMore => 'More languages are coming.';

  @override
  String get haptics => 'Haptics';

  @override
  String get premiumSection => 'Premium';

  @override
  String get premiumActiveShort => 'Active';

  @override
  String get premiumUnlock => 'Unlock';

  @override
  String get premiumDebug => 'Test Premium (debug only)';

  @override
  String get profileSection => 'Profile';

  @override
  String get switchProfile => 'Switch profile';

  @override
  String get renameProfile => 'Rename profile';

  @override
  String get deleteProfile => 'Delete profile';

  @override
  String deleteProfileTitle(String name) {
    return 'Delete $name?';
  }

  @override
  String get deleteProfileBody =>
      'This profile’s calendar, streak and gallery will be deleted.';

  @override
  String get parentsArea => 'Parents’ area';

  @override
  String get aboutLine =>
      'Kleine Pause · QuizQuiz questions by Zitat des Tages (zitatdestages.net)';

  @override
  String get premiumTitle => 'Kleine Pause Premium';

  @override
  String get premiumSubtitle => 'Your whole year, at your pace.';

  @override
  String get perkNoAds => 'No ads';

  @override
  String get perkNoAdsBody => 'Not before or after the game either';

  @override
  String get perkPast => 'Catch up on any past day';

  @override
  String get perkPastBody => 'Since 1 January, as far back as you like';

  @override
  String get perkAhead => 'Play 3 days ahead';

  @override
  String get perkAheadBody => 'For holidays, weekends or curiosity';

  @override
  String get perkProfiles => 'For every profile';

  @override
  String get perkProfilesBody => 'Adults and kids on this device';

  @override
  String get planYearly => 'Yearly';

  @override
  String get planYearlyNote => 'Most popular';

  @override
  String get planOnce => 'One-time';

  @override
  String get planOnceNote => 'For this year';

  @override
  String pricePerYear(String price) {
    return '$price / year';
  }

  @override
  String get premiumStart => 'Start Premium';

  @override
  String get premiumActive => 'Premium is active. Thank you!';

  @override
  String get restorePurchases => 'Restore purchases';

  @override
  String get terms => 'Terms';

  @override
  String get termsBody =>
      'Premium covers every profile on this device. The yearly plan renews automatically and can be cancelled any time in your store settings. The one-time purchase lasts until 31 December this year.';

  @override
  String get purchaseUnavailableTitle => 'Not available right now';

  @override
  String get purchaseUnavailableBody =>
      'The store is not connected in this version yet.';

  @override
  String get restoreNoneTitle => 'Nothing found';

  @override
  String get restoreNoneBody =>
      'There is no Premium purchase for this account.';

  @override
  String kidsHello(String name) {
    return 'Hi $name!';
  }

  @override
  String get parents => 'Parents';

  @override
  String stickersCollected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count stickers collected',
      one: '1 sticker collected',
    );
    return '$_temp0';
  }

  @override
  String stickersToPage(int count, String month) {
    return '$count more for the $month page';
  }

  @override
  String stickerPageDone(String month) {
    return '$month page complete!';
  }

  @override
  String stickerFor(String date) {
    return 'Sticker from $date';
  }

  @override
  String get stickerColorIn => 'Colour it in';

  @override
  String get stickerColoredTitle => 'Beautiful!';

  @override
  String get stickerColoredBody =>
      'Your picture is done. Tap another sticker to keep colouring.';

  @override
  String get gateTitle => 'Ask a grown-up';

  @override
  String get gateBody => 'This area is for grown-ups.';

  @override
  String gateQuestion(int a, int b) {
    return 'What is $a × $b?';
  }

  @override
  String get gateWrong => 'Not quite. New question:';

  @override
  String get categoryCreative => 'Creative';

  @override
  String get categoryWord => 'Words';

  @override
  String get categoryQuiz => 'Quiz & Trivia';

  @override
  String get categoryLogic => 'Logic';

  @override
  String get categoryArcade => 'Skill & Arcade';

  @override
  String get categoryMemory => 'Memory';

  @override
  String get categoryNumbers => 'Numbers';

  @override
  String get categoryMindful => 'Unwind';

  @override
  String get theme1 => 'Fresh Start & Winter';

  @override
  String get theme2 => 'Love & Carnival';

  @override
  String get theme3 => 'Awakening';

  @override
  String get theme4 => 'Easter & Garden';

  @override
  String get theme5 => 'Blossom & Nature';

  @override
  String get theme6 => 'Sport & Motion';

  @override
  String get theme7 => 'Holidays & Sea';

  @override
  String get theme8 => 'Travel & World';

  @override
  String get theme9 => 'School & Knowledge';

  @override
  String get theme10 => 'Autumn & Spooky';

  @override
  String get theme11 => 'Cosy Days';

  @override
  String get theme12 => 'Advent & Year in Review';

  @override
  String get edition1 => 'Snowflake Edition';

  @override
  String get edition2 => 'Heartbeat Edition';

  @override
  String get edition3 => 'Spring Awakening Edition';

  @override
  String get edition4 => 'Easter Bunny Edition';

  @override
  String get edition5 => 'Blossom Edition';

  @override
  String get edition6 => 'Midsummer Edition';

  @override
  String get edition7 => 'Beach Edition';

  @override
  String get edition8 => 'Wanderlust Edition';

  @override
  String get edition9 => 'Harvest Edition';

  @override
  String get edition10 => 'Autumn Leaves Edition';

  @override
  String get edition11 => 'Lantern Edition';

  @override
  String get edition12 => 'Advent Magic Edition';

  @override
  String get specialNewYear => 'New Year’s Day';

  @override
  String get specialValentine => 'Valentine’s Day';

  @override
  String get specialLeapDay => 'Leap Day bonus';

  @override
  String get specialPiDay => 'Pi Day';

  @override
  String get specialSpring => 'First day of spring';

  @override
  String get specialAprilFools => 'April Fools’ Day';

  @override
  String get specialEarthDay => 'Earth Day';

  @override
  String get specialBookDay => 'World Book Day';

  @override
  String get specialMayDay => 'May Day';

  @override
  String get specialSummer => 'First day of summer';

  @override
  String get specialUnityDay => 'German Unity Day';

  @override
  String get specialHalloween => 'Halloween';

  @override
  String get specialStMartin => 'St Martin’s Day';

  @override
  String get specialChristmasEve => 'Christmas Eve';

  @override
  String get specialChristmas => 'Christmas';

  @override
  String get specialBoxingDay => 'Boxing Day';

  @override
  String get specialNewYearsEve => 'New Year’s Eve';

  @override
  String get specialCarnival => 'Carnival';

  @override
  String get specialEaster => 'Easter';

  @override
  String get specialMothersDay => 'Mother’s Day';

  @override
  String get specialAdvent => 'Advent calendar';

  @override
  String get motifPumpkin => 'Pumpkin';

  @override
  String get motifHeart => 'Heart';

  @override
  String get motifFlower => 'Flower';

  @override
  String get motifStar => 'Star';

  @override
  String get motifTree => 'Christmas tree';

  @override
  String get motifLantern => 'Lantern';

  @override
  String get motifMask => 'Carnival mask';

  @override
  String get motifEgg => 'Easter egg';

  @override
  String get motifLeaf => 'Autumn leaf';

  @override
  String get motifMushroom => 'Toadstool';

  @override
  String get motifHouse => 'Little house';

  @override
  String get motifFish => 'Fish';

  @override
  String get motifSnowman => 'Snowman';

  @override
  String get motifSun => 'Sun';

  @override
  String get motifButterfly => 'Butterfly';

  @override
  String get motifHedgehog => 'Hedgehog in the leaves';

  @override
  String get motifIcecream => 'Ice cream';

  @override
  String get motifSailboat => 'Sailboat';

  @override
  String get motifUmbrella => 'Umbrella';

  @override
  String get gameColoring => 'Colouring';

  @override
  String get gamePixelArt => 'Pixel Art';

  @override
  String get gameWordGuess => 'Word Guess';

  @override
  String get gameAnagram => 'Anagrams';

  @override
  String get gameWordSearch => 'Word Search';

  @override
  String get gameQuoteQuiz => 'QuizQuiz';

  @override
  String get gameTrueFalse => 'True or False';

  @override
  String get gameSudoku => 'Sudoku';

  @override
  String get gameNonogram => 'Nonogram';

  @override
  String get gameLightsOut => 'Lights Out';

  @override
  String get gameHanoi => 'Tower of Hanoi';

  @override
  String get gameMaze => 'Maze';

  @override
  String get gameStacking => 'Stacker';

  @override
  String get gameMinesweeper => 'Minesweeper';

  @override
  String get game2048 => '2048';

  @override
  String get gameNumberPyramid => 'Number Pyramid';

  @override
  String get gameMemory => 'Memory';

  @override
  String get gameSimon => 'Colour Sequence';

  @override
  String get gameSlidePuzzle => 'Slide Puzzle';

  @override
  String get gameBreathing => 'Breathing Break';

  @override
  String get howToColoring =>
      'Pick a colour and tap an area to fill it. On Advanced you paint by numbers: each number belongs to one colour. A hint fills one area for you.';

  @override
  String get howToPixelArt =>
      'Every number stands for a colour. Pick a colour below, then tap or swipe over the matching squares until the picture is done.';

  @override
  String get howToWordGuess =>
      'Guess the word in six tries. Green: right letter, right spot. Yellow: in the word, wrong spot. Grey: not in the word.';

  @override
  String get howToAnagram =>
      'The letters are jumbled. Tap them in the right order to build the word. Tap a placed letter to take it back from there.';

  @override
  String get howToWordSearch =>
      'Find every word in the grid. Drag from the first to the last letter – across, down or diagonally.';

  @override
  String get howToQuoteQuiz =>
      'Read the quote and tap the person who said it. The questions come from the “Zitat des Tages” app.';

  @override
  String get howToTrueFalse =>
      'Is the statement right? Tap “True” or “False”. On Advanced you get ten seconds per statement.';

  @override
  String get howToSudoku =>
      'Fill the grid so every number appears exactly once in each row, column and box. Tap a cell, then a number. Use “Notes” to keep track of candidates.';

  @override
  String get howToNonogram =>
      'The numbers on the edge tell you how many cells in a row are filled. Fill the right cells to reveal a picture. Mark sure gaps with the cross.';

  @override
  String get howToLightsOut =>
      'A tap toggles a light and its neighbours. Switch every light off.';

  @override
  String get howToHanoi =>
      'Move the whole tower to the right peg. Tap a peg to lift its top disc, then tap the target. Never put a bigger disc on a smaller one.';

  @override
  String get howToMaze =>
      'Guide the dot to the goal. Swipe in a direction or use the arrows.';

  @override
  String get howToStacking =>
      'The block swings back and forth. Tap to drop it. Whatever overhangs falls off. Build the tower up to the target height.';

  @override
  String get howToMinesweeper =>
      'Uncover every cell without a mine. A number tells how many mines touch that cell. Use the flag to mark suspects. Your first tap is always safe.';

  @override
  String get howTo2048 =>
      'Swipe to slide all tiles. Equal numbers merge. Reach the target number.';

  @override
  String get howToNumberPyramid =>
      'Each brick is the sum of the two bricks below it. Fill the empty bricks, then check.';

  @override
  String get howToMemory =>
      'Turn over two cards at a time. Find all pairs with as few misses as possible.';

  @override
  String get howToSimon =>
      'Watch the colour sequence, then tap it back. Each round adds one colour.';

  @override
  String get howToSlidePuzzle =>
      'Slide tiles into the gap until the picture is whole again. Tap a tile next to the gap.';

  @override
  String get howToBreathing =>
      'Breathe with the circle: in as it grows, hold briefly, out as it shrinks. Nothing to win, just calm.';

  @override
  String get kidColoring =>
      'Choose a colour and tap a shape. Make the picture colourful!';

  @override
  String get kidPixelArt =>
      'Every number has a colour. Fill each square with the right colour!';

  @override
  String get kidAnagram =>
      'The letters are mixed up. Tap them in the right order!';

  @override
  String get kidWordSearch =>
      'Find the words! Slide your finger over the letters.';

  @override
  String get kidTrueFalse => 'Is it true? Tap True or False.';

  @override
  String get kidSudoku =>
      'Each number may appear only once in every row. Give it a try!';

  @override
  String get kidLightsOut => 'Tap the lights until they are all off!';

  @override
  String get kidHanoi =>
      'Rebuild the tower on the right peg. Big discs always go at the bottom!';

  @override
  String get kidMaze => 'Help the dot through the maze to the goal!';

  @override
  String get kidStacking =>
      'Tap at just the right moment and build a tall tower!';

  @override
  String get kidNumberPyramid =>
      'Two bricks add up to the brick above them. Let’s count!';

  @override
  String get kidMemory => 'Turn over two cards and find the pairs!';

  @override
  String get kidSimon => 'Watch closely and tap the colours in the same order!';

  @override
  String get kidSlidePuzzle =>
      'Slide the pieces until the picture is right again!';

  @override
  String get kidBreathing =>
      'Breathe in and out with the circle. Nice and calm.';

  @override
  String detailGrid(String size, int minutes) {
    return '$size grid · about $minutes min';
  }

  @override
  String detailPairs(int count, int minutes) {
    return '$count pairs · about $minutes min';
  }

  @override
  String detailDiscs(int count, int minutes) {
    return '$count discs · about $minutes min';
  }

  @override
  String detailRows(int count, int minutes) {
    return '$count rows · about $minutes min';
  }

  @override
  String detailTarget(String target, int minutes) {
    return 'Target $target · about $minutes min';
  }

  @override
  String detailMines(String size, int mines, int minutes) {
    return '$size grid, $mines mines · about $minutes min';
  }

  @override
  String detailSequence(int count, int minutes) {
    return 'Sequence of $count · about $minutes min';
  }

  @override
  String detailBlocks(int count, int minutes) {
    return '$count blocks high · about $minutes min';
  }

  @override
  String detailBreaths(int count, int minutes) {
    return '$count breaths · about $minutes min';
  }

  @override
  String detailLetters(int count, int minutes) {
    return '$count letters · about $minutes min';
  }

  @override
  String detailAnagram(int count, int length, int minutes) {
    return '$count words of $length letters · about $minutes min';
  }

  @override
  String detailWords(int count, int minutes) {
    return '$count words · about $minutes min';
  }

  @override
  String detailQuiz(int questions, int answers, int minutes) {
    return '$questions questions, $answers answers · about $minutes min';
  }

  @override
  String detailStatements(int count, int minutes) {
    return '$count statements · about $minutes min';
  }

  @override
  String detailColoring(int colors, int minutes) {
    return 'Free colouring, $colors colours · about $minutes min';
  }

  @override
  String detailPaintByNumbers(int minutes) {
    return 'Paint by numbers · about $minutes min';
  }

  @override
  String sudokuGridLabel(int size) {
    return 'Sudoku $size by $size';
  }

  @override
  String cellLabel(int row, int column, String value) {
    return 'Row $row, column $column: $value';
  }

  @override
  String get cellEmpty => 'empty';

  @override
  String get cellFilled => 'filled';

  @override
  String get cellCrossed => 'crossed out';

  @override
  String get cellHidden => 'hidden';

  @override
  String numberLabel(int number) {
    return 'Number $number';
  }

  @override
  String tileLabel(int number) {
    return 'Tile $number';
  }

  @override
  String brickLabel(int row, int brick, String value) {
    return 'Row $row, brick $brick: $value';
  }

  @override
  String mistakesCount(int count) {
    return 'Mistakes $count';
  }

  @override
  String hintsCount(int used, int max) {
    return 'Hints $used of $max';
  }

  @override
  String movesCount(int count) {
    return 'Moves $count';
  }

  @override
  String scoreCount(int count) {
    return 'Points $count';
  }

  @override
  String target(String target) {
    return 'Target $target';
  }

  @override
  String roundOf(int current, int total) {
    return 'Round $current of $total';
  }

  @override
  String heightOf(int current, int total) {
    return 'Height $current of $total';
  }

  @override
  String breathOf(int current, int total) {
    return 'Breath $current of $total';
  }

  @override
  String attemptOf(int current, int total) {
    return 'Try $current of $total';
  }

  @override
  String attemptCount(int count) {
    return 'Try $count';
  }

  @override
  String wordOf(int current, int total) {
    return 'Word $current of $total';
  }

  @override
  String wordsFound(int current, int total) {
    return '$current of $total found';
  }

  @override
  String questionOf(int current, int total) {
    return 'Question $current of $total';
  }

  @override
  String pairsFound(int current, int total) {
    return '$current of $total pairs';
  }

  @override
  String lightsLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count lights on',
      one: '1 light on',
    );
    return '$_temp0';
  }

  @override
  String minesLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mines left',
      one: '1 mine left',
    );
    return '$_temp0';
  }

  @override
  String hanoiOptimal(int count) {
    return 'Best possible: $count moves';
  }

  @override
  String areasColored(int current, int total) {
    return '$current of $total areas';
  }

  @override
  String pixelsPainted(int current, int total) {
    return '$current of $total squares';
  }

  @override
  String secondsLeft(int count) {
    return '$count s';
  }

  @override
  String colorNumber(int number) {
    return 'Colour $number';
  }

  @override
  String get coloringLabel => 'Colouring picture';

  @override
  String pixelLabel(int size) {
    return 'Pixel picture $size by $size';
  }

  @override
  String get erase => 'Erase';

  @override
  String get notes => 'Notes';

  @override
  String get undo => 'Undo';

  @override
  String get check => 'Check';

  @override
  String get start => 'Start';

  @override
  String get shuffle => 'Shuffle';

  @override
  String get clear => 'Clear';

  @override
  String get tryAgain => 'Try again';

  @override
  String get next => 'Next';

  @override
  String get finish => 'Finish';

  @override
  String get reveal => 'Reveal';

  @override
  String get flag => 'Flag';

  @override
  String memoryCardOpen(int number) {
    return 'Card $number, face up';
  }

  @override
  String memoryCardClosed(int number) {
    return 'Card $number, face down';
  }

  @override
  String lightLabel(int row, int column, String state) {
    return 'Light row $row, column $column: $state';
  }

  @override
  String get lightOn => 'on';

  @override
  String get lightOff => 'off';

  @override
  String get lightsGoal => 'Switch every light off.';

  @override
  String get slideGoal => 'Slide the tiles into the right order.';

  @override
  String hanoiPeg(int number, int count) {
    return 'Peg $number, $count discs';
  }

  @override
  String get hanoiGoal => 'Move every disc to the right peg.';

  @override
  String get pyramidGoal => 'Each brick is the sum of the two below.';

  @override
  String get mazeLabel => 'Maze';

  @override
  String get directionUp => 'Up';

  @override
  String get directionDown => 'Down';

  @override
  String get directionLeft => 'Left';

  @override
  String get directionRight => 'Right';

  @override
  String get game2048Stuck => 'No moves left.';

  @override
  String get swipeHint => 'Swipe to slide the tiles.';

  @override
  String get nonogramFill => 'Fill';

  @override
  String get nonogramCross => 'Cross';

  @override
  String get mine => 'Mine';

  @override
  String get mineBoom => 'Boom! New try, new field.';

  @override
  String simonPad(int number) {
    return 'Colour $number';
  }

  @override
  String get simonWatch => 'Watch closely …';

  @override
  String get simonYourTurn => 'Your turn!';

  @override
  String get stackingHint => 'Tap to drop the block.';

  @override
  String get breatheIn => 'Breathe in';

  @override
  String get breatheHold => 'Hold';

  @override
  String get breatheOut => 'Breathe out';

  @override
  String get breatheReady => 'Ready?';

  @override
  String wordWas(String word) {
    return 'The word was: $word';
  }

  @override
  String wordSearchLabel(int size) {
    return 'Letter grid $size by $size';
  }

  @override
  String get whoSaidIt => 'Who said it?';

  @override
  String get answerRight => 'Correct!';

  @override
  String answerWrong(String answer) {
    return 'Not quite: $answer';
  }

  @override
  String get answerWrongPlain => 'Not quite.';

  @override
  String get quoteSource => 'Questions: Zitat des Tages · zitatdestages.net';

  @override
  String get quizUnavailable =>
      'No questions available right now. Please try again later.';

  @override
  String get trueOrFalse => 'True or false?';

  @override
  String get answerTrue => 'True';

  @override
  String get answerFalse => 'False';

  @override
  String get timeUp => 'Time’s up!';
}
