import 'package:flutter/material.dart';
import 'package:whichgame/core/localization/app_language.dart';
import 'package:whichgame/presentation/app_scope.dart';

class AppLanguageButton extends StatelessWidget {
  const AppLanguageButton({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    final nextLanguage = controller.language == AppLanguage.english
        ? AppLanguage.arabic
        : AppLanguage.english;

    return IconButton(
      tooltip: nextLanguage.nativeLabel,
      onPressed: () async {
        // A direct toggle avoids rebuilding the app while a popup route is
        // being dismissed, which is both faster and safer on Flutter debug
        // builds. The controller notifies the whole localized UI immediately.
        await controller.setLanguage(nextLanguage);
      },
      icon: const Icon(Icons.language_rounded),
    );
  }
}
