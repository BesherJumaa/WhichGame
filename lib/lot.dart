import 'package:flutter/material.dart';
import 'package:whichgame/presentation/teams/teams_screen.dart';

/// Legacy screen name retained for source compatibility.
@Deprecated('Use TeamsScreen instead.')
class Lot extends StatelessWidget {
  const Lot({super.key});

  @override
  Widget build(BuildContext context) => const TeamsScreen();
}
