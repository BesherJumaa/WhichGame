import 'package:whichgame/domain/models/player_profile.dart';

class Team {
  const Team({required this.index, required this.players});

  final int index;
  final List<PlayerProfile> players;
}
