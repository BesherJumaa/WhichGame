import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:whichgame/core/constants/app_strings.dart';
import 'package:whichgame/core/theme/app_colors.dart';
import 'package:whichgame/core/widgets/app_page.dart';
import 'package:whichgame/core/widgets/game_artwork.dart';
import 'package:whichgame/core/widgets/language_button.dart';
import 'package:whichgame/domain/models/game.dart';
import 'package:whichgame/presentation/about/about_sheet.dart';
import 'package:whichgame/presentation/app_scope.dart';
import 'package:whichgame/presentation/coach/coach_tour_scope.dart';
import 'package:whichgame/presentation/generals/generals_picker_sheet.dart';

class PlayScreen extends StatefulWidget {
  const PlayScreen({
    required this.onOpenGames,
    required this.onOpenTeams,
    this.coachHeroKey,
    this.coachQuickActionsKey,
    this.coachLanguageKey,
    super.key,
  });

  final VoidCallback onOpenGames;
  final VoidCallback onOpenTeams;
  final GlobalKey? coachHeroKey;
  final GlobalKey? coachQuickActionsKey;
  final GlobalKey? coachLanguageKey;

  @override
  State<PlayScreen> createState() => _PlayScreenState();
}

class _PlayScreenState extends State<PlayScreen> {
  int _rollVersion = 0;

