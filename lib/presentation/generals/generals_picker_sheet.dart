import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:whichgame/core/constants/app_strings.dart';
import 'package:whichgame/core/widgets/app_bottom_sheet_safe_area.dart';
import 'package:whichgame/domain/models/generals_faction.dart';
import 'package:whichgame/domain/models/player_profile.dart';
import 'package:whichgame/domain/services/generals_picker_service.dart';
import 'package:whichgame/presentation/app_scope.dart';

Future<void> showGeneralsPicker(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    useSafeArea: true,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => const AppBottomSheetSafeArea(
      child: GeneralsPickerSheet(),
    ),
  );
}

class GeneralsPickerSheet extends StatefulWidget {
  const GeneralsPickerSheet({super.key});

  @override
  State<GeneralsPickerSheet> createState() => _GeneralsPickerSheetState();
}

class _GeneralsPickerSheetState extends State<GeneralsPickerSheet> {
  static const Duration _rollDuration = Duration(seconds: 3);
  static const Duration _rollStep = Duration(milliseconds: 110);

  List<GeneralsAssignment> _assignments = const [];
  Timer? _rollTimer;
  int _rollTick = 0;
  bool _rolling = false;
  bool _didPrecacheFactions = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final players = AppScope.of(context).activePlayers;
      if (players.length >= 2) {
        _start();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didPrecacheFactions) return;

    _didPrecacheFactions = true;
    for (final faction in GeneralsFaction.values) {
      precacheImage(AssetImage(faction.assetPath), context);
    }
  }

  @override
  void dispose() {
    _rollTimer?.cancel();
    super.dispose();
  }

  void _start() {
    final controller = AppScope.of(context);
    if (controller.activePlayers.length < 2) {
      return;
    }

    _rollTimer?.cancel();
    final startedAt = DateTime.now();

    HapticFeedback.selectionClick();
    setState(() {
      _assignments = controller.generateGeneralsAssignments();
      _rolling = true;
      _rollTick = 0;
    });

    _rollTimer = Timer.periodic(_rollStep, (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (DateTime.now().difference(startedAt) >= _rollDuration) {
        timer.cancel();
        _rollTimer = null;
        setState(() => _rolling = false);
        HapticFeedback.mediumImpact();
        return;
      }

      setState(() => _rollTick++);
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    final players = controller.activePlayers;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final maxHeight = MediaQuery.sizeOf(context).height * 0.78;

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: scheme.primaryContainer,
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(Icons.casino_rounded, color: scheme.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.generalsFactionPicker,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        AppStrings.generalsFactionPickerDescription,
                        maxLines: 2,
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
            const SizedBox(height: 14),
            if (players.length < 2)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 28),
                child: Column(
                  children: [
                    Icon(
                      Icons.people_outline_rounded,
                      size: 42,
                      color: scheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      AppStrings.generalsNeedsPlayers,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
            else ...[
              Container(
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Icon(
                      _rolling
                          ? Icons.autorenew_rounded
                          : Icons.check_circle_rounded,
                      size: 19,
                      color: _rolling ? scheme.primary : scheme.tertiary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _rolling
                            ? AppStrings.rollingArmies
                            : AppStrings.generalsResults,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                    if (_rolling)
                      SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          color: scheme.primary,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: players.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 7),
                  itemBuilder: (context, index) {
                    final player = players[index];
                    final faction =
                        _displayFaction(player, index, _rollTick);
                    return _AssignmentRow(
                      player: player,
                      faction: faction,
                      rolling: _rolling,
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: FilledButton(
                  onPressed: _rolling ? null : _start,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.shuffle_rounded),
                        const SizedBox(width: 8),
                        Text(
                          _assignments.isEmpty
                              ? AppStrings.assignArmies
                              : AppStrings.assignAgain,
                          maxLines: 1,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            height: 1.15,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  GeneralsFaction _displayFaction(
    PlayerProfile player,
    int index,
    int tick,
  ) {
    if (_rolling || _assignments.isEmpty) {
      return GeneralsFaction.values[(tick + index * 3) % GeneralsFaction.values.length];
    }

    for (final assignment in _assignments) {
      if (assignment.player.id == player.id) {
        return assignment.faction;
      }
    }
    return GeneralsFaction.values[index % GeneralsFaction.values.length];
  }
}

class _AssignmentRow extends StatelessWidget {
  const _AssignmentRow({
    required this.player,
    required this.faction,
    required this.rolling,
  });

  final PlayerProfile player;
  final GeneralsFaction faction;
  final bool rolling;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      height: 78,
      padding: const EdgeInsetsDirectional.fromSTEB(10, 6, 8, 6),
      decoration: BoxDecoration(
        color: rolling
            ? scheme.surfaceContainerLow
            : scheme.primaryContainer.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: rolling
              ? scheme.outlineVariant.withValues(alpha: 0.7)
              : scheme.primary.withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: scheme.primaryContainer,
            child: Text(
              player.name.trim().isEmpty
                  ? '?'
                  : player.name.trim().characters.first.toUpperCase(),
              style: TextStyle(
                color: scheme.onPrimaryContainer,
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
              textAlign: TextAlign.start,
              style: const TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Tooltip(
            message: faction.label,
            child: Semantics(
              label: faction.label,
              image: true,
              child: SizedBox(
                width: 62,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 50,
                      height: 48,
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: scheme.surfaceContainerHighest
                            .withValues(alpha: 0.55),
                        borderRadius: BorderRadius.circular(11),
                      ),
                      alignment: Alignment.center,
                      child: Image.asset(
                        faction.assetPath,
                        width: 46,
                        height: 44,
                        fit: BoxFit.contain,
                        alignment: Alignment.center,
                        filterQuality: FilterQuality.medium,
                        errorBuilder: (context, error, stackTrace) => Icon(
                          Icons.shield_outlined,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    SizedBox(
                      height: 14,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          faction.shortLabel,
                          maxLines: 1,
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontSize: 10.5,
                            height: 1,
                            fontWeight: FontWeight.w800,
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
