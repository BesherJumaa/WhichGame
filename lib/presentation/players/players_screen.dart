import 'package:flutter/material.dart';
import 'package:whichgame/core/constants/app_strings.dart';
import 'package:whichgame/core/theme/app_colors.dart';
import 'package:whichgame/core/widgets/app_bottom_sheet_safe_area.dart';
import 'package:whichgame/core/widgets/app_page.dart';
import 'package:whichgame/core/widgets/language_button.dart';
import 'package:whichgame/domain/models/player_profile.dart';
import 'package:whichgame/presentation/app_scope.dart';
import 'package:whichgame/presentation/players/widgets/player_editor_sheet.dart';

class PlayersScreen extends StatelessWidget {
  const PlayersScreen({
    this.coachRosterKey,
    this.coachArchiveKey,
    super.key,
  });

  final GlobalKey? coachRosterKey;
  final GlobalKey? coachArchiveKey;

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    final permanent = controller.permanentPlayers;
    final guests = controller.guestPlayers;

    return SafeArea(
      child: Column(
        children: [
          AppBar(
            title: Text(AppStrings.players),
            actions: [
              IconButton(
                key: coachArchiveKey,
                tooltip: AppStrings.managePlayerArchive,
                onPressed: () => _showPlayerArchiveManager(context),
                icon: controller.archivedPlayersCount == 0
                    ? const Icon(Icons.archive_outlined)
                    : Badge.count(
                        count: controller.archivedPlayersCount,
                        child: const Icon(Icons.archive_outlined),
                      ),
              ),
              const AppLanguageButton(),
              IconButton.filledTonal(
                tooltip: AppStrings.addPlayer,
                onPressed: () => _addPlayer(context),
                icon: const Icon(Icons.person_add_alt_1_rounded),
              ),
              PopupMenuButton<_PlayerBulkAction>(
                tooltip: AppStrings.bulkActions,
                onSelected: (action) {
                  if (action == _PlayerBulkAction.selectAll) {
                    controller.setAllPermanentPlayersActive(true);
                  } else if (action == _PlayerBulkAction.deselectAll) {
                    controller.setAllPermanentPlayersActive(false);
                  } else {
                    controller.clearGuests();
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: _PlayerBulkAction.selectAll,
                    child: Text(AppStrings.selectAllSavedPlayers),
                  ),
                  PopupMenuItem(
                    value: _PlayerBulkAction.deselectAll,
                    child: Text(AppStrings.deselectAllSavedPlayers),
                  ),
                  if (guests.isNotEmpty)
                    PopupMenuItem(
                      value: _PlayerBulkAction.clearGuests,
                      child: Text(AppStrings.clearAllGuests),
                    ),
                ],
                icon: const Icon(Icons.more_vert_rounded),
              ),
              const SizedBox(width: 6),
            ],
          ),
          Expanded(
            child: AppPage(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 18),
              child: ListView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                children: [
                  KeyedSubtree(
                    key: coachRosterKey,
                    child: _PlayerSummary(
                      active: controller.activePlayers.length,
                      permanent: permanent.length,
                      guests: guests.length,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _SectionTitle(
                    title: AppStrings.savedPlayers,
                    subtitle: AppStrings.cachedOnDevice,
                    count: permanent.length,
                  ),
                  const SizedBox(height: 7),
                  if (permanent.isEmpty)
                    _EmptyPlayers(onAdd: () => _addPlayer(context))
                  else
                    ...permanent.map(
                      (player) => Padding(
                        padding: const EdgeInsets.only(bottom: 7),
                        child: _PlayerCard(player: player),
                      ),
                    ),
                  if (guests.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    _SectionTitle(
                      title: AppStrings.guests,
                      subtitle: AppStrings.guestsSessionOnly,
                      count: guests.length,
                    ),
                    const SizedBox(height: 7),
                    ...guests.map(
                      (player) => Padding(
                        padding: const EdgeInsets.only(bottom: 7),
                        child: _PlayerCard(player: player),
                      ),
                    ),
                  ],
                  const SizedBox(height: 6),
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: TextButton.icon(
                      onPressed: () => _addPlayer(context, permanent: false),
                      icon: const Icon(Icons.person_add_alt_rounded, size: 18),
                      label: Text(AppStrings.quickAddGuest),
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

  Future<void> _addPlayer(BuildContext context, {bool? permanent}) async {
    final result = await showPlayerEditorSheet(context);
    if (result == null || !context.mounted) {
      return;
    }
    await AppScope.of(context).addPlayer(
      name: result.name,
      permanent: permanent ?? result.permanent,
    );
  }

  Future<void> _showPlayerArchiveManager(BuildContext context) {
    final initialIndex = AppScope.of(context).archivedPlayersCount > 0 ? 1 : 0;
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (_) => AppBottomSheetSafeArea(
        child: _PlayerArchiveManagerSheet(initialIndex: initialIndex),
      ),
    );
  }
}

class _PlayerSummary extends StatelessWidget {
  const _PlayerSummary({
    required this.active,
    required this.permanent,
    required this.guests,
  });

  final int active;
  final int permanent;
  final int guests;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.7)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: scheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.groups_2_rounded,
              color: scheme.onPrimaryContainer,
              size: 22,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.activePlayersReady(active),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  AppStrings.savedAndGuestPlayers(permanent, guests),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: scheme.onSurfaceVariant,
                    fontSize: 11.5,
                  ),
                ),
              ],
            ),
          ),
          Tooltip(
            message: AppStrings.rosterHint,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Icon(
                Icons.info_outline_rounded,
                size: 19,
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.title,
    required this.subtitle,
    required this.count,
  });

  final String title;
  final String subtitle;
  final int count;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(width: 7),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            '$count',
            style: const TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.end,
            style: TextStyle(
              color: scheme.onSurfaceVariant,
              fontSize: 11,
            ),
          ),
        ),
      ],
    );
  }
}

