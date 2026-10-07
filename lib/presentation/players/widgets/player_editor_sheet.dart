import 'package:flutter/material.dart';
import 'package:whichgame/core/constants/app_strings.dart';
import 'package:whichgame/domain/models/player_profile.dart';

class PlayerEditorResult {
  const PlayerEditorResult({required this.name, required this.permanent});

  final String name;
  final bool permanent;
}

Future<PlayerEditorResult?> showPlayerEditorSheet(
  BuildContext context, {
  PlayerProfile? player,
}) {
  return showModalBottomSheet<PlayerEditorResult>(
    context: context,
    showDragHandle: true,
    useSafeArea: true,
    isScrollControlled: true,
    builder: (context) => _PlayerEditorSheet(player: player),
  );
}

class _PlayerEditorSheet extends StatefulWidget {
  const _PlayerEditorSheet({this.player});

  final PlayerProfile? player;

  @override
  State<_PlayerEditorSheet> createState() => _PlayerEditorSheetState();
}

class _PlayerEditorSheetState extends State<_PlayerEditorSheet> {
  late final TextEditingController _nameController;
  late bool _permanent;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.player?.name ?? '');
    _permanent = widget.player == null || !widget.player!.isGuest;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      return;
    }
    Navigator.of(context).pop(
      PlayerEditorResult(name: name, permanent: _permanent),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.viewInsetsOf(context);
    final scheme = Theme.of(context).colorScheme;
    final isEditing = widget.player != null;

    return Padding(
      padding: EdgeInsets.fromLTRB(22, 2, 22, 24 + viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isEditing ? AppStrings.editPlayer : AppStrings.addPlayer,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          Text(
            AppStrings.playerCacheHint,
            style: TextStyle(color: scheme.onSurfaceVariant, height: 1.4),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _nameController,
            autofocus: !isEditing,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.done,
            onSubmitted: (value) => _submit(),
            decoration: InputDecoration(
              labelText: AppStrings.playerName,
              hintText: AppStrings.playerNameHint,
              prefixIcon: const Icon(Icons.person_outline_rounded),
            ),
          ),
          const SizedBox(height: 14),
          SwitchListTile.adaptive(
            value: _permanent,
            onChanged: (value) => setState(() => _permanent = value),
            contentPadding: const EdgeInsets.symmetric(horizontal: 4),
            title: Text(
              _permanent
                  ? AppStrings.permanentPlayer
                  : AppStrings.guestPlayer,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            subtitle: Text(
              _permanent
                  ? AppStrings.permanentPlayerHint
                  : AppStrings.guestPlayerHint,
            ),
            secondary: Icon(
              _permanent
                  ? Icons.save_outlined
                  : Icons.person_add_alt_1_rounded,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _submit,
              icon: Icon(isEditing ? Icons.save_rounded : Icons.add_rounded),
              label: Text(
                isEditing ? AppStrings.saveChanges : AppStrings.addPlayer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
