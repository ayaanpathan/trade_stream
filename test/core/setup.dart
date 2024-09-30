import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:trade_stream/core/env.dart';
import 'package:trade_stream/features/trading_home/presentation/cubit/trading_cubit.dart';
import 'package:trade_stream/core/network/websocket_service.dart';
import 'package:trade_stream/core/network/cubit/connectivity_cubit.dart';
import 'package:trade_stream/features/trading_home/data/models/trading_price_model.dart';

class MockWebSocketService extends Mock implements WebSocketService {
  @override
  Stream<List<TradingPriceModel>> getPriceForTradingInstruments() {
    return Stream.value([]);
  }
}

class MockConnectivityCubit extends Mock implements ConnectivityCubit {}

class MockTradingCubit extends Mock implements TradingCubit {}

void setupTestDependencies() {
  Env.init();
  final getIt = GetIt.instance;

  final mockTradingCubit = MockTradingCubit();
  when(() => mockTradingCubit.subscribeAll()).thenAnswer((_) async {});

  // Register mocks
  getIt.registerFactory<TradingCubit>(() => MockTradingCubit());
  getIt.registerLazySingleton<WebSocketService>(() => MockWebSocketService());
  getIt.registerLazySingleton<ConnectivityCubit>(() => MockConnectivityCubit());
}

void tearDownTestDependencies() {
  GetIt.instance.reset();
}
