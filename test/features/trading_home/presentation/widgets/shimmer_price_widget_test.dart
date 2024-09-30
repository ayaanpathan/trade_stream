import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shimmer/shimmer.dart';
import 'package:trade_stream/core/consts.dart';
import 'package:trade_stream/features/trading_home/presentation/widgets/shimmer_price_widget.dart';

void main() {
  group('ShimmerPriceWidget', () {
    testWidgets('renders correctly with shimmer effect',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ShimmerPriceWidget(),
          ),
        ),
      );

      // Verify Shimmer widget is present
      expect(find.byType(Shimmer), findsOneWidget);

      // Verify Row is present
      expect(find.byType(Row), findsOneWidget);

      // Verify Icon is present
      expect(find.byIcon(Icons.arrow_upward), findsOneWidget);

      // Verify Text is present
      expect(find.text('00.000'), findsOneWidget);

      // Verify Row properties
      final row = tester.widget<Row>(find.byType(Row));
      expect(row.mainAxisSize, MainAxisSize.min);

      // Verify Icon properties
      final icon = tester.widget<Icon>(find.byIcon(Icons.arrow_upward));
      expect(icon.color, Colors.grey);
      expect(icon.size, AppMargins.margin16);

      // Verify Text properties
      final text = tester.widget<Text>(find.text('00.000'));
      expect(text.style?.fontSize, 18);
      expect(text.style?.fontWeight, FontWeight.bold);
      expect(text.style?.color, Colors.grey);
    });
  });
}
