import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../core/dates.dart';
import '../data/content.dart';
import '../data/device_services.dart';
import '../data/premium.dart';
import '../data/quote_quiz.dart';
import '../data/repositories.dart';
import '../domain/access.dart';
import '../domain/models.dart';
import '../domain/planner.dart';
import '../domain/stats.dart';

/// The app's single source of truth for profiles, progress and settings.
///
/// Screens read it through `context.watch<AppState>()`; every mutation goes
/// through a method here so persistence stays in one place.
class AppState extends ChangeNotifier {
  AppState({
    required ProfileRepository profiles,
    required ProgressRepository progress,
    required SettingsRepository settings,
    required this.purchases,
    required this.reminders,
    required this.speech,
    required this.quotes,
    this._bundle,
    DateTime Function()? clock,
    this.planner = const DayPlanner(),
    this.accessPolicy = const AccessPolicy(),
  })  : _profilesRepo = profiles,
        _progressRepo = progress,
        _settingsRepo = settings,
        _clock = clock ?? DateTime.now;

  final ProfileRepository _profilesRepo;
  final ProgressRepository _progressRepo;
  final SettingsRepository _settingsRepo;
  final PurchaseService purchases;
  final ReminderService reminders;
  final SpeechService speech;
  final QuoteQuizRepository quotes;
  final DayPlanner planner;
  final AccessPolicy accessPolicy;
  final AssetBundle? _bundle;
  final DateTime Function() _clock;

  List<Profile> _profiles = [];
  Profile? _active;
  Map<String, DayRecord> _records = {};
  List<GalleryItem> _gallery = [];
  Set<String> _seenTutorials = {};
  AppSettings _settings = const AppSettings();
  final Map<String, Future<GameContent>> _content = {};

  List<Profile> get profiles => List.unmodifiable(_profiles);
  Profile? get activeProfile => _active;
  Map<String, DayRecord> get records => Map.unmodifiable(_records);
  List<GalleryItem> get gallery => List.unmodifiable(_gallery);
  AppSettings get settings => _settings;
  bool get isPremium => purchases.isPremium;
  DateTime get today => dayOnly(_clock());
  ProgressStats get stats => ProgressStats(_records);
  Audience get audience => _active?.audience ?? Audience.adult;

  void load() {
    _settings = _settingsRepo.load();
    _profiles = _profilesRepo.loadAll();
    final activeId = _profilesRepo.activeId;
    _active = _profiles.where((p) => p.id == activeId).firstOrNull;
    _loadProfileData();
  }

  void _loadProfileData() {
    final p = _active;
    _records = p == null ? {} : _progressRepo.loadRecords(p.id);
    _gallery = p == null ? [] : _progressRepo.loadGallery(p.id);
    _seenTutorials = p == null ? {} : _progressRepo.loadSeenTutorials(p.id);
  }

  // ---------------------------------------------------------------- profiles

  Future<Profile> createProfile({required String name, required Audience audience}) async {
    final profile = Profile(
      id: '${_clock().microsecondsSinceEpoch}',
      name: name.trim(),
      audience: audience,
      createdAt: today,
      lastDifficulty: audience == Audience.kid ? Difficulty.easy : Difficulty.standard,
      colorIndex: _nextColorIndex(audience),
    );
    _profiles = [..._profiles, profile];
    await _profilesRepo.saveAll(_profiles);
    await selectProfile(profile.id);
    return profile;
  }

  /// Kids start teal (index 1) like the designs, adults copper; further
  /// profiles of the same kind get the next free colour.
  int _nextColorIndex(Audience audience) {
    const adultColors = [0, 2, 3, 4, 5];
    const kidColors = [1, 3, 5, 2];
    final sameKind = _profiles.where((p) => p.audience == audience).length;
    final colors = audience == Audience.kid ? kidColors : adultColors;
    return colors[sameKind % colors.length];
  }

  Future<void> selectProfile(String? id) async {
    _active = _profiles.where((p) => p.id == id).firstOrNull;
    await _profilesRepo.setActiveId(_active?.id);
    _loadProfileData();
    notifyListeners();
  }

  Future<void> updateProfile(Profile profile) async {
    _profiles = [for (final p in _profiles) p.id == profile.id ? profile : p];
    if (_active?.id == profile.id) _active = profile;
    await _profilesRepo.saveAll(_profiles);
    notifyListeners();
  }

