// This is a basic Flutter widget test for the Reminder App.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:reminder_app/main.dart';

void main() {
  testWidgets('Reminder App loads correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ReminderApp());

    // Wait for async operations to complete
    await tester.pumpAndSettle();

    // Verify that our app loads with the expected UI elements.
    expect(find.text('My Reminders'), findsOneWidget);
  });
}
