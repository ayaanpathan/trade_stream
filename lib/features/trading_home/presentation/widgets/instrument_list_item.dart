import 'package:flutter/material.dart';
import 'package:trade_stream/core/consts.dart';
import 'package:trade_stream/features/trading_home/domain/entities/trading_instrument.dart';
import 'package:trade_stream/features/trading_home/presentation/widgets/price_widget.dart';
import 'package:trade_stream/features/trading_home/presentation/widgets/shimmer_price_widget.dart';

/// A widget that displays a single trading instrument item in a list.
///
/// This widget is used to show information about a trading instrument,
/// including its symbol, description, and current price.
class InstrumentListItem extends StatelessWidget {
  /// The trading instrument to display.
  final TradingInstrument instrument;

  /// Callback function to be called when the item is tapped.
  final VoidCallback onTap;

  /// Creates an [InstrumentListItem].
  ///
  /// The [instrument] and [onTap] parameters are required.
  const InstrumentListItem({
    super.key,
    required this.instrument,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    /// Determines if the price for the instrument has been loaded.
    final bool isPriceLoaded =
        instrument.price != null && instrument.price! > 0;

    return Card(
      margin: const EdgeInsets.symmetric(
        vertical: AppMargins.margin08,
        horizontal: AppMargins.margin16,
      ),
      color: AppColors.secondaryBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppMargins.margin16),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(AppMargins.margin16),
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF0F3443),
          child: Text(
            instrument.displaySymbol[0],
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        title: Text(
          instrument.displaySymbol,
          style:
              const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        subtitle: Text(
          instrument.description,
          style: TextStyle(color: Colors.white.withOpacity(0.7)),
        ),
        trailing: isPriceLoaded
            ? PriceWidget(
                price: instrument.price!,
                previousPrice:
                    instrument.previousTickPrice ?? instrument.price!,
              )
            : const ShimmerPriceWidget(),
        onTap: isPriceLoaded ? onTap : null,
      ),
    );
  }
}
