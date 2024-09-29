import 'package:trade_stream/features/trading_home/data/models/trading_instrument_model.dart';
import 'package:trade_stream/features/trading_home/data/models/trading_price_model.dart';

/// An abstract class defining the interface for a trading repository.
///
/// This repository is responsible for managing trading-related data operations,
/// including price updates, instrument subscriptions, and market data retrieval.
abstract class TradingRepository {
  /// Returns a stream of price updates for subscribed trading instruments.
  ///
  /// The stream emits a list of [TradingPriceModel] objects, each representing
  /// the latest price information for a subscribed instrument.
  Stream<List<TradingPriceModel>> getPriceForTradingInstruments();

  /// Subscribes to price updates for a specific trading instrument.
  ///
  /// [symbol] is the unique identifier for the instrument to subscribe to.
  Future<void> subscribe(String symbol);

  /// Unsubscribes from price updates for a specific trading instrument.
  ///
  /// [symbol] is the unique identifier for the instrument to unsubscribe from.
  Future<void> unsubscribe(String symbol);

  /// Retrieves a list of trading instruments for a specific market.
  ///
  /// [market] is the identifier for the market (e.g., 'forex', 'crypto').
  /// Returns a list of [TradingInstrumentModel] objects representing the available
  /// instruments in the specified market.
  Future<List<TradingInstrumentModel>> getTradingInstruments(String market);

  /// Closes the repository and releases any resources.
  ///
  /// This method should be called when the repository is no longer needed.
  Future<void> close();

  /// Establishes a connection to the trading data source.
  ///
  /// This method should be called before performing any operations with the repository.
  Future<void> connect();
}