  void _pickGame() {
    final controller = AppScope.of(context);
    final picked = controller.pickRandomGame();
    if (picked == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.noGameMatches)),
      );
      return;
    }

    HapticFeedback.mediumImpact();
    setState(() => _rollVersion++);
  }

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return SafeArea(
      child: Column(
        children: [
          AppBar(
            title: const _BrandTitle(),
            actions: [
              AppLanguageButton(targetKey: widget.coachLanguageKey),
              IconButton(
                tooltip: AppStrings.aboutTooltip,
                onPressed: () => showAboutWhichGame(
                  context,
                  onStartTour: CoachTourScope.maybeOf(context)?.startTour,
                ),
                icon: const Icon(Icons.info_outline_rounded),
              ),
              const SizedBox(width: 4),
            ],
          ),
          Expanded(
            child: AppPage(
              maxWidth: 1080,
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 18),
              child: ListView(
                children: [
                  KeyedSubtree(
                    key: widget.coachHeroKey,
                    child: _HeroCard(
                      game: controller.lastPickedGame,
                      rollVersion: _rollVersion,
                      poolCount: controller.randomPool.length,
                      onPick: _pickGame,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _StatsRow(
                    enabled: controller.selectedGamesCount,
                    pool: controller.randomPool.length,
                    players: controller.activePlayers.length,
                  ),
                  const SizedBox(height: 12),
                  KeyedSubtree(
                    key: widget.coachQuickActionsKey,
                    child: _QuickActions(
                      onOpenGames: widget.onOpenGames,
                      onOpenTeams: widget.onOpenTeams,
                      onOpenGenerals: controller.activePlayers.length >= 2
                          ? () => showGeneralsPicker(context)
                          : null,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          AppStrings.recentlyPicked,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      if (controller.gameFilters.hasFilters)
                        TextButton.icon(
                          onPressed: controller.clearGameFilters,
                          icon: const Icon(
                            Icons.filter_alt_off_rounded,
                            size: 17,
                          ),
                          label: Text(AppStrings.clearFilters),
                        ),
                    ],
                  ),
                  const SizedBox(height: 7),
                  if (controller.recentGames.isEmpty)
                    _EmptyRecent(onOpenGames: widget.onOpenGames)
                  else
                    SizedBox(
                      height: 82,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: controller.recentGames.length,
                        separatorBuilder: (context, index) => const SizedBox(width: 7),
                        itemBuilder: (context, index) {
                          final game = controller.recentGames[index];
                          return _RecentGameCard(game: game);
                        },
                      ),
                    ),
                  const SizedBox(height: 20),
                  Center(
                    child: Text(
                      AppStrings.developedBy,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                        fontWeight: FontWeight.w700,
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
}

class _BrandTitle extends StatelessWidget {
  const _BrandTitle();

  @override
  Widget build(BuildContext context) {
    // This widget is const, so explicitly depend on Localizations to make the
    // title refresh immediately when the app language changes.
    Localizations.localeOf(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.sports_esports_rounded, color: AppColors.accent),
        const SizedBox(width: 9),
        Text(AppStrings.appName),
      ],
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.game,
    required this.rollVersion,
    required this.poolCount,
    required this.onPick,
  });

  final Game? game;
  final int rollVersion;
  final int poolCount;
  final VoidCallback onPick;

  static const double height = 328;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.heroStart, AppColors.heroEnd],
          ),
          border: Border.all(color: AppColors.white09),
          boxShadow: [
            BoxShadow(
              blurRadius: 28,
              offset: const Offset(0, 12),
              color: AppColors.seed.withValues(alpha: 0.14),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.white08,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      AppStrings.gamesInPool(poolCount),
                      style: const TextStyle(
                        color: AppColors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const Spacer(),
                  const Icon(Icons.auto_awesome_rounded, color: AppColors.accent),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 174,
                child: Center(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 520),
                    switchInCurve: Curves.easeOutBack,
                    switchOutCurve: Curves.easeInCubic,
                    transitionBuilder: (child, animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: ScaleTransition(
                          scale: Tween<double>(begin: 0.9, end: 1).animate(animation),
                          child: child,
                        ),
                      );
                    },
                    child: game == null
                        ? _EmptyHero(key: ValueKey('empty-${AppStrings.currentLanguage.code}'))
                        : _PickedGame(
                            key: ValueKey('${game!.id}-$rollVersion'),
                            game: game!,
                          ),
                  ),
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: FilledButton(
                  onPressed: onPick,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: AppColors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.casino_rounded, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          game == null ? AppStrings.pickGame : AppStrings.pickAgain,
                          maxLines: 1,
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            height: 1.15,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                AppStrings.randomPoolHint,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.white60,
                  fontSize: 10.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyHero extends StatelessWidget {
  const _EmptyHero({super.key});

  @override
  Widget build(BuildContext context) {
    Localizations.localeOf(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.question_mark_rounded, size: 58, color: AppColors.white),
        const SizedBox(height: 8),
        Text(
          AppStrings.emptyHeroTitle,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.white,
            fontSize: 24,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          AppStrings.emptyHeroSubtitle,
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.white60, fontSize: 12),
        ),
      ],
    );
  }
}

class _PickedGame extends StatelessWidget {
  const _PickedGame({required this.game, super.key});

  final Game game;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GameArtwork(game: game, width: 112, height: 76, borderRadius: 18),
        const SizedBox(height: 10),
        Text(
          game.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.white,
            fontSize: 21,
            height: 1.05,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          game.playerLabel,
          style: const TextStyle(
            color: AppColors.white70,
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({
    required this.enabled,
    required this.pool,
    required this.players,
  });

  final int enabled;
  final int pool;
  final int players;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _MiniStat(
            icon: Icons.check_circle_outline_rounded,
            value: '$enabled',
            label: AppStrings.gamesEnabled,
          ),
        ),
        const SizedBox(width: 7),
        Expanded(
          child: _MiniStat(
            icon: Icons.casino_outlined,
            value: '$pool',
            label: AppStrings.inRandomPool,
          ),
        ),
        const SizedBox(width: 7),
        Expanded(
          child: _MiniStat(
            icon: Icons.people_outline_rounded,
            value: '$players',
            label: AppStrings.playersReady,
          ),
        ),
      ],
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      height: 66,
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 8),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.65)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 19, color: scheme.primary),
          const SizedBox(width: 7),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                ),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 9.5, color: scheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions({
    required this.onOpenGames,
    required this.onOpenTeams,
    required this.onOpenGenerals,
  });

  final VoidCallback onOpenGames;
  final VoidCallback onOpenTeams;
  final VoidCallback? onOpenGenerals;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _QuickActionButton(
            icon: Icons.tune_rounded,
            label: AppStrings.manageGames,
            onTap: onOpenGames,
          ),
        ),
        const SizedBox(width: 7),
        Expanded(
          child: _QuickActionButton(
            icon: Icons.groups_2_outlined,
            label: AppStrings.splitTeams,
            onTap: onOpenTeams,
          ),
        ),
        const SizedBox(width: 7),
        Expanded(
          child: _QuickActionButton(
            icon: Icons.casino_rounded,
            label: AppStrings.openGeneralsPicker,
            onTap: onOpenGenerals,
          ),
        ),
      ],
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surfaceContainer,
      borderRadius: BorderRadius.circular(15),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: onTap,
        child: SizedBox(
          height: 54,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 18,
                  color: onTap == null ? scheme.onSurfaceVariant : scheme.primary,
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      color: onTap == null ? scheme.onSurfaceVariant : null,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RecentGameCard extends StatelessWidget {
  const _RecentGameCard({required this.game});

  final Game game;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: 190,
      padding: const EdgeInsets.all(7),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.6)),
      ),
      child: Row(
        children: [
          GameArtwork(game: game, width: 72, height: 58, borderRadius: 11),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  game.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 3),
                Text(
                  game.playerLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 9.5, color: scheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyRecent extends StatelessWidget {
  const _EmptyRecent({required this.onOpenGames});

  final VoidCallback onOpenGames;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          const Icon(Icons.history_rounded),
          const SizedBox(width: 9),
          Expanded(child: Text(AppStrings.noRecentPicks)),
          TextButton(
            onPressed: onOpenGames,
            child: Text(AppStrings.manageGames),
          ),
        ],
      ),
    );
  }
}
