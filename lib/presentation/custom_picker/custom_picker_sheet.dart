import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:whichgame/core/constants/app_strings.dart';
import 'package:whichgame/core/theme/app_colors.dart';
import 'package:whichgame/core/widgets/app_bottom_sheet_safe_area.dart';
import 'package:whichgame/domain/models/custom_choice.dart';
import 'package:whichgame/presentation/app_scope.dart';

Future<void> showCustomPicker(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    useSafeArea: true,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => const AppBottomSheetSafeArea(
      child: CustomPickerSheet(),
    ),
  );
}

class CustomPickerSheet extends StatefulWidget {
  const CustomPickerSheet({super.key});

  @override
  State<CustomPickerSheet> createState() => _CustomPickerSheetState();
}

class _CustomPickerSheetState extends State<CustomPickerSheet> {
  static const _rollDuration = Duration(milliseconds: 1800);
  static const _rollStep = Duration(milliseconds: 95);

  final TextEditingController _optionController = TextEditingController();
  final FocusNode _optionFocusNode = FocusNode();

  Timer? _rollTimer;
  CustomChoice? _result;
  int _rollTick = 0;
  bool _rolling = false;

  @override
  void dispose() {
    _rollTimer?.cancel();
    _optionController.dispose();
    _optionFocusNode.dispose();
    super.dispose();
  }

  Future<void> _addOption() async {
    final label = _optionController.text.trim();
    if (label.isEmpty) {
      return;
    }

    await AppScope.read(context).addCustomChoice(label);
    if (!mounted) {
      return;
    }
    _optionController.clear();
    _optionFocusNode.requestFocus();
    HapticFeedback.selectionClick();
  }

  void _pick() {
    final controller = AppScope.read(context);
    final pool = controller.enabledCustomChoices;
    if (pool.length < 2 || _rolling) {
      return;
    }

    _rollTimer?.cancel();
    final startedAt = DateTime.now();
    setState(() {
      _rolling = true;
      _rollTick = 0;
    });
    HapticFeedback.selectionClick();

    _rollTimer = Timer.periodic(_rollStep, (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (DateTime.now().difference(startedAt) >= _rollDuration) {
        timer.cancel();
        _rollTimer = null;
        final picked = controller.pickRandomCustomChoice();
        setState(() {
          _result = picked;
          _rolling = false;
        });
        HapticFeedback.mediumImpact();
        return;
      }

      setState(() => _rollTick++);
    });
  }

