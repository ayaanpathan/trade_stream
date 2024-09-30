import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trade_stream/core/network/cubit/connectivity_cubit.dart';
import 'package:trade_stream/core/widgets/connection_alert_dialog.dart';
import 'package:trade_stream/core/network/websocket_service.dart';
import 'package:get_it/get_it.dart';

/// A widget that wraps its child with connectivity management functionality.
///
/// This widget listens to connectivity changes and manages the WebSocket connection
/// accordingly. It also shows a dialog when there's no internet connection.
class ConnectionWrapper extends StatefulWidget {
  /// The child widget to be wrapped.
  final Widget child;

  /// Creates a [ConnectionWrapper] with the given [child].
  ///
  /// The [child] parameter must not be null.
  const ConnectionWrapper({super.key, required this.child});

  @override
  State<ConnectionWrapper> createState() => _ConnectionWrapperState();
}

class _ConnectionWrapperState extends State<ConnectionWrapper> {
  /// The WebSocket service used for managing the connection.
  late final WebSocketService _webSocketService;
  late final ConnectivityCubit _connectivityCubit;

  @override
  void initState() {
    super.initState();
    _webSocketService = GetIt.instance<WebSocketService>();
    _connectivityCubit = GetIt.instance<ConnectivityCubit>();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ConnectivityCubit, ConnectivityState>(
      bloc: _connectivityCubit,
      listener: (context, state) {
        if (state is ConnectivityFailure) {
          // Close the WebSocket connection when connectivity fails.
          _webSocketService.close();
          // Show a non-dismissible dialog indicating no internet connection.
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
          // When connectivity is restored and the dialog is showing, close it
          // and reconnect the WebSocket.
          if (Navigator.canPop(context)) {
            Navigator.of(context).pop();
            _webSocketService.connect();
          }
        }
      },
      child: widget.child,
    );
  }
}
