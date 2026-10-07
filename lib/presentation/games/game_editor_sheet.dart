
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:whichgame/core/constants/app_strings.dart';
import 'package:whichgame/core/widgets/game_artwork.dart';
import 'package:whichgame/domain/models/game.dart';
import 'package:whichgame/presentation/app_scope.dart';

class GameEditorSheet extends StatefulWidget {
  const GameEditorSheet({this.game, super.key});

  final Game? game;

  @override
  State<GameEditorSheet> createState() => _GameEditorSheetState();
}

class _GameEditorSheetState extends State<GameEditorSheet> {
  static const _maxImageBytes = 12 * 1024 * 1024;
  final _formKey = GlobalKey<FormState>();
  final _imagePicker = ImagePicker();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _minPlayersController;
  late final TextEditingController _maxPlayersController;
  late GameCategory _category;
  late Set<GameMode> _modes;

  Uint8List? _pendingImageBytes;
  String? _pendingImageName;
  bool _removeExistingImage = false;
  bool _pickingImage = false;
  bool _saving = false;
  String? _formError;

  bool get _editing => widget.game != null;
  bool get _hasPendingImage => _pendingImageBytes != null;
  bool get _hasStoredImage =>
      widget.game?.hasCustomImage == true && !_removeExistingImage;
  bool get _hasAnyCustomImage => _hasPendingImage || _hasStoredImage;

