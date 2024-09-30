import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trade_stream/core/widgets/connection_alert_dialog.dart';

void main() {
  testWidgets('ConnectionAlertDialog displays correct content',
      (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: ConnectionAlertDialog(),
      ),
    ));

    // Verify that the AlertDialog is present
    expect(find.byType(AlertDialog), findsOneWidget);

    // Verify the WiFi off icon
    expect(find.byIcon(Icons.wifi_off_rounded), findsOneWidget);

    // Verify the text message
    expect(
        find.text('Please check your internet connection...'), findsOneWidget);

    // Verify the CircularProgressIndicator
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
