import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trade_stream/core/env.dart';
import 'package:trade_stream/core/network/cubit/connectivity_cubit.dart';
import 'package:trade_stream/core/widgets/connection_alert_dialog.dart';
import 'package:trade_stream/features/trading_home/data/repository/mock_trading_repository.dart';
import 'package:trade_stream/features/trading_home/data/repository/trading_repository.dart';
import 'package:trade_stream/features/trading_home/presentation/cubit/trading_cubit.dart';
import 'package:trade_stream/features/trading_home/presentation/pages/trading_home_page.dart';
import 'package:trade_stream/core/network/websocket_service.dart';

void main() async {
  await Env.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Trading App',
      theme: _buildDarkTheme(),
      home: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => ConnectivityCubit(),
          ),
          BlocProvider(
            create: (context) => TradingCubit(
              // MockTradingRepository(),
              TradingRepositoryImpl(
                WebSocketService('wss://ws.finnhub.io/?token=${Env.apiToken}'),
              ),
            ),
          ),
        ],
        child: const TradingHomePage(),
      ),
    );
  }

  ThemeData _buildDarkTheme() {
    final ThemeData base = ThemeData.dark();
    return base.copyWith(
      primaryColor: Colors.blueGrey[800],
      scaffoldBackgroundColor: Colors.grey[900],
      appBarTheme: AppBarTheme(
        color: Colors.blueGrey[900],
        elevation: 0,
      ),
      cardTheme: CardTheme(
        color: Colors.grey[850],
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        fillColor: Colors.grey[800],
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class ConnectionWrapper extends StatefulWidget {
  final Widget child;

  const ConnectionWrapper({super.key, required this.child});

  @override
  State<ConnectionWrapper> createState() => _ConnectionWrapperState();
}

class _ConnectionWrapperState extends State<ConnectionWrapper> {
  late final WebSocketService webSocketService;
  @override
  void initState() {
    webSocketService =
        WebSocketService('wss://ws.finnhub.io/?token=${Env.apiToken}');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ConnectivityCubit, ConnectivityState>(
      listener: (context, state) {
        if (state is ConnectivityFailure) {
          webSocketService.close();
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return const PopScope(
                canPop: false,
                child: ConnectionAlertDialog(),
              );
            },
          );
        } else if (state is ConnectivitySuccess) {
          Navigator.of(context).pop();
          webSocketService.connect();
        }
      },
      child: widget.child,
    );
  }
}