class _PlayerCard extends StatelessWidget {
  const _PlayerCard({required this.player});

  final PlayerProfile player;

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    final selected = controller.activePlayerIds.contains(player.id);
    final scheme = Theme.of(context).colorScheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 170),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: selected
            ? scheme.primaryContainer.withValues(alpha: 0.2)
            : scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: selected
              ? scheme.primary.withValues(alpha: 0.55)
              : scheme.outlineVariant.withValues(alpha: 0.72),
        ),
      ),
      child: Material(
        color: AppColors.transparent,
        borderRadius: BorderRadius.circular(15),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => controller.togglePlayerActive(player.id),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 7, 4, 7),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 19,
                  backgroundColor: player.isGuest
                      ? scheme.tertiaryContainer
                      : scheme.primaryContainer,
                  foregroundColor: player.isGuest
                      ? scheme.onTertiaryContainer
                      : scheme.onPrimaryContainer,
                  child: Text(
                    player.name.isEmpty
                        ? '?'
                        : player.name.substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              player.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          if (player.isGuest) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.accent.withValues(alpha: 0.14),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                AppStrings.guestBadge,
                                style: TextStyle(
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.accent,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        selected
                            ? AppStrings.includedInTeams
                            : AppStrings.notPlayingThisSession,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: scheme.onSurfaceVariant,
                          fontSize: 10.5,
                        ),
                      ),
                    ],
                  ),
                ),
                Checkbox.adaptive(
                  value: selected,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                  onChanged: (_) => controller.togglePlayerActive(player.id),
                ),
                SizedBox(
                  width: 36,
                  height: 36,
                  child: PopupMenuButton<_PlayerAction>(
                    padding: EdgeInsets.zero,
                    iconSize: 19,
                    onSelected: (action) async {
                      if (action == _PlayerAction.edit) {
                        final result = await showPlayerEditorSheet(
                          context,
                          player: player,
                        );
                        if (result != null && context.mounted) {
                          await AppScope.of(context).updatePlayer(
                            player: player,
                            name: result.name,
                            permanent: result.permanent,
                          );
                        }
                        return;
                      }
                      if (action == _PlayerAction.archive) {
                        await controller.archivePlayer(player.id);
                        return;
                      }
                      if (context.mounted) {
                        await _confirmDelete(context, player);
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: _PlayerAction.edit,
                        child: Text(AppStrings.edit),
                      ),
                      if (!player.isGuest)
                        PopupMenuItem(
                          value: _PlayerAction.archive,
                          child: Text(AppStrings.archive),
                        ),
                      PopupMenuItem(
                        value: _PlayerAction.delete,
                        child: Text(AppStrings.delete),
                      ),
                    ],
                    icon: const Icon(Icons.more_vert_rounded),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, PlayerProfile player) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppStrings.deletePlayerTitle(player.name)),
        content: Text(
          player.isGuest
              ? AppStrings.deleteGuestHint
              : AppStrings.deletePermanentHint,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(AppStrings.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: AppColors.white,
            ),
            child: Text(AppStrings.delete),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await AppScope.of(context).deletePlayer(player);
    }
  }
}

