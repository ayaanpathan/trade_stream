import 'package:trade_stream/features/trading_home/domain/entities/trading_instrument.dart';

/// A model class representing a trading instrument.
///
/// This class extends [TradingInstrument] and provides additional functionality
/// for JSON serialization and deserialization.
class TradingInstrumentModel extends TradingInstrument {
  /// Creates a new [TradingInstrumentModel] instance.
  ///
  /// All parameters are required and are passed to the superclass constructor.
  TradingInstrumentModel({
    required super.description,
    required super.displaySymbol,
    required super.symbol,
    required super.price,
    required super.previousTickPrice,
    required super.volume,
  });

  /// Creates a [TradingInstrumentModel] from a JSON map.
  ///
  /// This factory constructor takes a [Map<String, dynamic>] and creates
  /// a new [TradingInstrumentModel] instance from it. If 'price', 'previousTickPrice',
  /// or 'volume' are not present in the JSON, they default to 0.
  ///
  /// [json] The JSON map to create the model from.
  ///
  /// Returns a new [TradingInstrumentModel] instance.
  factory TradingInstrumentModel.fromJson(Map<String, dynamic> json) {
    return TradingInstrumentModel(
      description: json['description'],
      displaySymbol: json['displaySymbol'],
      symbol: json['symbol'],
      price: json['price'] ?? 0,
      previousTickPrice: json['previousTickPrice'] ?? 0,
      volume: json['volume'] ?? 0,
    );
  }

  /// Converts this [TradingInstrumentModel] to a JSON map.
  ///
  /// Returns a [Map<String, dynamic>] representing this model.
  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'displaySymbol': displaySymbol,
      'symbol': symbol,
      'price': price,
      'previousTickPrice': previousTickPrice,
      'volume': volume,
    };
  }

  /// Creates a new [TradingInstrumentModel] instance from a [TradingInstrument].
  ///
  /// This factory constructor takes a [TradingInstrument] and creates
  /// a new [TradingInstrumentModel] instance from it. If 'price', 'previousTickPrice',
  /// or 'volume' are not present in the JSON, they default to 0.
  ///
  /// [instrument] The [TradingInstrument] to create the model from.
  ///
  /// [newPrice] The new price to use. Defaults to the price of the [instrument].
  ///
  /// [newVolume] The new volume to use. Defaults to the volume of the [instrument].
  ///
  /// Returns a new [TradingInstrumentModel] instance.
  factory TradingInstrumentModel.fromTradingInstrument(
    TradingInstrument instrument, {
    double? newPrice,
    double? newVolume,
  }) {
    return TradingInstrumentModel(
      symbol: instrument.symbol,
      previousTickPrice: instrument.price,
      price: newPrice ?? instrument.price,
      volume: newVolume ?? instrument.volume,
      description: instrument.description,
      displaySymbol: instrument.displaySymbol,
      // Add other properties here
    );
  }
}
