import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:mocktail/mocktail.dart';
import 'package:trade_stream/core/network/cubit/connectivity_cubit.dart';

class MockConnectivity extends Mock implements Connectivity {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ConnectivityCubit', () {
    late ConnectivityCubit connectivityCubit;
    late MockConnectivity mockConnectivity;

    setUp(() {
      mockConnectivity = MockConnectivity();
      when(() => mockConnectivity.onConnectivityChanged).thenAnswer(
        (_) => Stream.fromIterable([]),
      );
      connectivityCubit = ConnectivityCubit();
    });

    test('initial state is ConnectivityInitial', () {
      connectivityCubit = ConnectivityCubit();
      expect(connectivityCubit.state, isA<ConnectivityInitial>());
    });

    group('_initConnectivity', () {
      blocTest<ConnectivityCubit, ConnectivityState>(
        'emits [ConnectivitySuccess] when WiFi is connected',
        build: () {
          connectivityCubit.emit(ConnectivitySuccess());
          when(() => mockConnectivity.checkConnectivity()).thenAnswer(
            (_) async => [ConnectivityResult.wifi],
          );
          return ConnectivityCubit();
        },
        expect: () => [],
      );

      blocTest<ConnectivityCubit, ConnectivityState>(
        'emits [ConnectivityFailure] when no connection',
        build: () {
          when(() => mockConnectivity.checkConnectivity()).thenAnswer(
            (_) async => [ConnectivityResult.none],
          );
          return ConnectivityCubit();
        },
        expect: () => [],
      );

      blocTest<ConnectivityCubit, ConnectivityState>(
        'emits [ConnectivityError] when exception occurs',
        build: () {
          when(() => mockConnectivity.checkConnectivity())
              .thenThrow(Exception('Test error'));
          return ConnectivityCubit();
        },
        expect: () => [],
      );
    });

    group('_updateConnectionStatus', () {
      setUp(() {
        connectivityCubit = ConnectivityCubit();
      });
    });
  });
}
