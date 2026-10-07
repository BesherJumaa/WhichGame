import 'package:flutter/material.dart';
import 'package:whichgame/core/constants/app_strings.dart';
import 'package:whichgame/core/widgets/app_bottom_sheet_safe_area.dart';
import 'package:whichgame/core/widgets/app_page.dart';
import 'package:whichgame/core/widgets/game_artwork.dart';
import 'package:whichgame/core/widgets/language_button.dart';
import 'package:whichgame/domain/models/game.dart';
import 'package:whichgame/domain/models/game_filter.dart';
import 'package:whichgame/presentation/app_controller.dart';
import 'package:whichgame/presentation/app_scope.dart';
import 'package:whichgame/presentation/games/game_editor_sheet.dart';
import 'package:whichgame/presentation/games/widgets/game_card.dart';

class GamesScreen extends StatefulWidget {
  const GamesScreen({
    this.coachFiltersKey,
    this.coachBoardKey,
    this.coachArchiveKey,
    super.key,
  });

  final GlobalKey? coachFiltersKey;
  final GlobalKey? coachBoardKey;
  final GlobalKey? coachArchiveKey;

  @override
  State<GamesScreen> createState() => _GamesScreenState();
}

class _GamesScreenState extends State<GamesScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final games = controller.visibleGames(_searchController.text);
    final hasSearchOrFilters =
        controller.gameFilters.hasFilters || _searchController.text.isNotEmpty;

    return SafeArea(
      child: Column(
        children: [
          AppBar(
            title: Text(AppStrings.gameLibrary),
            actions: [
              IconButton(
                tooltip: AppStrings.addGame,
                onPressed: () => _showGameEditor(context),
                icon: const Icon(Icons.add_circle_outline_rounded),
              ),
              IconButton(
                key: widget.coachArchiveKey,
                tooltip: AppStrings.manageGameBoard,
                onPressed: () => _showArchivedGames(context),
                icon: controller.archivedGamesCount == 0
                    ? const Icon(Icons.archive_outlined)
                    : Badge.count(
                        count: controller.archivedGamesCount,
                        child: const Icon(Icons.archive_outlined),
                      ),
              ),
              const AppLanguageButton(),
              if (hasSearchOrFilters)
                IconButton(
                  tooltip: AppStrings.clearFilters,
                  onPressed: () => _clearAll(controller),
                  icon: const Icon(Icons.filter_alt_off_rounded),
                ),
              const SizedBox(width: 2),
            ],
          ),
          Expanded(
            child: AppPage(
              maxWidth: 1200,
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 12),
              child: Column(
                children: [
                  KeyedSubtree(
                    key: widget.coachFiltersKey,
                    child: _SearchAndFilterRow(
                      searchController: _searchController,
                      onSearchChanged: () => setState(() {}),
                      filters: controller.gameFilters,
                      onCategoryChanged: controller.setCategoryFilter,
                      onModeChanged: controller.setModeFilter,
                      onPoolChanged: controller.setPoolFilter,
                    ),
                  ),
                  const SizedBox(height: 4),
                  SizedBox(
                    height: 30,
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            AppStrings.gameLibrarySummary(
                              games.length,
                              controller.selectedGamesCount,
                              controller.randomPool.length,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                              fontSize: 11.5,
                            ),
                          ),
                        ),
                        PopupMenuButton<_BulkGameAction>(
                          tooltip: AppStrings.bulkActions,
                          padding: EdgeInsets.zero,
                          iconSize: 19,
                          onSelected: (action) => _handleBulkAction(
                            controller,
                            games,
                            action,
                          ),
                          itemBuilder: (context) => [
                            _bulkItem(
                              _BulkGameAction.enableVisible,
                              Icons.checklist_rounded,
                              AppStrings.selectVisible,
                            ),
                            _bulkItem(
                              _BulkGameAction.disableVisible,
                              Icons.remove_done_rounded,
                              AppStrings.deselectVisible,
                            ),
                            _bulkItem(
                              _BulkGameAction.archiveVisible,
                              Icons.archive_outlined,
                              AppStrings.archiveVisibleGames,
                            ),
                            const PopupMenuDivider(),
                            _bulkItem(
                              _BulkGameAction.enableAll,
                              Icons.done_all_rounded,
                              AppStrings.enableAllGames,
                            ),
                            _bulkItem(
                              _BulkGameAction.disableAll,
                              Icons.block_rounded,
                              AppStrings.disableAllGames,
                            ),
                            _bulkItem(
                              _BulkGameAction.archiveDisabled,
                              Icons.inventory_2_outlined,
                              AppStrings.archiveDisabledGames,
                            ),
                          ],
                          icon: const Icon(Icons.more_horiz_rounded),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: KeyedSubtree(
                      key: widget.coachBoardKey,
                      child: games.isEmpty
                          ? _EmptyGames(onClear: () => _clearAll(controller))
                          : LayoutBuilder(
                              builder: (context, constraints) {
                                final columns = switch (constraints.maxWidth) {
                                  < 330 => 3,
                                  < 620 => 4,
                                  < 820 => 5,
                                  < 1040 => 6,
                                  _ => 7,
                                };

                                return CustomScrollView(
                                  keyboardDismissBehavior:
                                      ScrollViewKeyboardDismissBehavior.onDrag,
                                  slivers: _buildGameSlivers(
                                    context: context,
                                    games: games,
                                    columns: columns,
                                  ),
                                );
                              },
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  PopupMenuItem<_BulkGameAction> _bulkItem(
    _BulkGameAction action,
    IconData icon,
    String label,
  ) {
    return PopupMenuItem(
      value: action,
      child: Row(
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 9),
          Text(label),
        ],
      ),
    );
  }

  List<Widget> _buildGameSlivers({
    required BuildContext context,
    required List<Game> games,
    required int columns,
  }) {
    final controller = AppScope.of(context);
    final theme = Theme.of(context);
    final slivers = <Widget>[];

    for (final category in GameCategory.values) {
      final categoryGames = games
          .where((game) => game.category == category)
          .toList(growable: false);
      if (categoryGames.isEmpty) continue;

      slivers.add(
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(2, 5, 2, 5),
            child: Row(
              children: [
                Text(
                  category.label,
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(width: 6),
                _CountBadge(count: categoryGames.length),
              ],
            ),
          ),
        ),
      );
      slivers.add(
        SliverGrid(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            mainAxisSpacing: 6,
            crossAxisSpacing: 6,
            mainAxisExtent: columns <= 3 ? 104 : 98,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final game = categoryGames[index];
              return GameCard(
                game: game,
                selected: controller.isGameSelected(game.id),
                onToggle: () => controller.toggleGame(game.id),
                onAction: (action) => _handleGameAction(context, game, action),
              );
            },
            childCount: categoryGames.length,
          ),
        ),
      );
      slivers.add(const SliverToBoxAdapter(child: SizedBox(height: 5)));
    }

    return slivers;
  }

  Future<void> _handleGameAction(
    BuildContext context,
    Game game,
    GameCardAction action,
  ) async {
    final controller = AppScope.of(context);
    switch (action) {
      case GameCardAction.details:
        await _showGameDetails(context, game);
        break;
      case GameCardAction.edit:
        await _showGameEditor(context, game: game);
        break;
      case GameCardAction.onlyThis:
        await controller.selectOnlyGame(game.id);
        break;
      case GameCardAction.archive:
        await controller.archiveGame(game.id);
        break;
      case GameCardAction.remove:
        await _confirmRemoveGame(context, game);
        break;
    }
  }

  Future<void> _handleBulkAction(
    AppController controller,
    List<Game> visibleGames,
    _BulkGameAction action,
  ) async {
    switch (action) {
      case _BulkGameAction.enableVisible:
        await controller.setVisibleGamesSelected(visibleGames, true);
        break;
      case _BulkGameAction.disableVisible:
        await controller.setVisibleGamesSelected(visibleGames, false);
        break;
      case _BulkGameAction.archiveVisible:
        await controller.archiveGames(visibleGames.map((game) => game.id));
        break;
      case _BulkGameAction.enableAll:
        await controller.setAllGamesSelected(true);
        break;
      case _BulkGameAction.disableAll:
        await controller.setAllGamesSelected(false);
        break;
      case _BulkGameAction.archiveDisabled:
        await controller.archiveDisabledGames();
        break;
    }
  }

  Future<void> _clearAll(AppController controller) async {
    _searchController.clear();
    await controller.clearGameFilters();
    if (mounted) setState(() {});
  }

  Future<void> _showGameEditor(BuildContext context, {Game? game}) {
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (_) => AppBottomSheetSafeArea(
        child: GameEditorSheet(game: game),
      ),
    );
  }

  Future<void> _confirmRemoveGame(BuildContext context, Game game) async {
    final controller = AppScope.of(context);
    final confirmed = await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: Text(AppStrings.removeGameTitle(game.title)),
            content: Text(AppStrings.removeGameWarning),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: Text(AppStrings.cancel),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: Text(AppStrings.removeGame),
              ),
            ],
          ),
        ) ??
        false;

    if (confirmed) {
      await controller.deleteGame(game);
    }
  }

  Future<void> _showGameDetails(BuildContext context, Game game) {
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (_) => AppBottomSheetSafeArea(
        child: _GameDetailsSheet(gameId: game.id),
      ),
    );
  }

  Future<void> _showArchivedGames(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (_) => const AppBottomSheetSafeArea(
        child: _ArchivedGamesSheet(initialIndex: 1),
      ),
    );
  }
}

