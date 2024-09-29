import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:trade_stream/core/consts.dart';

/// A widget that displays a shimmer effect for a list item.
///
/// This widget is typically used as a placeholder while loading actual content.
/// It creates a shimmering effect over a card layout that resembles a list item
/// with a leading avatar, title, subtitle, and trailing element.
class ShimmerListItem extends StatelessWidget {
  /// Creates a [ShimmerListItem].
  ///
  /// The [key] parameter is optional and is used to control how one widget replaces
  /// another widget in the tree.
  const ShimmerListItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.shimmerBase,
      highlightColor: AppColors.shimmerHighlight,
      child: Card(
        margin: const EdgeInsets.symmetric(
          vertical: AppMargins.margin08,
          horizontal: AppMargins.margin16,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppMargins.margin16),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(AppMargins.margin16),
          leading: const CircleAvatar(
            backgroundColor: Colors.white,
          ),
          title: Container(
            width: double.infinity,
            height: 16,
            color: Colors.white,
          ),
          subtitle: Container(
            width: double.infinity,
            height: 12,
            color: Colors.white,
          ),
          trailing: Container(
            width: 60,
            height: 20,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
