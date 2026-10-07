import 'dart:io';

import 'package:flutter/material.dart';
import 'package:whichgame/core/theme/app_colors.dart';
import 'package:whichgame/domain/models/game.dart';

class GameArtwork extends StatelessWidget {
  const GameArtwork({
    required this.game,
    this.size = 72,
    this.width,
    this.height,
    this.borderRadius = 20,
    this.fit = BoxFit.cover,
    super.key,
  });

  final Game game;
  final double size;
  final double? width;
  final double? height;
  final double borderRadius;
  final BoxFit fit;

  double get _width => width ?? size;
  double get _height => height ?? size;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: SizedBox(
        width: _width,
        height: _height,
        child: _buildImage(context),
      ),
    );
  }

  Widget _buildImage(BuildContext context) {
    final customImagePath = game.customImagePath?.trim();
    if (customImagePath != null && customImagePath.isNotEmpty) {
      return Image.file(
        File(customImagePath),
        fit: fit,
        filterQuality: FilterQuality.medium,
        errorBuilder: (context, error, stackTrace) => _buildBundledImage(context),
      );
    }

    return _buildBundledImage(context);
  }

  Widget _buildBundledImage(BuildContext context) {
    if (game.isCustom || game.assetPath.trim().isEmpty) {
      return _Fallback(
        game: game,
        width: _width,
        height: _height,
        borderRadius: borderRadius,
      );
    }

    return Image.asset(
      game.assetPath,
      fit: fit,
      filterQuality: FilterQuality.medium,
      errorBuilder: (context, error, stackTrace) => _Fallback(
        game: game,
        width: _width,
        height: _height,
        borderRadius: borderRadius,
      ),
    );
  }
}

class _Fallback extends StatelessWidget {
  const _Fallback({
    required this.game,
    required this.width,
    required this.height,
    required this.borderRadius,
  });

  final Game game;
  final double width;
  final double height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final icon = switch (game.category) {
      GameCategory.card => Icons.style_rounded,
      GameCategory.sport => Icons.sports_soccer_rounded,
      GameCategory.video => Icons.sports_esports_rounded,
    };

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            scheme.primaryContainer,
            AppColors.seed.withValues(alpha: 0.78),
          ],
        ),
      ),
      child: Icon(
        icon,
        size: height * 0.42,
        color: scheme.onPrimaryContainer,
      ),
    );
  }
}
