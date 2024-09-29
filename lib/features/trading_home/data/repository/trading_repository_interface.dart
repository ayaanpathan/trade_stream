import 'package:trade_stream/features/trading_home/data/models/trading_instrument_model.dart';
import 'package:trade_stream/features/trading_home/data/models/trading_price_model.dart';

abstract class TradingRepository {
  Stream<List<TradingPriceModel>> getPriceForTradingInstruments();
  Future<void> subscribe(String symbol);
  Future<void> unsubscribe(String symbol);
  Future<List<TradingInstrumentModel>> getTradingInstruments(String market);
  Future<void> close();
  Future<void> connect();
}
