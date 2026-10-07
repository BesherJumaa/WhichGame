import 'package:whichgame/domain/models/game.dart';

enum GamePoolFilter { all, selected, unselected }

class GameFilterState {
  const GameFilterState({
    this.category,
    this.mode,
    this.pool = GamePoolFilter.all,
  });

  final GameCategory? category;
  final GameMode? mode;
  final GamePoolFilter pool;

  bool get hasFilters =>
      category != null || mode != null || pool != GamePoolFilter.all;

  bool matches(Game game) {
    final categoryMatches = category == null || game.category == category;
    final modeMatches = mode == null || game.modes.contains(mode);
    return categoryMatches && modeMatches;
  }

  bool matchesSelection(bool selected) {
    return switch (pool) {
      GamePoolFilter.all => true,
      GamePoolFilter.selected => selected,
      GamePoolFilter.unselected => !selected,
    };
  }

  GameFilterState copyWith({
    GameCategory? category,
    bool clearCategory = false,
    GameMode? mode,
    bool clearMode = false,
    GamePoolFilter? pool,
  }) {
    return GameFilterState(
      category: clearCategory ? null : category ?? this.category,
      mode: clearMode ? null : mode ?? this.mode,
      pool: pool ?? this.pool,
    );
  }

  Map<String, Object?> toJson() => {
        'category': category?.name,
        'mode': mode?.name,
        'pool': pool.name,
      };

  factory GameFilterState.fromJson(Map<String, dynamic> json) {
    // Backward-compatible migration from the previous multi-select filter format.
    final legacyCategories = (json['categories'] as List<dynamic>? ?? const [])
        .whereType<String>();
    final legacyModes =
        (json['modes'] as List<dynamic>? ?? const []).whereType<String>();

    final categoryName = json['category'] as String? ??
        (legacyCategories.isEmpty ? null : legacyCategories.first);
    final modeName =
        json['mode'] as String? ?? (legacyModes.isEmpty ? null : legacyModes.first);

    final category = categoryName == null
        ? null
        : GameCategory.values
            .cast<GameCategory?>()
            .firstWhere((item) => item?.name == categoryName, orElse: () => null);
    final mode = modeName == null
        ? null
        : GameMode.values
            .cast<GameMode?>()
            .firstWhere((item) => item?.name == modeName, orElse: () => null);

    final poolName = json['pool'] as String?;
    final legacySelectedOnly = json['showSelectedOnly'] as bool? ?? false;
    final pool = poolName == null
        ? (legacySelectedOnly ? GamePoolFilter.selected : GamePoolFilter.all)
        : GamePoolFilter.values.firstWhere(
            (item) => item.name == poolName,
            orElse: () => GamePoolFilter.all,
          );

    return GameFilterState(category: category, mode: mode, pool: pool);
  }
}
