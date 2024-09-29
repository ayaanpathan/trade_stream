import 'dart:async';
import 'dart:convert';
import 'dart:developer' as dev;
import 'package:get_it/get_it.dart';
import 'package:trade_stream/core/env.dart';
import 'package:trade_stream/features/trading_home/data/models/trading_price_model.dart';
import 'package:trade_stream/features/trading_home/presentation/cubit/trading_cubit.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

/// A service class for managing WebSocket connections and related operations.
class WebSocketService {
  WebSocketChannel? _channel;
  Timer? _heartbeatTimer;
  Timer? _reconnectTimer;
  DateTime? _lastHeartbeatResponse;
  bool _isConnected = false;
  final Duration _heartbeatInterval = const Duration(seconds: 60);
  final Duration _reconnectInterval = const Duration(seconds: 5);

  /// Creates a new instance of [WebSocketService] and connects to the specified URL.
  ///
  /// [url] The WebSocket URL to connect to.
  WebSocketService(String url)
      : _channel = WebSocketChannel.connect(Uri.parse(url));

  /// Returns a stream of [TradingPriceModel] lists based on incoming WebSocket messages.
  ///
  /// This method filters and transforms the incoming WebSocket messages to extract
  /// trading price information.
  Stream<List<TradingPriceModel>> getPriceForTradingInstruments() {
    return _channel!.stream.map((event) {
      final decodedData = json.decode(event);
      if (decodedData['type'] == 'trade') {
        List<dynamic> data = decodedData['data'];
        return data.map((e) => TradingPriceModel.fromJson(e)).toList();
      }
      return [];
    });
  }

  /// Subscribes to updates for a specific trading symbol.
  ///
  /// [symbol] The trading symbol to subscribe to.
  Future<void> subscribe(String symbol) async {
    _channel!.sink.add(json.encode({
      'type': 'subscribe',
      'symbol': symbol,
    }));
    _channel!.ready;
  }

  /// Unsubscribes from updates for a specific trading symbol.
  ///
  /// [symbol] The trading symbol to unsubscribe from.
  Future<void> unsubscribe(String symbol) async {
    _channel!.sink.add(json.encode({
      'type': 'unsubscribe',
      'symbol': symbol,
    }));
  }

  /// Disposes of the WebSocket connection.
  void dispose() {
    _channel!.sink.close();
  }

  /// Establishes a connection to the WebSocket server.
  ///
  /// This method initializes the WebSocket connection, starts the heartbeat mechanism,
  /// and sets up listeners for incoming messages and connection events.
  Future<void> connect() async {
    dev.log(
      'Connecting to WebSocket',
      name: 'WebSocketService',
    );
    _channel = WebSocketChannel.connect(
        Uri.parse('wss://ws.finnhub.io/?token=${Env.apiKey}'));
    _isConnected = true;
    _startHeartbeat();
    _channel!.stream.listen(
      _onMessage,
      onError: _onError,
      onDone: _onDone,
    );
    await GetIt.I<TradingCubit>()
        .subscribeAll()
        .then((value) => GetIt.I<TradingCubit>().updateState());
  }

  /// Starts the heartbeat mechanism to keep the connection alive.
  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(_heartbeatInterval, (_) {
      if (_isConnected) {
        _sendHeartbeat();
        _checkConnection();
      }
    });
  }

  /// Sends a heartbeat message to the server.
  void _sendHeartbeat() {
    dev.log('Sending heartbeat');
    _channel?.sink.add('{"type": "pong"}');
  }

  /// Checks the connection status and initiates reconnection if necessary.
  void _checkConnection() {
    if (_lastHeartbeatResponse != null &&
        DateTime.now().difference(_lastHeartbeatResponse!) >
            _heartbeatInterval * 2) {
      dev.log('Connection lost. Attempting to reconnect...');
      _isConnected = false;
      _reconnect();
    }
  }

  /// Handles incoming WebSocket messages.
  ///
  /// [message] The received message.
  void _onMessage(dynamic message) {
    dev.log('Received WebSocket message: $message');
    _lastHeartbeatResponse = DateTime.now();
  }

  /// Handles WebSocket errors.
  ///
  /// [error] The error that occurred.
  void _onError(error) {
    dev.log('WebSocket error: $error', error: error);
    _isConnected = false;
    _reconnect();
  }

  /// Handles WebSocket connection closure.
  void _onDone() {
    dev.log('WebSocket connection closed');
    _isConnected = false;
    _reconnect();
  }

  /// Attempts to reconnect to the WebSocket server.
  void _reconnect() {
    _channel?.sink.close();
    _heartbeatTimer?.cancel();
    _reconnectTimer?.cancel();

    _reconnectTimer = Timer.periodic(_reconnectInterval, (_) {
      if (!_isConnected) {
        dev.log('Attempting to reconnect...');
        connect();
      } else {
        _reconnectTimer?.cancel();
      }
    });
  }

  /// Sends a message through the WebSocket connection.
  ///
  /// [message] The message to send.
  void send(String message) {
    if (_isConnected) {
      _channel?.sink.add(message);
    } else {
      dev.log('Cannot send message. WebSocket is not connected.');
    }
  }

  /// Closes the WebSocket connection and cancels all timers.
  Future<void> close() async {
    _isConnected = false;
    _heartbeatTimer?.cancel();
    _reconnectTimer?.cancel();
    _channel?.sink.close();
  }

  /// Returns the current connection status.
  bool get isConnected => _isConnected;
}