  Future<void> deleteProfile(String id) async {
    _profiles = _profiles.where((p) => p.id != id).toList();
    await _profilesRepo.saveAll(_profiles);
    await _progressRepo.deleteProfileData(id);
    if (_active?.id == id) {
      await selectProfile(null);
    } else {
      notifyListeners();
    }
  }

  /// Streak of any profile (shown on the profile picker).
  int streakOf(Profile profile) => ProgressStats(_progressRepo.loadRecords(profile.id))
      .streak(today: today, since: profile.createdAt);

  int get streak {
    final p = _active;
    return p == null ? 0 : stats.streak(today: today, since: p.createdAt);
  }

  // ---------------------------------------------------------------- plan

  DayPlan planFor(DateTime date) => planner.planFor(date, audience: audience);

  DayAccess accessFor(DateTime date) =>
      accessPolicy.accessFor(date, today: today, premium: isPremium);

  DayRecord? recordFor(DateTime date) => _records[dateKey(date)];

  // ---------------------------------------------------------------- results

  Future<void> recordResult(DayPlan plan, Difficulty difficulty, LevelResult result) async {
    final p = _active;
    if (p == null) return;
    final key = dateKey(plan.date);
    final record = _records[key] ?? DayRecord(dateKey: key, gameId: plan.type.id);
    _records = {..._records, key: record.withResult(difficulty, result)};
    await _progressRepo.saveRecords(p.id, _records);
    await updateProfile(p.copyWith(lastDifficulty: difficulty));
  }

  Future<void> addToGallery(GalleryItem item) async {
    final p = _active;
    if (p == null) return;
    _gallery = [..._gallery.where((g) => g.id != item.id), item];
    await _progressRepo.saveGallery(p.id, _gallery);
    notifyListeners();
  }

  bool hasSeenTutorial(GameType type) => _seenTutorials.contains(type.id);

  Future<void> markTutorialSeen(GameType type) async {
    final p = _active;
    if (p == null || !_seenTutorials.add(type.id)) return;
    await _progressRepo.saveSeenTutorials(p.id, _seenTutorials);
  }

  // ---------------------------------------------------------------- content

  Future<GameContent> contentFor(String languageCode) {
    final lang = GameContent.resolveLanguage(languageCode);
    return _content[lang] ??= GameContent.load(lang, bundle: _bundle);
  }

  // ---------------------------------------------------------------- premium

  Future<PurchaseOutcome> buyPremium(PremiumPlan plan) async {
    final outcome = await purchases.buy(plan);
    notifyListeners();
    return outcome;
  }

  Future<bool> restorePurchases() async {
    final found = await purchases.restore();
    notifyListeners();
    return found;
  }

  Future<void> setPremiumForTesting(bool value) async {
    final service = purchases;
    if (service is LocalPurchaseService) {
      await service.setPremiumForTesting(value);
      notifyListeners();
    }
  }

  // ---------------------------------------------------------------- settings

  Future<void> setLocale(String? code) => _saveSettings(_settings.copyWith(localeCode: () => code));

  Future<void> setHaptics(bool on) => _saveSettings(_settings.copyWith(haptics: on));

  /// Turns the daily reminder on or off. Returns false if notifications were
  /// not allowed (the setting then stays off).
  Future<bool> setReminder({
    required bool enabled,
    int? hour,
    int? minute,
    required String title,
    required String body,
  }) async {
    var next = _settings.copyWith(
      reminderEnabled: enabled,
      reminderHour: hour,
      reminderMinute: minute,
    );
    var ok = true;
    if (enabled) {
      ok = await reminders.scheduleDaily(
        hour: next.reminderHour,
        minute: next.reminderMinute,
        title: title,
        body: body,
      );
      if (!ok) next = next.copyWith(reminderEnabled: false);
    } else {
      await reminders.cancel();
    }
    await _saveSettings(next);
    return ok;
  }

  Future<void> _saveSettings(AppSettings s) async {
    _settings = s;
    await _settingsRepo.save(s);
    notifyListeners();
  }

  /// Called when the app returns to the foreground: screens re-read [today].
  void refreshDay() => notifyListeners();

  void haptic() {
    if (_settings.haptics) HapticFeedback.lightImpact();
  }
}
