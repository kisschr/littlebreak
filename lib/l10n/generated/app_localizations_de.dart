// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Kleine Pause';

  @override
  String get tabToday => 'Heute';

  @override
  String get tabCalendar => 'Kalender';

  @override
  String get tabGallery => 'Galerie';

  @override
  String get tabProfile => 'Profil';

  @override
  String get tabStickers => 'Sticker';

  @override
  String get close => 'Schließen';

  @override
  String get ok => 'OK';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get save => 'Speichern';

  @override
  String get delete => 'Löschen';

  @override
  String get done => 'Fertig';

  @override
  String get off => 'Aus';

  @override
  String get played => 'gespielt';

  @override
  String get pickerOverline => 'Kleine Pause · 366 Spiele';

  @override
  String get pickerTitle => 'Wer spielt heute?';

  @override
  String get pickerWelcome => 'Willkommen bei Kleine Pause';

  @override
  String get pickerBody =>
      'Jedes Profil hat seinen eigenen Kalender, seine Serie und seine Galerie.';

  @override
  String get newProfile => 'Neues Profil';

  @override
  String get audienceAdults => 'Erwachsene';

  @override
  String get audienceAdultsBody => 'Alle Spiele, mit Zeit und Bestenwerten';

  @override
  String get audienceKids => 'Kinder';

  @override
  String get audienceKidsBody =>
      'Ohne Zeitdruck, mit Vorlesen und Elternsperre';

  @override
  String get createProfileTitle => 'Wie heißt du?';

  @override
  String get profileNameHint => 'Name';

  @override
  String get createProfile => 'Profil anlegen';

  @override
  String get createAdultNote =>
      'Du startest auf Standard und kannst jeden Tag die Stufe wählen.';

  @override
  String get createKidNote =>
      'Kinderprofile spielen ohne Uhr und Werbung. Käufe und Einstellungen sind hinter einer Elternsperre.';

  @override
  String streakDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Tage',
      one: '1 Tag',
    );
    return '$_temp0';
  }

  @override
  String streakSeries(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Tage Serie',
      one: '1 Tag Serie',
    );
    return '$_temp0';
  }

  @override
  String get streakExplain =>
      'So viele Tage hintereinander hast du gespielt. Ein verpasster Tag pro Woche wird verziehen.';

  @override
  String profileOf(String name) {
    return 'Profil $name';
  }

  @override
  String dayNumber(int day) {
    return 'Tag $day';
  }

  @override
  String aboutMinutes(int minutes) {
    return 'ca. $minutes Min';
  }

  @override
  String get threeLevels => '3 Stufen';

  @override
  String levelsSolved(int count) {
    return '$count von 3 Stufen';
  }

  @override
  String lastLevel(String level) {
    return 'Zuletzt: $level';
  }

  @override
  String get openDoor => 'Türchen öffnen';

  @override
  String get continuePlaying => 'Weiterspielen';

  @override
  String get playAgain => 'Nochmal spielen';

  @override
  String get thisWeek => 'Diese Woche';

  @override
  String weekProgress(int count) {
    return '$count von 7';
  }

  @override
  String tomorrowTeaser(String category) {
    return 'Morgen: $category';
  }

  @override
  String get tomorrowWithPremium => 'Mit Premium schon heute spielen';

  @override
  String get tomorrowPlayNow => 'Jetzt schon vorspielen';

  @override
  String get weekdayMo => 'Mo';

  @override
  String get weekdayTu => 'Di';

  @override
  String get weekdayWe => 'Mi';

  @override
  String get weekdayTh => 'Do';

  @override
  String get weekdayFr => 'Fr';

  @override
  String get weekdaySa => 'Sa';

  @override
  String get weekdaySu => 'So';

  @override
  String get levelEasy => 'Einfach';

  @override
  String get levelStandard => 'Standard';

  @override
  String get levelAdvanced => 'Fortgeschritten';

  @override
  String get levelQuestion => 'Wie knifflig?';

  @override
  String get levelGroup => 'Stufe';

  @override
  String get goldHint =>
      'Alle drei Stufen geschafft: Der Tag wird im Kalender golden.';

  @override
  String startLevel(String level) {
    return '$level starten';
  }

  @override
  String starsOf(int count) {
    return '$count von 3 Sternen';
  }

  @override
  String levelChipLabel(String level) {
    return 'Stufe $level, tippen zum Wechseln';
  }

  @override
  String get leaveGame => 'Spiel verlassen';

  @override
  String get hint => 'Tipp';

  @override
  String get pause => 'Pause';

  @override
  String get pausedTitle => 'Pause';

  @override
  String get pausedBody => 'Die Zeit steht still, bis du weiterspielst.';

  @override
  String get resume => 'Weiterspielen';

  @override
  String get leaveTitle => 'Spiel verlassen?';

  @override
  String get leaveBody => 'Dein Fortschritt in dieser Stufe geht verloren.';

  @override
  String get keepPlaying => 'Weiterspielen';

  @override
  String get leave => 'Verlassen';

  @override
  String get howToTitle => 'So geht’s';

  @override
  String get letsGo => 'Los geht’s';

  @override
  String get readAloud => 'Vorlesen';

  @override
  String get resultGreat => 'Großartig!';

  @override
  String get resultDone => 'Geschafft!';

  @override
  String get resultGood => 'Gut gespielt!';

  @override
  String get statTime => 'Zeit';

  @override
  String get statMistakes => 'Fehler';

  @override
  String get statMoves => 'Züge';

  @override
  String get statScore => 'Punkte';

  @override
  String get statAttempts => 'Versuche';

  @override
  String get statStreak => 'Tage Serie';

  @override
  String get statStars => 'Sterne';

  @override
  String get statStickers => 'Sticker';

  @override
  String get statPlayed => 'Tage gespielt';

  @override
  String get statGold => 'Gold-Tage';

  @override
  String get share => 'Teilen';

  @override
  String nextLevelQuestion(String level) {
    return '$level?';
  }

  @override
  String shareText(String day, String game, String stars, String time) {
    return 'Kleine Pause · $day\n$game $stars in $time';
  }

  @override
  String get adHeader => 'ANZEIGE · NACH DEM SPIEL';

  @override
  String get adRemove => 'Werbefrei mit Premium';

  @override
  String get adLabel => 'Anzeige';

  @override
  String get houseAdTitle => 'Spiel jeden Tag des Jahres';

  @override
  String get houseAdBody =>
      'Mit Premium verpasste Tage nachholen, ohne Werbung.';

  @override
  String tomorrowWaits(String what) {
    return 'Morgen wartet: $what';
  }

  @override
  String reminderAt(String time) {
    return 'Erinnerung um $time Uhr';
  }

  @override
  String get reminderOff => 'Erinnerung einschalten';

  @override
  String get reminderSettingTitle => 'Erinnerung';

  @override
  String get reminderExplain =>
      'Jeden Tag zur gleichen Zeit an deine kleine Pause erinnern.';

  @override
  String get reminderDaily => 'Täglich erinnern';

  @override
  String get reminderTime => 'Uhrzeit';

  @override
  String get reminderTitle => 'Zeit für eine kleine Pause';

  @override
  String get reminderBody => 'Dein Spiel des Tages wartet schon.';

  @override
  String get reminderDeniedTitle => 'Mitteilungen sind aus';

  @override
  String get reminderDeniedBody =>
      'Erlaube Mitteilungen für Kleine Pause in den Einstellungen deines Geräts.';

  @override
  String get viewMonth => 'Monat';

  @override
  String get viewYear => 'Jahr';

  @override
  String get previousMonth => 'Vormonat';

  @override
  String get nextMonth => 'Nächster Monat';

  @override
  String monthPlayed(int played, int available) {
    return '$played von $available gespielt';
  }

  @override
  String get dayToday => 'heute';

  @override
  String get dayGold => 'gespielt, Gold';

  @override
  String get dayCatchUp => 'nachholen';

  @override
  String get dayMissedPremium => 'verpasst, nur mit Premium';

  @override
  String get dayPlayAhead => 'vorspielen';

  @override
  String get dayLocked => 'gesperrt';

  @override
  String get legend => 'Legende';

  @override
  String get legendPlayed => 'Gespielt';

  @override
  String get legendGold => 'Gold: alle 3 Stufen';

  @override
  String get legendCatchUp => 'Nachholen';

  @override
  String get legendAhead => 'Vorspielen';

  @override
  String missedDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Tage verpasst',
      one: '1 Tag verpasst',
    );
    return '$_temp0';
  }

  @override
  String get missedBody => 'Mit Premium nachholen und 3 Tage vorspielen';

  @override
  String yearSummary(int played, int gold) {
    return '$played Tage gespielt · $gold Gold-Tage';
  }

  @override
  String galleryCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Bilder',
      one: '1 Bild',
      zero: 'Noch keine Bilder',
    );
    return '$_temp0';
  }

  @override
  String get galleryEmptyTitle => 'Deine Galerie';

  @override
  String get galleryEmptyBody =>
      'Hier landen deine ausgemalten Bilder und Pixel-Kunstwerke.';

  @override
  String get settings => 'Einstellungen';

  @override
  String get language => 'Sprache';

  @override
  String get languageSystem => 'Wie das Gerät';

  @override
  String get languageGerman => 'Deutsch';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageMore => 'Weitere Sprachen folgen.';

  @override
  String get haptics => 'Vibration';

  @override
  String get premiumSection => 'Premium';

  @override
  String get premiumActiveShort => 'Aktiv';

  @override
  String get premiumUnlock => 'Freischalten';

  @override
  String get premiumDebug => 'Premium testen (nur Debug)';

  @override
  String get profileSection => 'Profil';

  @override
  String get switchProfile => 'Profil wechseln';

  @override
  String get renameProfile => 'Profil umbenennen';

  @override
  String get deleteProfile => 'Profil löschen';

  @override
  String deleteProfileTitle(String name) {
    return '$name löschen?';
  }

  @override
  String get deleteProfileBody =>
      'Kalender, Serie und Galerie dieses Profils werden gelöscht.';

  @override
  String get parentsArea => 'Elternbereich';

  @override
  String get aboutLine =>
      'Kleine Pause · QuizQuiz-Fragen von Zitat des Tages (zitatdestages.net)';

  @override
  String get premiumTitle => 'Kleine Pause Premium';

  @override
  String get premiumSubtitle => 'Dein ganzes Jahr, in deinem Tempo.';

  @override
  String get perkNoAds => 'Keine Werbung';

  @override
  String get perkNoAdsBody => 'Auch nicht vor oder nach dem Spiel';

  @override
  String get perkPast => 'Jeden vergangenen Tag nachholen';

  @override
  String get perkPastBody => 'Seit dem 1. Januar, so weit zurück du willst';

  @override
  String get perkAhead => '3 Tage vorspielen';

  @override
  String get perkAheadBody => 'Für Urlaub, Wochenende oder Neugier';

  @override
  String get perkProfiles => 'Für alle Profile';

  @override
  String get perkProfilesBody => 'Erwachsene und Kinder auf diesem Gerät';

  @override
  String get planYearly => 'Jährlich';

  @override
  String get planYearlyNote => 'Beliebteste Wahl';

  @override
  String get planOnce => 'Einmalig';

  @override
  String get planOnceNote => 'Für dieses Jahr';

  @override
  String pricePerYear(String price) {
    return '$price / Jahr';
  }

  @override
  String get premiumStart => 'Premium starten';

  @override
  String get premiumActive => 'Premium ist aktiv. Danke!';

  @override
  String get restorePurchases => 'Käufe wiederherstellen';

  @override
  String get terms => 'Bedingungen';

  @override
  String get termsBody =>
      'Premium gilt für alle Profile auf diesem Gerät. Das Jahresabo verlängert sich automatisch und ist jederzeit in den Store-Einstellungen kündbar. Der Einmalkauf gilt bis zum 31. Dezember dieses Jahres.';

  @override
  String get purchaseUnavailableTitle => 'Gerade nicht möglich';

  @override
  String get purchaseUnavailableBody =>
      'Der Store ist in dieser Version noch nicht angebunden.';

  @override
  String get restoreNoneTitle => 'Nichts gefunden';

  @override
  String get restoreNoneBody => 'Für dieses Konto gibt es keinen Premium-Kauf.';

  @override
  String kidsHello(String name) {
    return 'Hallo $name!';
  }

  @override
  String get parents => 'Eltern';

  @override
  String stickersCollected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Sticker gesammelt',
      one: '1 Sticker gesammelt',
    );
    return '$_temp0';
  }

  @override
  String stickersToPage(int count, String month) {
    return 'Noch $count bis zur $month-Seite';
  }

  @override
  String stickerPageDone(String month) {
    return '$month-Seite geschafft!';
  }

  @override
  String stickerFor(String date) {
    return 'Sticker vom $date';
  }

  @override
  String get stickerColorIn => 'Ausmalen';

  @override
  String get stickerColoredTitle => 'Wunderschön!';

  @override
  String get stickerColoredBody =>
      'Dein Bild ist fertig. Tipp einen anderen Sticker an, um weiterzumalen.';

  @override
  String get gateTitle => 'Frag deine Eltern';

  @override
  String get gateBody => 'Dieser Bereich ist für Erwachsene.';

  @override
  String gateQuestion(int a, int b) {
    return 'Wie viel ist $a × $b?';
  }

  @override
  String get gateWrong => 'Nicht ganz. Neue Aufgabe:';

  @override
  String get categoryCreative => 'Kreativ';

  @override
  String get categoryWord => 'Wort & Sprache';

  @override
  String get categoryQuiz => 'Quiz & Wissen';

  @override
  String get categoryLogic => 'Logik';

  @override
  String get categoryArcade => 'Geschick & Arcade';

  @override
  String get categoryMemory => 'Gedächtnis';

  @override
  String get categoryNumbers => 'Zahlen';

  @override
  String get categoryMindful => 'Entspannung';

  @override
  String get theme1 => 'Neuanfang & Winter';

  @override
  String get theme2 => 'Liebe & Fasching';

  @override
  String get theme3 => 'Erwachen';

  @override
  String get theme4 => 'Ostern & Garten';

  @override
  String get theme5 => 'Blüte & Natur';

  @override
  String get theme6 => 'Sport & Bewegung';

  @override
  String get theme7 => 'Ferien & Meer';

  @override
  String get theme8 => 'Reisen & Welt';

  @override
  String get theme9 => 'Schule & Wissen';

  @override
  String get theme10 => 'Herbst & Grusel';

  @override
  String get theme11 => 'Gemütlichkeit';

  @override
  String get theme12 => 'Advent & Jahresrückblick';

  @override
  String get edition1 => 'Schneeflocken-Edition';

  @override
  String get edition2 => 'Herzklopfen-Edition';

  @override
  String get edition3 => 'Frühlingserwachen-Edition';

  @override
  String get edition4 => 'Osterhasen-Edition';

  @override
  String get edition5 => 'Blütenzauber-Edition';

  @override
  String get edition6 => 'Sommeranfang-Edition';

  @override
  String get edition7 => 'Strandkorb-Edition';

  @override
  String get edition8 => 'Fernweh-Edition';

  @override
  String get edition9 => 'Erntezeit-Edition';

  @override
  String get edition10 => 'Herbstlaub-Edition';

  @override
  String get edition11 => 'Laternen-Edition';

  @override
  String get edition12 => 'Adventszauber-Edition';

  @override
  String get specialNewYear => 'Neujahr';

  @override
  String get specialValentine => 'Valentinstag';

  @override
  String get specialLeapDay => 'Schalttag-Bonus';

  @override
  String get specialPiDay => 'Pi-Tag';

  @override
  String get specialSpring => 'Frühlingsanfang';

  @override
  String get specialAprilFools => 'Aprilscherz';

  @override
  String get specialEarthDay => 'Tag der Erde';

  @override
  String get specialBookDay => 'Welttag des Buches';

  @override
  String get specialMayDay => 'Maifeiertag';

  @override
  String get specialSummer => 'Sommeranfang';

  @override
  String get specialUnityDay => 'Tag der Deutschen Einheit';

  @override
  String get specialHalloween => 'Halloween';

  @override
  String get specialStMartin => 'Martinstag';

  @override
  String get specialChristmasEve => 'Heiligabend';

  @override
  String get specialChristmas => 'Weihnachten';

  @override
  String get specialBoxingDay => 'Zweiter Weihnachtstag';

  @override
  String get specialNewYearsEve => 'Silvester';

  @override
  String get specialCarnival => 'Rosenmontag';

  @override
  String get specialEaster => 'Ostern';

  @override
  String get specialMothersDay => 'Muttertag';

  @override
  String get specialAdvent => 'Adventskalender';

  @override
  String get motifPumpkin => 'Kürbis';

  @override
  String get motifHeart => 'Herz';

  @override
  String get motifFlower => 'Blume';

  @override
  String get motifStar => 'Stern';

  @override
  String get motifTree => 'Tannenbaum';

  @override
  String get motifLantern => 'Laterne';

  @override
  String get motifMask => 'Faschingsmaske';

  @override
  String get motifEgg => 'Osterei';

  @override
  String get motifLeaf => 'Herbstblatt';

  @override
  String get motifMushroom => 'Fliegenpilz';

  @override
  String get motifHouse => 'Häuschen';

  @override
  String get motifFish => 'Fisch';

  @override
  String get motifSnowman => 'Schneemann';

  @override
  String get motifSun => 'Sonne';

  @override
  String get motifButterfly => 'Schmetterling';

  @override
  String get motifHedgehog => 'Igel im Herbstlaub';

  @override
  String get motifIcecream => 'Eistüte';

  @override
  String get motifSailboat => 'Segelboot';

  @override
  String get motifUmbrella => 'Regenschirm';

  @override
  String get gameColoring => 'Ausmalen';

  @override
  String get gamePixelArt => 'Pixel-Kunst';

  @override
  String get gameWordGuess => 'Wortraten';

  @override
  String get gameAnagram => 'Buchstabensalat';

  @override
  String get gameWordSearch => 'Wortsuche';

  @override
  String get gameQuoteQuiz => 'QuizQuiz';

  @override
  String get gameTrueFalse => 'Wahr oder falsch';

  @override
  String get gameSudoku => 'Sudoku';

  @override
  String get gameNonogram => 'Nonogramm';

  @override
  String get gameLightsOut => 'Lichter aus';

  @override
  String get gameHanoi => 'Turm von Hanoi';

  @override
  String get gameMaze => 'Labyrinth';

  @override
  String get gameStacking => 'Turmbau';

  @override
  String get gameMinesweeper => 'Minensuche';

  @override
  String get game2048 => '2048';

  @override
  String get gameNumberPyramid => 'Zahlenpyramide';

  @override
  String get gameMemory => 'Memo';

  @override
  String get gameSimon => 'Farbenfolge';

  @override
  String get gameSlidePuzzle => 'Schiebepuzzle';

  @override
  String get gameBreathing => 'Atempause';

  @override
  String get howToColoring =>
      'Wähle eine Farbe und tippe auf eine Fläche, um sie auszumalen. Auf „Fortgeschritten“ malst du nach Zahlen: Jede Zahl gehört zu einer Farbe. Der Tipp malt eine Fläche für dich aus.';

  @override
  String get howToPixelArt =>
      'Jede Zahl steht für eine Farbe. Wähle unten die Farbe und tippe oder wische über die passenden Kästchen, bis das Bild fertig ist.';

  @override
  String get howToWordGuess =>
      'Errate das Wort in sechs Versuchen. Grün: Buchstabe an der richtigen Stelle. Gelb: kommt vor, aber woanders. Grau: kommt nicht vor.';

  @override
  String get howToAnagram =>
      'Die Buchstaben sind durcheinander. Tippe sie in der richtigen Reihenfolge an, um das Wort zu bilden. Tippe auf ein gelegtes Feld, um ab dort zurückzunehmen.';

  @override
  String get howToWordSearch =>
      'Finde alle Wörter im Gitter. Ziehe mit dem Finger vom ersten bis zum letzten Buchstaben – waagerecht, senkrecht oder diagonal.';

  @override
  String get howToQuoteQuiz =>
      'Lies das Zitat und tippe auf die Person, von der es stammt. Die Fragen kommen von der App „Zitat des Tages“.';

  @override
  String get howToTrueFalse =>
      'Stimmt die Aussage oder nicht? Tippe auf „Wahr“ oder „Falsch“. Auf „Fortgeschritten“ hast du pro Aussage zehn Sekunden.';

  @override
  String get howToSudoku =>
      'Fülle das Gitter so, dass jede Zahl in jeder Zeile, jeder Spalte und jedem Block genau einmal vorkommt. Tippe ein Feld an und dann eine Zahl. Mit „Notizen“ merkst du dir Kandidaten.';

  @override
  String get howToNonogram =>
      'Die Zahlen am Rand verraten, wie viele Felder hintereinander gefüllt sind. Fülle die richtigen Felder, und ein Bild entsteht. Mit dem Kreuz markierst du sichere Lücken.';

  @override
  String get howToLightsOut =>
      'Ein Tipp schaltet ein Licht und seine Nachbarn um. Schalte alle Lichter aus.';

  @override
  String get howToHanoi =>
      'Bringe den ganzen Turm auf den rechten Stab. Tippe einen Stab an, um die oberste Scheibe zu nehmen, und dann das Ziel. Nie eine größere auf eine kleinere Scheibe legen.';

  @override
  String get howToMaze =>
      'Führe den Punkt zum Ziel. Wische in eine Richtung oder nutze die Pfeile.';

  @override
  String get howToStacking =>
      'Der Block schwingt hin und her. Tippe, um ihn fallen zu lassen. Was übersteht, fällt ab. Baue den Turm bis zur Zielhöhe.';

  @override
  String get howToMinesweeper =>
      'Decke alle Felder ohne Mine auf. Die Zahl sagt, wie viele Minen um ein Feld liegen. Mit der Flagge markierst du Verdachtsfälle. Der erste Tipp ist immer sicher.';

  @override
  String get howTo2048 =>
      'Wische, um alle Kacheln zu schieben. Gleiche Zahlen verschmelzen. Erreiche die Zielzahl.';

  @override
  String get howToNumberPyramid =>
      'Jeder Stein ist die Summe der beiden Steine darunter. Fülle die leeren Steine und prüfe dann.';

  @override
  String get howToMemory =>
      'Decke immer zwei Karten auf. Finde alle Paare mit möglichst wenigen Fehlversuchen.';

  @override
  String get howToSimon =>
      'Schau dir die Farbenfolge an und tippe sie danach nach. Jede Runde kommt eine Farbe dazu.';

  @override
  String get howToSlidePuzzle =>
      'Schiebe die Kacheln in die Lücke, bis das Bild wieder stimmt. Tippe eine Kachel neben der Lücke an.';

  @override
  String get howToBreathing =>
      'Atme mit dem Kreis: einatmen, wenn er wächst, kurz halten, ausatmen, wenn er schrumpft. Es gibt nichts zu gewinnen, nur Ruhe.';

  @override
  String get kidColoring =>
      'Such dir eine Farbe aus und tippe auf eine Fläche. Mal das Bild ganz bunt an!';

  @override
  String get kidPixelArt =>
      'Jede Zahl hat eine Farbe. Mal alle Kästchen mit der richtigen Farbe aus!';

  @override
  String get kidAnagram =>
      'Die Buchstaben sind durcheinander. Tippe sie richtig nacheinander an!';

  @override
  String get kidWordSearch =>
      'Finde die Wörter! Fahre mit dem Finger über die Buchstaben.';

  @override
  String get kidTrueFalse => 'Stimmt das? Tippe auf Wahr oder Falsch.';

  @override
  String get kidSudoku =>
      'Jede Zahl darf in jeder Reihe nur einmal vorkommen. Probier es aus!';

  @override
  String get kidLightsOut => 'Tippe auf die Lichter, bis alle aus sind!';

  @override
  String get kidHanoi =>
      'Bau den Turm auf dem rechten Stab wieder auf. Große Scheiben immer unten!';

  @override
  String get kidMaze => 'Hilf dem Punkt durch das Labyrinth bis zum Ziel!';

  @override
  String get kidStacking =>
      'Tippe genau im richtigen Moment und bau einen hohen Turm!';

  @override
  String get kidNumberPyramid =>
      'Zwei Steine zusammen ergeben den Stein darüber. Rechne mit!';

  @override
  String get kidMemory => 'Dreh zwei Karten um und finde die Paare!';

  @override
  String get kidSimon =>
      'Schau gut zu und tippe die Farben in der gleichen Reihenfolge!';

  @override
  String get kidSlidePuzzle => 'Schiebe die Teile, bis das Bild wieder stimmt!';

  @override
  String get kidBreathing => 'Atme mit dem Kreis ein und aus. Ganz ruhig.';

  @override
  String detailGrid(String size, int minutes) {
    return '$size Felder · ca. $minutes Min';
  }

  @override
  String detailPairs(int count, int minutes) {
    return '$count Paare · ca. $minutes Min';
  }

  @override
  String detailDiscs(int count, int minutes) {
    return '$count Scheiben · ca. $minutes Min';
  }

  @override
  String detailRows(int count, int minutes) {
    return '$count Reihen · ca. $minutes Min';
  }

  @override
  String detailTarget(String target, int minutes) {
    return 'Ziel $target · ca. $minutes Min';
  }

  @override
  String detailMines(String size, int mines, int minutes) {
    return '$size Felder, $mines Minen · ca. $minutes Min';
  }

  @override
  String detailSequence(int count, int minutes) {
    return 'Folge von $count · ca. $minutes Min';
  }

  @override
  String detailBlocks(int count, int minutes) {
    return '$count Blöcke hoch · ca. $minutes Min';
  }

  @override
  String detailBreaths(int count, int minutes) {
    return '$count Atemzüge · ca. $minutes Min';
  }

  @override
  String detailLetters(int count, int minutes) {
    return '$count Buchstaben · ca. $minutes Min';
  }

  @override
  String detailAnagram(int count, int length, int minutes) {
    return '$count Wörter mit $length Buchstaben · ca. $minutes Min';
  }

  @override
  String detailWords(int count, int minutes) {
    return '$count Wörter · ca. $minutes Min';
  }

  @override
  String detailQuiz(int questions, int answers, int minutes) {
    return '$questions Fragen, $answers Antworten · ca. $minutes Min';
  }

  @override
  String detailStatements(int count, int minutes) {
    return '$count Aussagen · ca. $minutes Min';
  }

  @override
  String detailColoring(int colors, int minutes) {
    return 'Freies Ausmalen, $colors Farben · ca. $minutes Min';
  }

  @override
  String detailPaintByNumbers(int minutes) {
    return 'Malen nach Zahlen · ca. $minutes Min';
  }

  @override
  String sudokuGridLabel(int size) {
    return 'Sudoku $size mal $size';
  }

  @override
  String cellLabel(int row, int column, String value) {
    return 'Zeile $row, Spalte $column: $value';
  }

  @override
  String get cellEmpty => 'leer';

  @override
  String get cellFilled => 'gefüllt';

  @override
  String get cellCrossed => 'ausgekreuzt';

  @override
  String get cellHidden => 'verdeckt';

  @override
  String numberLabel(int number) {
    return 'Zahl $number';
  }

  @override
  String tileLabel(int number) {
    return 'Kachel $number';
  }

  @override
  String brickLabel(int row, int brick, String value) {
    return 'Reihe $row, Stein $brick: $value';
  }

  @override
  String mistakesCount(int count) {
    return 'Fehler $count';
  }

  @override
  String hintsCount(int used, int max) {
    return 'Tipps $used von $max';
  }

  @override
  String movesCount(int count) {
    return 'Züge $count';
  }

  @override
  String scoreCount(int count) {
    return 'Punkte $count';
  }

  @override
  String target(String target) {
    return 'Ziel $target';
  }

  @override
  String roundOf(int current, int total) {
    return 'Runde $current von $total';
  }

  @override
  String heightOf(int current, int total) {
    return 'Höhe $current von $total';
  }

  @override
  String breathOf(int current, int total) {
    return 'Atemzug $current von $total';
  }

  @override
  String attemptOf(int current, int total) {
    return 'Versuch $current von $total';
  }

  @override
  String attemptCount(int count) {
    return 'Versuch $count';
  }

  @override
  String wordOf(int current, int total) {
    return 'Wort $current von $total';
  }

  @override
  String wordsFound(int current, int total) {
    return '$current von $total gefunden';
  }

  @override
  String questionOf(int current, int total) {
    return 'Frage $current von $total';
  }

  @override
  String pairsFound(int current, int total) {
    return '$current von $total Paaren';
  }

  @override
  String lightsLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Lichter an',
      one: '1 Licht an',
    );
    return '$_temp0';
  }

  @override
  String minesLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Minen übrig',
      one: '1 Mine übrig',
    );
    return '$_temp0';
  }

  @override
  String hanoiOptimal(int count) {
    return 'Bestmöglich: $count Züge';
  }

  @override
  String areasColored(int current, int total) {
    return '$current von $total Flächen';
  }

  @override
  String pixelsPainted(int current, int total) {
    return '$current von $total Kästchen';
  }

  @override
  String secondsLeft(int count) {
    return '$count s';
  }

  @override
  String colorNumber(int number) {
    return 'Farbe $number';
  }

  @override
  String get coloringLabel => 'Ausmalbild';

  @override
  String pixelLabel(int size) {
    return 'Pixelbild $size mal $size';
  }

  @override
  String get erase => 'Löschen';

  @override
  String get notes => 'Notizen';

  @override
  String get undo => 'Rückgängig';

  @override
  String get check => 'Prüfen';

  @override
  String get start => 'Start';

  @override
  String get shuffle => 'Mischen';

  @override
  String get clear => 'Leeren';

  @override
  String get tryAgain => 'Nochmal';

  @override
  String get next => 'Weiter';

  @override
  String get finish => 'Fertig';

  @override
  String get reveal => 'Aufdecken';

  @override
  String get flag => 'Flagge';

  @override
  String memoryCardOpen(int number) {
    return 'Karte $number, offen';
  }

  @override
  String memoryCardClosed(int number) {
    return 'Karte $number, verdeckt';
  }

  @override
  String lightLabel(int row, int column, String state) {
    return 'Licht Zeile $row, Spalte $column: $state';
  }

  @override
  String get lightOn => 'an';

  @override
  String get lightOff => 'aus';

  @override
  String get lightsGoal => 'Schalte alle Lichter aus.';

  @override
  String get slideGoal => 'Schiebe die Kacheln in die richtige Reihenfolge.';

  @override
  String hanoiPeg(int number, int count) {
    return 'Stab $number, $count Scheiben';
  }

  @override
  String get hanoiGoal => 'Bringe alle Scheiben auf den rechten Stab.';

  @override
  String get pyramidGoal => 'Jeder Stein ist die Summe der zwei darunter.';

  @override
  String get mazeLabel => 'Labyrinth';

  @override
  String get directionUp => 'Hoch';

  @override
  String get directionDown => 'Runter';

  @override
  String get directionLeft => 'Links';

  @override
  String get directionRight => 'Rechts';

  @override
  String get game2048Stuck => 'Keine Züge mehr.';

  @override
  String get swipeHint => 'Wische, um die Kacheln zu schieben.';

  @override
  String get nonogramFill => 'Füllen';

  @override
  String get nonogramCross => 'Kreuz';

  @override
  String get mine => 'Mine';

  @override
  String get mineBoom => 'Bumm! Neuer Versuch mit neuem Feld.';

  @override
  String simonPad(int number) {
    return 'Farbe $number';
  }

  @override
  String get simonWatch => 'Gut zuschauen …';

  @override
  String get simonYourTurn => 'Du bist dran!';

  @override
  String get stackingHint => 'Tippe, um den Block fallen zu lassen.';

  @override
  String get breatheIn => 'Einatmen';

  @override
  String get breatheHold => 'Halten';

  @override
  String get breatheOut => 'Ausatmen';

  @override
  String get breatheReady => 'Bereit?';

  @override
  String wordWas(String word) {
    return 'Gesucht war: $word';
  }

  @override
  String wordSearchLabel(int size) {
    return 'Buchstabengitter $size mal $size';
  }

  @override
  String get whoSaidIt => 'Wer hat’s gesagt?';

  @override
  String get answerRight => 'Richtig!';

  @override
  String answerWrong(String answer) {
    return 'Leider nein: $answer';
  }

  @override
  String get answerWrongPlain => 'Leider nein.';

  @override
  String get quoteSource => 'Fragen: Zitat des Tages · zitatdestages.net';

  @override
  String get quizUnavailable =>
      'Gerade keine Fragen da. Versuch es später nochmal.';

  @override
  String get trueOrFalse => 'Wahr oder falsch?';

  @override
  String get answerTrue => 'Wahr';

  @override
  String get answerFalse => 'Falsch';

  @override
  String get timeUp => 'Zeit um!';
}
