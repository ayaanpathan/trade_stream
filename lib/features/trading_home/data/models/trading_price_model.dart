import 'package:trade_stream/features/trading_home/domain/entities/trading_price.dart';

class TradingPriceModel extends TradingPrice {
  TradingPriceModel({
    required super.symbol,
    required super.price,
    required super.volume,
  });

  factory TradingPriceModel.fromJson(Map<String, dynamic> json) {
    return TradingPriceModel(
      symbol: json['s'],
      price: json['p'].toDouble(),
      volume: json['v'].toDouble(),
    );
  }
}
