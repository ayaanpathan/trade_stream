class TradingInstrument {
  final String description;
  final String displaySymbol;
  final String symbol;
  double? price;
  double? previousTickPrice;
  double? volume;

  TradingInstrument({
    required this.description,
    required this.displaySymbol,
    required this.symbol,
    required this.price,
    required this.previousTickPrice,
    required this.volume,
  });
}
