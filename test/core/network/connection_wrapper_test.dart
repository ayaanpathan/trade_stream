import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:trade_stream/core/network/cubit/connectivity_cubit.dart';
import 'package:trade_stream/core/network/websocket_service.dart';

import '../setup.dart';

void main() {
  late ConnectivityCubit mockConnectivityCubit;
  late WebSocketService mockWebSocketService;

  setUp(() {
    try {
      setupTestDependencies();
      mockConnectivityCubit = GetIt.instance<ConnectivityCubit>();
      mockWebSocketService = GetIt.instance<WebSocketService>();

      when(() => mockConnectivityCubit.state).thenReturn(ConnectivityInitial());
      when(() => mockWebSocketService.close()).thenAnswer((_) async {});
      when(() => mockWebSocketService.connect()).thenAnswer((_) async {});
    } catch (e, stackTrace) {
      debugPrint('Exception during setup: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  });

  tearDown(() {
    try {
      tearDownTestDependencies();
    } catch (e, stackTrace) {
      debugPrint('Exception during teardown: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  });

  testWidgets('ConnectionWrapper shows dialog on ConnectivityFailure',
      (WidgetTester tester) async {
    // Emit ConnectivityFailure state
    when(() => mockConnectivityCubit.state).thenReturn(ConnectivityFailure());
    mockConnectivityCubit.emit(ConnectivityFailure());

    await tester.pumpAndSettle();
  });

  testWidgets(
      'ConnectionWrapper closes dialog and reconnects on ConnectivitySuccess',
      (WidgetTester tester) async {
    // Start with ConnectivityFailure to show the dialog
    when(() => mockConnectivityCubit.state).thenReturn(ConnectivityFailure());
    await tester.pumpAndSettle();

    // Emit ConnectivitySuccess state
    when(() => mockConnectivityCubit.state).thenReturn(ConnectivitySuccess());
    mockConnectivityCubit.emit(ConnectivitySuccess());

    await tester.pumpAndSettle();
  });
}
