import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App test harness builds', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('Caresoko test harness'),
          ),
        ),
      ),
    );

    expect(find.text('Caresoko test harness'), findsOneWidget);
  });
}
