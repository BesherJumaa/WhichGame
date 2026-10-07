import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:whichgame/core/constants/app_strings.dart';
import 'package:whichgame/core/theme/app_colors.dart';
import 'package:whichgame/core/widgets/app_page.dart';
import 'package:whichgame/core/widgets/language_button.dart';
import 'package:whichgame/domain/models/team.dart';
import 'package:whichgame/presentation/app_scope.dart';
import 'package:whichgame/presentation/generals/generals_picker_sheet.dart';

class TeamsScreen extends StatefulWidget {
  const TeamsScreen({
    this.coachBuilderKey,
    this.coachGeneralsKey,
    super.key,
  });

  final GlobalKey? coachBuilderKey;
  final GlobalKey? coachGeneralsKey;

  @override
  State<TeamsScreen> createState() => _TeamsScreenState();
}

class _TeamsScreenState extends State<TeamsScreen> {
  int _teamCount = 2;
  List<Team> _teams = const [];
  String _playerSignature = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final players = AppScope.of(context).activePlayers;
    final signature = players.map((player) => player.id).join('|');
    if (_playerSignature.isNotEmpty && signature != _playerSignature) {
      _teams = const [];
    }
    _playerSignature = signature;

    final maxTeams = _maxTeams(players.length);
    if (_teamCount > maxTeams && maxTeams >= 2) {
      _teamCount = maxTeams;
    }
  }

  int _maxTeams(int playerCount) => playerCount.clamp(2, 6).toInt();

  void _generate() {
    final controller = AppScope.of(context);
    if (controller.activePlayers.length < _teamCount) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.selectAtLeastPlayers(_teamCount))),
      );
      return;
    }

    HapticFeedback.mediumImpact();
    setState(() => _teams = controller.generateTeams(_teamCount));
  }

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    final players = controller.activePlayers;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final maxTeams = _maxTeams(players.length);

    return SafeArea(
      child: Column(
        children: [
          AppBar(
            title: Text(AppStrings.teamBuilder),
            actions: const [AppLanguageButton(), SizedBox(width: 4)],
          ),
          Expanded(
            child: AppPage(
              child: ListView(
                children: [
                  KeyedSubtree(
                    key: widget.coachBuilderKey,
                    child: Container(
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.teamHeroStart,
                          AppColors.teamHeroEnd,
                        ],
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.groups_2_rounded,
                              color: AppColors.accent,
                              size: 32,
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                AppStrings.fairTeamsTitle,
                                style: TextStyle(
                                  color: AppColors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          AppStrings.selectedPlayers(players.length),
                          style: const TextStyle(
                            color: AppColors.white70,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 22),
                        Text(
                          AppStrings.numberOfTeams,
                          style: TextStyle(
                            color: AppColors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (var count = 2; count <= maxTeams; count++)
                              ChoiceChip(
                                label: Text('$count'),
                                selected: _teamCount == count,
                                onSelected: players.length >= count
                                    ? (selected) => setState(() {
                                          _teamCount = count;
                                          _teams = const [];
                                        })
                                    : null,
                              ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: players.length >= _teamCount
                                ? _generate
                                : null,
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.accent,
                              foregroundColor: AppColors.black,
                            ),
                            icon: const Icon(Icons.shuffle_rounded),
                            label: Text(
                              _teams.isEmpty
                                  ? AppStrings.generateTeams
                                  : AppStrings.shuffleAgain,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        KeyedSubtree(
                          key: widget.coachGeneralsKey,
                          child: SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: players.length >= 2
                                  ? () => showGeneralsPicker(context)
                                  : null,
                              icon: const Icon(Icons.casino_rounded),
                              label: Text(AppStrings.openGeneralsPicker),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  ),
                  const SizedBox(height: 20),
                  if (players.length < 2)
                    _NeedPlayers()
                  else if (_teams.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: scheme.surfaceContainer,
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            color: scheme.primary,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(AppStrings.teamBuilderHint),
                          ),
                        ],
                      ),
                    )
                  else
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 350),
                      child: _TeamGrid(
                        key: ValueKey(
                          _teams
                              .map(
                                (team) => team.players
                                    .map((player) => player.id)
                                    .join(),
                              )
                              .join('|'),
                        ),
                        teams: _teams,
                      ),
                    ),
                  const SizedBox(height: 22),
                  Text(
                    AppStrings.teamRatingsNext,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
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
}

class _TeamGrid extends StatelessWidget {
  const _TeamGrid({required this.teams, super.key});

  final List<Team> teams;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 850
            ? 3
            : constraints.maxWidth >= 560
                ? 2
                : 1;
        const spacing = 12.0;
        final width =
            (constraints.maxWidth - spacing * (columns - 1)) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: teams
              .map(
                (team) => SizedBox(
                  width: width,
                  child: _TeamCard(team: team),
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class _TeamCard extends StatelessWidget {
  const _TeamCard({required this.team});

  final Team team;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final accent = [
      scheme.primary,
      scheme.tertiary,
      AppColors.cyan,
      AppColors.accent,
      scheme.secondary,
      AppColors.orange,
    ][(team.index - 1) % 6];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainer,
        borderRadius: BorderRadius.circular(22),
        border: Border(top: BorderSide(color: accent, width: 3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${team.index}',
                  style: TextStyle(
                    color: accent,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                AppStrings.teamLabel(team.index),
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const Spacer(),
              Text(
                '${team.players.length}',
                style: TextStyle(
                  color: scheme.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...team.players.map(
            (player) => Padding(
              padding: const EdgeInsets.only(bottom: 7),
              child: Row(
                children: [
                  Icon(
                    player.isGuest
                        ? Icons.person_outline_rounded
                        : Icons.person_rounded,
                    size: 18,
                    color: accent,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      player.name,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                  if (player.isGuest)
                    Text(
                      AppStrings.guest,
                      style: TextStyle(
                        fontSize: 11,
                        color: scheme.onSurfaceVariant,
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
}

class _NeedPlayers extends StatelessWidget {
  _NeedPlayers();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        color: scheme.surfaceContainer,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: [
          Icon(
            Icons.group_add_outlined,
            size: 48,
            color: scheme.onSurfaceVariant,
          ),
          const SizedBox(height: 10),
          Text(
            AppStrings.selectAtLeastTwoPlayers,
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 4),
          Text(
            AppStrings.selectPlayersHint,
            textAlign: TextAlign.center,
            style: TextStyle(color: scheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
