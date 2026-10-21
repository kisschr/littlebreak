import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In de, this message translates to:
  /// **'Kleine Pause'**
  String get appTitle;

  /// No description provided for @tabToday.
  ///
  /// In de, this message translates to:
  /// **'Heute'**
  String get tabToday;

  /// No description provided for @tabCalendar.
  ///
  /// In de, this message translates to:
  /// **'Kalender'**
  String get tabCalendar;

  /// No description provided for @tabGallery.
  ///
  /// In de, this message translates to:
  /// **'Galerie'**
  String get tabGallery;

  /// No description provided for @tabProfile.
  ///
  /// In de, this message translates to:
  /// **'Profil'**
  String get tabProfile;

  /// No description provided for @tabStickers.
  ///
  /// In de, this message translates to:
  /// **'Sticker'**
  String get tabStickers;

  /// No description provided for @close.
  ///
  /// In de, this message translates to:
  /// **'Schließen'**
  String get close;

  /// No description provided for @ok.
  ///
  /// In de, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @cancel.
  ///
  /// In de, this message translates to:
  /// **'Abbrechen'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In de, this message translates to:
  /// **'Speichern'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In de, this message translates to:
  /// **'Löschen'**
  String get delete;

  /// No description provided for @done.
  ///
  /// In de, this message translates to:
  /// **'Fertig'**
  String get done;

  /// No description provided for @off.
  ///
  /// In de, this message translates to:
  /// **'Aus'**
  String get off;

  /// No description provided for @played.
  ///
  /// In de, this message translates to:
  /// **'gespielt'**
  String get played;

  /// No description provided for @pickerOverline.
  ///
  /// In de, this message translates to:
  /// **'Kleine Pause · 366 Spiele'**
  String get pickerOverline;

  /// No description provided for @pickerTitle.
  ///
  /// In de, this message translates to:
  /// **'Wer spielt heute?'**
  String get pickerTitle;

  /// No description provided for @pickerWelcome.
  ///
  /// In de, this message translates to:
  /// **'Willkommen bei Kleine Pause'**
  String get pickerWelcome;

  /// No description provided for @pickerBody.
  ///
  /// In de, this message translates to:
  /// **'Jedes Profil hat seinen eigenen Kalender, seine Serie und seine Galerie.'**
  String get pickerBody;

  /// No description provided for @newProfile.
  ///
  /// In de, this message translates to:
  /// **'Neues Profil'**
  String get newProfile;

  /// No description provided for @audienceAdults.
  ///
  /// In de, this message translates to:
  /// **'Erwachsene'**
  String get audienceAdults;

  /// No description provided for @audienceAdultsBody.
  ///
  /// In de, this message translates to:
  /// **'Alle Spiele, mit Zeit und Bestenwerten'**
  String get audienceAdultsBody;

  /// No description provided for @audienceKids.
  ///
  /// In de, this message translates to:
  /// **'Kinder'**
  String get audienceKids;

  /// No description provided for @audienceKidsBody.
  ///
  /// In de, this message translates to:
  /// **'Ohne Zeitdruck, mit Vorlesen und Elternsperre'**
  String get audienceKidsBody;

  /// No description provided for @createProfileTitle.
  ///
  /// In de, this message translates to:
  /// **'Wie heißt du?'**
  String get createProfileTitle;

  /// No description provided for @profileNameHint.
  ///
  /// In de, this message translates to:
  /// **'Name'**
  String get profileNameHint;

  /// No description provided for @createProfile.
  ///
  /// In de, this message translates to:
  /// **'Profil anlegen'**
  String get createProfile;

  /// No description provided for @createAdultNote.
  ///
  /// In de, this message translates to:
  /// **'Du startest auf Standard und kannst jeden Tag die Stufe wählen.'**
  String get createAdultNote;

  /// No description provided for @createKidNote.
  ///
  /// In de, this message translates to:
  /// **'Kinderprofile spielen ohne Uhr und Werbung. Käufe und Einstellungen sind hinter einer Elternsperre.'**
  String get createKidNote;

  /// No description provided for @streakDays.
  ///
  /// In de, this message translates to:
  /// **'{count, plural, =1{1 Tag} other{{count} Tage}}'**
  String streakDays(int count);

  /// No description provided for @streakSeries.
  ///
  /// In de, this message translates to:
  /// **'{count, plural, =1{1 Tag Serie} other{{count} Tage Serie}}'**
  String streakSeries(int count);

  /// No description provided for @streakExplain.
  ///
  /// In de, this message translates to:
  /// **'So viele Tage hintereinander hast du gespielt. Ein verpasster Tag pro Woche wird verziehen.'**
  String get streakExplain;

  /// No description provided for @profileOf.
  ///
  /// In de, this message translates to:
  /// **'Profil {name}'**
  String profileOf(String name);

  /// No description provided for @dayNumber.
  ///
  /// In de, this message translates to:
  /// **'Tag {day}'**
  String dayNumber(int day);

  /// No description provided for @aboutMinutes.
  ///
  /// In de, this message translates to:
  /// **'ca. {minutes} Min'**
  String aboutMinutes(int minutes);

  /// No description provided for @threeLevels.
  ///
  /// In de, this message translates to:
  /// **'3 Stufen'**
  String get threeLevels;

  /// No description provided for @levelsSolved.
  ///
  /// In de, this message translates to:
  /// **'{count} von 3 Stufen'**
  String levelsSolved(int count);

  /// No description provided for @lastLevel.
  ///
  /// In de, this message translates to:
  /// **'Zuletzt: {level}'**
  String lastLevel(String level);

  /// No description provided for @openDoor.
  ///
  /// In de, this message translates to:
  /// **'Türchen öffnen'**
  String get openDoor;

  /// No description provided for @continuePlaying.
  ///
  /// In de, this message translates to:
  /// **'Weiterspielen'**
  String get continuePlaying;

  /// No description provided for @playAgain.
  ///
  /// In de, this message translates to:
  /// **'Nochmal spielen'**
  String get playAgain;

  /// No description provided for @thisWeek.
  ///
  /// In de, this message translates to:
  /// **'Diese Woche'**
  String get thisWeek;

  /// No description provided for @weekProgress.
  ///
  /// In de, this message translates to:
  /// **'{count} von 7'**
  String weekProgress(int count);

  /// No description provided for @tomorrowTeaser.
  ///
  /// In de, this message translates to:
  /// **'Morgen: {category}'**
  String tomorrowTeaser(String category);

  /// No description provided for @tomorrowWithPremium.
  ///
  /// In de, this message translates to:
  /// **'Mit Premium schon heute spielen'**
  String get tomorrowWithPremium;

  /// No description provided for @tomorrowPlayNow.
  ///
  /// In de, this message translates to:
  /// **'Jetzt schon vorspielen'**
  String get tomorrowPlayNow;

  /// No description provided for @weekdayMo.
  ///
  /// In de, this message translates to:
  /// **'Mo'**
  String get weekdayMo;

  /// No description provided for @weekdayTu.
  ///
  /// In de, this message translates to:
  /// **'Di'**
  String get weekdayTu;

  /// No description provided for @weekdayWe.
  ///
  /// In de, this message translates to:
  /// **'Mi'**
  String get weekdayWe;

  /// No description provided for @weekdayTh.
  ///
  /// In de, this message translates to:
  /// **'Do'**
  String get weekdayTh;

  /// No description provided for @weekdayFr.
  ///
  /// In de, this message translates to:
  /// **'Fr'**
  String get weekdayFr;

  /// No description provided for @weekdaySa.
  ///
  /// In de, this message translates to:
  /// **'Sa'**
  String get weekdaySa;

  /// No description provided for @weekdaySu.
  ///
  /// In de, this message translates to:
  /// **'So'**
  String get weekdaySu;

  /// No description provided for @levelEasy.
  ///
  /// In de, this message translates to:
  /// **'Einfach'**
  String get levelEasy;

  /// No description provided for @levelStandard.
  ///
  /// In de, this message translates to:
  /// **'Standard'**
  String get levelStandard;

  /// No description provided for @levelAdvanced.
  ///
  /// In de, this message translates to:
  /// **'Fortgeschritten'**
  String get levelAdvanced;

  /// No description provided for @levelQuestion.
  ///
  /// In de, this message translates to:
  /// **'Wie knifflig?'**
  String get levelQuestion;

  /// No description provided for @levelGroup.
  ///
  /// In de, this message translates to:
  /// **'Stufe'**
  String get levelGroup;

  /// No description provided for @goldHint.
  ///
  /// In de, this message translates to:
  /// **'Alle drei Stufen geschafft: Der Tag wird im Kalender golden.'**
  String get goldHint;

  /// No description provided for @startLevel.
  ///
  /// In de, this message translates to:
  /// **'{level} starten'**
  String startLevel(String level);

  /// No description provided for @starsOf.
  ///
  /// In de, this message translates to:
  /// **'{count} von 3 Sternen'**
  String starsOf(int count);

  /// No description provided for @levelChipLabel.
  ///
  /// In de, this message translates to:
  /// **'Stufe {level}, tippen zum Wechseln'**
  String levelChipLabel(String level);

  /// No description provided for @leaveGame.
  ///
  /// In de, this message translates to:
  /// **'Spiel verlassen'**
  String get leaveGame;

  /// No description provided for @hint.
  ///
  /// In de, this message translates to:
  /// **'Tipp'**
  String get hint;

  /// No description provided for @pause.
  ///
  /// In de, this message translates to:
  /// **'Pause'**
  String get pause;

  /// No description provided for @pausedTitle.
  ///
  /// In de, this message translates to:
  /// **'Pause'**
  String get pausedTitle;

  /// No description provided for @pausedBody.
  ///
  /// In de, this message translates to:
  /// **'Die Zeit steht still, bis du weiterspielst.'**
  String get pausedBody;

  /// No description provided for @resume.
  ///
  /// In de, this message translates to:
  /// **'Weiterspielen'**
  String get resume;

  /// No description provided for @leaveTitle.
  ///
  /// In de, this message translates to:
  /// **'Spiel verlassen?'**
  String get leaveTitle;

  /// No description provided for @leaveBody.
  ///
  /// In de, this message translates to:
  /// **'Dein Fortschritt in dieser Stufe geht verloren.'**
  String get leaveBody;

  /// No description provided for @keepPlaying.
  ///
  /// In de, this message translates to:
  /// **'Weiterspielen'**
  String get keepPlaying;

  /// No description provided for @leave.
  ///
  /// In de, this message translates to:
  /// **'Verlassen'**
  String get leave;

  /// No description provided for @howToTitle.
  ///
  /// In de, this message translates to:
  /// **'So geht’s'**
  String get howToTitle;

  /// No description provided for @letsGo.
  ///
  /// In de, this message translates to:
  /// **'Los geht’s'**
  String get letsGo;

  /// No description provided for @readAloud.
  ///
  /// In de, this message translates to:
  /// **'Vorlesen'**
  String get readAloud;

  /// No description provided for @resultGreat.
  ///
  /// In de, this message translates to:
  /// **'Großartig!'**
  String get resultGreat;

  /// No description provided for @resultDone.
  ///
  /// In de, this message translates to:
  /// **'Geschafft!'**
  String get resultDone;

  /// No description provided for @resultGood.
  ///
  /// In de, this message translates to:
  /// **'Gut gespielt!'**
  String get resultGood;

  /// No description provided for @statTime.
  ///
  /// In de, this message translates to:
  /// **'Zeit'**
  String get statTime;

  /// No description provided for @statMistakes.
  ///
  /// In de, this message translates to:
  /// **'Fehler'**
  String get statMistakes;

  /// No description provided for @statMoves.
  ///
  /// In de, this message translates to:
  /// **'Züge'**
  String get statMoves;

  /// No description provided for @statScore.
  ///
  /// In de, this message translates to:
  /// **'Punkte'**
  String get statScore;

  /// No description provided for @statAttempts.
  ///
  /// In de, this message translates to:
  /// **'Versuche'**
  String get statAttempts;

  /// No description provided for @statStreak.
  ///
  /// In de, this message translates to:
  /// **'Tage Serie'**
  String get statStreak;

  /// No description provided for @statStars.
  ///
  /// In de, this message translates to:
  /// **'Sterne'**
  String get statStars;

  /// No description provided for @statStickers.
  ///
  /// In de, this message translates to:
  /// **'Sticker'**
  String get statStickers;

  /// No description provided for @statPlayed.
  ///
  /// In de, this message translates to:
  /// **'Tage gespielt'**
  String get statPlayed;

  /// No description provided for @statGold.
  ///
  /// In de, this message translates to:
  /// **'Gold-Tage'**
  String get statGold;

  /// No description provided for @share.
  ///
  /// In de, this message translates to:
  /// **'Teilen'**
  String get share;

  /// No description provided for @nextLevelQuestion.
  ///
  /// In de, this message translates to:
  /// **'{level}?'**
  String nextLevelQuestion(String level);

  /// No description provided for @shareText.
  ///
  /// In de, this message translates to:
  /// **'Kleine Pause · {day}\n{game} {stars} in {time}'**
  String shareText(String day, String game, String stars, String time);

  /// No description provided for @adHeader.
  ///
  /// In de, this message translates to:
  /// **'ANZEIGE · NACH DEM SPIEL'**
  String get adHeader;

  /// No description provided for @adRemove.
  ///
  /// In de, this message translates to:
  /// **'Werbefrei mit Premium'**
  String get adRemove;

  /// No description provided for @adLabel.
  ///
  /// In de, this message translates to:
  /// **'Anzeige'**
  String get adLabel;

  /// No description provided for @houseAdTitle.
  ///
  /// In de, this message translates to:
  /// **'Spiel jeden Tag des Jahres'**
  String get houseAdTitle;

  /// No description provided for @houseAdBody.
  ///
  /// In de, this message translates to:
  /// **'Mit Premium verpasste Tage nachholen, ohne Werbung.'**
  String get houseAdBody;

  /// No description provided for @tomorrowWaits.
  ///
  /// In de, this message translates to:
  /// **'Morgen wartet: {what}'**
  String tomorrowWaits(String what);

  /// No description provided for @reminderAt.
  ///
  /// In de, this message translates to:
  /// **'Erinnerung um {time} Uhr'**
  String reminderAt(String time);

  /// No description provided for @reminderOff.
  ///
  /// In de, this message translates to:
  /// **'Erinnerung einschalten'**
  String get reminderOff;

  /// No description provided for @reminderSettingTitle.
  ///
  /// In de, this message translates to:
  /// **'Erinnerung'**
  String get reminderSettingTitle;

  /// No description provided for @reminderExplain.
  ///
  /// In de, this message translates to:
  /// **'Jeden Tag zur gleichen Zeit an deine kleine Pause erinnern.'**
  String get reminderExplain;

  /// No description provided for @reminderDaily.
  ///
  /// In de, this message translates to:
  /// **'Täglich erinnern'**
  String get reminderDaily;

  /// No description provided for @reminderTime.
  ///
  /// In de, this message translates to:
  /// **'Uhrzeit'**
  String get reminderTime;

  /// No description provided for @reminderTitle.
  ///
  /// In de, this message translates to:
  /// **'Zeit für eine kleine Pause'**
  String get reminderTitle;

  /// No description provided for @reminderBody.
  ///
  /// In de, this message translates to:
  /// **'Dein Spiel des Tages wartet schon.'**
  String get reminderBody;

  /// No description provided for @reminderDeniedTitle.
  ///
  /// In de, this message translates to:
  /// **'Mitteilungen sind aus'**
  String get reminderDeniedTitle;

  /// No description provided for @reminderDeniedBody.
  ///
  /// In de, this message translates to:
  /// **'Erlaube Mitteilungen für Kleine Pause in den Einstellungen deines Geräts.'**
  String get reminderDeniedBody;

  /// No description provided for @viewMonth.
  ///
  /// In de, this message translates to:
  /// **'Monat'**
  String get viewMonth;

  /// No description provided for @viewYear.
  ///
  /// In de, this message translates to:
  /// **'Jahr'**
  String get viewYear;

  /// No description provided for @previousMonth.
  ///
  /// In de, this message translates to:
  /// **'Vormonat'**
  String get previousMonth;

  /// No description provided for @nextMonth.
  ///
  /// In de, this message translates to:
  /// **'Nächster Monat'**
  String get nextMonth;

  /// No description provided for @monthPlayed.
  ///
  /// In de, this message translates to:
  /// **'{played} von {available} gespielt'**
  String monthPlayed(int played, int available);

  /// No description provided for @dayToday.
  ///
  /// In de, this message translates to:
  /// **'heute'**
  String get dayToday;

  /// No description provided for @dayGold.
  ///
  /// In de, this message translates to:
  /// **'gespielt, Gold'**
  String get dayGold;

  /// No description provided for @dayCatchUp.
  ///
  /// In de, this message translates to:
  /// **'nachholen'**
  String get dayCatchUp;

  /// No description provided for @dayMissedPremium.
  ///
  /// In de, this message translates to:
  /// **'verpasst, nur mit Premium'**
  String get dayMissedPremium;

  /// No description provided for @dayPlayAhead.
  ///
  /// In de, this message translates to:
  /// **'vorspielen'**
  String get dayPlayAhead;

  /// No description provided for @dayLocked.
  ///
  /// In de, this message translates to:
  /// **'gesperrt'**
  String get dayLocked;

  /// No description provided for @legend.
  ///
  /// In de, this message translates to:
  /// **'Legende'**
  String get legend;

  /// No description provided for @legendPlayed.
  ///
  /// In de, this message translates to:
  /// **'Gespielt'**
  String get legendPlayed;

  /// No description provided for @legendGold.
  ///
  /// In de, this message translates to:
  /// **'Gold: alle 3 Stufen'**
  String get legendGold;

  /// No description provided for @legendCatchUp.
  ///
  /// In de, this message translates to:
  /// **'Nachholen'**
  String get legendCatchUp;

  /// No description provided for @legendAhead.
  ///
  /// In de, this message translates to:
  /// **'Vorspielen'**
  String get legendAhead;

  /// No description provided for @missedDays.
  ///
  /// In de, this message translates to:
  /// **'{count, plural, =1{1 Tag verpasst} other{{count} Tage verpasst}}'**
  String missedDays(int count);

  /// No description provided for @missedBody.
  ///
  /// In de, this message translates to:
  /// **'Mit Premium nachholen und 3 Tage vorspielen'**
  String get missedBody;

  /// No description provided for @yearSummary.
  ///
  /// In de, this message translates to:
  /// **'{played} Tage gespielt · {gold} Gold-Tage'**
  String yearSummary(int played, int gold);

  /// No description provided for @galleryCount.
  ///
  /// In de, this message translates to:
  /// **'{count, plural, =0{Noch keine Bilder} =1{1 Bild} other{{count} Bilder}}'**
  String galleryCount(int count);

  /// No description provided for @galleryEmptyTitle.
  ///
  /// In de, this message translates to:
  /// **'Deine Galerie'**
  String get galleryEmptyTitle;

  /// No description provided for @galleryEmptyBody.
  ///
  /// In de, this message translates to:
  /// **'Hier landen deine ausgemalten Bilder und Pixel-Kunstwerke.'**
  String get galleryEmptyBody;

  /// No description provided for @settings.
  ///
  /// In de, this message translates to:
  /// **'Einstellungen'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In de, this message translates to:
  /// **'Sprache'**
  String get language;

  /// No description provided for @languageSystem.
  ///
  /// In de, this message translates to:
  /// **'Wie das Gerät'**
  String get languageSystem;

  /// No description provided for @languageGerman.
  ///
  /// In de, this message translates to:
  /// **'Deutsch'**
  String get languageGerman;

  /// No description provided for @languageEnglish.
  ///
  /// In de, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageMore.
  ///
  /// In de, this message translates to:
  /// **'Weitere Sprachen folgen.'**
  String get languageMore;

  /// No description provided for @haptics.
  ///
  /// In de, this message translates to:
  /// **'Vibration'**
  String get haptics;

  /// No description provided for @premiumSection.
  ///
  /// In de, this message translates to:
  /// **'Premium'**
  String get premiumSection;

  /// No description provided for @premiumActiveShort.
  ///
  /// In de, this message translates to:
  /// **'Aktiv'**
  String get premiumActiveShort;

  /// No description provided for @premiumUnlock.
  ///
  /// In de, this message translates to:
  /// **'Freischalten'**
  String get premiumUnlock;

  /// No description provided for @premiumDebug.
  ///
  /// In de, this message translates to:
  /// **'Premium testen (nur Debug)'**
  String get premiumDebug;

  /// No description provided for @profileSection.
  ///
  /// In de, this message translates to:
  /// **'Profil'**
  String get profileSection;

  /// No description provided for @switchProfile.
  ///
  /// In de, this message translates to:
  /// **'Profil wechseln'**
  String get switchProfile;

  /// No description provided for @renameProfile.
  ///
  /// In de, this message translates to:
  /// **'Profil umbenennen'**
  String get renameProfile;

  /// No description provided for @deleteProfile.
  ///
  /// In de, this message translates to:
  /// **'Profil löschen'**
  String get deleteProfile;

  /// No description provided for @deleteProfileTitle.
  ///
  /// In de, this message translates to:
  /// **'{name} löschen?'**
  String deleteProfileTitle(String name);

  /// No description provided for @deleteProfileBody.
  ///
  /// In de, this message translates to:
  /// **'Kalender, Serie und Galerie dieses Profils werden gelöscht.'**
  String get deleteProfileBody;

  /// No description provided for @parentsArea.
  ///
  /// In de, this message translates to:
  /// **'Elternbereich'**
  String get parentsArea;

  /// No description provided for @aboutLine.
  ///
  /// In de, this message translates to:
  /// **'Kleine Pause · QuizQuiz-Fragen von Zitat des Tages (zitatdestages.net)'**
  String get aboutLine;

  /// No description provided for @premiumTitle.
  ///
  /// In de, this message translates to:
  /// **'Kleine Pause Premium'**
  String get premiumTitle;

  /// No description provided for @premiumSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Dein ganzes Jahr, in deinem Tempo.'**
  String get premiumSubtitle;

  /// No description provided for @perkNoAds.
  ///
  /// In de, this message translates to:
  /// **'Keine Werbung'**
  String get perkNoAds;

  /// No description provided for @perkNoAdsBody.
  ///
  /// In de, this message translates to:
  /// **'Auch nicht vor oder nach dem Spiel'**
  String get perkNoAdsBody;

  /// No description provided for @perkPast.
  ///
  /// In de, this message translates to:
  /// **'Jeden vergangenen Tag nachholen'**
  String get perkPast;

  /// No description provided for @perkPastBody.
  ///
  /// In de, this message translates to:
  /// **'Seit dem 1. Januar, so weit zurück du willst'**
  String get perkPastBody;

  /// No description provided for @perkAhead.
  ///
  /// In de, this message translates to:
  /// **'3 Tage vorspielen'**
  String get perkAhead;

  /// No description provided for @perkAheadBody.
  ///
  /// In de, this message translates to:
  /// **'Für Urlaub, Wochenende oder Neugier'**
  String get perkAheadBody;

  /// No description provided for @perkProfiles.
  ///
  /// In de, this message translates to:
  /// **'Für alle Profile'**
  String get perkProfiles;

  /// No description provided for @perkProfilesBody.
  ///
  /// In de, this message translates to:
  /// **'Erwachsene und Kinder auf diesem Gerät'**
  String get perkProfilesBody;

  /// No description provided for @planYearly.
  ///
  /// In de, this message translates to:
  /// **'Jährlich'**
  String get planYearly;

  /// No description provided for @planYearlyNote.
  ///
  /// In de, this message translates to:
  /// **'Beliebteste Wahl'**
  String get planYearlyNote;

  /// No description provided for @planOnce.
  ///
  /// In de, this message translates to:
  /// **'Einmalig'**
  String get planOnce;

  /// No description provided for @planOnceNote.
  ///
  /// In de, this message translates to:
  /// **'Für dieses Jahr'**
  String get planOnceNote;

  /// No description provided for @pricePerYear.
  ///
  /// In de, this message translates to:
  /// **'{price} / Jahr'**
  String pricePerYear(String price);

  /// No description provided for @premiumStart.
  ///
  /// In de, this message translates to:
  /// **'Premium starten'**
  String get premiumStart;

  /// No description provided for @premiumActive.
  ///
  /// In de, this message translates to:
  /// **'Premium ist aktiv. Danke!'**
  String get premiumActive;

  /// No description provided for @restorePurchases.
  ///
  /// In de, this message translates to:
  /// **'Käufe wiederherstellen'**
  String get restorePurchases;

  /// No description provided for @terms.
  ///
  /// In de, this message translates to:
  /// **'Bedingungen'**
  String get terms;

  /// No description provided for @termsBody.
  ///
  /// In de, this message translates to:
  /// **'Premium gilt für alle Profile auf diesem Gerät. Das Jahresabo verlängert sich automatisch und ist jederzeit in den Store-Einstellungen kündbar. Der Einmalkauf gilt bis zum 31. Dezember dieses Jahres.'**
  String get termsBody;

  /// No description provided for @purchaseUnavailableTitle.
  ///
  /// In de, this message translates to:
  /// **'Gerade nicht möglich'**
  String get purchaseUnavailableTitle;

  /// No description provided for @purchaseUnavailableBody.
  ///
  /// In de, this message translates to:
  /// **'Der Store ist in dieser Version noch nicht angebunden.'**
  String get purchaseUnavailableBody;

  /// No description provided for @restoreNoneTitle.
  ///
  /// In de, this message translates to:
  /// **'Nichts gefunden'**
  String get restoreNoneTitle;

  /// No description provided for @restoreNoneBody.
  ///
  /// In de, this message translates to:
  /// **'Für dieses Konto gibt es keinen Premium-Kauf.'**
  String get restoreNoneBody;

  /// No description provided for @kidsHello.
  ///
  /// In de, this message translates to:
  /// **'Hallo {name}!'**
  String kidsHello(String name);

  /// No description provided for @parents.
  ///
  /// In de, this message translates to:
  /// **'Eltern'**
  String get parents;

  /// No description provided for @stickersCollected.
  ///
  /// In de, this message translates to:
  /// **'{count, plural, =1{1 Sticker gesammelt} other{{count} Sticker gesammelt}}'**
  String stickersCollected(int count);

  /// No description provided for @stickersToPage.
  ///
  /// In de, this message translates to:
  /// **'Noch {count} bis zur {month}-Seite'**
  String stickersToPage(int count, String month);

  /// No description provided for @stickerPageDone.
  ///
  /// In de, this message translates to:
  /// **'{month}-Seite geschafft!'**
  String stickerPageDone(String month);

  /// No description provided for @stickerFor.
  ///
  /// In de, this message translates to:
  /// **'Sticker vom {date}'**
  String stickerFor(String date);

  /// No description provided for @gateTitle.
  ///
  /// In de, this message translates to:
  /// **'Frag deine Eltern'**
  String get gateTitle;

  /// No description provided for @gateBody.
  ///
  /// In de, this message translates to:
  /// **'Dieser Bereich ist für Erwachsene.'**
  String get gateBody;

  /// No description provided for @gateQuestion.
  ///
  /// In de, this message translates to:
  /// **'Wie viel ist {a} × {b}?'**
  String gateQuestion(int a, int b);

  /// No description provided for @gateWrong.
  ///
  /// In de, this message translates to:
  /// **'Nicht ganz. Neue Aufgabe:'**
  String get gateWrong;

  /// No description provided for @categoryCreative.
  ///
  /// In de, this message translates to:
  /// **'Kreativ'**
  String get categoryCreative;

  /// No description provided for @categoryWord.
  ///
  /// In de, this message translates to:
  /// **'Wort & Sprache'**
  String get categoryWord;

  /// No description provided for @categoryQuiz.
  ///
  /// In de, this message translates to:
  /// **'Quiz & Wissen'**
  String get categoryQuiz;

  /// No description provided for @categoryLogic.
  ///
  /// In de, this message translates to:
  /// **'Logik'**
  String get categoryLogic;

  /// No description provided for @categoryArcade.
  ///
  /// In de, this message translates to:
  /// **'Geschick & Arcade'**
  String get categoryArcade;

  /// No description provided for @categoryMemory.
  ///
  /// In de, this message translates to:
  /// **'Gedächtnis'**
  String get categoryMemory;

  /// No description provided for @categoryNumbers.
  ///
  /// In de, this message translates to:
  /// **'Zahlen'**
  String get categoryNumbers;

  /// No description provided for @categoryMindful.
  ///
  /// In de, this message translates to:
  /// **'Entspannung'**
  String get categoryMindful;

  /// No description provided for @theme1.
  ///
  /// In de, this message translates to:
  /// **'Neuanfang & Winter'**
  String get theme1;

  /// No description provided for @theme2.
  ///
  /// In de, this message translates to:
  /// **'Liebe & Fasching'**
  String get theme2;

  /// No description provided for @theme3.
  ///
  /// In de, this message translates to:
  /// **'Erwachen'**
  String get theme3;

  /// No description provided for @theme4.
  ///
  /// In de, this message translates to:
  /// **'Ostern & Garten'**
  String get theme4;

  /// No description provided for @theme5.
  ///
  /// In de, this message translates to:
  /// **'Blüte & Natur'**
  String get theme5;

  /// No description provided for @theme6.
  ///
  /// In de, this message translates to:
  /// **'Sport & Bewegung'**
  String get theme6;

  /// No description provided for @theme7.
  ///
  /// In de, this message translates to:
  /// **'Ferien & Meer'**
  String get theme7;

  /// No description provided for @theme8.
  ///
  /// In de, this message translates to:
  /// **'Reisen & Welt'**
  String get theme8;

  /// No description provided for @theme9.
  ///
  /// In de, this message translates to:
  /// **'Schule & Wissen'**
  String get theme9;

  /// No description provided for @theme10.
  ///
  /// In de, this message translates to:
  /// **'Herbst & Grusel'**
  String get theme10;

  /// No description provided for @theme11.
  ///
  /// In de, this message translates to:
  /// **'Gemütlichkeit'**
  String get theme11;

  /// No description provided for @theme12.
  ///
  /// In de, this message translates to:
  /// **'Advent & Jahresrückblick'**
  String get theme12;

  /// No description provided for @edition1.
  ///
  /// In de, this message translates to:
  /// **'Schneeflocken-Edition'**
  String get edition1;

  /// No description provided for @edition2.
  ///
  /// In de, this message translates to:
  /// **'Herzklopfen-Edition'**
  String get edition2;

  /// No description provided for @edition3.
  ///
  /// In de, this message translates to:
  /// **'Frühlingserwachen-Edition'**
  String get edition3;

  /// No description provided for @edition4.
  ///
  /// In de, this message translates to:
  /// **'Osterhasen-Edition'**
  String get edition4;

  /// No description provided for @edition5.
  ///
  /// In de, this message translates to:
  /// **'Blütenzauber-Edition'**
  String get edition5;

  /// No description provided for @edition6.
  ///
  /// In de, this message translates to:
  /// **'Sommeranfang-Edition'**
  String get edition6;

  /// No description provided for @edition7.
  ///
  /// In de, this message translates to:
  /// **'Strandkorb-Edition'**
  String get edition7;

  /// No description provided for @edition8.
  ///
  /// In de, this message translates to:
  /// **'Fernweh-Edition'**
  String get edition8;

  /// No description provided for @edition9.
  ///
  /// In de, this message translates to:
  /// **'Erntezeit-Edition'**
  String get edition9;

  /// No description provided for @edition10.
  ///
  /// In de, this message translates to:
  /// **'Herbstlaub-Edition'**
  String get edition10;

  /// No description provided for @edition11.
  ///
  /// In de, this message translates to:
  /// **'Laternen-Edition'**
  String get edition11;

  /// No description provided for @edition12.
  ///
  /// In de, this message translates to:
  /// **'Adventszauber-Edition'**
  String get edition12;

  /// No description provided for @specialNewYear.
  ///
  /// In de, this message translates to:
  /// **'Neujahr'**
  String get specialNewYear;

  /// No description provided for @specialValentine.
  ///
  /// In de, this message translates to:
  /// **'Valentinstag'**
  String get specialValentine;

  /// No description provided for @specialLeapDay.
  ///
  /// In de, this message translates to:
  /// **'Schalttag-Bonus'**
  String get specialLeapDay;

  /// No description provided for @specialPiDay.
  ///
  /// In de, this message translates to:
  /// **'Pi-Tag'**
  String get specialPiDay;

  /// No description provided for @specialSpring.
  ///
  /// In de, this message translates to:
  /// **'Frühlingsanfang'**
  String get specialSpring;

  /// No description provided for @specialAprilFools.
  ///
  /// In de, this message translates to:
  /// **'Aprilscherz'**
  String get specialAprilFools;

  /// No description provided for @specialEarthDay.
  ///
  /// In de, this message translates to:
  /// **'Tag der Erde'**
  String get specialEarthDay;

  /// No description provided for @specialBookDay.
  ///
  /// In de, this message translates to:
  /// **'Welttag des Buches'**
  String get specialBookDay;

  /// No description provided for @specialMayDay.
  ///
  /// In de, this message translates to:
  /// **'Maifeiertag'**
  String get specialMayDay;

  /// No description provided for @specialSummer.
  ///
  /// In de, this message translates to:
  /// **'Sommeranfang'**
  String get specialSummer;

  /// No description provided for @specialUnityDay.
  ///
  /// In de, this message translates to:
  /// **'Tag der Deutschen Einheit'**
  String get specialUnityDay;

  /// No description provided for @specialHalloween.
  ///
  /// In de, this message translates to:
  /// **'Halloween'**
  String get specialHalloween;

  /// No description provided for @specialStMartin.
  ///
  /// In de, this message translates to:
  /// **'Martinstag'**
  String get specialStMartin;

  /// No description provided for @specialChristmasEve.
  ///
  /// In de, this message translates to:
  /// **'Heiligabend'**
  String get specialChristmasEve;

  /// No description provided for @specialChristmas.
  ///
  /// In de, this message translates to:
  /// **'Weihnachten'**
  String get specialChristmas;

  /// No description provided for @specialBoxingDay.
  ///
  /// In de, this message translates to:
  /// **'Zweiter Weihnachtstag'**
  String get specialBoxingDay;

  /// No description provided for @specialNewYearsEve.
  ///
  /// In de, this message translates to:
  /// **'Silvester'**
  String get specialNewYearsEve;

  /// No description provided for @specialCarnival.
  ///
  /// In de, this message translates to:
  /// **'Rosenmontag'**
  String get specialCarnival;

  /// No description provided for @specialEaster.
  ///
  /// In de, this message translates to:
  /// **'Ostern'**
  String get specialEaster;

  /// No description provided for @specialMothersDay.
  ///
  /// In de, this message translates to:
  /// **'Muttertag'**
  String get specialMothersDay;

  /// No description provided for @specialAdvent.
  ///
  /// In de, this message translates to:
  /// **'Adventskalender'**
  String get specialAdvent;

  /// No description provided for @motifPumpkin.
  ///
  /// In de, this message translates to:
  /// **'Kürbis'**
  String get motifPumpkin;

  /// No description provided for @motifHeart.
  ///
  /// In de, this message translates to:
  /// **'Herz'**
  String get motifHeart;

  /// No description provided for @motifFlower.
  ///
  /// In de, this message translates to:
  /// **'Blume'**
  String get motifFlower;

  /// No description provided for @motifStar.
  ///
  /// In de, this message translates to:
  /// **'Stern'**
  String get motifStar;

  /// No description provided for @motifTree.
  ///
  /// In de, this message translates to:
  /// **'Tannenbaum'**
  String get motifTree;

  /// No description provided for @motifLantern.
  ///
  /// In de, this message translates to:
  /// **'Laterne'**
  String get motifLantern;

  /// No description provided for @motifMask.
  ///
  /// In de, this message translates to:
  /// **'Faschingsmaske'**
  String get motifMask;

  /// No description provided for @motifEgg.
  ///
  /// In de, this message translates to:
  /// **'Osterei'**
  String get motifEgg;

  /// No description provided for @motifLeaf.
  ///
  /// In de, this message translates to:
  /// **'Herbstblatt'**
  String get motifLeaf;

  /// No description provided for @motifMushroom.
  ///
  /// In de, this message translates to:
  /// **'Fliegenpilz'**
  String get motifMushroom;

  /// No description provided for @motifHouse.
  ///
  /// In de, this message translates to:
  /// **'Häuschen'**
  String get motifHouse;

  /// No description provided for @motifFish.
  ///
  /// In de, this message translates to:
  /// **'Fisch'**
  String get motifFish;

  /// No description provided for @motifSnowman.
  ///
  /// In de, this message translates to:
  /// **'Schneemann'**
  String get motifSnowman;

  /// No description provided for @motifSun.
  ///
  /// In de, this message translates to:
  /// **'Sonne'**
  String get motifSun;

  /// No description provided for @motifButterfly.
  ///
  /// In de, this message translates to:
  /// **'Schmetterling'**
  String get motifButterfly;

  /// No description provided for @motifHedgehog.
  ///
  /// In de, this message translates to:
  /// **'Igel im Herbstlaub'**
  String get motifHedgehog;

  /// No description provided for @motifIcecream.
  ///
  /// In de, this message translates to:
  /// **'Eistüte'**
  String get motifIcecream;

  /// No description provided for @motifSailboat.
  ///
  /// In de, this message translates to:
  /// **'Segelboot'**
  String get motifSailboat;

  /// No description provided for @motifUmbrella.
  ///
  /// In de, this message translates to:
  /// **'Regenschirm'**
  String get motifUmbrella;

  /// No description provided for @gameColoring.
  ///
  /// In de, this message translates to:
  /// **'Ausmalen'**
  String get gameColoring;

  /// No description provided for @gamePixelArt.
  ///
  /// In de, this message translates to:
  /// **'Pixel-Kunst'**
  String get gamePixelArt;

  /// No description provided for @gameWordGuess.
  ///
  /// In de, this message translates to:
  /// **'Wortraten'**
  String get gameWordGuess;

  /// No description provided for @gameAnagram.
  ///
  /// In de, this message translates to:
  /// **'Buchstabensalat'**
  String get gameAnagram;

  /// No description provided for @gameWordSearch.
  ///
  /// In de, this message translates to:
  /// **'Wortsuche'**
  String get gameWordSearch;

  /// No description provided for @gameQuoteQuiz.
  ///
  /// In de, this message translates to:
  /// **'QuizQuiz'**
  String get gameQuoteQuiz;

  /// No description provided for @gameTrueFalse.
  ///
  /// In de, this message translates to:
  /// **'Wahr oder falsch'**
  String get gameTrueFalse;

  /// No description provided for @gameSudoku.
  ///
  /// In de, this message translates to:
  /// **'Sudoku'**
  String get gameSudoku;

  /// No description provided for @gameNonogram.
  ///
  /// In de, this message translates to:
  /// **'Nonogramm'**
  String get gameNonogram;

  /// No description provided for @gameLightsOut.
  ///
  /// In de, this message translates to:
  /// **'Lichter aus'**
  String get gameLightsOut;

  /// No description provided for @gameHanoi.
  ///
  /// In de, this message translates to:
  /// **'Turm von Hanoi'**
  String get gameHanoi;

  /// No description provided for @gameMaze.
  ///
  /// In de, this message translates to:
  /// **'Labyrinth'**
  String get gameMaze;

  /// No description provided for @gameStacking.
  ///
  /// In de, this message translates to:
  /// **'Turmbau'**
  String get gameStacking;

  /// No description provided for @gameMinesweeper.
  ///
  /// In de, this message translates to:
  /// **'Minensuche'**
  String get gameMinesweeper;

  /// No description provided for @game2048.
  ///
  /// In de, this message translates to:
  /// **'2048'**
  String get game2048;

  /// No description provided for @gameNumberPyramid.
  ///
  /// In de, this message translates to:
  /// **'Zahlenpyramide'**
  String get gameNumberPyramid;

  /// No description provided for @gameMemory.
  ///
  /// In de, this message translates to:
  /// **'Memo'**
  String get gameMemory;

  /// No description provided for @gameSimon.
  ///
  /// In de, this message translates to:
  /// **'Farbenfolge'**
  String get gameSimon;

  /// No description provided for @gameSlidePuzzle.
  ///
  /// In de, this message translates to:
  /// **'Schiebepuzzle'**
  String get gameSlidePuzzle;

  /// No description provided for @gameBreathing.
  ///
  /// In de, this message translates to:
  /// **'Atempause'**
  String get gameBreathing;

  /// No description provided for @howToColoring.
  ///
  /// In de, this message translates to:
  /// **'Wähle eine Farbe und tippe auf eine Fläche, um sie auszumalen. Auf „Fortgeschritten“ malst du nach Zahlen: Jede Zahl gehört zu einer Farbe. Der Tipp malt eine Fläche für dich aus.'**
  String get howToColoring;

  /// No description provided for @howToPixelArt.
  ///
  /// In de, this message translates to:
  /// **'Jede Zahl steht für eine Farbe. Wähle unten die Farbe und tippe oder wische über die passenden Kästchen, bis das Bild fertig ist.'**
  String get howToPixelArt;

  /// No description provided for @howToWordGuess.
  ///
  /// In de, this message translates to:
  /// **'Errate das Wort in sechs Versuchen. Grün: Buchstabe an der richtigen Stelle. Gelb: kommt vor, aber woanders. Grau: kommt nicht vor.'**
  String get howToWordGuess;

  /// No description provided for @howToAnagram.
  ///
  /// In de, this message translates to:
  /// **'Die Buchstaben sind durcheinander. Tippe sie in der richtigen Reihenfolge an, um das Wort zu bilden. Tippe auf ein gelegtes Feld, um ab dort zurückzunehmen.'**
  String get howToAnagram;

  /// No description provided for @howToWordSearch.
  ///
  /// In de, this message translates to:
  /// **'Finde alle Wörter im Gitter. Ziehe mit dem Finger vom ersten bis zum letzten Buchstaben – waagerecht, senkrecht oder diagonal.'**
  String get howToWordSearch;

  /// No description provided for @howToQuoteQuiz.
  ///
  /// In de, this message translates to:
  /// **'Lies das Zitat und tippe auf die Person, von der es stammt. Die Fragen kommen von der App „Zitat des Tages“.'**
  String get howToQuoteQuiz;

  /// No description provided for @howToTrueFalse.
  ///
  /// In de, this message translates to:
  /// **'Stimmt die Aussage oder nicht? Tippe auf „Wahr“ oder „Falsch“. Auf „Fortgeschritten“ hast du pro Aussage zehn Sekunden.'**
  String get howToTrueFalse;

  /// No description provided for @howToSudoku.
  ///
  /// In de, this message translates to:
  /// **'Fülle das Gitter so, dass jede Zahl in jeder Zeile, jeder Spalte und jedem Block genau einmal vorkommt. Tippe ein Feld an und dann eine Zahl. Mit „Notizen“ merkst du dir Kandidaten.'**
  String get howToSudoku;

  /// No description provided for @howToNonogram.
  ///
  /// In de, this message translates to:
  /// **'Die Zahlen am Rand verraten, wie viele Felder hintereinander gefüllt sind. Fülle die richtigen Felder, und ein Bild entsteht. Mit dem Kreuz markierst du sichere Lücken.'**
  String get howToNonogram;

  /// No description provided for @howToLightsOut.
  ///
  /// In de, this message translates to:
  /// **'Ein Tipp schaltet ein Licht und seine Nachbarn um. Schalte alle Lichter aus.'**
  String get howToLightsOut;

  /// No description provided for @howToHanoi.
  ///
  /// In de, this message translates to:
  /// **'Bringe den ganzen Turm auf den rechten Stab. Tippe einen Stab an, um die oberste Scheibe zu nehmen, und dann das Ziel. Nie eine größere auf eine kleinere Scheibe legen.'**
  String get howToHanoi;

  /// No description provided for @howToMaze.
  ///
  /// In de, this message translates to:
  /// **'Führe den Punkt zum Ziel. Wische in eine Richtung oder nutze die Pfeile.'**
  String get howToMaze;

  /// No description provided for @howToStacking.
  ///
  /// In de, this message translates to:
  /// **'Der Block schwingt hin und her. Tippe, um ihn fallen zu lassen. Was übersteht, fällt ab. Baue den Turm bis zur Zielhöhe.'**
  String get howToStacking;

  /// No description provided for @howToMinesweeper.
  ///
  /// In de, this message translates to:
  /// **'Decke alle Felder ohne Mine auf. Die Zahl sagt, wie viele Minen um ein Feld liegen. Mit der Flagge markierst du Verdachtsfälle. Der erste Tipp ist immer sicher.'**
  String get howToMinesweeper;

  /// No description provided for @howTo2048.
  ///
  /// In de, this message translates to:
  /// **'Wische, um alle Kacheln zu schieben. Gleiche Zahlen verschmelzen. Erreiche die Zielzahl.'**
  String get howTo2048;

  /// No description provided for @howToNumberPyramid.
  ///
  /// In de, this message translates to:
  /// **'Jeder Stein ist die Summe der beiden Steine darunter. Fülle die leeren Steine und prüfe dann.'**
  String get howToNumberPyramid;

  /// No description provided for @howToMemory.
  ///
  /// In de, this message translates to:
  /// **'Decke immer zwei Karten auf. Finde alle Paare mit möglichst wenigen Fehlversuchen.'**
  String get howToMemory;

  /// No description provided for @howToSimon.
  ///
  /// In de, this message translates to:
  /// **'Schau dir die Farbenfolge an und tippe sie danach nach. Jede Runde kommt eine Farbe dazu.'**
  String get howToSimon;

  /// No description provided for @howToSlidePuzzle.
  ///
  /// In de, this message translates to:
  /// **'Schiebe die Kacheln in die Lücke, bis das Bild wieder stimmt. Tippe eine Kachel neben der Lücke an.'**
  String get howToSlidePuzzle;

  /// No description provided for @howToBreathing.
  ///
  /// In de, this message translates to:
  /// **'Atme mit dem Kreis: einatmen, wenn er wächst, kurz halten, ausatmen, wenn er schrumpft. Es gibt nichts zu gewinnen, nur Ruhe.'**
  String get howToBreathing;

  /// No description provided for @kidColoring.
  ///
  /// In de, this message translates to:
  /// **'Such dir eine Farbe aus und tippe auf eine Fläche. Mal das Bild ganz bunt an!'**
  String get kidColoring;

  /// No description provided for @kidPixelArt.
  ///
  /// In de, this message translates to:
  /// **'Jede Zahl hat eine Farbe. Mal alle Kästchen mit der richtigen Farbe aus!'**
  String get kidPixelArt;

  /// No description provided for @kidAnagram.
  ///
  /// In de, this message translates to:
  /// **'Die Buchstaben sind durcheinander. Tippe sie richtig nacheinander an!'**
  String get kidAnagram;

  /// No description provided for @kidWordSearch.
  ///
  /// In de, this message translates to:
  /// **'Finde die Wörter! Fahre mit dem Finger über die Buchstaben.'**
  String get kidWordSearch;

  /// No description provided for @kidTrueFalse.
  ///
  /// In de, this message translates to:
  /// **'Stimmt das? Tippe auf Wahr oder Falsch.'**
  String get kidTrueFalse;

  /// No description provided for @kidSudoku.
  ///
  /// In de, this message translates to:
  /// **'Jede Zahl darf in jeder Reihe nur einmal vorkommen. Probier es aus!'**
  String get kidSudoku;

  /// No description provided for @kidLightsOut.
  ///
  /// In de, this message translates to:
  /// **'Tippe auf die Lichter, bis alle aus sind!'**
  String get kidLightsOut;

  /// No description provided for @kidHanoi.
  ///
  /// In de, this message translates to:
  /// **'Bau den Turm auf dem rechten Stab wieder auf. Große Scheiben immer unten!'**
  String get kidHanoi;

  /// No description provided for @kidMaze.
  ///
  /// In de, this message translates to:
  /// **'Hilf dem Punkt durch das Labyrinth bis zum Ziel!'**
  String get kidMaze;

  /// No description provided for @kidStacking.
  ///
  /// In de, this message translates to:
  /// **'Tippe genau im richtigen Moment und bau einen hohen Turm!'**
  String get kidStacking;

  /// No description provided for @kidNumberPyramid.
  ///
  /// In de, this message translates to:
  /// **'Zwei Steine zusammen ergeben den Stein darüber. Rechne mit!'**
  String get kidNumberPyramid;

  /// No description provided for @kidMemory.
  ///
  /// In de, this message translates to:
  /// **'Dreh zwei Karten um und finde die Paare!'**
  String get kidMemory;

  /// No description provided for @kidSimon.
  ///
  /// In de, this message translates to:
  /// **'Schau gut zu und tippe die Farben in der gleichen Reihenfolge!'**
  String get kidSimon;

  /// No description provided for @kidSlidePuzzle.
  ///
  /// In de, this message translates to:
  /// **'Schiebe die Teile, bis das Bild wieder stimmt!'**
  String get kidSlidePuzzle;

  /// No description provided for @kidBreathing.
  ///
  /// In de, this message translates to:
  /// **'Atme mit dem Kreis ein und aus. Ganz ruhig.'**
  String get kidBreathing;

  /// No description provided for @detailGrid.
  ///
  /// In de, this message translates to:
  /// **'{size} Felder · ca. {minutes} Min'**
  String detailGrid(String size, int minutes);

  /// No description provided for @detailPairs.
  ///
  /// In de, this message translates to:
  /// **'{count} Paare · ca. {minutes} Min'**
  String detailPairs(int count, int minutes);

  /// No description provided for @detailDiscs.
  ///
  /// In de, this message translates to:
  /// **'{count} Scheiben · ca. {minutes} Min'**
  String detailDiscs(int count, int minutes);

  /// No description provided for @detailRows.
  ///
  /// In de, this message translates to:
  /// **'{count} Reihen · ca. {minutes} Min'**
  String detailRows(int count, int minutes);

  /// No description provided for @detailTarget.
  ///
  /// In de, this message translates to:
  /// **'Ziel {target} · ca. {minutes} Min'**
  String detailTarget(String target, int minutes);

  /// No description provided for @detailMines.
  ///
  /// In de, this message translates to:
  /// **'{size} Felder, {mines} Minen · ca. {minutes} Min'**
  String detailMines(String size, int mines, int minutes);

  /// No description provided for @detailSequence.
  ///
  /// In de, this message translates to:
  /// **'Folge von {count} · ca. {minutes} Min'**
  String detailSequence(int count, int minutes);

  /// No description provided for @detailBlocks.
  ///
  /// In de, this message translates to:
  /// **'{count} Blöcke hoch · ca. {minutes} Min'**
  String detailBlocks(int count, int minutes);

  /// No description provided for @detailBreaths.
  ///
  /// In de, this message translates to:
  /// **'{count} Atemzüge · ca. {minutes} Min'**
  String detailBreaths(int count, int minutes);

  /// No description provided for @detailLetters.
  ///
  /// In de, this message translates to:
  /// **'{count} Buchstaben · ca. {minutes} Min'**
  String detailLetters(int count, int minutes);

  /// No description provided for @detailAnagram.
  ///
  /// In de, this message translates to:
  /// **'{count} Wörter mit {length} Buchstaben · ca. {minutes} Min'**
  String detailAnagram(int count, int length, int minutes);

  /// No description provided for @detailWords.
  ///
  /// In de, this message translates to:
  /// **'{count} Wörter · ca. {minutes} Min'**
  String detailWords(int count, int minutes);

  /// No description provided for @detailQuiz.
  ///
  /// In de, this message translates to:
  /// **'{questions} Fragen, {answers} Antworten · ca. {minutes} Min'**
  String detailQuiz(int questions, int answers, int minutes);

  /// No description provided for @detailStatements.
  ///
  /// In de, this message translates to:
  /// **'{count} Aussagen · ca. {minutes} Min'**
  String detailStatements(int count, int minutes);

  /// No description provided for @detailColoring.
  ///
  /// In de, this message translates to:
  /// **'Freies Ausmalen, {colors} Farben · ca. {minutes} Min'**
  String detailColoring(int colors, int minutes);

  /// No description provided for @detailPaintByNumbers.
  ///
  /// In de, this message translates to:
  /// **'Malen nach Zahlen · ca. {minutes} Min'**
  String detailPaintByNumbers(int minutes);

  /// No description provided for @sudokuGridLabel.
  ///
  /// In de, this message translates to:
  /// **'Sudoku {size} mal {size}'**
  String sudokuGridLabel(int size);

  /// No description provided for @cellLabel.
  ///
  /// In de, this message translates to:
  /// **'Zeile {row}, Spalte {column}: {value}'**
  String cellLabel(int row, int column, String value);

  /// No description provided for @cellEmpty.
  ///
  /// In de, this message translates to:
  /// **'leer'**
  String get cellEmpty;

  /// No description provided for @cellFilled.
  ///
  /// In de, this message translates to:
  /// **'gefüllt'**
  String get cellFilled;

  /// No description provided for @cellCrossed.
  ///
  /// In de, this message translates to:
  /// **'ausgekreuzt'**
  String get cellCrossed;

  /// No description provided for @cellHidden.
  ///
  /// In de, this message translates to:
  /// **'verdeckt'**
  String get cellHidden;

  /// No description provided for @numberLabel.
  ///
  /// In de, this message translates to:
  /// **'Zahl {number}'**
  String numberLabel(int number);

  /// No description provided for @tileLabel.
  ///
  /// In de, this message translates to:
  /// **'Kachel {number}'**
  String tileLabel(int number);

  /// No description provided for @brickLabel.
  ///
  /// In de, this message translates to:
  /// **'Reihe {row}, Stein {brick}: {value}'**
  String brickLabel(int row, int brick, String value);

  /// No description provided for @mistakesCount.
  ///
  /// In de, this message translates to:
  /// **'Fehler {count}'**
  String mistakesCount(int count);

  /// No description provided for @hintsCount.
  ///
  /// In de, this message translates to:
  /// **'Tipps {used} von {max}'**
  String hintsCount(int used, int max);

  /// No description provided for @movesCount.
  ///
  /// In de, this message translates to:
  /// **'Züge {count}'**
  String movesCount(int count);

  /// No description provided for @scoreCount.
  ///
  /// In de, this message translates to:
  /// **'Punkte {count}'**
  String scoreCount(int count);

  /// No description provided for @target.
  ///
  /// In de, this message translates to:
  /// **'Ziel {target}'**
  String target(String target);

  /// No description provided for @roundOf.
  ///
  /// In de, this message translates to:
  /// **'Runde {current} von {total}'**
  String roundOf(int current, int total);

  /// No description provided for @heightOf.
  ///
  /// In de, this message translates to:
  /// **'Höhe {current} von {total}'**
  String heightOf(int current, int total);

  /// No description provided for @breathOf.
  ///
  /// In de, this message translates to:
  /// **'Atemzug {current} von {total}'**
  String breathOf(int current, int total);

  /// No description provided for @attemptOf.
  ///
  /// In de, this message translates to:
  /// **'Versuch {current} von {total}'**
  String attemptOf(int current, int total);

  /// No description provided for @attemptCount.
  ///
  /// In de, this message translates to:
  /// **'Versuch {count}'**
  String attemptCount(int count);

  /// No description provided for @wordOf.
  ///
  /// In de, this message translates to:
  /// **'Wort {current} von {total}'**
  String wordOf(int current, int total);

  /// No description provided for @wordsFound.
  ///
  /// In de, this message translates to:
  /// **'{current} von {total} gefunden'**
  String wordsFound(int current, int total);

  /// No description provided for @questionOf.
  ///
  /// In de, this message translates to:
  /// **'Frage {current} von {total}'**
  String questionOf(int current, int total);

  /// No description provided for @pairsFound.
  ///
  /// In de, this message translates to:
  /// **'{current} von {total} Paaren'**
  String pairsFound(int current, int total);

  /// No description provided for @lightsLeft.
  ///
  /// In de, this message translates to:
  /// **'{count, plural, =1{1 Licht an} other{{count} Lichter an}}'**
  String lightsLeft(int count);

  /// No description provided for @minesLeft.
  ///
  /// In de, this message translates to:
  /// **'{count, plural, =1{1 Mine übrig} other{{count} Minen übrig}}'**
  String minesLeft(int count);

  /// No description provided for @hanoiOptimal.
  ///
  /// In de, this message translates to:
  /// **'Bestmöglich: {count} Züge'**
  String hanoiOptimal(int count);

  /// No description provided for @areasColored.
  ///
  /// In de, this message translates to:
  /// **'{current} von {total} Flächen'**
  String areasColored(int current, int total);

  /// No description provided for @pixelsPainted.
  ///
  /// In de, this message translates to:
  /// **'{current} von {total} Kästchen'**
  String pixelsPainted(int current, int total);

  /// No description provided for @secondsLeft.
  ///
  /// In de, this message translates to:
  /// **'{count} s'**
  String secondsLeft(int count);

  /// No description provided for @colorNumber.
  ///
  /// In de, this message translates to:
  /// **'Farbe {number}'**
  String colorNumber(int number);

  /// No description provided for @coloringLabel.
  ///
  /// In de, this message translates to:
  /// **'Ausmalbild'**
  String get coloringLabel;

  /// No description provided for @pixelLabel.
  ///
  /// In de, this message translates to:
  /// **'Pixelbild {size} mal {size}'**
  String pixelLabel(int size);

  /// No description provided for @erase.
  ///
  /// In de, this message translates to:
  /// **'Löschen'**
  String get erase;

  /// No description provided for @notes.
  ///
  /// In de, this message translates to:
  /// **'Notizen'**
  String get notes;

  /// No description provided for @undo.
  ///
  /// In de, this message translates to:
  /// **'Rückgängig'**
  String get undo;

  /// No description provided for @check.
  ///
  /// In de, this message translates to:
  /// **'Prüfen'**
  String get check;

  /// No description provided for @start.
  ///
  /// In de, this message translates to:
  /// **'Start'**
  String get start;

  /// No description provided for @shuffle.
  ///
  /// In de, this message translates to:
  /// **'Mischen'**
  String get shuffle;

  /// No description provided for @clear.
  ///
  /// In de, this message translates to:
  /// **'Leeren'**
  String get clear;

  /// No description provided for @tryAgain.
  ///
  /// In de, this message translates to:
  /// **'Nochmal'**
  String get tryAgain;

  /// No description provided for @next.
  ///
  /// In de, this message translates to:
  /// **'Weiter'**
  String get next;

  /// No description provided for @finish.
  ///
  /// In de, this message translates to:
  /// **'Fertig'**
  String get finish;

  /// No description provided for @reveal.
  ///
  /// In de, this message translates to:
  /// **'Aufdecken'**
  String get reveal;

  /// No description provided for @flag.
  ///
  /// In de, this message translates to:
  /// **'Flagge'**
  String get flag;

  /// No description provided for @memoryCardOpen.
  ///
  /// In de, this message translates to:
  /// **'Karte {number}, offen'**
  String memoryCardOpen(int number);

  /// No description provided for @memoryCardClosed.
  ///
  /// In de, this message translates to:
  /// **'Karte {number}, verdeckt'**
  String memoryCardClosed(int number);

  /// No description provided for @lightLabel.
  ///
  /// In de, this message translates to:
  /// **'Licht Zeile {row}, Spalte {column}: {state}'**
  String lightLabel(int row, int column, String state);

  /// No description provided for @lightOn.
  ///
  /// In de, this message translates to:
  /// **'an'**
  String get lightOn;

  /// No description provided for @lightOff.
  ///
  /// In de, this message translates to:
  /// **'aus'**
  String get lightOff;

  /// No description provided for @lightsGoal.
  ///
  /// In de, this message translates to:
  /// **'Schalte alle Lichter aus.'**
  String get lightsGoal;

  /// No description provided for @slideGoal.
  ///
  /// In de, this message translates to:
  /// **'Schiebe die Kacheln in die richtige Reihenfolge.'**
  String get slideGoal;

  /// No description provided for @hanoiPeg.
  ///
  /// In de, this message translates to:
  /// **'Stab {number}, {count} Scheiben'**
  String hanoiPeg(int number, int count);

  /// No description provided for @hanoiGoal.
  ///
  /// In de, this message translates to:
  /// **'Bringe alle Scheiben auf den rechten Stab.'**
  String get hanoiGoal;

  /// No description provided for @pyramidGoal.
  ///
  /// In de, this message translates to:
  /// **'Jeder Stein ist die Summe der zwei darunter.'**
  String get pyramidGoal;

  /// No description provided for @mazeLabel.
  ///
  /// In de, this message translates to:
  /// **'Labyrinth'**
  String get mazeLabel;

  /// No description provided for @directionUp.
  ///
  /// In de, this message translates to:
  /// **'Hoch'**
  String get directionUp;

  /// No description provided for @directionDown.
  ///
  /// In de, this message translates to:
  /// **'Runter'**
  String get directionDown;

  /// No description provided for @directionLeft.
  ///
  /// In de, this message translates to:
  /// **'Links'**
  String get directionLeft;

  /// No description provided for @directionRight.
  ///
  /// In de, this message translates to:
  /// **'Rechts'**
  String get directionRight;

  /// No description provided for @game2048Stuck.
  ///
  /// In de, this message translates to:
  /// **'Keine Züge mehr.'**
  String get game2048Stuck;

  /// No description provided for @swipeHint.
  ///
  /// In de, this message translates to:
  /// **'Wische, um die Kacheln zu schieben.'**
  String get swipeHint;

  /// No description provided for @nonogramFill.
  ///
  /// In de, this message translates to:
  /// **'Füllen'**
  String get nonogramFill;

  /// No description provided for @nonogramCross.
  ///
  /// In de, this message translates to:
  /// **'Kreuz'**
  String get nonogramCross;

  /// No description provided for @mine.
  ///
  /// In de, this message translates to:
  /// **'Mine'**
  String get mine;

  /// No description provided for @mineBoom.
  ///
  /// In de, this message translates to:
  /// **'Bumm! Neuer Versuch mit neuem Feld.'**
  String get mineBoom;

  /// No description provided for @simonPad.
  ///
  /// In de, this message translates to:
  /// **'Farbe {number}'**
  String simonPad(int number);

  /// No description provided for @simonWatch.
  ///
  /// In de, this message translates to:
  /// **'Gut zuschauen …'**
  String get simonWatch;

  /// No description provided for @simonYourTurn.
  ///
  /// In de, this message translates to:
  /// **'Du bist dran!'**
  String get simonYourTurn;

  /// No description provided for @stackingHint.
  ///
  /// In de, this message translates to:
  /// **'Tippe, um den Block fallen zu lassen.'**
  String get stackingHint;

  /// No description provided for @breatheIn.
  ///
  /// In de, this message translates to:
  /// **'Einatmen'**
  String get breatheIn;

  /// No description provided for @breatheHold.
  ///
  /// In de, this message translates to:
  /// **'Halten'**
  String get breatheHold;

  /// No description provided for @breatheOut.
  ///
  /// In de, this message translates to:
  /// **'Ausatmen'**
  String get breatheOut;

  /// No description provided for @breatheReady.
  ///
  /// In de, this message translates to:
  /// **'Bereit?'**
  String get breatheReady;

  /// No description provided for @wordWas.
  ///
  /// In de, this message translates to:
  /// **'Gesucht war: {word}'**
  String wordWas(String word);

  /// No description provided for @wordSearchLabel.
  ///
  /// In de, this message translates to:
  /// **'Buchstabengitter {size} mal {size}'**
  String wordSearchLabel(int size);

  /// No description provided for @whoSaidIt.
  ///
  /// In de, this message translates to:
  /// **'Wer hat’s gesagt?'**
  String get whoSaidIt;

  /// No description provided for @answerRight.
  ///
  /// In de, this message translates to:
  /// **'Richtig!'**
  String get answerRight;

  /// No description provided for @answerWrong.
  ///
  /// In de, this message translates to:
  /// **'Leider nein: {answer}'**
  String answerWrong(String answer);

  /// No description provided for @answerWrongPlain.
  ///
  /// In de, this message translates to:
  /// **'Leider nein.'**
  String get answerWrongPlain;

  /// No description provided for @quoteSource.
  ///
  /// In de, this message translates to:
  /// **'Fragen: Zitat des Tages · zitatdestages.net'**
  String get quoteSource;

  /// No description provided for @quizUnavailable.
  ///
  /// In de, this message translates to:
  /// **'Gerade keine Fragen da. Versuch es später nochmal.'**
  String get quizUnavailable;

  /// No description provided for @trueOrFalse.
  ///
  /// In de, this message translates to:
  /// **'Wahr oder falsch?'**
  String get trueOrFalse;

  /// No description provided for @answerTrue.
  ///
  /// In de, this message translates to:
  /// **'Wahr'**
  String get answerTrue;

  /// No description provided for @answerFalse.
  ///
  /// In de, this message translates to:
  /// **'Falsch'**
  String get answerFalse;

  /// No description provided for @timeUp.
  ///
  /// In de, this message translates to:
  /// **'Zeit um!'**
  String get timeUp;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
