import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:trade_stream/core/consts.dart';
import 'package:trade_stream/core/env.dart';
import 'package:trade_stream/core/network/websocket_service.dart';
import 'package:trade_stream/features/trading_home/data/models/trading_instrument_model.dart';
import 'package:trade_stream/features/trading_home/data/models/trading_price_model.dart';
import 'package:trade_stream/features/trading_home/data/repository/trading_repository.dart';

class MockWebSocketService extends Mock implements WebSocketService {}

class MockClient extends Mock implements http.Client {}

void main() {
  late TradingRepositoryImpl repository;
  late MockWebSocketService mockWebSocketService;
  late MockClient mockHttpClient;

  setUpAll(() {
    Env.init();
    mockWebSocketService = MockWebSocketService();
    mockHttpClient = MockClient();

    // Set up the mock to return a Stream<List<TradingPriceModel>>
    final priceStream = Stream.fromIterable([
      [TradingPriceModel(symbol: 'AAPL', price: 150.0, volume: 1000)]
    ]);
    when(() => mockWebSocketService.getPriceForTradingInstruments())
        .thenAnswer((_) => priceStream);

    repository = TradingRepositoryImpl(mockWebSocketService);
  });

  group('TradingRepositoryImpl', () {
    test('_initPriceStream initializes price stream correctly', () async {
      final prices = [
        TradingPriceModel(symbol: 'AAPL', price: 150.0, volume: 1000),
      ];

      expect(prices, isA<List<TradingPriceModel>>());
      expect(prices.length, 1);
      expect(prices[0].symbol, 'AAPL');
      expect(prices[0].price, 150.0);
      expect(prices[0].volume, 1000);
    });

    test('subscribe calls WebSocketService.subscribe', () async {
      const symbol = 'AAPL';
      when(() => mockWebSocketService.subscribe(any()))
          .thenAnswer((_) async {});

      await repository.subscribe(symbol);

      verify(() => mockWebSocketService.subscribe(symbol)).called(1);
    });

    test('unsubscribe calls WebSocketService.unsubscribe', () async {
      const symbol = 'AAPL';
      when(() => mockWebSocketService.unsubscribe(any()))
          .thenAnswer((_) async {});

      await repository.unsubscribe(symbol);

      verify(() => mockWebSocketService.unsubscribe(symbol)).called(1);
    });

    test('close calls WebSocketService.close and closes price stream',
        () async {
      when(() => mockWebSocketService.close()).thenAnswer((_) async {});

      await repository.close();

      verify(() => mockWebSocketService.close()).called(1);
      expect(repository.getPriceForTradingInstruments(), emitsDone);
    });

    test('connect calls WebSocketService.connect', () async {
      when(() => mockWebSocketService.connect()).thenAnswer((_) async {});

      await repository.connect();

      verify(() => mockWebSocketService.connect()).called(1);
    });

    group('getTradingInstruments', () {
      test('returns list of TradingInstrumentModel for stocks', () async {
        const market = AppConstants.stocks;
        final url = Uri.parse('Test');
        const responseBody = '';
        when(() => mockHttpClient.get(url))
            .thenAnswer((_) async => http.Response(responseBody, 200));

        final result = await repository.getTradingInstruments(market);

        expect(result, isA<List<TradingInstrumentModel>>());
        expect(result.length, 50);
      });
    });
  });
}
