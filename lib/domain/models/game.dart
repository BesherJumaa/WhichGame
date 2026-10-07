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
    this.customImagePath,
    this.isCustom = false,
  });

  final String id;
  final String title;
  final String description;
  final GameCategory category;
  final int minPlayers;
  final int? maxPlayers;
  final Set<GameMode> modes;
  final String assetPath;
  final String? customImagePath;
  final bool isCustom;

  bool get hasCustomImage => customImagePath?.trim().isNotEmpty ?? false;

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

  Game copyWith({
    String? title,
    String? description,
    GameCategory? category,
    int? minPlayers,
    int? maxPlayers,
    bool clearMaxPlayers = false,
    Set<GameMode>? modes,
    String? assetPath,
    String? customImagePath,
    bool clearCustomImagePath = false,
    bool? isCustom,
  }) {
    return Game(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      minPlayers: minPlayers ?? this.minPlayers,
      maxPlayers: clearMaxPlayers ? null : maxPlayers ?? this.maxPlayers,
      modes: modes ?? this.modes,
      assetPath: assetPath ?? this.assetPath,
      customImagePath: clearCustomImagePath
          ? null
          : customImagePath ?? this.customImagePath,
      isCustom: isCustom ?? this.isCustom,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'category': category.name,
        'minPlayers': minPlayers,
        'maxPlayers': maxPlayers,
        'modes': modes.map((mode) => mode.name).toList(growable: false),
        'assetPath': assetPath,
        'customImagePath': customImagePath,
        'isCustom': isCustom,
      };

  factory Game.fromJson(Map<String, dynamic> json) {
    final categoryName = json['category'] as String?;
    final category = GameCategory.values.where(
      (item) => item.name == categoryName,
    );
    final rawModes = json['modes'];
    final parsedModes = <GameMode>{};
    if (rawModes is List<dynamic>) {
      for (final rawMode in rawModes.whereType<String>()) {
        for (final mode in GameMode.values) {
          if (mode.name == rawMode) {
            parsedModes.add(mode);
            break;
          }
        }
      }
    }

    final customImagePath = (json['customImagePath'] as String?)?.trim();

    return Game(
      id: (json['id'] as String? ?? '').trim(),
      title: (json['title'] as String? ?? '').trim(),
      description: (json['description'] as String? ?? '').trim(),
      category: category.isEmpty ? GameCategory.video : category.first,
      minPlayers: (json['minPlayers'] as num?)?.toInt() ?? 2,
      maxPlayers: (json['maxPlayers'] as num?)?.toInt(),
      modes: parsedModes.isEmpty ? {GameMode.local} : parsedModes,
      assetPath: (json['assetPath'] as String? ?? '').trim(),
      customImagePath:
          customImagePath == null || customImagePath.isEmpty ? null : customImagePath,
      isCustom: json['isCustom'] as bool? ?? false,
    );
  }
}