class _SearchAndFilterRow extends StatelessWidget {
  const _SearchAndFilterRow({
    required this.searchController,
    required this.onSearchChanged,
    required this.filters,
    required this.onCategoryChanged,
    required this.onModeChanged,
    required this.onPoolChanged,
  });

  final TextEditingController searchController;
  final VoidCallback onSearchChanged;
  final GameFilterState filters;
  final ValueChanged<GameCategory?> onCategoryChanged;
  final ValueChanged<GameMode?> onModeChanged;
  final ValueChanged<GamePoolFilter> onPoolChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: searchController,
              onChanged: (_) => onSearchChanged(),
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                isDense: true,
                hintText: AppStrings.searchGames,
                prefixIcon: const Icon(Icons.search_rounded, size: 18),
                prefixIconConstraints: const BoxConstraints(
                  minWidth: 36,
                  minHeight: 38,
                ),
                suffixIcon: searchController.text.isEmpty
                    ? null
                    : IconButton(
                        visualDensity: VisualDensity.compact,
                        onPressed: () {
                          searchController.clear();
                          onSearchChanged();
                        },
                        icon: const Icon(Icons.close_rounded, size: 17),
                      ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 8,
                ),
              ),
            ),
          ),
          const SizedBox(width: 5),
          _FilterMenu<String>(
            tooltip: AppStrings.category,
            icon: Icons.category_outlined,
            active: filters.category != null,
            value: filters.category?.name ?? '__all__',
            items: [
              _FilterMenuItem(value: '__all__', label: AppStrings.allCategories),
              ...GameCategory.values.map(
                (item) => _FilterMenuItem(value: item.name, label: item.label),
              ),
            ],
            onSelected: (value) => onCategoryChanged(
              value == '__all__'
                  ? null
                  : GameCategory.values.firstWhere((item) => item.name == value),
            ),
          ),
          const SizedBox(width: 4),
          _FilterMenu<String>(
            tooltip: AppStrings.playStyle,
            icon: Icons.sports_esports_outlined,
            active: filters.mode != null,
            value: filters.mode?.name ?? '__all__',
            items: [
              _FilterMenuItem(value: '__all__', label: AppStrings.allPlayStyles),
              ...GameMode.values.map(
                (item) => _FilterMenuItem(value: item.name, label: item.label),
              ),
            ],
            onSelected: (value) => onModeChanged(
              value == '__all__'
                  ? null
                  : GameMode.values.firstWhere((item) => item.name == value),
            ),
          ),
          const SizedBox(width: 4),
          _FilterMenu<String>(
            tooltip: AppStrings.poolStatus,
            icon: Icons.tune_rounded,
            active: filters.pool != GamePoolFilter.all,
            value: filters.pool.name,
            items: [
              _FilterMenuItem(
                value: GamePoolFilter.all.name,
                label: AppStrings.allGames,
              ),
              _FilterMenuItem(
                value: GamePoolFilter.selected.name,
                label: AppStrings.selectedGames,
              ),
              _FilterMenuItem(
                value: GamePoolFilter.unselected.name,
                label: AppStrings.unselectedGames,
              ),
            ],
            onSelected: (value) => onPoolChanged(
              GamePoolFilter.values.firstWhere((item) => item.name == value),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterMenu<T> extends StatelessWidget {
  const _FilterMenu({
    required this.tooltip,
    required this.icon,
    required this.active,
    required this.value,
    required this.items,
    required this.onSelected,
  });

  final String tooltip;
  final IconData icon;
  final bool active;
  final T value;
  final List<_FilterMenuItem<T>> items;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return PopupMenuButton<T>(
      tooltip: tooltip,
      initialValue: value,
      onSelected: onSelected,
      itemBuilder: (context) => items
          .map(
            (item) => PopupMenuItem<T>(
              value: item.value,
              child: Row(
                children: [
                  if (item.value == value)
                    const Icon(Icons.check_rounded, size: 17)
                  else
                    const SizedBox(width: 17),
                  const SizedBox(width: 8),
                  Text(item.label),
                ],
              ),
            ),
          )
          .toList(),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: active ? scheme.primaryContainer : scheme.surfaceContainer,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: active
                ? scheme.primary.withValues(alpha: 0.55)
                : scheme.outlineVariant,
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: active ? scheme.primary : scheme.onSurfaceVariant,
            ),
            if (active)
              Positioned(
                top: 5,
                right: 5,
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: scheme.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _FilterMenuItem<T> {
  const _FilterMenuItem({required this.value, required this.label});
  final T value;
  final String label;
}

class _GameDetailsSheet extends StatelessWidget {
  const _GameDetailsSheet({required this.gameId});

  final String gameId;

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    final game = controller.games.firstWhere((item) => item.id == gameId);
    final selected = controller.isGameSelected(game.id);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GameArtwork(
                  game: game,
                  width: 118,
                  height: 82,
                  borderRadius: 18,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        game.title,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        game.playerLabel,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(game.description, style: const TextStyle(height: 1.45)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: game.modes
                  .map(
                    (mode) => Chip(
                      visualDensity: VisualDensity.compact,
                      label: Text(mode.label),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => controller.toggleGame(game.id),
                    icon: Icon(
                      selected ? Icons.remove_rounded : Icons.add_rounded,
                    ),
                    label: Text(
                      selected
                          ? AppStrings.removeFromRandomPool
                          : AppStrings.addToRandomPool,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filledTonal(
                  tooltip: AppStrings.onlyThisGame,
                  onPressed: () async {
                    await controller.selectOnlyGame(game.id);
                    if (context.mounted) Navigator.pop(context);
                  },
                  icon: const Icon(Icons.filter_1_rounded),
                ),
                const SizedBox(width: 6),
                IconButton.filledTonal(
                  tooltip: AppStrings.archiveGame,
                  onPressed: () async {
                    await controller.archiveGame(game.id);
                    if (context.mounted) Navigator.pop(context);
                  },
                  icon: const Icon(Icons.archive_outlined),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ArchivedGamesSheet extends StatefulWidget {
  const _ArchivedGamesSheet({this.initialIndex = 0});

  final int initialIndex;

  @override
  State<_ArchivedGamesSheet> createState() => _ArchivedGamesSheetState();
}

class _ArchivedGamesSheetState extends State<_ArchivedGamesSheet>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final Set<String> _selectedIds = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialIndex < 0
          ? 0
          : widget.initialIndex > 1
              ? 1
              : widget.initialIndex,
    )
      ..addListener(() {
        if (!_tabController.indexIsChanging && mounted) {
          setState(_selectedIds.clear);
        }
      });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  bool get _showArchived => _tabController.index == 1;

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final boardGames = controller.games
        .where((game) => !controller.isGameArchived(game.id))
        .toList(growable: false)
      ..sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
    final archivedGames = controller.archivedGames;
    final visibleGames = _showArchived ? archivedGames : boardGames;

    _selectedIds.removeWhere(
      (id) => !visibleGames.any((game) => game.id == id),
    );

    return FractionallySizedBox(
      heightFactor: 0.84,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: scheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.inventory_2_outlined,
                    color: scheme.onPrimaryContainer,
                    size: 21,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.manageGameBoard,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        AppStrings.manageGameBoardHint,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            TabBar(
              controller: _tabController,
              tabs: [
                Tab(text: AppStrings.onBoardCount(boardGames.length)),
                Tab(text: AppStrings.archivedCount(archivedGames.length)),
              ],
            ),
            const SizedBox(height: 6),
            SizedBox(
              height: 34,
              child: Row(
                children: [
                  Text(
                    AppStrings.selectedCount(_selectedIds.length),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: visibleGames.isEmpty
                        ? null
                        : () => setState(() {
                              _selectedIds
                                ..clear()
                                ..addAll(visibleGames.map((game) => game.id));
                            }),
                    child: Text(AppStrings.selectAll),
                  ),
                  TextButton(
                    onPressed: _selectedIds.isEmpty
                        ? null
                        : () => setState(_selectedIds.clear),
                    child: Text(AppStrings.clearSelection),
                  ),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _ArchiveGameList(
                    games: boardGames,
                    selectedIds: _selectedIds,
                    onToggle: _toggle,
                    emptyLabel: AppStrings.noBoardGames,
                  ),
                  _ArchiveGameList(
                    games: archivedGames,
                    selectedIds: _selectedIds,
                    onToggle: _toggle,
                    emptyLabel: AppStrings.noArchivedGames,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _selectedIds.isEmpty
                    ? null
                    : () async {
                        final ids = _selectedIds.toSet();
                        if (_showArchived) {
                          await controller.unarchiveGames(ids);
                        } else {
                          await controller.archiveGames(ids);
                        }
                        if (mounted) {
                          setState(_selectedIds.clear);
                        }
                      },
                icon: Icon(
                  _showArchived
                      ? Icons.unarchive_rounded
                      : Icons.archive_rounded,
                ),
                label: Text(
                  _showArchived
                      ? AppStrings.restoreSelected(_selectedIds.length)
                      : AppStrings.archiveSelected(_selectedIds.length),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _toggle(String id) {
    setState(() {
      if (!_selectedIds.remove(id)) {
        _selectedIds.add(id);
      }
    });
  }
}

class _ArchiveGameList extends StatelessWidget {
  const _ArchiveGameList({
    required this.games,
    required this.selectedIds,
    required this.onToggle,
    required this.emptyLabel,
  });

  final List<Game> games;
  final Set<String> selectedIds;
  final ValueChanged<String> onToggle;
  final String emptyLabel;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    if (games.isEmpty) {
      return Center(
        child: Text(
          emptyLabel,
          style: TextStyle(color: scheme.onSurfaceVariant),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 720 ? 2 : 1;
        return GridView.builder(
          padding: const EdgeInsets.only(top: 4),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            mainAxisExtent: 58,
            mainAxisSpacing: 6,
            crossAxisSpacing: 6,
          ),
          itemCount: games.length,
          itemBuilder: (context, index) {
            final game = games[index];
            final selected = selectedIds.contains(game.id);
            return Material(
              color: selected
                  ? scheme.primaryContainer.withValues(alpha: 0.35)
                  : scheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(14),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () => onToggle(game.id),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(5, 5, 7, 5),
                  child: Row(
                    children: [
                      GameArtwork(
                        game: game,
                        width: 68,
                        height: 48,
                        borderRadius: 10,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          game.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      Checkbox.adaptive(
                        value: selected,
                        visualDensity: VisualDensity.compact,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        onChanged: (_) => onToggle(game.id),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _CountBadge extends StatelessWidget {
  const _CountBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$count',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: scheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _EmptyGames extends StatelessWidget {
  const _EmptyGames({required this.onClear});

  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 42,
            color: scheme.onSurfaceVariant,
          ),
          const SizedBox(height: 8),
          Text(
            AppStrings.noGamesMatch,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 3),
          Text(
            AppStrings.noGamesMatchHint,
            style: TextStyle(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 10),
          TextButton.icon(
            onPressed: onClear,
            icon: const Icon(Icons.filter_alt_off_rounded),
            label: Text(AppStrings.clearFilters),
          ),
        ],
      ),
    );
  }
}

enum _BulkGameAction {
  enableVisible,
  disableVisible,
  archiveVisible,
  enableAll,
  disableAll,
  archiveDisabled,
}
