import 'dart:async';
import 'dart:convert';
import 'dart:developer' as dev;
import 'package:trade_stream/core/consts.dart';
import 'package:trade_stream/features/trading_home/data/models/trading_price_model.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

/// A service class for managing WebSocket connections and related operations.
class WebSocketService {
  WebSocketChannel? channel;
  Timer? _heartbeatTimer;
  Timer? _reconnectTimer;
  DateTime? _lastHeartbeatResponse;
  bool _isConnected = false;
  final Duration _heartbeatInterval = const Duration(seconds: 60);
  Completer<void>? _connectionCompleter;

  /// Creates a new instance of [WebSocketService] and connects to the specified URL.
  ///
  /// [url] The WebSocket URL to connect to.
  WebSocketService(String url)
      : channel = WebSocketChannel.connect(Uri.parse(url));

  /// Returns a stream of [TradingPriceModel] lists based on incoming WebSocket messages.
  ///
  /// This method filters and transforms the incoming WebSocket messages to extract
  /// trading price information.
  Stream<List<TradingPriceModel>> getPriceForTradingInstruments() {
    return channel!.stream.map((event) {
      final decodedData = json.decode(event);
      if (decodedData['type'] == 'trade') {
        List<dynamic> data = decodedData['data'];
        final prices = data.map((e) => TradingPriceModel.fromJson(e)).toList();
        return prices;
      }
      return [];
    });
  }

  /// Subscribes to updates for a specific trading symbol.
  ///
  /// [symbol] The trading symbol to subscribe to.
  Future<void> subscribe(String symbol) async {
    final message = json.encode({
      'type': 'subscribe',
      'symbol': symbol,
    });
    channel!.sink.add(message);
  }

  /// Unsubscribes from updates for a specific trading symbol.
  ///
  /// [symbol] The trading symbol to unsubscribe from.
  Future<void> unsubscribe(String symbol) async {
    channel!.sink.add(json.encode({
      'type': 'unsubscribe',
      'symbol': symbol,
    }));
  }

  /// Disposes of the WebSocket connection.
  void dispose() {
    channel!.sink.close();
  }

  /// Establishes a connection to the WebSocket server.
  ///
  /// This method initializes the WebSocket connection, starts the heartbeat mechanism,
  /// and sets up listeners for incoming messages and connection events.
  Future<void> connect() async {
    if (_isConnected) {
      dev.log('Already connected to WebSocket', name: 'WebSocketService');
      return;
    }

    _connectionCompleter = Completer<void>();

    dev.log('Connecting to WebSocket', name: 'WebSocketService');
    try {
      channel = WebSocketChannel.connect(Uri.parse(AppConstants.websocketApi));
      dev.log('WebSocket channel created', name: 'WebSocketService');

      channel!.stream.listen(
        _onMessage,
        onError: _onError,
        onDone: _onDone,
      );
      dev.log('WebSocket listeners set up', name: 'WebSocketService');

      await channel!.ready;
      dev.log('WebSocket connection ready', name: 'WebSocketService');

      _isConnected = true;
      _startHeartbeat();
      _connectionCompleter!.complete();

      dev.log('WebSocket connected successfully', name: 'WebSocketService');

      // Test the connection
      send('{"type": "ping"}');
      dev.log('Ping sent to WebSocket server', name: 'WebSocketService');
    } catch (e) {
      dev.log('Error connecting to WebSocket: $e',
          name: 'WebSocketService', error: e);
      _isConnected = false;
      _connectionCompleter!.completeError(e);
      // Don't call _reconnect() here to avoid potential loops
    }
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
    channel?.sink.add('{"type": "pong"}');
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
  Future<void> _onMessage(dynamic message) async {
    dev.log('Received WebSocket message: $message', name: 'WebSocketService');
    try {
      final decodedData = json.decode(message);
      dev.log('Decoded message type: ${decodedData['type']}',
          name: 'WebSocketService');
      if (decodedData['type'] == 'trade') {
        // Process trade data
      } else if (decodedData['type'] == 'ping') {
        send('{"type": "pong"}');
      } else {
        dev.log('Unhandled message type: ${decodedData['type']}',
            name: 'WebSocketService');
      }
    } catch (e) {
      dev.log('Error processing WebSocket message: $e',
          name: 'WebSocketService', error: e);
    }
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
    dev.log('WebSocket connection closed', name: 'WebSocketService');
    _isConnected = false;
    _reconnect();
  }

  /// Attempts to reconnect to the WebSocket server.
  Future<void> _reconnect() async {
    dev.log('Attempting to reconnect WebSocket', name: 'WebSocketService');
    await close();
    await connect();
    if (_isConnected) {
      dev.log('WebSocket reconnected successfully', name: 'WebSocketService');
    } else {
      dev.log('WebSocket reconnection failed', name: 'WebSocketService');
    }
  }

  /// Sends a message through the WebSocket connection.
  ///
  /// [message] The message to send.
  void send(String message) {
    if (_isConnected) {
      channel?.sink.add(message);
    } else {
      dev.log('Cannot send message. WebSocket is not connected.');
    }
  }

  /// Closes the WebSocket connection and cancels all timers.
  Future<void> close() async {
    _isConnected = false;
    _heartbeatTimer?.cancel();
    _reconnectTimer?.cancel();
    channel?.sink.close();
  }

  /// Returns the current connection status.
  bool get isConnected => _isConnected;
}
