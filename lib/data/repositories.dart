import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/models.dart';

/// Thin JSON layer over SharedPreferences. Everything the app stores is
/// small (a few hundred day records per profile), so a key–value store is
/// enough and keeps the app free of native database setup.
class JsonStore {
  JsonStore(this._prefs);

  final SharedPreferences _prefs;

  Object? read(String key) {
    final raw = _prefs.getString(key);
    if (raw == null) return null;
    try {
      return jsonDecode(raw);
    } on FormatException {
      return null;
    }
  }

  Future<void> write(String key, Object? value) =>
      _prefs.setString(key, jsonEncode(value));

  Future<void> remove(String key) => _prefs.remove(key);

  String? readString(String key) => _prefs.getString(key);
  Future<void> writeString(String key, String value) => _prefs.setString(key, value);
  bool? readBool(String key) => _prefs.getBool(key);
  Future<void> writeBool(String key, bool value) => _prefs.setBool(key, value);
  int? readInt(String key) => _prefs.getInt(key);
  Future<void> writeInt(String key, int value) => _prefs.setInt(key, value);
}

class ProfileRepository {
  ProfileRepository(this._store);

  final JsonStore _store;

  static const _profilesKey = 'profiles.v1';
  static const _activeKey = 'profiles.active';

  List<Profile> loadAll() {
    final raw = _store.read(_profilesKey);
    if (raw is! List) return [];
    return raw
        .whereType<Map<Object?, Object?>>()
        .map((m) => Profile.fromJson(m.cast<String, Object?>()))
        .toList();
  }

  Future<void> saveAll(List<Profile> profiles) =>
      _store.write(_profilesKey, profiles.map((p) => p.toJson()).toList());

  String? get activeId => _store.readString(_activeKey);

  Future<void> setActiveId(String? id) =>
      id == null ? _store.remove(_activeKey) : _store.writeString(_activeKey, id);
}

/// A finished creative piece (coloring page, pixel art) for the gallery.
class GalleryItem {
  const GalleryItem({
    required this.dateKey,
    required this.gameId,
    required this.motif,
    required this.difficulty,
    required this.colors,
  });

  factory GalleryItem.fromJson(Map<String, Object?> json) => GalleryItem(
        dateKey: json['date'] as String? ?? '',
        gameId: json['game'] as String? ?? '',
        motif: json['motif'] as String? ?? '',
        difficulty: Difficulty.fromName(json['difficulty'] as String?),
        colors: ((json['colors'] as List<Object?>?) ?? const [])
            .map((c) => (c as num?)?.toInt())
            .toList(),
      );

  final String dateKey;
  final String gameId;
  final String motif;
  final Difficulty difficulty;

  /// ARGB per region/pixel, null = left empty.
  final List<int?> colors;

  String get id => '$dateKey/$gameId/${difficulty.name}';

  Map<String, Object?> toJson() => {
        'date': dateKey,
        'game': gameId,
        'motif': motif,
        'difficulty': difficulty.name,
        'colors': colors,
      };
}

class ProgressRepository {
  ProgressRepository(this._store);

  final JsonStore _store;

  String _recordsKey(String profileId) => 'progress.v1.$profileId';
  String _tutorialKey(String profileId) => 'tutorials.v1.$profileId';
  String _galleryKey(String profileId) => 'gallery.v1.$profileId';

  Map<String, DayRecord> loadRecords(String profileId) {
    final raw = _store.read(_recordsKey(profileId));
    if (raw is! Map) return {};
    final result = <String, DayRecord>{};
    raw.forEach((key, value) {
      if (value is Map) {
        result[key as String] = DayRecord.fromJson(value.cast<String, Object?>());
      }
    });
    return result;
  }

  Future<void> saveRecords(String profileId, Map<String, DayRecord> records) =>
      _store.write(
        _recordsKey(profileId),
        {for (final e in records.entries) e.key: e.value.toJson()},
      );

  Set<String> loadSeenTutorials(String profileId) {
    final raw = _store.read(_tutorialKey(profileId));
    return raw is List ? raw.whereType<String>().toSet() : <String>{};
  }

  Future<void> saveSeenTutorials(String profileId, Set<String> ids) =>
      _store.write(_tutorialKey(profileId), ids.toList());

  List<GalleryItem> loadGallery(String profileId) {
    final raw = _store.read(_galleryKey(profileId));
    if (raw is! List) return [];
    return raw
        .whereType<Map<Object?, Object?>>()
        .map((m) => GalleryItem.fromJson(m.cast<String, Object?>()))
        .toList();
  }

  Future<void> saveGallery(String profileId, List<GalleryItem> items) =>
      _store.write(_galleryKey(profileId), items.map((i) => i.toJson()).toList());

  Future<void> deleteProfileData(String profileId) async {
    await _store.remove(_recordsKey(profileId));
    await _store.remove(_tutorialKey(profileId));
    await _store.remove(_galleryKey(profileId));
  }
}

class AppSettings {
  const AppSettings({
    this.localeCode,
    this.reminderEnabled = false,
    this.reminderHour = 8,
    this.reminderMinute = 0,
    this.haptics = true,
  });

  /// `de`, `en`, or null to follow the device language.
  final String? localeCode;
  final bool reminderEnabled;
  final int reminderHour;
  final int reminderMinute;
  final bool haptics;

  AppSettings copyWith({
    String? Function()? localeCode,
    bool? reminderEnabled,
    int? reminderHour,
    int? reminderMinute,
    bool? haptics,
  }) =>
      AppSettings(
        localeCode: localeCode != null ? localeCode() : this.localeCode,
        reminderEnabled: reminderEnabled ?? this.reminderEnabled,
        reminderHour: reminderHour ?? this.reminderHour,
        reminderMinute: reminderMinute ?? this.reminderMinute,
        haptics: haptics ?? this.haptics,
      );
}

class SettingsRepository {
  SettingsRepository(this._store);

  final JsonStore _store;
  static const _key = 'settings.v1';

  AppSettings load() {
    final raw = _store.read(_key);
    if (raw is! Map) return const AppSettings();
    return AppSettings(
      localeCode: raw['locale'] as String?,
      reminderEnabled: raw['reminder'] as bool? ?? false,
      reminderHour: (raw['hour'] as num?)?.toInt() ?? 8,
      reminderMinute: (raw['minute'] as num?)?.toInt() ?? 0,
      haptics: raw['haptics'] as bool? ?? true,
    );
  }

  Future<void> save(AppSettings s) => _store.write(_key, {
        'locale': s.localeCode,
        'reminder': s.reminderEnabled,
        'hour': s.reminderHour,
        'minute': s.reminderMinute,
        'haptics': s.haptics,
      });
}
