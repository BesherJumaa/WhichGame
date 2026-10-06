import 'package:flutter/material.dart';

class SlideRight<T> extends PageRouteBuilder<T> {
  SlideRight({required Widget page})
    : super(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curvedAnimation = CurvedAnimation(
            parent: animation,
            curve: Curves.easeInCirc,
          );

          return ScaleTransition(
            scale: Tween<double>(begin: 0, end: 1).animate(curvedAnimation),
            child: Align(
              alignment: Alignment.center,
              child: FadeTransition(opacity: animation, child: child),
            ),
          );
        },
      );
}

abstract final class AppColor {
  static const Color gray = Color(0xFF838080);

  // Purple theme.
  static const Color primaryColor = Color(0xFF491396);
  static const Color secondColor = Color(0xFF7F14FF);
  static const Color thirdColor = Color(0xFF8A54DC);
  static const Color fourthColor = Color(0xFF7EE749);

  static const Color black = Color(0xFF000000);
  static const Color white = Color(0xFFFFFFFF);
  static const Color backGroundColor = Color(0xFFF8F9FC);
  static const Color green = Color(0xFF7EE749);
  static const Color red = Color(0xFFAD2626);

  static const MaterialColor primaryMaterialColor = Colors.deepPurple;
}

abstract final class AppLinks {
  static const String root = 'asset/';
  static const String appBar = '${root}appBar.json';
  static const String game = '${root}game.json';
  static const String start = '${root}start.json';
  static const String play = '${root}play.json';
  static const String button = '${root}button.json';
  static const String floating = '${root}floating.json';
}
