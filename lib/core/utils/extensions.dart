extension PriceFormatting on double {
  String toUSD(double price) {
    return price.toStringAsFixed(5);
  }
}

extension PercentageFormatting on double {
  String toPercentage() {
    return '${this >= 0 ? '+' : ''}${toStringAsFixed(2)}%';
  }
}
