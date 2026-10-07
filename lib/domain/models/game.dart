import 'package:whichgame/core/constants/app_strings.dart';

enum GameCategory {
  video,
  card,
  sport;

  String get label => switch (this) {
        GameCategory.video => AppStrings.categoryVideo,
        GameCategory.card => AppStrings.categoryCard,
        GameCategory.sport => AppStrings.categorySport,
      };
}

enum GameMode {
  twoPlayers,
  group,
  local,
  lan,
  online;

  String get label => switch (this) {
        GameMode.twoPlayers => AppStrings.modeTwoPlayers,
        GameMode.group => AppStrings.modeGroup,
        GameMode.local => AppStrings.modeLocal,
        GameMode.lan => AppStrings.modeLan,
        GameMode.online => AppStrings.modeOnline,
      };
}

class Game {
  const Game({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.minPlayers,
    required this.maxPlayers,
    required this.modes,
    required this.assetPath,
  });

  final String id;
  final String title;
  final String description;
  final GameCategory category;
  final int minPlayers;
  final int? maxPlayers;
  final Set<GameMode> modes;
  final String assetPath;

  String get playerLabel {
    final max = maxPlayers;
    if (max == null) {
      return AppStrings.minPlayers(minPlayers);
    }
    if (minPlayers == max) {
      return AppStrings.exactPlayers(minPlayers);
    }
    return AppStrings.playerRange(minPlayers, max);
  }
}
