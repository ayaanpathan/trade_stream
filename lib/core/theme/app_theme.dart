import 'package:flutter/material.dart';

/// A class that provides theme-related functionality for the application.
class AppTheme {
  /// Builds and returns a dark theme for the application.
  ///
  /// This method creates a custom dark theme based on [ThemeData.dark()],
  /// with specific modifications to various theme properties.
  ///
  /// Returns:
  ///   A [ThemeData] object representing the custom dark theme.
  static ThemeData buildDarkTheme() {
    final ThemeData base = ThemeData.dark();
    return base.copyWith(
      // Sets the primary color to a dark blue-grey shade.
      primaryColor: Colors.blueGrey[800],
      // Sets the scaffold background color to a very dark grey.
      scaffoldBackgroundColor: Colors.grey[900],
      // Customizes the app bar appearance.
      appBarTheme: AppBarTheme(
        color: Colors.blueGrey[900],
        elevation: 0,
      ),
      // Defines the default style for cards in the app.
      cardTheme: CardTheme(
        color: Colors.grey[850],
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      // Customizes the appearance of input fields.
      inputDecorationTheme: InputDecorationTheme(
        fillColor: Colors.grey[800],
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  // You can add more theme-related methods here in the future
}
