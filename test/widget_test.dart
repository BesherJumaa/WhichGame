import 'package:flutter_test/flutter_test.dart';
import 'package:whichgame/main.dart';

void main() {
  testWidgets('shows the main game chooser', (tester) async {
    await tester.pumpWidget(const WhichGameApp());
    await tester.pump();

    expect(find.text('Which game i have to play ? '), findsOneWidget);
    expect(
      find.text('Turn on to choose between CS & General & BattleField'),
      findsOneWidget,
    );
  });
}
