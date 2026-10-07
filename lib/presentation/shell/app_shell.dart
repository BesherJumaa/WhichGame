import 'package:flutter/material.dart';
import 'package:whichgame/core/constants/app_strings.dart';
import 'package:whichgame/presentation/about/about_sheet.dart';
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

  List<_Destination> get _destinations => [
        _Destination(AppStrings.play, Icons.casino_outlined, Icons.casino_rounded),
        _Destination(AppStrings.games, Icons.grid_view_outlined, Icons.grid_view_rounded),
        _Destination(AppStrings.players, Icons.people_outline_rounded, Icons.people_rounded),
        _Destination(AppStrings.teams, Icons.groups_outlined, Icons.groups_rounded),
      ];

  late final _pages = <Widget>[
    PlayScreen(onOpenGames: () => _select(1), onOpenTeams: () => _select(3)),
    const GamesScreen(),
    const PlayersScreen(),
    const TeamsScreen(),
  ];

  void _select(int value) => setState(() => _index = value);

  @override
  Widget build(BuildContext context) {
    // Register a locale dependency so navigation labels update immediately
    // when switching English/Arabic without recreating the shell state.
    Localizations.localeOf(context);
    final destinations = _destinations;

    return LayoutBuilder(
      builder: (context, constraints) {
        final useRail = constraints.maxWidth >= 900;
        final content = AnimatedSwitcher(
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
          child: KeyedSubtree(key: ValueKey(_index), child: _pages[_index]),
        );

        if (useRail) {
          return Scaffold(
            body: Row(
              children: [
                SafeArea(
                  child: NavigationRail(
                    selectedIndex: _index,
                    onDestinationSelected: _select,
                    extended: constraints.maxWidth >= 1180,
                    leading: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: IconButton.filledTonal(
                        tooltip: AppStrings.aboutTooltip,
                        onPressed: () => showAboutWhichGame(context),
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
        }

        return Scaffold(
          body: content,
          bottomNavigationBar: NavigationBar(
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
      },
    );
  }
}

class _Destination {
  const _Destination(this.label, this.icon, this.selectedIcon);

  final String label;
  final IconData icon;
  final IconData selectedIcon;
}
