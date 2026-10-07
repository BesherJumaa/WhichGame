import 'package:flutter/material.dart';

/// Ensures modal-sheet content never sits underneath the system gesture area.
///
/// `showModalBottomSheet(useSafeArea: true)` protects the top/left/right of a
/// sheet, but bottom sheets intentionally extend to the bottom edge. Wrapping
/// the content with this widget adds the missing bottom protection while still
/// allowing keyboard-aware children to use `MediaQuery.viewInsets` normally.
class AppBottomSheetSafeArea extends StatelessWidget {
  const AppBottomSheetSafeArea({
    required this.child,
    this.minimumBottom = 10,
    super.key,
  });

  final Widget child;
  final double minimumBottom;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      minimum: EdgeInsets.only(bottom: minimumBottom),
      child: child,
    );
  }
}
