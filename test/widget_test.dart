import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:whichgame/core/constants/app_strings.dart';
import 'package:whichgame/core/localization/app_language.dart';
import 'package:whichgame/data/catalog/game_catalog.dart';
import 'package:whichgame/data/local/game_image_storage.dart';
import 'package:whichgame/domain/models/custom_choice.dart';
import 'package:whichgame/domain/models/game.dart';
import 'package:whichgame/domain/models/game_filter.dart';
import 'package:whichgame/domain/models/player_profile.dart';
import 'package:whichgame/domain/services/generals_picker_service.dart';

void main() {
  setUp(() => AppStrings.setLanguage(AppLanguage.english));

  test('catalog contains only multiplayer games with unique ids', () {
    final games = GameCatalog.buildGames();
    final ids = games.map((game) => game.id).toSet();

    expect(games.length, greaterThanOrEqualTo(46));
    expect(ids.length, games.length);
    expect(games.every((game) => game.minPlayers >= 2), isTrue);
    expect(games.every((game) => game.title.trim().isNotEmpty), isTrue);
    expect(ids, containsAll(<String>['coup', 'trix', 'istimar']));
    expect(ids, isNot(contains('turkish_cards')));
  });

  test('first-run board intentionally exposes only a small starter set', () {
    final games = GameCatalog.buildGames();
    final ids = games.map((game) => game.id).toSet();

    expect(GameCatalog.defaultBoardGameIds, isNotEmpty);
    expect(ids.containsAll(GameCatalog.defaultBoardGameIds), isTrue);
    expect(GameCatalog.defaultBoardGameIds.length, lessThan(games.length / 2));
  });

  test('every catalog game has a bundled local artwork asset', () {
    for (final game in GameCatalog.buildGames()) {
      expect(
        game.assetPath.startsWith('images/games/'),
        isTrue,
        reason: '${game.title} should use the centralized game-assets folder.',
      );
      expect(
        File(game.assetPath).existsSync(),
        isTrue,
        reason: 'Missing artwork for ${game.title}: ${game.assetPath}',
      );
    }
  });

  test('single dropdown mode filter only returns matching games', () {
    const filter = GameFilterState(mode: GameMode.lan);
    final matching = GameCatalog.buildGames().where(filter.matches).toList();

    expect(matching, isNotEmpty);
    expect(
      matching.every((game) => game.modes.contains(GameMode.lan)),
      isTrue,
    );
  });

  test('pool filter can show selected or unselected games', () {
    const selected = GameFilterState(pool: GamePoolFilter.selected);
    const unselected = GameFilterState(pool: GamePoolFilter.unselected);

    expect(selected.matchesSelection(true), isTrue);
    expect(selected.matchesSelection(false), isFalse);
    expect(unselected.matchesSelection(true), isFalse);
    expect(unselected.matchesSelection(false), isTrue);
  });


  test('custom games serialize all editable fields', () {
    const game = Game(
      id: 'custom_game_1',
      title: 'Rocket League',
      description: 'Quick matches',
      category: GameCategory.sport,
      minPlayers: 2,
      maxPlayers: 8,
      modes: {GameMode.twoPlayers, GameMode.local, GameMode.online},
      assetPath: 'asset/app_icon.png',
      customImagePath: '/app/support/game_images/custom_game_1.webp',
      isCustom: true,
    );

    final restored = Game.fromJson(game.toJson());
    expect(restored.id, game.id);
    expect(restored.title, game.title);
    expect(restored.description, game.description);
    expect(restored.category, game.category);
    expect(restored.minPlayers, game.minPlayers);
    expect(restored.maxPlayers, game.maxPlayers);
    expect(restored.modes, unorderedEquals(game.modes));
    expect(restored.customImagePath, game.customImagePath);
    expect(restored.hasCustomImage, isTrue);
    expect(restored.isCustom, isTrue);
  });

  test('game image storage copies and removes app-owned artwork', () async {
    final root = await Directory.systemTemp.createTemp('whichgame_game_images_');
    final storage = GameImageStorage(
      supportDirectoryProvider: () async => root,
    );

    try {
      final path = await storage.saveImage(
        gameId: 'custom_game_1',
        bytes: Uint8List.fromList(<int>[1, 2, 3, 4]),
        originalFileName: 'cover.webp',
      );

      expect(File(path).existsSync(), isTrue);
      expect(path.endsWith('.webp'), isTrue);

      await storage.deleteImage(path);
      expect(File(path).existsSync(), isFalse);
    } finally {
      if (await root.exists()) {
        await root.delete(recursive: true);
      }
    }
  });

  test('custom picker choices serialize with their enabled state', () {
    const choice = CustomChoice(
      id: 'choice_1',
      label: 'Pizza',
      enabled: false,
    );

    final restored = CustomChoice.fromJson(choice.toJson());
    expect(restored.id, choice.id);
    expect(restored.label, choice.label);
    expect(restored.enabled, isFalse);
  });

  test('generals picker avoids duplicate armies until the pool is exhausted', () {
    final service = GeneralsPickerService(random: Random(11));
    final players = List.generate(
      10,
      (index) => PlayerProfile(
        id: 'player_$index',
        name: 'Player $index',
        isGuest: false,
      ),
    );

    final assignments = service.assign(players);
    expect(assignments.length, players.length);
    expect(
      assignments.map((assignment) => assignment.faction).toSet().length,
      10,
    );
  });

  test('Arabic localization switches labels without changing game ids', () {
    final englishIds = GameCatalog.buildGames().map((game) => game.id).toList();
    AppStrings.setLanguage(AppLanguage.arabic);
    final arabicGames = GameCatalog.buildGames();

    expect(arabicGames.map((game) => game.id).toList(), englishIds);
    expect(AppStrings.players, 'اللاعبون');
    expect(AppStrings.appName, 'أي لعبة؟');
    expect(AppStrings.pickGame, 'اختر لعبة');
    expect(arabicGames.first.title.isNotEmpty, isTrue);
  });
}
