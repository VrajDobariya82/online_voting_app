import 'package:flutter_test/flutter_test.dart';

import 'package:online_voting_app/main.dart';

void main() {
  testWidgets('SmartVote app loads', (WidgetTester tester) async {
    await tester.pumpWidget(const SmartVoteApp());

    expect(find.text('SmartVote'), findsOneWidget);
  });
}
