import 'package:flutter/material.dart';
import 'package:trade_stream/core/consts.dart';
import 'package:trade_stream/core/utils/extensions.dart';

class PriceWidget extends StatelessWidget {
  final double price;
  final double previousPrice;

  const PriceWidget({
    super.key,
    required this.price,
    required this.previousPrice,
  });

  @override
  Widget build(BuildContext context) {
    final isPositive = price >= previousPrice;
    final color = isPositive ? Colors.green : Colors.red;

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