class _PlayerArchiveManagerSheet extends StatefulWidget {
  const _PlayerArchiveManagerSheet({this.initialIndex = 0});

  final int initialIndex;

  @override
  State<_PlayerArchiveManagerSheet> createState() =>
      _PlayerArchiveManagerSheetState();
}

class _PlayerArchiveManagerSheetState
    extends State<_PlayerArchiveManagerSheet>
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
    final roster = controller.permanentPlayers;
    final archived = controller.archivedPlayers;
    final visible = _showArchived ? archived : roster;

    _selectedIds.removeWhere(
      (id) => !visible.any((player) => player.id == id),
    );

    return FractionallySizedBox(
      heightFactor: 0.82,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
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
                    Icons.manage_accounts_outlined,
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
                        AppStrings.managePlayerArchive,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        AppStrings.managePlayerArchiveHint,
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
                Tab(text: AppStrings.rosterCount(roster.length)),
                Tab(text: AppStrings.archivedPlayersCount(archived.length)),
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
                    onPressed: visible.isEmpty
                        ? null
                        : () => setState(() {
                              _selectedIds
                                ..clear()
                                ..addAll(visible.map((player) => player.id));
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
                  _ArchivePlayerList(
                    players: roster,
                    selectedIds: _selectedIds,
                    onToggle: _toggle,
                    emptyLabel: AppStrings.noSavedPlayers,
                  ),
                  _ArchivePlayerList(
                    players: archived,
                    selectedIds: _selectedIds,
                    onToggle: _toggle,
                    emptyLabel: AppStrings.noArchivedPlayers,
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
                          await controller.unarchivePlayers(ids);
                        } else {
                          await controller.archivePlayers(ids);
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

class _ArchivePlayerList extends StatelessWidget {
  const _ArchivePlayerList({
    required this.players,
    required this.selectedIds,
    required this.onToggle,
    required this.emptyLabel,
  });

  final List<PlayerProfile> players;
  final Set<String> selectedIds;
  final ValueChanged<String> onToggle;
  final String emptyLabel;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    if (players.isEmpty) {
      return Center(
        child: Text(
          emptyLabel,
          style: TextStyle(color: scheme.onSurfaceVariant),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.only(top: 4),
      itemCount: players.length,
      separatorBuilder: (context, index) => const SizedBox(height: 5),
      itemBuilder: (context, index) {
        final player = players[index];
        final selected = selectedIds.contains(player.id);
        return Material(
          color: selected
              ? scheme.primaryContainer.withValues(alpha: 0.35)
              : scheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(14),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => onToggle(player.id),
            child: SizedBox(
              height: 54,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 5, 4, 5),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: scheme.primaryContainer,
                      foregroundColor: scheme.onPrimaryContainer,
                      child: Text(
                        player.name.trim().isEmpty
                            ? '?'
                            : player.name.trim().characters.first.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Text(
                        player.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Checkbox.adaptive(
                      value: selected,
                      visualDensity: VisualDensity.compact,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      onChanged: (_) => onToggle(player.id),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _EmptyPlayers extends StatelessWidget {
  const _EmptyPlayers({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.7)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.person_add_alt_1_rounded,
            size: 30,
            color: scheme.onSurfaceVariant,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.buildPlayerCache,
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
                SizedBox(height: 2),
                Text(
                  AppStrings.buildPlayerCacheHint,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 11.5),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          FilledButton.tonal(
            onPressed: onAdd,
            child: Text(AppStrings.add),
          ),
        ],
      ),
    );
  }
}

enum _PlayerAction { edit, archive, delete }
enum _PlayerBulkAction { selectAll, deselectAll, clearGuests }
