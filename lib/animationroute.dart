import 'package:flutter/material.dart';

class SlideRight extends PageRouteBuilder {
  final Page;
  SlideRight({this.Page})
      : super(
            pageBuilder: (context, animation, animationtow) => Page,
            transitionsBuilder: (context, animation, animationtow, child) {
              //  var begin = Offset(1, 1);
              //  var end = Offset(0, 0);
              Duration(seconds: 3);
              double begin = 0;
              double end = 1;
              var tween = Tween(begin: begin, end: end);
              var curvesanimation =
                  CurvedAnimation(parent: animation, curve: Curves.easeInCirc);
              return ScaleTransition(
                  scale: tween.animate(curvesanimation),
                  child: Align(
                    alignment: Alignment.center,
                    child: FadeTransition(
                      opacity: animation,
                      child: child,
                    ),
                  ));
              // Align(
              //   alignment: Alignment.center,
              //   child: SizeTransition(
              //     sizeFactor: animation,
              //     child: child,
              //   )
              //     FadeTransition(
              //   opacity: animation,
              //   child: child,
              // );
            });
}

class AppColor {
  static const Color gray = Color(0xff838080);
  //-----------------Orange Theme
  // static const Color primaryColor = Color(0xffe55f25);
  // static const Color secondColor = Color(0xffd25d1e);
  // static const Color thirdColor = Color(0xffff7765);
  // ----------------Purple Theme
  static const Color primaryColor = Color(0xff491396);
  static const Color secondColor = Color(0xff7f14ff);
  static const Color thirdColor = Color(0xff8a54dc);
  // -------------Green Theme
  // static const Color primaryColor = Color(0xff067208);
  // static const Color secondColor = Color(0xff19ad1d);
  // static const Color thirdColor = Color(0xff52ef55);
  // ---------Blue
  // static const Color primaryColor = Color(0xe0050942);
  // static const Color secondColor = Color(0xff242c8d);
  // static const Color thirdColor = Color(0xe02e38ad);
  static const Color fourthColor = Color(0xff7ee749);
  // static const Color primaryColor = Color(0xff2535e5);
  // static const Color secondColor = Color(0xff1e51d2);
  // static const Color thirdColor = Color(0xff6584ff);
  static const Color black = Color(0xff000000);
  static const Color white = Color(0xffffffff);
  static const Color backGroundColor = Color(0xfff8f9fc);
  static const Color green = Color(0xFF7EE749);
  static const Color red = Color(0xFFAD2626);

  // static const MaterialColor primarymaterialcolor = Colors.deepOrange;
  static const MaterialColor primarymaterialcolor = Colors.deepPurple;
// static const MaterialColor primarymaterialcolor = Colors.green;
// static const MaterialColor primarymaterialcolor = Colors.indigo;
}

class AppLinks {
  static const root = "asset/";
  static const appBar = "asset/appBar.json";
  static const game = "asset/game.json";
  static const start = "asset/start.json";
  static const play = "asset/play.json";
  static const button = "asset/button.json";
  static const floating = "asset/floating.json";
}
