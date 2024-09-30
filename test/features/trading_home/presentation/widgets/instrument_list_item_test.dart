import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trade_stream/core/consts.dart';
import 'package:trade_stream/features/trading_home/domain/entities/trading_instrument.dart';
import 'package:trade_stream/features/trading_home/presentation/widgets/instrument_list_item.dart';
import 'package:trade_stream/features/trading_home/presentation/widgets/price_widget.dart';
import 'package:trade_stream/features/trading_home/presentation/widgets/shimmer_price_widget.dart';

void main() {
  group('InstrumentListItem', () {
    testWidgets('displays correct information when price is loaded',
        (WidgetTester tester) async {
      final instrument = TradingInstrument(
        symbol: 'AAPL',
        description: 'Apple Inc.',
        displaySymbol: 'AAPL',
        price: 150.0,
        previousTickPrice: 147.5,
        volume: 1000000,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InstrumentListItem(instrument: instrument, onTap: () {}),
          ),
        ),
      );

      // Verify that the widget displays the correct symbol
      expect(find.text('AAPL'), findsOneWidget);

      // Verify that the widget displays the correct description
      expect(find.text('Apple Inc.'), findsOneWidget);

      // Verify that the PriceWidget is displayed
      expect(find.byType(PriceWidget), findsOneWidget);

      // Verify that the Card has the correct color
      final card = tester.widget<Card>(find.byType(Card));
      expect(card.color, AppColors.secondaryBackground);

      // Verify that the ListTile is tappable
      final listTile = tester.widget<ListTile>(find.byType(ListTile));
      expect(listTile.onTap, isNotNull);
    });

    testWidgets('displays ShimmerPriceWidget when price is not loaded',
        (WidgetTester tester) async {
      final instrument = TradingInstrument(
        symbol: 'AAPL',
        description: 'Apple Inc.',
        displaySymbol: 'AAPL',
        price: null,
        previousTickPrice: null,
        volume: 1000000,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InstrumentListItem(instrument: instrument, onTap: () {}),
          ),
        ),
      );

      // Verify that the ShimmerPriceWidget is displayed
      expect(find.byType(ShimmerPriceWidget), findsOneWidget);

      // Verify that the ListTile is not tappable
      final listTile = tester.widget<ListTile>(find.byType(ListTile));
      expect(listTile.onTap, isNull);
    });
  });
}
