import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trade_stream/core/consts.dart';
import 'package:trade_stream/core/utils/extensions.dart';
import 'package:trade_stream/features/trading_home/presentation/widgets/price_widget.dart';

void main() {
  group('PriceWidget', () {
    testWidgets(
        'displays correct price and positive indicator when price increases',
        (WidgetTester tester) async {
      const currentPrice = 150.0;
      const previousPrice = 145.0;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body:
                PriceWidget(price: currentPrice, previousPrice: previousPrice),
          ),
        ),
      );

      // Check if the price is displayed correctly
      expect(find.text(currentPrice.toUSD(currentPrice)), findsOneWidget);

      // Check if the up arrow is displayed
      expect(find.byIcon(Icons.arrow_upward), findsOneWidget);

      // Check if the color is correct for positive change
      final text =
          tester.widget<Text>(find.text(currentPrice.toUSD(currentPrice)));
      expect(text.style?.color, AppColors.accentColorLight);

      final icon = tester.widget<Icon>(find.byIcon(Icons.arrow_upward));
      expect(icon.color, AppColors.accentColorLight);
    });

    testWidgets(
        'displays correct price and negative indicator when price decreases',
        (WidgetTester tester) async {
      const currentPrice = 140.0;
      const previousPrice = 145.0;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body:
                PriceWidget(price: currentPrice, previousPrice: previousPrice),
          ),
        ),
      );

      // Check if the price is displayed correctly
      expect(find.text(currentPrice.toUSD(currentPrice)), findsOneWidget);

      // Check if the down arrow is displayed
      expect(find.byIcon(Icons.arrow_downward), findsOneWidget);

      // Check if the color is correct for negative change
      final text =
          tester.widget<Text>(find.text(currentPrice.toUSD(currentPrice)));
      expect(text.style?.color, Colors.red);

      final icon = tester.widget<Icon>(find.byIcon(Icons.arrow_downward));
      expect(icon.color, Colors.red);
    });

    testWidgets(
        'displays correct price and positive indicator when price remains the same',
        (WidgetTester tester) async {
      const currentPrice = 145.0;
      const previousPrice = 145.0;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body:
                PriceWidget(price: currentPrice, previousPrice: previousPrice),
          ),
        ),
      );

      // Check if the price is displayed correctly
      expect(find.text(currentPrice.toUSD(currentPrice)), findsOneWidget);

      // Check if the up arrow is displayed (since it's considered positive when equal)
      expect(find.byIcon(Icons.arrow_upward), findsOneWidget);

      // Check if the color is correct for positive change
      final text =
          tester.widget<Text>(find.text(currentPrice.toUSD(currentPrice)));
      expect(text.style?.color, AppColors.accentColorLight);

      final icon = tester.widget<Icon>(find.byIcon(Icons.arrow_upward));
      expect(icon.color, AppColors.accentColorLight);
    });
  });
}
