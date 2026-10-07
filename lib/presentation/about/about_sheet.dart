import 'package:flutter/material.dart';
import 'package:whichgame/core/constants/app_images.dart';
import 'package:whichgame/core/constants/app_strings.dart';
import 'package:whichgame/core/theme/app_colors.dart';
import 'package:whichgame/core/widgets/app_bottom_sheet_safe_area.dart';

Future<void> showAboutWhichGame(
  BuildContext context, {
  VoidCallback? onStartTour,
}) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (context) => AppBottomSheetSafeArea(
      child: _AboutSheet(onStartTour: onStartTour),
    ),
  );
}

class _AboutSheet extends StatelessWidget {
  const _AboutSheet({required this.onStartTour});

  final VoidCallback? onStartTour;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 4, 24, 30),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Image.asset(
                  AppImages.appIcon,
                  width: 58,
                  height: 58,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      gradient: const LinearGradient(
                        colors: [AppColors.seed, AppColors.brandSecondary],
                      ),
                    ),
                    child: const Icon(
                      Icons.casino_rounded,
                      color: AppColors.white,
                      size: 30,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.appName,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(AppStrings.appTagline),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.code_rounded, color: AppColors.accent),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    AppStrings.developedBy,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Text(
            AppStrings.aboutDescription,
            style: TextStyle(color: scheme.onSurfaceVariant, height: 1.45),
          ),
          if (onStartTour != null) ...[
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  Future<void>.delayed(
                    const Duration(milliseconds: 240),
                    () => onStartTour?.call(),
                  );
                },
                icon: const Icon(Icons.auto_awesome_rounded),
                label: Text(AppStrings.startAppTour),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