  @override
  void initState() {
    super.initState();
    final game = widget.game;
    _titleController = TextEditingController(text: game?.title ?? '');
    _descriptionController = TextEditingController(text: game?.description ?? '');
    _minPlayersController = TextEditingController(
      text: (game?.minPlayers ?? 2).toString(),
    );
    _maxPlayersController = TextEditingController(
      text: game?.maxPlayers?.toString() ?? '',
    );
    _category = game?.category ?? GameCategory.video;
    _modes = {...?game?.modes};
    if (_modes.isEmpty) {
      _modes = {GameMode.local};
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _minPlayersController.dispose();
    _maxPlayersController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final mediaQuery = MediaQuery.of(context);

    return AnimatedPadding(
      duration: const Duration(milliseconds: 160),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(bottom: mediaQuery.viewInsets.bottom),
      child: FractionallySizedBox(
        heightFactor: 0.92,
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 4, 12, 10),
                child: Row(
                  children: [
                    _HeaderArtwork(
                      game: widget.game,
                      category: _category,
                      pendingBytes: _pendingImageBytes,
                      removeStoredImage: _removeExistingImage,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _editing ? AppStrings.editGame : AppStrings.addGame,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            AppStrings.gameSavedLocally,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: AppStrings.cancel,
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _titleController,
                        autofocus: !_editing,
                        textCapitalization: TextCapitalization.words,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          labelText: AppStrings.gameName,
                          hintText: AppStrings.gameNameHint,
                          prefixIcon: const Icon(Icons.videogame_asset_rounded),
                        ),
                        validator: (value) => value == null || value.trim().isEmpty
                            ? AppStrings.gameName
                            : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _descriptionController,
                        minLines: 2,
                        maxLines: 4,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: InputDecoration(
                          labelText: AppStrings.gameDescription,
                          hintText: AppStrings.gameDescriptionHint,
                          alignLabelWithHint: true,
                          prefixIcon: const Padding(
                            padding: EdgeInsets.only(bottom: 42),
                            child: Icon(Icons.notes_rounded),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      _ImageSection(
                        game: widget.game,
                        category: _category,
                        pendingBytes: _pendingImageBytes,
                        hasCustomImage: _hasAnyCustomImage,
                        removeStoredImage: _removeExistingImage,
                        picking: _pickingImage,
                        onPick: _pickImage,
                        onRemove: _removeImage,
                      ),
                      const SizedBox(height: 14),
                      DropdownButtonFormField<GameCategory>(
                        initialValue: _category,
                        decoration: InputDecoration(
                          labelText: AppStrings.category,
                          prefixIcon: const Icon(Icons.category_outlined),
                        ),
                        items: GameCategory.values
                            .map(
                              (category) => DropdownMenuItem(
                                value: category,
                                child: Text(category.label),
                              ),
                            )
                            .toList(growable: false),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _category = value);
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _minPlayersController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              decoration: InputDecoration(
                                labelText: AppStrings.minimumPlayers,
                                prefixIcon: const Icon(Icons.person_rounded),
                              ),
                              validator: (value) {
                                final count = int.tryParse(value ?? '');
                                return count == null || count < 1
                                    ? AppStrings.minimumPlayers
                                    : null;
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextFormField(
                              controller: _maxPlayersController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              decoration: InputDecoration(
                                labelText: AppStrings.maximumPlayers,
                                hintText: AppStrings.noMaximum,
                                prefixIcon:
                                    const Icon(Icons.groups_2_rounded),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Text(
                        AppStrings.gameModes,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 7,
                        runSpacing: 7,
                        children: GameMode.values
                            .map(
                              (mode) => FilterChip(
                                selected: _modes.contains(mode),
                                label: Text(mode.label),
                                onSelected: (selected) {
                                  setState(() {
                                    if (selected) {
                                      _modes.add(mode);
                                    } else {
                                      _modes.remove(mode);
                                    }
                                    _formError = null;
                                  });
                                },
                              ),
                            )
                            .toList(growable: false),
                      ),
                      if (_formError != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          _formError!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: scheme.error,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 10, 18, 6),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _saving ? null : _save,
                    icon: _saving
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.save_rounded),
                    label: Text(
                      _editing ? AppStrings.saveChanges : AppStrings.saveGame,
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

  Future<void> _pickImage() async {
    if (_pickingImage) return;
    setState(() {
      _pickingImage = true;
      _formError = null;
    });

    try {
      final file = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        requestFullMetadata: false,
      );
      if (file == null || !mounted) {
        return;
      }

      final length = await file.length();
      if (!mounted) return;
      if (length > _maxImageBytes) {
        setState(() => _formError = AppStrings.gameImageTooLarge);
        return;
      }

      final bytes = await file.readAsBytes();
      if (!mounted) return;
      if (bytes.isEmpty) {
        setState(() => _formError = AppStrings.gameImageReadFailed);
        return;
      }

      setState(() {
        _pendingImageBytes = bytes;
        _pendingImageName = file.name;
        _removeExistingImage = false;
      });
    } catch (_) {
      if (mounted) {
        setState(() => _formError = AppStrings.gameImageReadFailed);
      }
    } finally {
      if (mounted) {
        setState(() => _pickingImage = false);
      }
    }
  }

  void _removeImage() {
    setState(() {
      _pendingImageBytes = null;
      _pendingImageName = null;
      _removeExistingImage = widget.game?.hasCustomImage == true;
      _formError = null;
    });
  }

  Future<void> _save() async {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _formError = null);

    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    if (_modes.isEmpty) {
      setState(() => _formError = AppStrings.chooseGameMode);
      return;
    }

    final minPlayers = int.parse(_minPlayersController.text);
    final maxText = _maxPlayersController.text.trim();
    final maxPlayers = maxText.isEmpty ? null : int.tryParse(maxText);
    if (maxPlayers != null && maxPlayers < minPlayers) {
      setState(() => _formError = AppStrings.invalidPlayerRange);
      return;
    }

    setState(() => _saving = true);
    final controller = AppScope.of(context);
    final game = widget.game;

    try {
      if (game == null) {
        await controller.addGame(
          title: _titleController.text,
          description: _descriptionController.text,
          category: _category,
          minPlayers: minPlayers,
          maxPlayers: maxPlayers,
          modes: _modes,
          imageBytes: _pendingImageBytes,
          imageFileName: _pendingImageName,
        );
      } else {
        await controller.updateGame(
          game: game,
          title: _titleController.text,
          description: _descriptionController.text,
          category: _category,
          minPlayers: minPlayers,
          maxPlayers: maxPlayers,
          modes: _modes,
          imageBytes: _pendingImageBytes,
          imageFileName: _pendingImageName,
          removeCustomImage: _removeExistingImage,
        );
      }

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _saving = false;
          _formError = AppStrings.gameSaveFailed;
        });
      }
    }
  }
}

class _ImageSection extends StatelessWidget {
  const _ImageSection({
    required this.game,
    required this.category,
    required this.pendingBytes,
    required this.hasCustomImage,
    required this.removeStoredImage,
    required this.picking,
    required this.onPick,
    required this.onRemove,
  });

  final Game? game;
  final GameCategory category;
  final Uint8List? pendingBytes;
  final bool hasCustomImage;
  final bool removeStoredImage;
  final bool picking;
  final VoidCallback onPick;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _EditorArtworkPreview(
              game: game,
              category: category,
              pendingBytes: pendingBytes,
              removeStoredImage: removeStoredImage,
              width: 94,
              height: 72,
              borderRadius: 14,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.gameImage,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    AppStrings.gameImageHint,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      OutlinedButton.icon(
                        onPressed: picking ? null : onPick,
                        icon: picking
                            ? const SizedBox.square(
                                dimension: 15,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.add_photo_alternate_outlined, size: 18),
                        label: Text(
                          hasCustomImage
                              ? AppStrings.changeGameImage
                              : AppStrings.chooseGameImage,
                        ),
                      ),
                      if (hasCustomImage)
                        TextButton.icon(
                          onPressed: picking ? null : onRemove,
                          icon: const Icon(Icons.delete_outline_rounded, size: 18),
                          label: Text(AppStrings.removeGameImage),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderArtwork extends StatelessWidget {
  const _HeaderArtwork({
    required this.game,
    required this.category,
    required this.pendingBytes,
    required this.removeStoredImage,
  });

  final Game? game;
  final GameCategory category;
  final Uint8List? pendingBytes;
  final bool removeStoredImage;

  @override
  Widget build(BuildContext context) {
    return _EditorArtworkPreview(
      game: game,
      category: category,
      pendingBytes: pendingBytes,
      removeStoredImage: removeStoredImage,
      width: 54,
      height: 54,
      borderRadius: 14,
    );
  }
}

class _EditorArtworkPreview extends StatelessWidget {
  const _EditorArtworkPreview({
    required this.game,
    required this.category,
    required this.pendingBytes,
    required this.removeStoredImage,
    required this.width,
    required this.height,
    required this.borderRadius,
  });

  final Game? game;
  final GameCategory category;
  final Uint8List? pendingBytes;
  final bool removeStoredImage;
  final double width;
  final double height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final bytes = pendingBytes;
    if (bytes != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: SizedBox(
          width: width,
          height: height,
          child: Image.memory(
            bytes,
            fit: BoxFit.cover,
            filterQuality: FilterQuality.medium,
          ),
        ),
      );
    }

    final existingGame = game;
    if (existingGame != null) {
      return GameArtwork(
        game: removeStoredImage
            ? existingGame.copyWith(clearCustomImagePath: true)
            : existingGame,
        width: width,
        height: height,
        borderRadius: borderRadius,
      );
    }

    final scheme = Theme.of(context).colorScheme;
    final icon = switch (category) {
      GameCategory.video => Icons.sports_esports_rounded,
      GameCategory.card => Icons.style_rounded,
      GameCategory.sport => Icons.sports_soccer_rounded,
    };

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Icon(icon, color: scheme.onPrimaryContainer),
    );
  }
}
