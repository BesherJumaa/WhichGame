import 'package:flutter/material.dart';
import 'package:whichgame/core/constants/app_strings.dart';
import 'package:whichgame/core/theme/app_colors.dart';
import 'package:whichgame/core/widgets/game_artwork.dart';
import 'package:whichgame/domain/models/game.dart';

enum GameCardAction { details, onlyThis, archive }

class GameCard extends StatelessWidget {
  const GameCard({
    required this.game,
    required this.selected,
    required this.onToggle,
    required this.onAction,
    super.key,
  });

  final Game game;
  final bool selected;
  final VoidCallback onToggle;
  final ValueChanged<GameCardAction> onAction;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: selected
            ? scheme.primaryContainer.withValues(alpha: 0.18)
            : scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: selected
              ? scheme.primary.withValues(alpha: 0.68)
              : scheme.outlineVariant.withValues(alpha: 0.62),
          width: selected ? 1.25 : 0.8,
        ),
      ),
      child: Material(
        color: AppColors.transparent,
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onToggle,
          onLongPress: () => onAction(GameCardAction.details),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    LayoutBuilder(
                      builder: (context, constraints) => GameArtwork(
                        game: game,
                        width: constraints.maxWidth,
                        height: constraints.maxHeight,
                        borderRadius: 0,
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: _SelectionBadge(selected: selected),
                    ),
                    Positioned(
                      top: 2,
                      left: 2,
                      child: PopupMenuButton<GameCardAction>(
                        tooltip: AppStrings.bulkActions,
                        padding: EdgeInsets.zero,
                        iconSize: 16,
                        color: scheme.surfaceContainerHigh,
                        onSelected: onAction,
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: GameCardAction.details,
                            child: _MenuRow(
                              icon: Icons.info_outline_rounded,
                              label: AppStrings.gameDetails,
                            ),
                          ),
                          PopupMenuItem(
                            value: GameCardAction.onlyThis,
                            child: _MenuRow(
                              icon: Icons.filter_1_rounded,
                              label: AppStrings.onlyThisGame,
                            ),
                          ),
                          PopupMenuItem(
                            value: GameCardAction.archive,
                            child: _MenuRow(
                              icon: Icons.archive_outlined,
                              label: AppStrings.archive,
                            ),
                          ),
                        ],
                        icon: Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            color: scheme.surface.withValues(alpha: 0.92),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.more_horiz_rounded,
                            size: 15,
                            color: scheme.onSurface,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 4,
                      bottom: 4,
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 62),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.black.withValues(alpha: 0.68),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.people_outline_rounded,
                              size: 9,
                              color: AppColors.white,
                            ),
                            const SizedBox(width: 2),
                            Flexible(
                              child: Text(
                                game.playerLabel,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: AppColors.white,
                                  fontSize: 8,
                                  height: 1,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 31,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(6, 4, 6, 4),
                  child: Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Text(
                      game.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        height: 1.05,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18),
        const SizedBox(width: 9),
        Text(label),
      ],
    );
  }
}

class _SelectionBadge extends StatelessWidget {
  const _SelectionBadge({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: selected ? scheme.primary : scheme.surface.withValues(alpha: 0.92),
        shape: BoxShape.circle,
        border: selected ? null : Border.all(color: scheme.outlineVariant),
      ),
      child: Icon(
        selected ? Icons.check_rounded : Icons.add_rounded,
        size: 14,
        color: selected ? scheme.onPrimary : scheme.onSurfaceVariant,
      ),
    );
  }
}
