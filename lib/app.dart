import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:whichgame/core/constants/app_strings.dart';
import 'package:whichgame/core/theme/app_theme.dart';
import 'package:whichgame/presentation/app_controller.dart';
import 'package:whichgame/presentation/app_scope.dart';
import 'package:whichgame/presentation/shell/app_shell.dart';

class WhichGameApp extends StatelessWidget {
  const WhichGameApp({required this.controller, super.key});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    // Keep the InheritedNotifier stable. Rebuilding/replacing an inherited
    // scope at the same time its dependents are reacting to the same
    // ChangeNotifier can trigger framework dependency assertions in debug
    // mode. Only MaterialApp needs to rebuild for locale/title changes.
    return AppScope(
      controller: controller,
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          return MaterialApp(
            title: AppStrings.appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: ThemeMode.system,
            locale: controller.language.locale,
            supportedLocales: const [Locale('en'), Locale('ar')],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: const AppShell(),
          );
        },
      ),
    );
  }
}
