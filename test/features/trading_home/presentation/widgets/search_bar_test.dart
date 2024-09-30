import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trade_stream/core/consts.dart';
import 'package:trade_stream/features/trading_home/presentation/widgets/search_bar.dart';

void main() {
  group('HomeSearchBar', () {
    testWidgets('renders correctly with given properties',
        (WidgetTester tester) async {
      final controller = TextEditingController();
      String? changedValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HomeSearchBar(
              controller: controller,
              onChanged: (value) => changedValue = value,
            ),
          ),
        ),
      );

      // Verify the TextField is rendered
      expect(find.byType(TextField), findsOneWidget);

      // Verify the hint text
      expect(find.text('Search symbols..'), findsOneWidget);

      // Verify the search icon
      expect(find.byIcon(Icons.search), findsOneWidget);

      // Verify the padding
      final paddingFinder = find.byType(Padding);
      expect(paddingFinder, findsOneWidget);
      final padding = tester.widget<Padding>(paddingFinder);
      expect(padding.padding, const EdgeInsets.all(AppMargins.margin04));

      // Verify the TextField decoration
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.decoration?.filled, true);
      expect(textField.decoration?.fillColor, AppColors.secondaryBackground);
      expect(textField.decoration?.border, isA<OutlineInputBorder>());

      // Verify the text style
      expect(textField.style?.color, AppColors.textPrimary);

      // Test onChanged callback
      await tester.enterText(find.byType(TextField), 'AAPL');
      expect(changedValue, 'AAPL');
    });

    testWidgets('updates text when controller changes',
        (WidgetTester tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HomeSearchBar(
              controller: controller,
              onChanged: (_) {},
            ),
          ),
        ),
      );

      // Update the controller
      controller.text = 'GOOGL';
      await tester.pump();

      // Verify the text field shows the updated text
      expect(find.text('GOOGL'), findsOneWidget);
    });
  });
}
