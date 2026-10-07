import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:whichgame/core/localization/app_language.dart';
import 'package:whichgame/domain/models/custom_choice.dart';
import 'package:whichgame/domain/models/game.dart';
import 'package:whichgame/domain/models/game_filter.dart';
import 'package:whichgame/domain/models/player_profile.dart';

class AppStorage {
  AppStorage({SharedPreferencesAsync? preferences})
      : _preferences = preferences ?? SharedPreferencesAsync();

  static const _playersKey = 'whichgame.players.v2';
  static const _activePlayersKey = 'whichgame.activePlayers.v2';
  static const _selectedGamesKey = 'whichgame.selectedGames.v2';
  static const _gameFiltersKey = 'whichgame.gameFilters.v2';
  static const _recentGamesKey = 'whichgame.recentGames.v2';
  static const _archivedGamesKey = 'whichgame.archivedGames.v1';
  static const _archivedPlayersKey = 'whichgame.archivedPlayers.v1';
  static const _languageKey = 'whichgame.language.v1';
  static const _coachTourCompletedKey = 'whichgame.coachTour.completed.v1';
  static const _customChoicesKey = 'whichgame.customChoices.v1';
  static const _customGamesKey = 'whichgame.customGames.v1';
  static const _gameOverridesKey = 'whichgame.gameOverrides.v1';
  static const _deletedGameIdsKey = 'whichgame.deletedGames.v1';

  final SharedPreferencesAsync _preferences;

  Future<List<PlayerProfile>> loadPlayers() async {
    final raw = await _preferences.getString(_playersKey);
    if (raw == null || raw.isEmpty) {
      return const [];
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List<dynamic>) {
        return const [];
      }
      return decoded
          .whereType<Map<String, dynamic>>()
          .map(PlayerProfile.fromJson)
          .toList(growable: false);
    } on FormatException {
      return const [];
    }
  }

  Future<void> savePlayers(List<PlayerProfile> players) {
    final payload = jsonEncode(players.map((player) => player.toJson()).toList());
    return _preferences.setString(_playersKey, payload);
  }

  Future<Set<String>> loadActivePlayerIds() async {
    final values = await _preferences.getStringList(_activePlayersKey);
    return (values ?? const <String>[]).toSet();
  }

  Future<void> saveActivePlayerIds(Set<String> ids) {
    return _preferences.setStringList(_activePlayersKey, ids.toList()..sort());
  }

  Future<Set<String>?> loadSelectedGameIds() async {
    final values = await _preferences.getStringList(_selectedGamesKey);
    return values?.toSet();
  }

  Future<void> saveSelectedGameIds(Set<String> ids) {
    return _preferences.setStringList(_selectedGamesKey, ids.toList()..sort());
  }

  Future<GameFilterState> loadGameFilters() async {
    final raw = await _preferences.getString(_gameFiltersKey);
    if (raw == null || raw.isEmpty) {
      return const GameFilterState();
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return GameFilterState.fromJson(decoded);
      }
    } on FormatException {
      // Corrupt optional UI preferences should never prevent the app from booting.
    }
    return const GameFilterState();
  }

  Future<void> saveGameFilters(GameFilterState filters) {
    return _preferences.setString(_gameFiltersKey, jsonEncode(filters.toJson()));
  }

  Future<List<String>> loadRecentGameIds() async {
    return await _preferences.getStringList(_recentGamesKey) ?? const [];
  }

  Future<void> saveRecentGameIds(List<String> ids) {
    return _preferences.setStringList(_recentGamesKey, ids);
  }

  Future<Set<String>?> loadArchivedGameIds() async {
    final values = await _preferences.getStringList(_archivedGamesKey);
    return values?.toSet();
  }

  Future<void> saveArchivedGameIds(Set<String> ids) {
    return _preferences.setStringList(_archivedGamesKey, ids.toList()..sort());
  }

  Future<Set<String>> loadArchivedPlayerIds() async {
    final values = await _preferences.getStringList(_archivedPlayersKey);
    return (values ?? const <String>[]).toSet();
  }

  Future<void> saveArchivedPlayerIds(Set<String> ids) {
    return _preferences.setStringList(
      _archivedPlayersKey,
      ids.toList()..sort(),
    );
  }

  Future<AppLanguage> loadLanguage() async {
    return AppLanguage.fromCode(await _preferences.getString(_languageKey));
  }

  Future<void> saveLanguage(AppLanguage language) {
    return _preferences.setString(_languageKey, language.code);
  }

  Future<List<CustomChoice>> loadCustomChoices() async {
    final raw = await _preferences.getString(_customChoicesKey);
    if (raw == null || raw.isEmpty) {
      return const [];
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List<dynamic>) {
        return const [];
      }
      return decoded
          .whereType<Map<String, dynamic>>()
          .map(CustomChoice.fromJson)
          .where((choice) => choice.id.isNotEmpty && choice.label.trim().isNotEmpty)
          .toList(growable: false);
    } on FormatException {
      return const [];
    }
  }

  Future<void> saveCustomChoices(List<CustomChoice> choices) {
    final payload = jsonEncode(choices.map((choice) => choice.toJson()).toList());
    return _preferences.setString(_customChoicesKey, payload);
  }

  Future<List<Game>> loadCustomGames() => _loadGames(_customGamesKey);

  Future<void> saveCustomGames(List<Game> games) {
    return _saveGames(_customGamesKey, games);
  }

  Future<List<Game>> loadGameOverrides() => _loadGames(_gameOverridesKey);

  Future<void> saveGameOverrides(List<Game> games) {
    return _saveGames(_gameOverridesKey, games);
  }

  Future<Set<String>> loadDeletedGameIds() async {
    final values = await _preferences.getStringList(_deletedGameIdsKey);
    return (values ?? const <String>[]).toSet();
  }

  Future<void> saveDeletedGameIds(Set<String> ids) {
    return _preferences.setStringList(
      _deletedGameIdsKey,
      ids.toList()..sort(),
    );
  }

  Future<List<Game>> _loadGames(String key) async {
    final raw = await _preferences.getString(key);
    if (raw == null || raw.isEmpty) {
      return const [];
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List<dynamic>) {
        return const [];
      }
      return decoded
          .whereType<Map<String, dynamic>>()
          .map(Game.fromJson)
          .where((game) => game.id.isNotEmpty && game.title.isNotEmpty)
          .toList(growable: false);
    } on FormatException {
      return const [];
    }
  }

  Future<void> _saveGames(String key, List<Game> games) {
    final payload = jsonEncode(games.map((game) => game.toJson()).toList());
    return _preferences.setString(key, payload);
  }

  Future<bool> loadCoachTourCompleted() async {
    return await _preferences.getBool(_coachTourCompletedKey) ?? false;
  }

  Future<void> saveCoachTourCompleted(bool completed) {
    return _preferences.setBool(_coachTourCompletedKey, completed);
  }
}
