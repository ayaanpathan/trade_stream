import 'package:flutter/material.dart';
import 'package:trade_stream/core/consts.dart';
import 'package:trade_stream/core/utils/extensions.dart';

/// A widget that displays a price with an indicator showing whether it has increased or decreased.
///
/// This widget shows the current price along with an up or down arrow icon to indicate
/// the price movement compared to a previous price.
class PriceWidget extends StatelessWidget {
  /// The current price to display.
  final double price;

  /// The previous price used to determine if the current price has increased or decreased.
  final double previousPrice;

  /// Creates a PriceWidget.
  ///
  /// [price] is the current price to display.
  /// [previousPrice] is used to determine if the price has increased or decreased.
  const PriceWidget({
    super.key,
    required this.price,
    required this.previousPrice,
  });

  @override
  Widget build(BuildContext context) {
    final isPositive = price >= previousPrice;
    final color = isPositive ? AppColors.accentColorLight : Colors.red;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isPositive ? Icons.arrow_upward : Icons.arrow_downward,
              color: color,
              size: AppMargins.margin16,
            ),
            const SizedBox(width: AppMargins.margin04),
            Text(
              price.toUSD(price),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
