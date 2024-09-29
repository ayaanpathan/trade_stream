import 'package:flutter/material.dart';
import 'package:trade_stream/core/consts.dart';
import 'package:trade_stream/features/trading_home/domain/entities/trading_instrument.dart';
import 'package:trade_stream/features/trading_home/presentation/widgets/price_widget.dart';

class InstrumentListItem extends StatelessWidget {
  final TradingInstrument instrument;
  final VoidCallback onTap;

  const InstrumentListItem({
    super.key,
    required this.instrument,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
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
        trailing: PriceWidget(
          price: instrument.price!,
          previousPrice: instrument.previousTickPrice!,
        ),
        onTap: onTap,
      ),
    );
  }
}
