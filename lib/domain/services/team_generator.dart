import 'dart:math';

import 'package:whichgame/domain/models/player_profile.dart';
import 'package:whichgame/domain/models/team.dart';

class TeamGenerator {
  const TeamGenerator({this.random});

  final Random? random;

  List<Team> split(List<PlayerProfile> players, int teamCount) {
    if (teamCount < 2) {
      throw ArgumentError.value(teamCount, 'teamCount', 'Must be at least 2.');
    }
    if (players.length < teamCount) {
      throw ArgumentError('There must be at least one player per team.');
    }

    final shuffled = List<PlayerProfile>.of(players);
    shuffled.shuffle(random ?? Random());

    final buckets = List.generate(teamCount, (_) => <PlayerProfile>[]);
    for (var index = 0; index < shuffled.length; index++) {
      buckets[index % teamCount].add(shuffled[index]);
    }

    return List.generate(
      teamCount,
      (index) => Team(
        index: index + 1,
        players: List.unmodifiable(buckets[index]),
      ),
    );
  }
}
