import 'package:flutter/material.dart';
import 'package:whichgame/core/constants/app_strings.dart';

/// The old team drawer was replaced by the dedicated Players and Teams tabs.
/// This widget remains only so stale external imports do not break immediately.
@Deprecated('Use PlayersScreen and TeamsScreen instead.')
class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key, this.notes = const []});

  final List<String> notes;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(AppStrings.legacyTeamToolsMoved),
        ),
      ),
    );
  }
}
