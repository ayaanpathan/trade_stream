import 'dart:async';
import 'dart:math';
import 'package:trade_stream/features/trading_home/data/models/trading_instrument_model.dart';
import 'package:trade_stream/features/trading_home/data/models/trading_price_model.dart';
import 'package:trade_stream/features/trading_home/data/repository/trading_repository_interface.dart';

/// A mock implementation of the [TradingRepository] interface for testing and development purposes.
///
/// This class simulates real-time price updates for trading instruments and provides
/// methods to subscribe to and unsubscribe from price updates for specific symbols.
class MockTradingRepository implements TradingRepository {
  /// StreamController for broadcasting price updates.
  final _priceStreamController =
      StreamController<List<TradingPriceModel>>.broadcast();

  /// Random number generator for simulating price and volume data.
  final _random = Random();

  /// Timer for periodic price updates.
  Timer? _timer;

  /// List of symbols currently subscribed for price updates.
  final List<String> _subscribedSymbols = [];

  /// Creates a new instance of [MockTradingRepository] and starts price updates.
  MockTradingRepository() {
    _startPriceUpdates();
  }

  /// Starts periodic price updates for subscribed symbols.
  void _startPriceUpdates() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_subscribedSymbols.isNotEmpty) {
        final updatedPrices = _subscribedSymbols.map((symbol) {
          return TradingPriceModel(
            symbol: symbol,
            price: _random.nextDouble() * 1,
            volume: _random.nextInt(1).toDouble(),
          );
        }).toList();
        _priceStreamController.add(updatedPrices);
      }
    });
  }

  @override
  Stream<List<TradingPriceModel>> getPriceForTradingInstruments() {
    return _priceStreamController.stream;
  }

  @override
  Future<void> subscribe(String symbol) async {
    if (!_subscribedSymbols.contains(symbol)) {
      _subscribedSymbols.add(symbol);
    }
  }

  @override
  Future<void> unsubscribe(String symbol) async {
    _subscribedSymbols.remove(symbol);
  }

  @override
  Future<List<TradingInstrumentModel>> getTradingInstruments(
      String market) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));

    final instruments = List.generate(20, (index) {
      final symbol = '${market.toUpperCase()}$index';
      return TradingInstrumentModel(
        symbol: symbol,
        displaySymbol: symbol,
        description: 'Mock $market instrument $index',
        price: _random.nextDouble() * 1,
        volume: _random.nextInt(1).toDouble(),
        previousTickPrice: _random.nextDouble() * 1,
      );
    });

    return instruments;
  }

  @override
  Future<void> close() async {
    _timer?.cancel();
    await _priceStreamController.close();
  }

  @override
  Future<void> connect() async {
    // Simulate connection delay
    await Future.delayed(const Duration(seconds: 1));
  }
}
