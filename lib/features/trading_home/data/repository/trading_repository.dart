import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:trade_stream/core/consts.dart';
import 'package:trade_stream/core/env.dart';
import 'package:trade_stream/features/trading_home/data/models/trading_instrument_model.dart';
import 'package:trade_stream/features/trading_home/data/models/trading_price_model.dart';

import 'package:trade_stream/features/trading_home/data/repository/trading_repository_interface.dart';
import 'package:trade_stream/core/network/websocket_service.dart';

class TradingRepositoryImpl implements TradingRepository {
  final WebSocketService webSocketService;
  late final StreamController<List<TradingPriceModel>> _priceStreamController;

  TradingRepositoryImpl(this.webSocketService) {
    _priceStreamController =
        StreamController<List<TradingPriceModel>>.broadcast();
    _initPriceStream();
  }

  void _initPriceStream() {
    webSocketService.getPriceForTradingInstruments().listen(
      (prices) {
        _priceStreamController.add(prices);
      },
      onError: (error) {
        _priceStreamController.addError(error);
      },
    );
  }

  @override
  Stream<List<TradingPriceModel>> getPriceForTradingInstruments() {
    return _priceStreamController.stream;
  }

  @override
  Future<void> subscribe(String symbol) async {
    await webSocketService.subscribe(symbol);
  }

  @override
  Future<void> unsubscribe(String symbol) async {
    await webSocketService.unsubscribe(symbol);
  }

  @override
  Future<void> close() async {
    await webSocketService.close();
    await _priceStreamController.close();
  }

  @override
  Future<void> connect() async {
    await webSocketService.connect();
  }

  @override
  Future<List<TradingInstrumentModel>> getTradingInstruments(
      String market) async {
    print('market: $market');
    print(
        'exchange: ${market == AppConstants.crypto ? AppConstants.binance : AppConstants.oanda}');
    final response = await http.get(
      Uri.parse(
          'https://finnhub.io/api/v1/$market/symbol?exchange=${market == AppConstants.crypto ? AppConstants.binance : AppConstants.oanda}&token=${Env.apiToken}'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonResponse = json.decode(response.body);
      final tradingSymbols = jsonResponse
          .take(AppConstants.maxInstrumentsForFreeAccount)
          .map((json) => TradingInstrumentModel.fromJson(json))
          .toList();
      return tradingSymbols;
    } else {
      throw Exception(response.body);
    }
  }
}
