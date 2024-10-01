import 'dart:async';
import 'dart:convert';
import 'dart:developer' as dev;
import 'package:http/http.dart' as http;
import 'package:trade_stream/core/consts.dart';
import 'package:trade_stream/core/env.dart';
import 'package:trade_stream/features/trading_home/data/models/trading_instrument_model.dart';
import 'package:trade_stream/features/trading_home/data/models/trading_price_model.dart';

import 'package:trade_stream/features/trading_home/data/repository/trading_repository_interface.dart';
import 'package:trade_stream/core/network/websocket_service.dart';

/// Implementation of the [TradingRepository] interface.
///
/// This class manages trading-related data operations, including price updates,
/// instrument subscriptions, and market data retrieval.
class TradingRepositoryImpl implements TradingRepository {
  /// The WebSocket service used for real-time price updates.
  final WebSocketService webSocketService;

  /// Stream controller for broadcasting price updates.
  late final StreamController<List<TradingPriceModel>> _priceStreamController;

  /// Creates a new instance of [TradingRepositoryImpl].
  ///
  /// [webSocketService] is required for managing WebSocket connections.
  TradingRepositoryImpl(this.webSocketService) {
    _priceStreamController =
        StreamController<List<TradingPriceModel>>.broadcast();
    _initPriceStream();
  }

  /// Initializes the price stream by listening to the WebSocket service.
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
    dev.log('Fetching trading instruments for market: $market');
    dev.log(
        'Exchange: ${market == AppConstants.crypto ? AppConstants.coinbase : AppConstants.oanda}');

    const baseUrl = 'https://finnhub.io/api/v1';
    final endpoint =
        market == AppConstants.stocks ? 'stock/symbol' : '$market/symbol';
    final exchange = market == AppConstants.stocks
        ? 'US'
        : (market == AppConstants.crypto
            ? AppConstants.binance
            : AppConstants.oanda);
    final additionalParams = market == AppConstants.stocks
        ? '&mic=XNAS&securityType=Common Stock'
        : '';

    final response = await http.get(
      Uri.parse(
          '$baseUrl/$endpoint?exchange=$exchange$additionalParams&token=${Env.apiKey}'),
    );

    if (response.statusCode == 200) {
      if (response.body.trim().startsWith('{') ||
          response.body.trim().startsWith('[')) {
        try {
          final List<dynamic> jsonResponse = json.decode(response.body);
          final tradingSymbols = jsonResponse
              .take(AppConstants.maxInstrumentsForFreeAccount)
              .map((json) => TradingInstrumentModel.fromJson(json))
              .toList();
          return tradingSymbols;
        } catch (e) {
          dev.log('Error parsing JSON response: $e', error: e);
          throw Exception('Failed to parse API response');
        }
      } else {
        dev.log('Received non-JSON response', error: response.body);
        throw Exception('Received unexpected response format');
      }
    } else {
      dev.log('Error fetching trading instruments: ${response.body}',
          error: response.body);
      throw Exception(
          'Failed to fetch trading instruments: ${response.statusCode}');
    }
  }
}
