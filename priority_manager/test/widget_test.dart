import 'package:flutter_test/flutter_test.dart';
import 'package:priority_manager/main.dart';

void main() {
  testWidgets('App loads and shows home screen', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.text('Tasks'), findsOneWidget);
  });
}