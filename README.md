# Kleine Pause

Jeden Tag ein neues kleines Spiel: 366 Tage, 20 Spielarten, jedes in drei Stufen
(Einfach, Standard, Fortgeschritten). Die App funktioniert komplett offline, hat
eigene Profile für Erwachsene und Kinder und ist auf Deutsch und Englisch
verfügbar. Gestaltet im Liquid-Glass-Stil mit
[liquid_glass_widgets](https://pub.dev/packages/liquid_glass_widgets).

## Spiele

| Wochentag  | Erwachsene                                   | Kinder                          |
|------------|----------------------------------------------|---------------------------------|
| Montag     | Ausmalen, Pixel-Kunst                         | Ausmalen, Pixel-Kunst           |
| Dienstag   | Wortraten, Buchstabensalat, Wortsuche         | Wortsuche, Buchstabensalat      |
| Mittwoch   | QuizQuiz (Zitat des Tages), Wahr oder falsch  | Labyrinth, Wahr oder falsch     |
| Donnerstag | Sudoku, Nonogramm, Lichter aus, Zahlenpyramide, Turm von Hanoi | Sudoku, Lichter aus, Zahlenpyramide |
| Freitag    | Turmbau, 2048, Minensuche                     | Turmbau, Turm von Hanoi         |
| Samstag    | Memo, Farbenfolge                             | Memo, Farbenfolge               |
| Sonntag    | Schiebepuzzle, Labyrinth                      | Schiebepuzzle, Ausmalen, Atempause |

Besondere Tage (Neujahr, Ostern, Halloween, Advent, Weihnachten, ...) ersetzen
den Wochenrhythmus. Der Plan ist eine reine Funktion des Datums
(`lib/domain/planner.dart`), alle Rätsel werden aus dem Datum erzeugt, daher
braucht die App weder Server noch Download.

## Regeln

- Der Kalender beginnt am 1. Januar.
- Free: heute spielen, mit Werbung nach dem Spiel.
- Premium: jeden vergangenen Tag nachholen, 3 Tage vorspielen, keine Werbung.
- Kinderprofile: kein Zeitdruck, Vorlesen, Sticker, Elternbereich hinter einer Rechenfrage.

## QuizQuiz und die Zitat-des-Tages-API

`lib/data/quote_quiz.dart` lädt die Fragen von
`https://api.zitatdestages.net/quotes/questions` (Sprache über `l`), speichert sie
auf dem Gerät und nutzt offline die mitgelieferten Fragen in
`assets/content/<sprache>/quotes.json`. Zukünftige Fragen werden nie vor ihrem
Datum gezeigt.

## Aufbau

```
lib/
  app/        App-Widget und AppState (einziger Zustand, Persistenz)
  core/       Datum, deterministischer Zufall
  domain/     Modelle, Tagesplan, Zugriffsregeln, Statistik
  data/       Speicher, Inhalte, Zitat-API, Premium, Erinnerung, Vorlesen
  design/     Farben, Icons, Glas-Komponenten
  games/      ein Ordner pro Spiel + game_registry.dart
  screens/    Heute, Kalender, Galerie, Profil, Spiel, Ergebnis, Kinder
  l10n/       ARB-Dateien (de ist die Vorlage) und Texthilfen
assets/content/<sprache>/   Wörter, Themen, Fakten, Zitate
```

**Neues Spiel:** eine `GameDefinition` in `lib/games/<name>/` anlegen, in
`game_registry.dart` eintragen, Namen und Anleitung in beiden ARB-Dateien
ergänzen und im Planer einem Wochentag zuordnen.

**Neue Sprache:** `lib/l10n/app_<code>.arb` und `assets/content/<code>/`
anlegen, den Code in `GameContent.supportedLanguages` ergänzen.

## Entwickeln

```sh
flutter pub get
flutter gen-l10n
flutter analyze
flutter test
flutter run
```

In Debug-Builds werden Käufe simuliert und im Profil gibt es einen
Premium-Schalter zum Testen. Für Release-Builds ohne Store:
`--dart-define=SIMULATE_PURCHASES=true`.

## CI

- `ci.yml` läuft nur für Pull Requests, die App-Code ändern (Analyse und Tests).
- `build.yml` baut APK und Web nur auf Knopfdruck oder für einen Versions-Tag
  (`git tag v0.1.0 && git push origin v0.1.0`). Die Dateien liegen danach als
  Artefakte am Workflow-Lauf.
- `store-screenshots.yml` erzeugt auf Knopfdruck die Store-Screenshots
  (Android-Handy 1080 × 1920, iPhone 6,9" 1320 × 2868, iPad 13" 2064 × 2752,
  je Deutsch und Englisch) als Artefakt `store-screenshots`. Lokal:
  `flutter test test/store --dart-define=STORE_SHOTS=true`, die Bilder liegen
  dann in `build/store_screenshots/`.

## Noch offen

- Werbung: `AdService` zeigt bisher eine eigene Premium-Anzeige; ein Werbe-SDK
  (z. B. AdMob) wird dort eingesetzt.
- Käufe: `PurchaseService` ist lokal; Store-Anbindung (RevenueCat oder
  `in_app_purchase`) ersetzt `LocalPurchaseService` in `main.dart`.
- Android-Release-Signatur und App-Icons.
- Dunkler Modus.

Schrift: Nunito (SIL Open Font License, `assets/fonts/OFL.txt`).
