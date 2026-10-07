import 'package:flutter/material.dart';
import 'package:whichgame/core/constants/app_strings.dart';
import 'package:whichgame/core/theme/app_colors.dart';

class AppCoachStep {
  const AppCoachStep({
    required this.title,
    required this.description,
    required this.icon,
    this.targetKey,
  });

  final String title;
  final String description;
  final IconData icon;
  final GlobalKey? targetKey;
}

class AppCoachMarkOverlay extends StatefulWidget {
  const AppCoachMarkOverlay({
    required this.step,
    required this.stepIndex,
    required this.stepCount,
    required this.onNext,
    required this.onBack,
    required this.onSkip,
    super.key,
  });

  final AppCoachStep step;
  final int stepIndex;
  final int stepCount;
  final VoidCallback onNext;
  final VoidCallback? onBack;
  final VoidCallback onSkip;

  @override
  State<AppCoachMarkOverlay> createState() => _AppCoachMarkOverlayState();
}

class _AppCoachMarkOverlayState extends State<AppCoachMarkOverlay>
    with SingleTickerProviderStateMixin {
  final GlobalKey _overlayKey = GlobalKey(debugLabel: 'coach-overlay');
  late final AnimationController _pulseController;
  Rect? _targetRect;
  int _measureAttempts = 0;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1050),
      lowerBound: 0,
      upperBound: 1,
    )..repeat(reverse: true);
    _scheduleMeasure();
  }

  @override
  void didUpdateWidget(covariant AppCoachMarkOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.stepIndex != widget.stepIndex ||
        oldWidget.step.targetKey != widget.step.targetKey) {
      _targetRect = null;
      _measureAttempts = 0;
      _scheduleMeasure();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _scheduleMeasure() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _measureTarget();
    });
  }

  void _measureTarget() {
    final targetContext = widget.step.targetKey?.currentContext;
    final overlayContext = _overlayKey.currentContext;

    if (widget.step.targetKey == null) {
      if (_targetRect != null) {
        setState(() => _targetRect = null);
      }
      return;
    }

    if (targetContext == null || overlayContext == null) {
      _retryMeasure();
      return;
    }

    final targetBox = targetContext.findRenderObject();
    final overlayBox = overlayContext.findRenderObject();
    if (targetBox is! RenderBox ||
        overlayBox is! RenderBox ||
        !targetBox.hasSize ||
        !overlayBox.hasSize) {
      _retryMeasure();
      return;
    }

    final targetGlobal = targetBox.localToGlobal(Offset.zero);
    final overlayGlobal = overlayBox.localToGlobal(Offset.zero);
    final localTopLeft = targetGlobal - overlayGlobal;
    final nextRect = localTopLeft & targetBox.size;

    if (_targetRect != nextRect) {
      setState(() => _targetRect = nextRect);
    }
  }

  void _retryMeasure() {
    if (_measureAttempts >= 5) {
      return;
    }
    _measureAttempts++;
    _scheduleMeasure();
  }

  double _boundedPosition(double value, double minimum, double maximum) {
    final safeMaximum = maximum < minimum ? minimum : maximum;
    return value.clamp(minimum, safeMaximum).toDouble();
  }

  @override
  Widget build(BuildContext context) {
    final targetRect = _targetRect;
    final highlightRect = targetRect?.inflate(7);

    return Material(
      color: Colors.transparent,
      child: SizedBox.expand(
        key: _overlayKey,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final safeTop = MediaQuery.paddingOf(context).top;
            final safeBottom = MediaQuery.paddingOf(context).bottom;
            final cardWidth = (constraints.maxWidth - 28)
                .clamp(0.0, 460.0)
                .toDouble();
            final placeBelow = targetRect == null ||
                targetRect.center.dy < constraints.maxHeight * 0.45;

            final availableTop = safeTop + 14;
            final availableBottom = safeBottom + 14;
            final desiredTop = targetRect == null
                ? null
                : _boundedPosition(
                    targetRect.bottom + 18,
                    availableTop,
                    constraints.maxHeight - 250 - availableBottom,
                  );
            final desiredBottom = targetRect == null
                ? null
                : _boundedPosition(
                    constraints.maxHeight - targetRect.top + 18,
                    availableBottom,
                    constraints.maxHeight - 250 - availableTop,
                  );

            return Stack(
              fit: StackFit.expand,
              children: [
                CustomPaint(
                  painter: _CoachScrimPainter(targetRect: highlightRect),
                ),
                if (highlightRect != null)
                  AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      final pulse = Curves.easeInOut.transform(
                        _pulseController.value,
                      );
                      return Positioned.fromRect(
                        rect: highlightRect.inflate(2 + pulse * 3),
                        child: IgnorePointer(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(22),
                              border: Border.all(
                                color: AppColors.accent.withValues(
                                  alpha: 0.72 + pulse * 0.28,
                                ),
                                width: 2 + pulse,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.accent.withValues(
                                    alpha: 0.16 + pulse * 0.12,
                                  ),
                                  blurRadius: 22 + pulse * 8,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                if (targetRect == null)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: SizedBox(
                        width: cardWidth,
                        child: _CoachCard(
                          step: widget.step,
                          stepIndex: widget.stepIndex,
                          stepCount: widget.stepCount,
                          onNext: widget.onNext,
                          onBack: widget.onBack,
                          onSkip: widget.onSkip,
                        ),
                      ),
                    ),
                  )
                else
                  Positioned(
                    left: (constraints.maxWidth - cardWidth) / 2,
                    width: cardWidth,
                    top: placeBelow ? desiredTop : null,
                    bottom: placeBelow ? null : desiredBottom,
                    child: _CoachCard(
                      step: widget.step,
                      stepIndex: widget.stepIndex,
                      stepCount: widget.stepCount,
                      onNext: widget.onNext,
                      onBack: widget.onBack,
                      onSkip: widget.onSkip,
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _CoachCard extends StatelessWidget {
  const _CoachCard({
    required this.step,
    required this.stepIndex,
    required this.stepCount,
    required this.onNext,
    required this.onBack,
    required this.onSkip,
  });

  final AppCoachStep step;
  final int stepIndex;
  final int stepCount;
  final VoidCallback onNext;
  final VoidCallback? onBack;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isLast = stepIndex == stepCount - 1;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 260),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.06),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        ),
      ),
      child: Container(
        key: ValueKey(stepIndex),
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: scheme.outlineVariant.withValues(alpha: 0.7),
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x33000000),
              blurRadius: 28,
              offset: Offset(0, 14),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: scheme.primaryContainer,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(step.icon, color: scheme.onPrimaryContainer),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    step.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                Text(
                  AppStrings.coachStep(stepIndex + 1, stepCount),
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 2),
                IconButton(
                  tooltip: AppStrings.skip,
                  onPressed: onSkip,
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.close_rounded, size: 19),
                ),
              ],
            ),
            const SizedBox(height: 11),
            Text(
              step.description,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
                height: 1.42,
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: Wrap(
                    spacing: 5,
                    children: List.generate(
                      stepCount,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        width: index == stepIndex ? 18 : 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: index == stepIndex
                              ? scheme.primary
                              : scheme.outlineVariant,
                          borderRadius: BorderRadius.circular(99),
                        ),
                      ),
                    ),
                  ),
                ),
                if (onBack != null)
                  TextButton(
                    onPressed: onBack,
                    child: Text(AppStrings.back),
                  ),
                const SizedBox(width: 6),
                FilledButton.icon(
                  onPressed: onNext,
                  icon: Icon(
                    isLast ? Icons.check_rounded : Icons.arrow_forward_rounded,
                    size: 18,
                  ),
                  label: Text(isLast ? AppStrings.done : AppStrings.next),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CoachScrimPainter extends CustomPainter {
  const _CoachScrimPainter({required this.targetRect});

  final Rect? targetRect;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.saveLayer(Offset.zero & size, Paint());
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xB8000000),
    );

    if (targetRect != null) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(targetRect!, const Radius.circular(20)),
        Paint()..blendMode = BlendMode.clear,
      );
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _CoachScrimPainter oldDelegate) =>
      oldDelegate.targetRect != targetRect;
}
