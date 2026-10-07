import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:whichgame/domain/models/player_profile.dart';
import 'package:whichgame/domain/services/team_generator.dart';

void main() {
  test('team generator keeps team sizes balanced', () {
    final generator = TeamGenerator(random: Random(7));
    final players = List.generate(
      9,
      (index) => PlayerProfile(
        id: 'p$index',
        name: 'Player ${index + 1}',
        isGuest: false,
      ),
    );

    final teams = generator.split(players, 4);
    final sizes = teams.map((team) => team.players.length).toList()..sort();

    expect(teams.length, 4);
    expect(sizes.last - sizes.first, lessThanOrEqualTo(1));
    expect(teams.expand((team) => team.players).map((player) => player.id).toSet().length, 9);
  });

  test('team generator rejects more teams than players', () {
    const players = [
      PlayerProfile(id: 'a', name: 'A', isGuest: false),
      PlayerProfile(id: 'b', name: 'B', isGuest: false),
    ];

    expect(
      () => const TeamGenerator().split(players, 3),
      throwsArgumentError,
    );
  });
}
