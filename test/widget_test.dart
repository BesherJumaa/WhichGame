import 'dart:io';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:whichgame/core/constants/app_strings.dart';
import 'package:whichgame/core/localization/app_language.dart';
import 'package:whichgame/data/catalog/game_catalog.dart';
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
