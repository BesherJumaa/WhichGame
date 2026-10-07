import 'dart:async';

import 'package:flutter/material.dart';
import 'package:whichgame/core/constants/app_strings.dart';
import 'package:whichgame/core/widgets/app_coach_mark.dart';
import 'package:whichgame/presentation/about/about_sheet.dart';
import 'package:whichgame/presentation/app_scope.dart';
import 'package:whichgame/presentation/coach/coach_tour_scope.dart';
import 'package:whichgame/presentation/games/games_screen.dart';
import 'package:whichgame/presentation/play/play_screen.dart';
import 'package:whichgame/presentation/players/players_screen.dart';
import 'package:whichgame/presentation/teams/teams_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;
  int? _coachStepIndex;
  bool _checkedAutomaticTour = false;

  final _playHeroKey = GlobalKey(debugLabel: 'coach-play-hero');
  final _playQuickActionsKey = GlobalKey(debugLabel: 'coach-play-actions');
  final _languageKey = GlobalKey(debugLabel: 'coach-language');
  final _gamesFiltersKey = GlobalKey(debugLabel: 'coach-games-filters');
  final _gamesBoardKey = GlobalKey(debugLabel: 'coach-games-board');
  final _gamesArchiveKey = GlobalKey(debugLabel: 'coach-games-archive');
  final _playersRosterKey = GlobalKey(debugLabel: 'coach-players-roster');
  final _playersArchiveKey = GlobalKey(debugLabel: 'coach-players-archive');
  final _teamsBuilderKey = GlobalKey(debugLabel: 'coach-teams-builder');
  final _generalsKey = GlobalKey(debugLabel: 'coach-generals');
  final _navigationKey = GlobalKey(debugLabel: 'coach-navigation');

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = <Widget>[
      PlayScreen(
        onOpenGames: () => _select(1),
        onOpenTeams: () => _select(3),
        coachHeroKey: _playHeroKey,
        coachQuickActionsKey: _playQuickActionsKey,
        coachLanguageKey: _languageKey,
      ),
      GamesScreen(
        coachFiltersKey: _gamesFiltersKey,
        coachBoardKey: _gamesBoardKey,
        coachArchiveKey: _gamesArchiveKey,
      ),
      PlayersScreen(
        coachRosterKey: _playersRosterKey,
        coachArchiveKey: _playersArchiveKey,
      ),
      TeamsScreen(
        coachBuilderKey: _teamsBuilderKey,
        coachGeneralsKey: _generalsKey,
      ),
    ];
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_checkedAutomaticTour) {
      return;
    }
    _checkedAutomaticTour = true;

    if (!AppScope.read(context).shouldShowCoachTour) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _startCoachTour();
    });
  }

  List<_Destination> get _destinations => [
        _Destination(AppStrings.play, Icons.casino_outlined, Icons.casino_rounded),
        _Destination(AppStrings.games, Icons.grid_view_outlined, Icons.grid_view_rounded),
        _Destination(AppStrings.players, Icons.people_outline_rounded, Icons.people_rounded),
        _Destination(AppStrings.teams, Icons.groups_outlined, Icons.groups_rounded),
      ];

  List<_CoachTourStep> get _coachSteps => [
        _CoachTourStep(
          tabIndex: 0,
          data: AppCoachStep(
            title: AppStrings.coachWelcomeTitle,
            description: AppStrings.coachWelcomeDescription,
            icon: Icons.sports_esports_rounded,
          ),
        ),
        _CoachTourStep(
          tabIndex: 0,
          data: AppCoachStep(
            title: AppStrings.coachPlayTitle,
            description: AppStrings.coachPlayDescription,
            icon: Icons.casino_rounded,
            targetKey: _playHeroKey,
          ),
        ),
        _CoachTourStep(
          tabIndex: 0,
          data: AppCoachStep(
            title: AppStrings.coachQuickActionsTitle,
            description: AppStrings.coachQuickActionsDescription,
            icon: Icons.bolt_rounded,
            targetKey: _playQuickActionsKey,
          ),
        ),
        _CoachTourStep(
          tabIndex: 1,
          data: AppCoachStep(
            title: AppStrings.coachGameFiltersTitle,
            description: AppStrings.coachGameFiltersDescription,
            icon: Icons.tune_rounded,
            targetKey: _gamesFiltersKey,
          ),
        ),
        _CoachTourStep(
          tabIndex: 1,
          data: AppCoachStep(
            title: AppStrings.coachGameBoardTitle,
            description: AppStrings.coachGameBoardDescription,
            icon: Icons.grid_view_rounded,
            targetKey: _gamesBoardKey,
          ),
        ),
        _CoachTourStep(
          tabIndex: 1,
          data: AppCoachStep(
            title: AppStrings.coachGameArchiveTitle,
            description: AppStrings.coachGameArchiveDescription,
            icon: Icons.archive_rounded,
            targetKey: _gamesArchiveKey,
          ),
        ),
        _CoachTourStep(
          tabIndex: 2,
          data: AppCoachStep(
            title: AppStrings.coachPlayersTitle,
            description: AppStrings.coachPlayersDescription,
            icon: Icons.people_alt_rounded,
            targetKey: _playersRosterKey,
          ),
        ),
        _CoachTourStep(
          tabIndex: 2,
          data: AppCoachStep(
            title: AppStrings.coachPlayerArchiveTitle,
            description: AppStrings.coachPlayerArchiveDescription,
            icon: Icons.inventory_2_rounded,
            targetKey: _playersArchiveKey,
          ),
        ),
        _CoachTourStep(
          tabIndex: 3,
          data: AppCoachStep(
            title: AppStrings.coachTeamsTitle,
            description: AppStrings.coachTeamsDescription,
            icon: Icons.groups_2_rounded,
            targetKey: _teamsBuilderKey,
          ),
        ),
        _CoachTourStep(
          tabIndex: 3,
          data: AppCoachStep(
            title: AppStrings.coachGeneralsTitle,
            description: AppStrings.coachGeneralsDescription,
            icon: Icons.casino_rounded,
            targetKey: _generalsKey,
          ),
        ),
        _CoachTourStep(
          tabIndex: 0,
          data: AppCoachStep(
            title: AppStrings.coachLanguageTitle,
            description: AppStrings.coachLanguageDescription,
            icon: Icons.language_rounded,
            targetKey: _languageKey,
          ),
        ),
        _CoachTourStep(
          tabIndex: 0,
          data: AppCoachStep(
            title: AppStrings.coachNavigationTitle,
            description: AppStrings.coachNavigationDescription,
            icon: Icons.space_dashboard_rounded,
            targetKey: _navigationKey,
          ),
        ),
      ];

  void _select(int value) {
    if (_coachStepIndex != null) {
      return;
    }
    setState(() => _index = value);
  }

  void _startCoachTour() {
    _showCoachStep(0);
  }

  void _showCoachStep(int index) {
    final steps = _coachSteps;
    if (index < 0 || index >= steps.length) {
      _finishCoachTour();
      return;
    }

    final step = steps[index];
    setState(() {
      _index = step.tabIndex;
      _coachStepIndex = index;
    });
  }

  void _nextCoachStep() {
    final current = _coachStepIndex;
    if (current == null) {
      return;
    }
    if (current >= _coachSteps.length - 1) {
      _finishCoachTour();
      return;
    }
    _showCoachStep(current + 1);
  }

  void _previousCoachStep() {
    final current = _coachStepIndex;
    if (current == null || current <= 0) {
      return;
    }
    _showCoachStep(current - 1);
  }

  void _finishCoachTour() {
    if (!mounted) {
      return;
    }
    setState(() => _coachStepIndex = null);
    unawaited(AppScope.read(context).completeCoachTour());
  }

  @override
  Widget build(BuildContext context) {
    // Register a locale dependency so navigation labels and coach copy update
    // immediately when switching English/Arabic.
    Localizations.localeOf(context);
    final destinations = _destinations;

    return CoachTourScope(
      startTour: _startCoachTour,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final useRail = constraints.maxWidth >= 900;
          final currentPage = KeyedSubtree(
            key: ValueKey(_index),
            child: _pages[_index],
          );
          final content = _coachStepIndex != null
              ? currentPage
              : AnimatedSwitcher(
                  duration: const Duration(milliseconds: 260),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  transitionBuilder: (child, animation) => FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.015, 0),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  ),
                  child: currentPage,
                );

          final Widget scaffold;
          if (useRail) {
            scaffold = Scaffold(
              body: Row(
                children: [
                  SafeArea(
                    child: NavigationRail(
                      key: _navigationKey,
                      selectedIndex: _index,
                      onDestinationSelected: _select,
                      extended: constraints.maxWidth >= 1180,
                      leading: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        child: IconButton.filledTonal(
                          tooltip: AppStrings.aboutTooltip,
                          onPressed: () => showAboutWhichGame(
                            context,
                            onStartTour: _startCoachTour,
                          ),
                          icon: const Icon(Icons.sports_esports_rounded),
                        ),
                      ),
                      destinations: destinations
                          .map(
                            (item) => NavigationRailDestination(
                              icon: Icon(item.icon),
                              selectedIcon: Icon(item.selectedIcon),
                              label: Text(item.label),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  const VerticalDivider(width: 1),
                  Expanded(child: content),
                ],
              ),
            );
          } else {
            scaffold = Scaffold(
              body: content,
              bottomNavigationBar: NavigationBar(
                key: _navigationKey,
                selectedIndex: _index,
                onDestinationSelected: _select,
                destinations: destinations
                    .map(
                      (item) => NavigationDestination(
                        icon: Icon(item.icon),
                        selectedIcon: Icon(item.selectedIcon),
                        label: item.label,
                      ),
                    )
                    .toList(),
              ),
            );
          }

          final coachIndex = _coachStepIndex;
          if (coachIndex == null) {
            return scaffold;
          }

          final steps = _coachSteps;
          final step = steps[coachIndex];
          return Stack(
            fit: StackFit.expand,
            children: [
              scaffold,
              AppCoachMarkOverlay(
                step: step.data,
                stepIndex: coachIndex,
                stepCount: steps.length,
                onNext: _nextCoachStep,
                onBack: coachIndex == 0 ? null : _previousCoachStep,
                onSkip: _finishCoachTour,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CoachTourStep {
  const _CoachTourStep({required this.tabIndex, required this.data});

  final int tabIndex;
  final AppCoachStep data;
}

class _Destination {
  const _Destination(this.label, this.icon, this.selectedIcon);

  final String label;
  final IconData icon;
  final IconData selectedIcon;
}
