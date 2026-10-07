import 'package:flutter/material.dart';
import 'package:whichgame/core/localization/app_language.dart';
import 'package:whichgame/presentation/app_scope.dart';

class AppLanguageButton extends StatelessWidget {
  const AppLanguageButton({this.targetKey, super.key});

  final GlobalKey? targetKey;

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    final nextLanguage = controller.language == AppLanguage.english
        ? AppLanguage.arabic
        : AppLanguage.english;

    return IconButton(
      key: targetKey,
      tooltip: nextLanguage.nativeLabel,
      onPressed: () async {
        await controller.setLanguage(nextLanguage);
      },
      icon: const Icon(Icons.language_rounded),
    );
  }
}
