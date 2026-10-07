import 'dart:math';

import 'package:whichgame/domain/models/generals_faction.dart';
import 'package:whichgame/domain/models/player_profile.dart';

class GeneralsAssignment {
  const GeneralsAssignment({required this.player, required this.faction});

  final PlayerProfile player;
  final GeneralsFaction faction;
}

class GeneralsPickerService {
  GeneralsPickerService({Random? random}) : _random = random ?? Random();

  final Random _random;

  List<GeneralsAssignment> assign(List<PlayerProfile> players) {
    if (players.isEmpty) {
      return const [];
    }

    final result = <GeneralsAssignment>[];
    var available = GeneralsFaction.values.toList()..shuffle(_random);

    for (final player in players) {
      if (available.isEmpty) {
        available = GeneralsFaction.values.toList()..shuffle(_random);
      }
      result.add(
        GeneralsAssignment(
          player: player,
          faction: available.removeLast(),
        ),
      );
    }

    return result;
  }
}
