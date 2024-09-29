import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trade_stream/core/env.dart';
import 'package:trade_stream/core/network/cubit/connectivity_cubit.dart';
import 'package:trade_stream/core/widgets/connection_alert_dialog.dart';
import 'package:trade_stream/core/network/websocket_service.dart';

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
  late final WebSocketService webSocketService;

  @override
  void initState() {
    // Initialize the WebSocket service with the API URL and key.
    webSocketService = WebSocketService('${Env.apiUrl}${Env.apiKey}');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ConnectivityCubit, ConnectivityState>(
      listener: (context, state) {
        if (state is ConnectivityFailure) {
          // Close the WebSocket connection when connectivity fails.
          webSocketService.close();
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
            webSocketService.connect();
          }
        }
      },
      child: widget.child,
    );
  }
}
