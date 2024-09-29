import 'package:trade_stream/features/trading_home/domain/entities/trading_price.dart';

/// A model class representing trading price information.
///
/// This class extends [TradingPrice] and provides functionality to create
/// instances from JSON data.
class TradingPriceModel extends TradingPrice {
  /// Creates a [TradingPriceModel] instance.
  ///
  /// [symbol] is the trading symbol.
  /// [price] is the current price of the asset.
  /// [volume] is the trading volume.
  TradingPriceModel({
    required super.symbol,
    required super.price,
    required super.volume,
  });

  /// Creates a [TradingPriceModel] instance from a JSON map.
  ///
  /// [json] is a map containing the trading price data.
  ///
  /// Returns a new [TradingPriceModel] instance.
  factory TradingPriceModel.fromJson(Map<String, dynamic> json) {
    return TradingPriceModel(
      symbol: json['s'],
      price: json['p'].toDouble(),
      volume: json['v'].toDouble(),
    );
  }
}
