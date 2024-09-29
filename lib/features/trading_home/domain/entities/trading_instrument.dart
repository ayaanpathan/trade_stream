/// Represents a trading instrument with its associated information.
///
/// This class encapsulates the essential details of a tradable asset,
/// including its description, symbol, and current market data.
class TradingInstrument {
  /// A brief description of the trading instrument.
  final String description;

  /// The human-readable symbol used to display the instrument.
  final String displaySymbol;

  /// The unique identifier for the trading instrument.
  final String symbol;

  /// The current market price of the instrument.
  ///
  /// This value may be null if the price is not available.
  double? price;

  /// The price from the previous market tick.
  ///
  /// This can be used to calculate price changes. May be null if not available.
  double? previousTickPrice;

  /// The trading volume of the instrument.
  ///
  /// Represents the number of units traded. May be null if not available.
  double? volume;

  /// Creates a new [TradingInstrument] instance.
  ///
  /// [description], [displaySymbol], and [symbol] are required.
  /// [price], [previousTickPrice], and [volume] are optional and can be null.
  TradingInstrument({
    required this.description,
    required this.displaySymbol,
    required this.symbol,
    required this.price,
    required this.previousTickPrice,
    required this.volume,
  });
}
