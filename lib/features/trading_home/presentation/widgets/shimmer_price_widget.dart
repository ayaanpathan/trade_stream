import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:trade_stream/core/consts.dart';

/// A widget that displays a shimmer effect for a price display.
///
/// This widget is typically used as a placeholder while loading actual price data.
/// It shows a shimmering effect on a row containing an upward arrow icon and a
/// placeholder price text.
class ShimmerPriceWidget extends StatelessWidget {
  /// Creates a ShimmerPriceWidget.
  ///
  /// The [key] parameter is optional and is used to control how one widget replaces
  /// another widget in the tree.
  const ShimmerPriceWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[500]!,
      highlightColor: Colors.grey[100]!,
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.arrow_upward,
            color: Colors.grey,
            size: AppMargins.margin16,
          ),
          SizedBox(width: AppMargins.margin04),
          Text(
            '00.000',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
