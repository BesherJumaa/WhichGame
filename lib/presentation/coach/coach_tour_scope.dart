import 'package:flutter/widgets.dart';

class CoachTourScope extends InheritedWidget {
  const CoachTourScope({
    required this.startTour,
    required super.child,
    super.key,
  });

  final VoidCallback startTour;

  static CoachTourScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<CoachTourScope>();
  }

  @override
  bool updateShouldNotify(CoachTourScope oldWidget) =>
      oldWidget.startTour != startTour;
}
