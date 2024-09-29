import 'dart:async';
import 'dart:math';
import 'package:trade_stream/features/trading_home/data/models/trading_instrument_model.dart';
import 'package:trade_stream/features/trading_home/data/models/trading_price_model.dart';
import 'package:trade_stream/features/trading_home/data/repository/trading_repository_interface.dart';

class MockTradingRepository implements TradingRepository {
  final _priceStreamController =
      StreamController<List<TradingPriceModel>>.broadcast();
  final _random = Random();
  Timer? _timer;
  final List<String> _subscribedSymbols = [];

  MockTradingRepository() {
    _startPriceUpdates();
  }

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
