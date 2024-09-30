import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shimmer/shimmer.dart';
import 'package:trade_stream/core/consts.dart';
import 'package:trade_stream/features/trading_home/presentation/widgets/shimmer_list_item.dart';

void main() {
  group('ShimmerListItem', () {
    testWidgets('renders correctly with shimmer effect',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ShimmerListItem(),
          ),
        ),
      );

      // Verify Shimmer widget is present
      expect(find.byType(Shimmer), findsOneWidget);

      // Verify Card widget is present
      expect(find.byType(Card), findsOneWidget);

      // Verify ListTile is present
      expect(find.byType(ListTile), findsOneWidget);

      // Verify CircleAvatar is present for the leading widget
      expect(find.byType(CircleAvatar), findsOneWidget);

      // Verify containers for title, subtitle, and trailing are present
      expect(find.byType(Container), findsNWidgets(4));

      // Verify Card properties
      final card = tester.widget<Card>(find.byType(Card));
      expect(
          card.margin,
          const EdgeInsets.symmetric(
            vertical: AppMargins.margin08,
            horizontal: AppMargins.margin16,
          ));
      expect(card.shape, isA<RoundedRectangleBorder>());

      // Verify ListTile properties
      final listTile = tester.widget<ListTile>(find.byType(ListTile));
      expect(
          listTile.contentPadding, const EdgeInsets.all(AppMargins.margin16));
    });
  });
}
