/// Extension on [double] for formatting prices.
extension PriceFormatting on double {
  /// Converts a price to a USD string representation with 5 decimal places.
  ///
  /// [price] The price to be formatted.
  ///
  /// Returns a string representation of the price with 5 decimal places.
  String toUSD(double price) {
    return price.toStringAsFixed(5);
  }
}

/// Extension on [double] for formatting percentages.
extension PercentageFormatting on double {
  /// Converts a number to a percentage string representation.
  ///
  /// The resulting string includes a '+' sign for positive numbers,
  /// and is formatted to 2 decimal places.
  ///
  /// Returns a string representation of the number as a percentage.
  String toPercentage() {
    return '${this >= 0 ? '+' : ''}${toStringAsFixed(2)}%';
  }
}

/// Extension on [String] for text manipulation.
extension StringExtension on String {
  /// Capitalizes the first letter of the string.
  ///
  /// Returns a new string with the first letter capitalized
  /// and the rest of the string in lowercase.
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}
