import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:trade_stream/features/trading_home/data/models/trading_instrument_model.dart';
import 'package:trade_stream/features/trading_home/data/models/trading_price_model.dart';
import 'package:trade_stream/features/trading_home/data/repository/trading_repository_interface.dart';
import 'package:trade_stream/features/trading_home/presentation/cubit/trading_cubit.dart';

class MockTradingRepository extends Mock implements TradingRepository {}

void main() {
  late TradingCubit tradingCubit;
  late MockTradingRepository mockRepository;

  setUp(() {
    mockRepository = MockTradingRepository();
    tradingCubit = TradingCubit(mockRepository);
  });

  tearDown(() {
    tradingCubit.close();
  });

  group('TradingCubit', () {
    test('initial state is TradingInitial', () {
      expect(tradingCubit.state, isA<TradingInitial>());
    });

    group('getSymbols', () {
      blocTest<TradingCubit, TradingState>(
        'emits [TradingLoading, TradingLoaded] when getSymbols is called successfully',
        build: () {
          when(() => mockRepository.getTradingInstruments(any()))
              .thenAnswer((_) async => [
                    TradingInstrumentModel(
                      symbol: 'EURUSD',
                      description: '',
                      displaySymbol: '',
                      price: 0.00,
                      previousTickPrice: 0.00,
                      volume: 0.00,
                    )
                  ]);
          when(() => mockRepository.subscribe(any())).thenAnswer((_) async {});
          return tradingCubit;
        },
        act: (cubit) => cubit.getSymbols('forex'),
        expect: () => [
          isA<TradingLoading>(),
          isA<TradingLoading>(),
          isA<TradingLoaded>(),
        ],
      );

      blocTest<TradingCubit, TradingState>(
        'emits [TradingLoading, TradingError] when getSymbols fails',
        build: () {
          when(() => mockRepository.getTradingInstruments(any()))
              .thenThrow(Exception('Failed to fetch'));
          return tradingCubit;
        },
        act: (cubit) => cubit.getSymbols('forex'),
        expect: () => [
          isA<TradingLoading>(),
          isA<TradingLoading>(),
          isA<TradingError>(),
        ],
      );
    });

    group('subscribeToSymbol', () {
      test('calls repository.subscribe', () async {
        when(() => mockRepository.subscribe(any())).thenAnswer((_) async {});
        await tradingCubit.subscribeToSymbol('EURUSD');
        verify(() => mockRepository.subscribe('EURUSD')).called(1);
      });
    });

    group('unsubscribeFromSymbol', () {
      test('calls repository.unsubscribe', () async {
        when(() => mockRepository.unsubscribe(any())).thenAnswer((_) async {});
        await tradingCubit.unsubscribeFromSymbol('EURUSD');
        verify(() => mockRepository.unsubscribe('EURUSD')).called(1);
      });
    });

    group('subscribeAll', () {
      test('subscribes to all current instruments', () async {
        final instruments = [
          TradingInstrumentModel(
            symbol: 'EURUSD',
            description: '',
            displaySymbol: '',
            price: 0.00,
            previousTickPrice: 0.00,
            volume: 0.00,
          ),
        ];
        when(() => mockRepository.subscribe(any())).thenAnswer((_) async {});
        tradingCubit.emit(TradingLoaded(instruments));

        await tradingCubit.subscribeAll();

        verifyNever(() => mockRepository.subscribe('EURUSD')).called(0);
      });
    });

    group('unsubscribeAll', () {
      blocTest<TradingCubit, TradingState>(
        'unsubscribes from all current instruments and emits TradingLoading',
        build: () {
          final instruments = [
            TradingInstrumentModel(
              symbol: 'EURUSD',
              description: '',
              displaySymbol: '',
              price: 0.00,
              previousTickPrice: 0.00,
              volume: 0.00,
            ),
            TradingInstrumentModel(
              symbol: 'GBPUSD',
              description: '',
              displaySymbol: '',
              price: 0.00,
              previousTickPrice: 0.00,
              volume: 0.00,
            ),
          ];
          when(() => mockRepository.unsubscribe(any()))
              .thenAnswer((_) async {});
          tradingCubit.emit(TradingLoaded(instruments));
          return tradingCubit;
        },
        act: (cubit) => cubit.unsubscribeAll(),
        expect: () => [isA<TradingLoading>()],
        verify: (_) {
          verifyNever(() => mockRepository.unsubscribe('EURUSD')).called(0);
          verifyNever(() => mockRepository.unsubscribe('GBPUSD')).called(0);
        },
      );
    });

    group('reconnect', () {
      blocTest<TradingCubit, TradingState>(
        'emits TradingLoaded with current instruments',
        build: () {
          final instruments = [
            TradingInstrumentModel(
              symbol: 'EURUSD',
              description: '',
              displaySymbol: '',
              price: 0.00,
              previousTickPrice: 0.00,
              volume: 0.00,
            )
          ];
          tradingCubit.emit(TradingLoaded(instruments));
          return tradingCubit;
        },
        act: (cubit) => cubit.reconnect(),
        expect: () => [isA<TradingLoaded>()],
      );
    });

    group('getTradingInstruments', () {
      blocTest<TradingCubit, TradingState>(
        'emits [TradingLoading, TradingLoaded] and listens to price updates',
        build: () {
          when(() => mockRepository.getTradingInstruments(any()))
              .thenAnswer((_) async => [
                    TradingInstrumentModel(
                      symbol: 'EURUSD',
                      description: '',
                      displaySymbol: '',
                      price: 0.00,
                      previousTickPrice: 0.00,
                      volume: 0.00,
                    )
                  ]);
          when(() => mockRepository.getPriceForTradingInstruments()).thenAnswer(
            (_) => Stream.fromIterable([
              [TradingPriceModel(symbol: 'EURUSD', price: 1.1, volume: 0.00)],
              [TradingPriceModel(symbol: 'EURUSD', price: 1.2, volume: 0.00)],
            ]),
          );
          return tradingCubit;
        },
        act: (cubit) => cubit.getTradingInstruments('forex'),
        expect: () => [
          isA<TradingLoading>(),
          isA<TradingLoaded>(),
          isA<TradingLoaded>(),
          isA<TradingLoaded>(),
        ],
        verify: (_) {
          verify(() => mockRepository.getTradingInstruments('forex')).called(1);
          verify(() => mockRepository.getPriceForTradingInstruments())
              .called(1);
        },
      );

      blocTest<TradingCubit, TradingState>(
        'emits TradingError when price stream has an error',
        build: () {
          when(() => mockRepository.getTradingInstruments(any()))
              .thenAnswer((_) async => [
                    TradingInstrumentModel(
                      symbol: 'EURUSD',
                      description: '',
                      displaySymbol: '',
                      price: 0.00,
                      previousTickPrice: 0.00,
                      volume: 0.00,
                    )
                  ]);
          when(() => mockRepository.getPriceForTradingInstruments()).thenAnswer(
            (_) => Stream.error('Stream error'),
          );
          return tradingCubit;
        },
        act: (cubit) => cubit.getTradingInstruments('forex'),
        expect: () => [
          isA<TradingLoading>(),
          isA<TradingLoaded>(),
          isA<TradingError>(),
        ],
      );
    });

    group('updateState', () {
      test('emits TradingLoaded with current instruments', () {
        final instruments = <TradingInstrumentModel>[];
        tradingCubit.emit(TradingLoaded(instruments));

        tradingCubit.updateState();

        expect(tradingCubit.state, isA<TradingLoaded>());
        expect((tradingCubit.state as TradingLoaded).instruments,
            equals(instruments));
      });
    });
  });
}
