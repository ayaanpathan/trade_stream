import 'package:trade_stream/features/trading_home/domain/entities/trading_instrument.dart';

class TradingInstrumentModel extends TradingInstrument {
  TradingInstrumentModel({
    required super.description,
    required super.displaySymbol,
    required super.symbol,
    required super.price,
    required super.previousTickPrice,
    required super.volume,
  });

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
}
