import 'dart:async';
import 'dart:math';


import 'package:flutter/foundation.dart';
import 'package:whichgame/core/constants/app_images.dart';
import 'package:whichgame/core/constants/app_strings.dart';
import 'package:whichgame/core/localization/app_language.dart';
import 'package:whichgame/data/catalog/game_catalog.dart';
import 'package:whichgame/data/local/app_storage.dart';
import 'package:whichgame/data/local/game_image_storage.dart';
import 'package:whichgame/domain/models/custom_choice.dart';
import 'package:whichgame/domain/models/game.dart';
import 'package:whichgame/domain/models/game_filter.dart';
import 'package:whichgame/domain/models/player_profile.dart';
import 'package:whichgame/domain/models/team.dart';
import 'package:whichgame/domain/services/generals_picker_service.dart';
import 'package:whichgame/domain/services/team_generator.dart';

class AppController extends ChangeNotifier {
  factory AppController({
    required AppStorage storage,
    TeamGenerator teamGenerator = const TeamGenerator(),
    GeneralsPickerService? generalsPickerService,
    GameImageStorage? gameImageStorage,
  }) {
    return AppController._(
      storage,
      teamGenerator,
      generalsPickerService ?? GeneralsPickerService(),
      gameImageStorage ?? GameImageStorage(),
    );
  }

  AppController._(
    this._storage,
    this._teamGenerator,
    this._generalsPickerService,
    this._gameImageStorage,
  );

  final AppStorage _storage;
  final TeamGenerator _teamGenerator;
  final GeneralsPickerService _generalsPickerService;
  final GameImageStorage _gameImageStorage;
  final Random _random = Random();

  List<Game> games = const [];
  final List<PlayerProfile> _permanentPlayers = [];
  final List<PlayerProfile> _guestPlayers = [];
  final Set<String> _activePlayerIds = {};
  final Set<String> _archivedPlayerIds = {};
  final Set<String> _selectedGameIds = {};
  final Set<String> _archivedGameIds = {};
  final List<String> _recentGameIds = [];
  final List<CustomChoice> _customChoices = [];
  final List<Game> _customGames = [];
  final List<Game> _gameOverrides = [];
  final Set<String> _deletedGameIds = {};
  String? _lastCustomChoiceId;

  GameFilterState _gameFilters = const GameFilterState();
  Game? _lastPickedGame;
  AppLanguage _language = AppLanguage.english;
  bool _coachTourCompleted = false;

