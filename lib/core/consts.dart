import 'package:flutter/material.dart';
import 'package:trade_stream/core/env.dart';

/// A class containing application-wide constants.
class AppConstants {
  /// websocket api
  static String websocketApi = 'wss://ws.finnhub.io/?token=${Env.apiKey}';

  /// The maximum number of WebSocket symbol subscriptions allowed for a free account.
  static const int maxInstrumentsForFreeAccount = 50;

  /// Constants for different cryptocurrency exchanges.
  static const String binance = 'binance';
  static const String coinbase = 'coinbase';
  static const String gemini = 'gemini';

  /// Constant for the Oanda forex trading platform.
  static const String oanda = 'oanda';

  /// Constants for different types of financial instruments.
  static const String forex = 'forex';
  static const String crypto = 'crypto';
  static const String stocks = 'stocks';
}

/// A class containing predefined margin values for consistent spacing throughout the app.
class AppMargins {
  static const double margin0 = 0.0;
  static const double margin04 = 4.0;
  static const double margin08 = 8.0;
  static const double margin12 = 12.0;
  static const double margin16 = 16.0;
  static const double margin20 = 20.0;
  static const double margin24 = 24.0;
  static const double margin28 = 28.0;
  static const double margin32 = 32.0;
  static const double margin36 = 36.0;
  static const double margin40 = 40.0;
  static const double margin44 = 44.0;
  static const double margin48 = 48.0;
  static const double margin52 = 52.0;
  static const double margin56 = 56.0;
  static const double margin60 = 60.0;
  static const double margin64 = 64.0;
  static const double margin68 = 68.0;
  static const double margin72 = 72.0;
  static const double margin76 = 76.0;
  static const double margin80 = 80.0;
  static const double margin84 = 84.0;
  static const double margin88 = 88.0;
  static const double margin92 = 92.0;
  static const double margin96 = 96.0;
  static const double margin100 = 100.0;
  static const double margin104 = 104.0;
  static const double margin108 = 108.0;
  static const double margin112 = 112.0;
  static const double margin116 = 116.0;
  static const double margin120 = 120.0;
}

/// A class containing color constants used throughout the application.
class AppColors {
  /// The primary background color of the app.
  static const Color primaryBackground = Color(0xFF1A1A2E);

  /// The secondary background color, used for elements like cards or dialogs.
  static const Color secondaryBackground = Color(0xFF16213E);

  /// The main accent color of the app.
  static const Color accentColor = Color(0xFF0F3443);

  /// A lighter shade of the accent color, used for highlights or contrasts.
  static const Color accentColorLight = Color(0xFF34E89E);

  /// The primary text color.
  static const Color textPrimary = Colors.white;

  /// The secondary text color, typically used for less emphasized text.
  static const Color textSecondary = Colors.white70;

  /// The base color for shimmer effects.
  static const Color shimmerBase = Color(0xFF16213E);

  /// The highlight color for shimmer effects.
  static const Color shimmerHighlight = Color(0xFF0F3443);
}