  Future<void> _editChoice(CustomChoice choice) async {
    final textController = TextEditingController(text: choice.label);
    final updated = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(AppStrings.editCustomOption),
        content: TextField(
          controller: textController,
          autofocus: true,
          textInputAction: TextInputAction.done,
          onSubmitted: (value) => Navigator.of(dialogContext).pop(value.trim()),
          decoration: InputDecoration(hintText: AppStrings.customOptionHint),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(AppStrings.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(
              textController.text.trim(),
            ),
            child: Text(AppStrings.saveChanges),
          ),
        ],
      ),
    );
    textController.dispose();

    if (!mounted || updated == null || updated.isEmpty) {
      return;
    }
    await AppScope.read(context).updateCustomChoice(choice.id, updated);
  }

  CustomChoice? _visibleResult(List<CustomChoice> enabledChoices) {
    if (_rolling && enabledChoices.isNotEmpty) {
      return enabledChoices[_rollTick % enabledChoices.length];
    }
    if (_result == null) {
      return null;
    }
    return enabledChoices.any((choice) => choice.id == _result!.id)
        ? _result
        : null;
  }

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    final choices = controller.customChoices;
    final enabledChoices = controller.enabledCustomChoices;
    final visibleResult = _visibleResult(enabledChoices);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final viewInsets = MediaQuery.viewInsetsOf(context);
    final maxHeight = MediaQuery.sizeOf(context).height * 0.88;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      padding: EdgeInsets.only(bottom: viewInsets.bottom),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: scheme.primaryContainer,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      Icons.auto_awesome_rounded,
                      color: scheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.customPicker,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          AppStrings.customPickerDescription,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                            height: 1.25,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _ResultStage(
                choice: visibleResult,
                rolling: _rolling,
                canPick: enabledChoices.length >= 2,
                onPick: _pick,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _optionController,
                      focusNode: _optionFocusNode,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _addOption(),
                      decoration: InputDecoration(
                        isDense: true,
                        hintText: AppStrings.customOptionHint,
                        prefixIcon: const Icon(Icons.add_circle_outline_rounded),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    tooltip: AppStrings.addCustomOption,
                    onPressed: _addOption,
                    icon: const Icon(Icons.add_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      AppStrings.customOptionsEnabled(
                        enabledChoices.length,
                        choices.length,
                      ),
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  if (choices.isNotEmpty)
                    PopupMenuButton<bool>(
                      tooltip: AppStrings.bulkActions,
                      onSelected: controller.setAllCustomChoicesEnabled,
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: true,
                          child: Row(
                            children: [
                              const Icon(Icons.done_all_rounded, size: 18),
                              const SizedBox(width: 9),
                              Text(AppStrings.enableAllOptions),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: false,
                          child: Row(
                            children: [
                              const Icon(Icons.remove_done_rounded, size: 18),
                              const SizedBox(width: 9),
                              Text(AppStrings.disableAllOptions),
                            ],
                          ),
                        ),
                      ],
                      icon: const Icon(Icons.more_horiz_rounded),
                    ),
                ],
              ),
              const SizedBox(height: 2),
              if (choices.isEmpty)
                Flexible(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 26),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.playlist_add_rounded,
                            size: 42,
                            color: scheme.onSurfaceVariant,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            AppStrings.noCustomOptions,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: choices.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 6),
                    itemBuilder: (context, index) {
                      final choice = choices[index];
                      return _ChoiceRow(
                        choice: choice,
                        onToggle: () => controller.toggleCustomChoice(choice.id),
                        onEdit: () => _editChoice(choice),
                        onDelete: () => controller.deleteCustomChoice(choice.id),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.save_outlined,
                    size: 14,
                    color: scheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 5),
                  Flexible(
                    child: Text(
                      AppStrings.customPickerSavedHint,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResultStage extends StatelessWidget {
  const _ResultStage({
    required this.choice,
    required this.rolling,
    required this.canPick,
    required this.onPick,
  });

  final CustomChoice? choice;
  final bool rolling;
  final bool canPick;
  final VoidCallback onPick;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      height: 132,
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: rolling
              ? [
                  scheme.primaryContainer,
                  scheme.secondaryContainer,
                ]
              : [
                  scheme.surfaceContainerHigh,
                  scheme.surfaceContainer,
                ],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: rolling
              ? scheme.primary.withValues(alpha: 0.55)
              : scheme.outlineVariant.withValues(alpha: 0.7),
        ),
      ),
      child: Column(
        children: [
          Text(
            rolling
                ? AppStrings.choosingCustomOption
                : AppStrings.customPickerResult,
            style: theme.textTheme.labelMedium?.copyWith(
              color: scheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 3),
          Expanded(
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  choice?.label ??
                      (canPick
                          ? AppStrings.pickCustomOption
                          : AppStrings.customPickerNeedsOptions),
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: choice == null && !canPick
                        ? scheme.onSurfaceVariant
                        : scheme.onSurface,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 38,
            child: FilledButton.icon(
              onPressed: canPick && !rolling ? onPick : null,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                backgroundColor: AppColors.accent,
                foregroundColor: AppColors.black,
              ),
              icon: Icon(
                rolling ? Icons.autorenew_rounded : Icons.casino_rounded,
                size: 18,
              ),
              label: Text(
                choice == null
                    ? AppStrings.pickCustomOption
                    : AppStrings.pickCustomAgain,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChoiceRow extends StatelessWidget {
  const _ChoiceRow({
    required this.choice,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  final CustomChoice choice;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Material(
      color: choice.enabled
          ? scheme.primaryContainer.withValues(alpha: 0.22)
          : scheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(15),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: onToggle,
        child: SizedBox(
          height: 54,
          child: Row(
            children: [
              Checkbox(
                value: choice.enabled,
                onChanged: (_) => onToggle(),
                visualDensity: VisualDensity.compact,
              ),
              Expanded(
                child: Text(
                  choice.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: choice.enabled
                        ? scheme.onSurface
                        : scheme.onSurfaceVariant,
                  ),
                ),
              ),
              IconButton(
                tooltip: AppStrings.edit,
                visualDensity: VisualDensity.compact,
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined, size: 18),
              ),
              IconButton(
                tooltip: AppStrings.delete,
                visualDensity: VisualDensity.compact,
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline_rounded, size: 18),
              ),
              const SizedBox(width: 2),
            ],
          ),
        ),
      ),
    );
  }
}