  List<PlayerProfile> get permanentPlayers => List.unmodifiable(
        _permanentPlayers
            .where((player) => !_archivedPlayerIds.contains(player.id)),
      );
  List<PlayerProfile> get archivedPlayers => List.unmodifiable(
        _permanentPlayers
            .where((player) => _archivedPlayerIds.contains(player.id))
            .toList()
          ..sort(
            (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
          ),
      );
  List<PlayerProfile> get guestPlayers => List.unmodifiable(_guestPlayers);
  List<PlayerProfile> get allPlayers => List.unmodifiable([
        ...permanentPlayers,
        ..._guestPlayers,
      ]);

  Set<String> get activePlayerIds => Set.unmodifiable(_activePlayerIds);
  Set<String> get archivedPlayerIds => Set.unmodifiable(_archivedPlayerIds);
  Set<String> get selectedGameIds => Set.unmodifiable(_selectedGameIds);
  Set<String> get archivedGameIds => Set.unmodifiable(_archivedGameIds);
  GameFilterState get gameFilters => _gameFilters;
  Game? get lastPickedGame => _lastPickedGame;
  AppLanguage get language => _language;
  bool get shouldShowCoachTour => !_coachTourCompleted;
  List<CustomChoice> get customChoices => List.unmodifiable(_customChoices);
  List<CustomChoice> get enabledCustomChoices => List.unmodifiable(
        _customChoices.where((choice) => choice.enabled),
      );

  List<PlayerProfile> get activePlayers => allPlayers
      .where((player) => _activePlayerIds.contains(player.id))
      .toList(growable: false);

  List<Game> get selectedGames => games
      .where(
        (game) =>
            _selectedGameIds.contains(game.id) &&
            !_archivedGameIds.contains(game.id),
      )
      .toList(growable: false);

  List<Game> get archivedGames => games
      .where((game) => _archivedGameIds.contains(game.id))
      .toList(growable: false)
    ..sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));

  List<Game> get randomPool => selectedGames
      .where(_gameFilters.matches)
      .toList(growable: false);

  List<Game> get recentGames => _recentGameIds
      .map(_gameById)
      .whereType<Game>()
      .where((game) => !_archivedGameIds.contains(game.id))
      .toList(growable: false);

  int get selectedGamesCount => selectedGames.length;
  int get archivedGamesCount => _archivedGameIds.length;
  int get archivedPlayersCount => _archivedPlayerIds.length;
  int get boardGamesCount => games.length - _archivedGameIds.length;

  Future<void> initialize() async {
    _language = await _storage.loadLanguage();
    _coachTourCompleted = await _storage.loadCoachTourCompleted();
    AppStrings.setLanguage(_language);

    final results = await Future.wait<dynamic>([
      _storage.loadPlayers(),
      _storage.loadActivePlayerIds(),
      _storage.loadSelectedGameIds(),
      _storage.loadGameFilters(),
      _storage.loadRecentGameIds(),
      _storage.loadArchivedGameIds(),
      _storage.loadArchivedPlayerIds(),
      _storage.loadCustomChoices(),
      _storage.loadCustomGames(),
      _storage.loadGameOverrides(),
      _storage.loadDeletedGameIds(),
    ]);

    _customGames
      ..clear()
      ..addAll(results[8] as List<Game>);
    _gameOverrides
      ..clear()
      ..addAll(results[9] as List<Game>);
    _deletedGameIds
      ..clear()
      ..addAll((results[10] as Set<String>).map(_migrateGameId));
    _rebuildGames();

    _permanentPlayers
      ..clear()
      ..addAll(results[0] as List<PlayerProfile>);

    final permanentIds = _permanentPlayers.map((player) => player.id).toSet();
    _archivedPlayerIds
      ..clear()
      ..addAll(
        (results[6] as Set<String>).where(permanentIds.contains),
      );

    final storedActiveIds = results[1] as Set<String>;
    _activePlayerIds
      ..clear()
      ..addAll(
        storedActiveIds.where(
          (id) => permanentIds.contains(id) && !_archivedPlayerIds.contains(id),
        ),
      );

    final availableGameIds = games.map((game) => game.id).toSet();
    final storedGameIds = (results[2] as Set<String>?)?.map(_migrateGameId).toSet();

    final storedArchivedGames = results[5] as Set<String>?;
    final initialArchivedGames = storedArchivedGames == null
        ? availableGameIds.difference(GameCatalog.defaultBoardGameIds)
        : storedArchivedGames
            .map(_migrateGameId)
            .where(availableGameIds.contains)
            .toSet();

    _archivedGameIds
      ..clear()
      ..addAll(initialArchivedGames);

    _selectedGameIds
      ..clear()
      ..addAll(
        storedGameIds == null
            ? GameCatalog.defaultBoardGameIds.where(availableGameIds.contains)
            : storedGameIds.where(availableGameIds.contains),
      )
      ..removeAll(_archivedGameIds);

    _gameFilters = results[3] as GameFilterState;

    _recentGameIds
      ..clear()
      ..addAll(
        (results[4] as List<String>)
            .map(_migrateGameId)
            .where(availableGameIds.contains)
            .take(5),
      );

    _customChoices
      ..clear()
      ..addAll(results[7] as List<CustomChoice>);

    // Persist the starter board only once. After that the user's exact board,
    // custom games, edits, deletes, and archive state are retained.
    if (storedArchivedGames == null) {
      await Future.wait([
        _storage.saveArchivedGameIds(_archivedGameIds),
        _storage.saveSelectedGameIds(_selectedGameIds),
      ]);
    }
  }

  Future<void> completeCoachTour() async {
    if (_coachTourCompleted) {
      return;
    }
    _coachTourCompleted = true;
    await _storage.saveCoachTourCompleted(true);
  }

  Future<void> setLanguage(AppLanguage language) async {
    if (_language == language) {
      return;
    }

    _language = language;
    AppStrings.setLanguage(language);
    _rebuildGames();
    _lastPickedGame = _lastPickedGame == null ? null : _gameById(_lastPickedGame!.id);
    notifyListeners();
    await _storage.saveLanguage(language);
  }

  List<Game> visibleGames(String query) {
    final normalizedQuery = query.trim().toLowerCase();
    final result = games.where((game) {
      if (_archivedGameIds.contains(game.id)) {
        return false;
      }
      if (!_gameFilters.matches(game)) {
        return false;
      }
      if (!_gameFilters.matchesSelection(_selectedGameIds.contains(game.id))) {
        return false;
      }
      if (normalizedQuery.isEmpty) {
        return true;
      }
      return game.title.toLowerCase().contains(normalizedQuery) ||
          game.description.toLowerCase().contains(normalizedQuery);
    }).toList();

    result.sort((a, b) {
      final categoryComparison = a.category.index.compareTo(b.category.index);
      if (categoryComparison != 0) {
        return categoryComparison;
      }
      return a.title.toLowerCase().compareTo(b.title.toLowerCase());
    });
    return result;
  }

  bool isGameSelected(String gameId) => _selectedGameIds.contains(gameId);
  bool isGameArchived(String gameId) => _archivedGameIds.contains(gameId);

  Future<Game> addGame({
    required String title,
    required String description,
    required GameCategory category,
    required int minPlayers,
    required int? maxPlayers,
    required Set<GameMode> modes,
    Uint8List? imageBytes,
    String? imageFileName,
  }) async {
    final id =
        'custom_game_${DateTime.now().microsecondsSinceEpoch}_${_random.nextInt(10000)}';
    String? customImagePath;

    if (imageBytes != null && imageFileName != null) {
      customImagePath = await _gameImageStorage.saveImage(
        gameId: id,
        bytes: imageBytes,
        originalFileName: imageFileName,
      );
    }

    final game = Game(
      id: id,
      title: title.trim(),
      description: description.trim(),
      category: category,
      minPlayers: minPlayers,
      maxPlayers: maxPlayers,
      modes: Set.unmodifiable(modes),
      assetPath: AppImages.appIcon,
      customImagePath: customImagePath,
      isCustom: true,
    );

    _customGames.add(game);
    _deletedGameIds.remove(game.id);
    _archivedGameIds.remove(game.id);
    _selectedGameIds.add(game.id);
    _rebuildGames();
    notifyListeners();

    try {
      await Future.wait([
        _storage.saveCustomGames(_customGames),
        _storage.saveDeletedGameIds(_deletedGameIds),
        _storage.saveArchivedGameIds(_archivedGameIds),
        _storage.saveSelectedGameIds(_selectedGameIds),
      ]);
    } catch (_) {
      _customGames.removeWhere((item) => item.id == game.id);
      _selectedGameIds.remove(game.id);
      _archivedGameIds.remove(game.id);
      _rebuildGames();
      notifyListeners();
      await _gameImageStorage.deleteImage(customImagePath);
      rethrow;
    }
    return game;
  }

  Future<void> updateGame({
    required Game game,
    required String title,
    required String description,
    required GameCategory category,
    required int minPlayers,
    required int? maxPlayers,
    required Set<GameMode> modes,
    Uint8List? imageBytes,
    String? imageFileName,
    bool removeCustomImage = false,
  }) async {
    final previousImagePath = game.customImagePath;
    String? nextImagePath = previousImagePath;
    var savedNewImage = false;

    if (imageBytes != null && imageFileName != null) {
      nextImagePath = await _gameImageStorage.saveImage(
        gameId: game.id,
        bytes: imageBytes,
        originalFileName: imageFileName,
      );
      savedNewImage = true;
    } else if (removeCustomImage) {
      nextImagePath = null;
    }

    final updated = game.copyWith(
      title: title.trim(),
      description: description.trim(),
      category: category,
      minPlayers: minPlayers,
      maxPlayers: maxPlayers,
      clearMaxPlayers: maxPlayers == null,
      modes: Set.unmodifiable(modes),
      customImagePath: nextImagePath,
      clearCustomImagePath: nextImagePath == null,
    );

    Game? previousStoredGame;
    var addedOverride = false;

    try {
      if (game.isCustom) {
        final index = _customGames.indexWhere((item) => item.id == game.id);
        if (index == -1) {
          if (savedNewImage) {
            await _gameImageStorage.deleteImage(nextImagePath);
          }
          return;
        }
        previousStoredGame = _customGames[index];
        _customGames[index] = updated.copyWith(isCustom: true);
        await _storage.saveCustomGames(_customGames);
      } else {
        final index = _gameOverrides.indexWhere((item) => item.id == game.id);
        if (index == -1) {
          _gameOverrides.add(updated.copyWith(isCustom: false));
          addedOverride = true;
        } else {
          previousStoredGame = _gameOverrides[index];
          _gameOverrides[index] = updated.copyWith(isCustom: false);
        }
        await _storage.saveGameOverrides(_gameOverrides);
      }
    } catch (_) {
      if (game.isCustom && previousStoredGame != null) {
        final index = _customGames.indexWhere((item) => item.id == game.id);
        if (index != -1) {
          _customGames[index] = previousStoredGame;
        }
      } else if (!game.isCustom) {
        if (addedOverride) {
          _gameOverrides.removeWhere((item) => item.id == game.id);
        } else if (previousStoredGame != null) {
          final index = _gameOverrides.indexWhere((item) => item.id == game.id);
          if (index != -1) {
            _gameOverrides[index] = previousStoredGame;
          }
        }
      }
      if (savedNewImage) {
        await _gameImageStorage.deleteImage(nextImagePath);
      }
      rethrow;
    }

    if (previousImagePath != null && previousImagePath != nextImagePath) {
      await _gameImageStorage.deleteImage(previousImagePath);
    }

    _rebuildGames();
    if (_lastPickedGame?.id == game.id) {
      _lastPickedGame = _gameById(game.id);
    }
    notifyListeners();
  }

  Future<void> deleteGame(Game game) async {
    final customImagePath = game.customImagePath;

    if (game.isCustom) {
      _customGames.removeWhere((item) => item.id == game.id);
    } else {
      _deletedGameIds.add(game.id);
      _gameOverrides.removeWhere((item) => item.id == game.id);
    }

    _selectedGameIds.remove(game.id);
    _archivedGameIds.remove(game.id);
    _recentGameIds.remove(game.id);
    if (_lastPickedGame?.id == game.id) {
      _lastPickedGame = null;
    }
    _rebuildGames();
    notifyListeners();

    await Future.wait([
      _storage.saveCustomGames(_customGames),
      _storage.saveGameOverrides(_gameOverrides),
      _storage.saveDeletedGameIds(_deletedGameIds),
      _storage.saveSelectedGameIds(_selectedGameIds),
      _storage.saveArchivedGameIds(_archivedGameIds),
      _storage.saveRecentGameIds(_recentGameIds),
    ]);
    await _gameImageStorage.deleteImage(customImagePath);
  }

  Future<void> toggleGame(String gameId) async {
    if (!_selectedGameIds.remove(gameId)) {
      _selectedGameIds.add(gameId);
    }
    notifyListeners();
    await _storage.saveSelectedGameIds(_selectedGameIds);
  }

  Future<void> selectOnlyGame(String gameId) async {
    _selectedGameIds
      ..clear()
      ..add(gameId);
    notifyListeners();
    await _storage.saveSelectedGameIds(_selectedGameIds);
  }

  Future<void> setAllGamesSelected(bool selected) async {
    final ids = games
        .where((game) => !_archivedGameIds.contains(game.id))
        .map((game) => game.id);
    if (selected) {
      _selectedGameIds.addAll(ids);
    } else {
      _selectedGameIds.removeAll(ids);
    }
    notifyListeners();
    await _storage.saveSelectedGameIds(_selectedGameIds);
  }

  Future<void> setVisibleGamesSelected(
    Iterable<Game> visibleGames,
    bool selected,
  ) async {
    final ids = visibleGames.map((game) => game.id);
    if (selected) {
      _selectedGameIds.addAll(ids);
    } else {
      _selectedGameIds.removeAll(ids);
    }
    notifyListeners();
    await _storage.saveSelectedGameIds(_selectedGameIds);
  }

  Future<void> archiveGame(String gameId) async {
    _archivedGameIds.add(gameId);
    _selectedGameIds.remove(gameId);
    _recentGameIds.remove(gameId);
    if (_lastPickedGame?.id == gameId) {
      _lastPickedGame = null;
    }
    notifyListeners();
    await Future.wait([
      _storage.saveArchivedGameIds(_archivedGameIds),
      _storage.saveSelectedGameIds(_selectedGameIds),
      _storage.saveRecentGameIds(_recentGameIds),
    ]);
  }

  Future<void> unarchiveGame(String gameId) async {
    _archivedGameIds.remove(gameId);
    _selectedGameIds.add(gameId);
    notifyListeners();
    await Future.wait([
      _storage.saveArchivedGameIds(_archivedGameIds),
      _storage.saveSelectedGameIds(_selectedGameIds),
    ]);
  }

  Future<void> archiveGames(Iterable<String> gameIds) async {
    final validIds = gameIds.where(_gameExists).toSet();
    if (validIds.isEmpty) {
      return;
    }

    _archivedGameIds.addAll(validIds);
    _selectedGameIds.removeAll(validIds);
    _recentGameIds.removeWhere(validIds.contains);
    if (_lastPickedGame != null && validIds.contains(_lastPickedGame!.id)) {
      _lastPickedGame = null;
    }
    notifyListeners();

    await Future.wait([
      _storage.saveArchivedGameIds(_archivedGameIds),
      _storage.saveSelectedGameIds(_selectedGameIds),
      _storage.saveRecentGameIds(_recentGameIds),
    ]);
  }

  Future<void> unarchiveGames(Iterable<String> gameIds) async {
    final validIds = gameIds.where(_gameExists).toSet();
    if (validIds.isEmpty) {
      return;
    }

    _archivedGameIds.removeAll(validIds);
    _selectedGameIds.addAll(validIds);
    notifyListeners();

    await Future.wait([
      _storage.saveArchivedGameIds(_archivedGameIds),
      _storage.saveSelectedGameIds(_selectedGameIds),
    ]);
  }

  Future<void> archiveDisabledGames() async {
    final disabledIds = games
        .where(
          (game) =>
              !_archivedGameIds.contains(game.id) &&
              !_selectedGameIds.contains(game.id),
        )
        .map((game) => game.id)
        .toSet();
    await archiveGames(disabledIds);
  }

  Future<void> setCategoryFilter(GameCategory? category) async {
    _gameFilters = _gameFilters.copyWith(
      category: category,
      clearCategory: category == null,
    );
    notifyListeners();
    await _storage.saveGameFilters(_gameFilters);
  }

  Future<void> setModeFilter(GameMode? mode) async {
    _gameFilters = _gameFilters.copyWith(
      mode: mode,
      clearMode: mode == null,
    );
    notifyListeners();
    await _storage.saveGameFilters(_gameFilters);
  }

  Future<void> setPoolFilter(GamePoolFilter pool) async {
    _gameFilters = _gameFilters.copyWith(pool: pool);
    notifyListeners();
    await _storage.saveGameFilters(_gameFilters);
  }

  Future<void> clearGameFilters() async {
    _gameFilters = const GameFilterState();
    notifyListeners();
    await _storage.saveGameFilters(_gameFilters);
  }

  Game? pickRandomGame() {
    final pool = randomPool;
    if (pool.isEmpty) {
      return null;
    }

    var picked = pool[_random.nextInt(pool.length)];
    if (pool.length > 1 && picked.id == _lastPickedGame?.id) {
      final alternatives = pool.where((game) => game.id != picked.id).toList();
      picked = alternatives[_random.nextInt(alternatives.length)];
    }

    _lastPickedGame = picked;
    _recentGameIds
      ..remove(picked.id)
      ..insert(0, picked.id);
    if (_recentGameIds.length > 5) {
      _recentGameIds.removeRange(5, _recentGameIds.length);
    }
    notifyListeners();
    unawaited(_storage.saveRecentGameIds(_recentGameIds));
    return picked;
  }

  Future<void> addCustomChoice(String label) async {
    final normalized = label.trim();
    if (normalized.isEmpty) {
      return;
    }

    _customChoices.add(
      CustomChoice(
        id: 'choice_${DateTime.now().microsecondsSinceEpoch}_${_random.nextInt(10000)}',
        label: normalized,
      ),
    );
    notifyListeners();
    await _storage.saveCustomChoices(_customChoices);
  }

  Future<void> updateCustomChoice(String id, String label) async {
    final normalized = label.trim();
    if (normalized.isEmpty) {
      return;
    }

    final index = _customChoices.indexWhere((choice) => choice.id == id);
    if (index == -1) {
      return;
    }

    _customChoices[index] = _customChoices[index].copyWith(label: normalized);
    notifyListeners();
    await _storage.saveCustomChoices(_customChoices);
  }

  Future<void> deleteCustomChoice(String id) async {
    final exists = _customChoices.any((choice) => choice.id == id);
    if (!exists) {
      return;
    }
    _customChoices.removeWhere((choice) => choice.id == id);
    if (_lastCustomChoiceId == id) {
      _lastCustomChoiceId = null;
    }
    notifyListeners();
    await _storage.saveCustomChoices(_customChoices);
  }

  Future<void> toggleCustomChoice(String id) async {
    final index = _customChoices.indexWhere((choice) => choice.id == id);
    if (index == -1) {
      return;
    }

    final choice = _customChoices[index];
    _customChoices[index] = choice.copyWith(enabled: !choice.enabled);
    notifyListeners();
    await _storage.saveCustomChoices(_customChoices);
  }

  Future<void> setAllCustomChoicesEnabled(bool enabled) async {
    if (_customChoices.isEmpty) {
      return;
    }

    for (var index = 0; index < _customChoices.length; index++) {
      _customChoices[index] = _customChoices[index].copyWith(enabled: enabled);
    }
    notifyListeners();
    await _storage.saveCustomChoices(_customChoices);
  }

  CustomChoice? pickRandomCustomChoice() {
    final pool = enabledCustomChoices;
    if (pool.isEmpty) {
      return null;
    }

    var picked = pool[_random.nextInt(pool.length)];
    if (pool.length > 1 && picked.id == _lastCustomChoiceId) {
      final alternatives = pool
          .where((choice) => choice.id != _lastCustomChoiceId)
          .toList(growable: false);
      picked = alternatives[_random.nextInt(alternatives.length)];
    }
    _lastCustomChoiceId = picked.id;
    return picked;
  }

  Future<void> addPlayer({required String name, required bool permanent}) async {
    final normalized = name.trim();
    if (normalized.isEmpty) {
      return;
    }

    final player = PlayerProfile(
      id: '${permanent ? 'player' : 'guest'}_${DateTime.now().microsecondsSinceEpoch}',
      name: normalized,
      isGuest: !permanent,
    );

    if (permanent) {
      _permanentPlayers.add(player);
    } else {
      _guestPlayers.add(player);
    }
    _activePlayerIds.add(player.id);
    notifyListeners();

    if (permanent) {
      await _storage.savePlayers(_permanentPlayers);
      await _storage.saveActivePlayerIds(_permanentActiveIds());
    }
  }

  Future<void> updatePlayer({
    required PlayerProfile player,
    required String name,
    required bool permanent,
  }) async {
    final normalized = name.trim();
    if (normalized.isEmpty) {
      return;
    }

    final wasPermanent = !player.isGuest;
    final updated = player.copyWith(name: normalized, isGuest: !permanent);

    _permanentPlayers.removeWhere((item) => item.id == player.id);
    _guestPlayers.removeWhere((item) => item.id == player.id);
    if (permanent) {
      _permanentPlayers.add(updated);
    } else {
      _guestPlayers.add(updated);
      _archivedPlayerIds.remove(player.id);
    }
    notifyListeners();

    if (permanent || wasPermanent) {
      await Future.wait([
        _storage.savePlayers(_permanentPlayers),
        _storage.saveActivePlayerIds(_permanentActiveIds()),
        _storage.saveArchivedPlayerIds(_archivedPlayerIds),
      ]);
    }
  }

  Future<void> deletePlayer(PlayerProfile player) async {
    if (player.isGuest) {
      _guestPlayers.removeWhere((item) => item.id == player.id);
    } else {
      _permanentPlayers.removeWhere((item) => item.id == player.id);
    }
    _activePlayerIds.remove(player.id);
    _archivedPlayerIds.remove(player.id);
    notifyListeners();

    if (!player.isGuest) {
      await Future.wait([
        _storage.savePlayers(_permanentPlayers),
        _storage.saveActivePlayerIds(_permanentActiveIds()),
        _storage.saveArchivedPlayerIds(_archivedPlayerIds),
      ]);
    }
  }

  Future<void> togglePlayerActive(String playerId) async {
    if (!_activePlayerIds.remove(playerId)) {
      _activePlayerIds.add(playerId);
    }
    notifyListeners();
    await _storage.saveActivePlayerIds(_permanentActiveIds());
  }

  Future<void> setAllPermanentPlayersActive(bool active) async {
    final ids = permanentPlayers.map((player) => player.id);
    if (active) {
      _activePlayerIds.addAll(ids);
    } else {
      _activePlayerIds.removeAll(ids);
    }
    notifyListeners();
    await _storage.saveActivePlayerIds(_permanentActiveIds());
  }

  Future<void> archivePlayer(String playerId) async {
    await archivePlayers([playerId]);
  }

  Future<void> unarchivePlayer(String playerId) async {
    await unarchivePlayers([playerId]);
  }

  Future<void> archivePlayers(Iterable<String> playerIds) async {
    final permanentIds = _permanentPlayers.map((player) => player.id).toSet();
    final validIds = playerIds.where(permanentIds.contains).toSet();
    if (validIds.isEmpty) {
      return;
    }

    _archivedPlayerIds.addAll(validIds);
    _activePlayerIds.removeAll(validIds);
    notifyListeners();

    await Future.wait([
      _storage.saveArchivedPlayerIds(_archivedPlayerIds),
      _storage.saveActivePlayerIds(_permanentActiveIds()),
    ]);
  }

  Future<void> unarchivePlayers(Iterable<String> playerIds) async {
    final permanentIds = _permanentPlayers.map((player) => player.id).toSet();
    final validIds = playerIds.where(permanentIds.contains).toSet();
    if (validIds.isEmpty) {
      return;
    }

    _archivedPlayerIds.removeAll(validIds);
    notifyListeners();
    await _storage.saveArchivedPlayerIds(_archivedPlayerIds);
  }

  void clearGuests() {
    final guestIds = _guestPlayers.map((player) => player.id).toSet();
    _guestPlayers.clear();
    _activePlayerIds.removeAll(guestIds);
    notifyListeners();
  }

  List<Team> generateTeams(int teamCount) {
    return _teamGenerator.split(activePlayers, teamCount);
  }

  List<GeneralsAssignment> generateGeneralsAssignments() {
    return _generalsPickerService.assign(activePlayers);
  }

  void _rebuildGames() {
    final overridesById = {
      for (final game in _gameOverrides) game.id: game,
    };
    final merged = <Game>[];

    for (final catalogGame in GameCatalog.buildGames()) {
      if (_deletedGameIds.contains(catalogGame.id)) {
        continue;
      }
      merged.add(overridesById[catalogGame.id] ?? catalogGame);
    }

    final existingIds = merged.map((game) => game.id).toSet();
    for (final customGame in _customGames) {
      if (_deletedGameIds.contains(customGame.id) ||
          existingIds.contains(customGame.id)) {
        continue;
      }
      merged.add(customGame.copyWith(isCustom: true));
      existingIds.add(customGame.id);
    }

    games = List.unmodifiable(merged);
  }

  Set<String> _permanentActiveIds() {
    final permanentIds = permanentPlayers.map((player) => player.id).toSet();
    return _activePlayerIds.where(permanentIds.contains).toSet();
  }

  String _migrateGameId(String id) => id == 'turkish_cards' ? 'trix' : id;

  Game? _gameById(String id) {
    for (final game in games) {
      if (game.id == id) {
        return game;
      }
    }
    return null;
  }

  bool _gameExists(String id) => games.any((game) => game.id == id);
}
