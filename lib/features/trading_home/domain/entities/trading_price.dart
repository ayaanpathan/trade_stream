/// Represents the price information for a trading instrument.
///
/// This class encapsulates the essential details of a trading price update,
/// including the instrument's symbol, current price, and trading volume.
class TradingPrice {
  /// The unique identifier for the trading instrument.
  final String symbol;

  /// The current market price of the instrument.
  final double price;

  /// The trading volume of the instrument.
  ///
  /// Represents the number of units traded in the latest update.
  final double volume;

  /// Creates a new [TradingPrice] instance.
  ///
  /// [symbol] is the unique identifier for the trading instrument.
  /// [price] is the current market price of the instrument.
  /// [volume] is the trading volume for this price update.
  TradingPrice({
    required this.symbol,
    required this.price,
    required this.volume,
  });
}
