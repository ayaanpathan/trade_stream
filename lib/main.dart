import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:trade_stream/core/env.dart';
import 'package:trade_stream/core/network/cubit/connectivity_cubit.dart';
import 'package:trade_stream/core/theme/app_theme.dart';
import 'package:trade_stream/core/widgets/connection_wrapper.dart';
import 'package:trade_stream/features/trading_home/data/repository/trading_repository.dart';
import 'package:trade_stream/features/trading_home/data/repository/trading_repository_interface.dart';
import 'package:trade_stream/features/trading_home/presentation/cubit/trading_cubit.dart';
import 'package:trade_stream/features/trading_home/presentation/pages/trading_home_page.dart';
import 'package:trade_stream/core/network/websocket_service.dart';

void main() async {
  await Env.init();
  setupGetIt();
  runApp(const MyApp());
}

void setupGetIt() {
  GetIt.I.registerLazySingleton<TradingCubit>(() => TradingCubit(
        TradingRepositoryImpl(
          WebSocketService('wss://ws.finnhub.io/?token=${Env.apiKey}'),
        ),
      ));
  GetIt.I.registerLazySingleton<WebSocketService>(
      () => WebSocketService('wss://ws.finnhub.io/?token=${Env.apiKey}'));
  GetIt.I.registerLazySingleton<TradingRepository>(() => TradingRepositoryImpl(
        WebSocketService('wss://ws.finnhub.io/?token=${Env.apiKey}'),
      ));
  GetIt.I.registerLazySingleton<ConnectivityCubit>(() => ConnectivityCubit());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ConnectivityCubit(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Trading App',
        theme: AppTheme.buildDarkTheme(),
        home: const ConnectionWrapper(child: TradingHomePage()),
      ),
    );
  }
}
