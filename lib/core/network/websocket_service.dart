import 'dart:async';
import 'dart:convert';
import 'package:trade_stream/core/env.dart';
import 'package:trade_stream/features/trading_home/data/models/trading_price_model.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketService {
  WebSocketChannel? _channel;
  Timer? _heartbeatTimer;
  Timer? _reconnectTimer;
  DateTime? _lastHeartbeatResponse;
  bool _isConnected = false;
  final Duration _heartbeatInterval = const Duration(seconds: 60);
  final Duration _reconnectInterval = const Duration(seconds: 5);

  WebSocketService(String url)
      : _channel = WebSocketChannel.connect(Uri.parse(url));

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

  Future<void> subscribe(String symbol) async {
    _channel!.sink.add(json.encode({
      'type': 'subscribe',
      'symbol': symbol,
    }));
    _channel!.ready;
  }

  Future<void> unsubscribe(String symbol) async {
    _channel!.sink.add(json.encode({
      'type': 'unsubscribe',
      'symbol': symbol,
    }));
  }

  void dispose() {
    _channel!.sink.close();
  }

  Future<void> connect() async {
    _channel = WebSocketChannel.connect(
        Uri.parse('wss://ws.finnhub.io/?token=${Env.apiToken}'));
    _isConnected = true;
    _startHeartbeat();
    _channel!.stream.listen(
      _onMessage,
      onError: _onError,
      onDone: _onDone,
    );
  }

  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(_heartbeatInterval, (_) {
      if (_isConnected) {
        _sendHeartbeat();
        _checkConnection();
      }
    });
  }

  void _sendHeartbeat() {
    print('Sending heartbeat');
    _channel?.sink.add('{"type": "ping"}');
  }

  void _checkConnection() {
    if (_lastHeartbeatResponse != null &&
        DateTime.now().difference(_lastHeartbeatResponse!) >
            _heartbeatInterval * 2) {
      print('Connection lost. Attempting to reconnect...');
      _isConnected = false;
      _reconnect();
    }
  }

  void _onMessage(dynamic message) {
    // Handle incoming messages
    if (message == '{"type": "ping"}') {
      print('Received heartbeat response');
      _lastHeartbeatResponse = DateTime.now();
    } else {
      // Process other messages
      print('Received message: $message');
    }
  }

  void _onError(error) {
    print('WebSocket error: $error');
    _isConnected = false;
    _reconnect();
  }

  void _onDone() {
    print('WebSocket connection closed');
    _isConnected = false;
    _reconnect();
  }

  void _reconnect() {
    _channel?.sink.close();
    _heartbeatTimer?.cancel();
    _reconnectTimer?.cancel();

    _reconnectTimer = Timer.periodic(_reconnectInterval, (_) {
      if (!_isConnected) {
        print('Attempting to reconnect...');
        connect();
      } else {
        _reconnectTimer?.cancel();
      }
    });
  }

  void send(String message) {
    if (_isConnected) {
      _channel?.sink.add(message);
    } else {
      print('Cannot send message. WebSocket is not connected.');
    }
  }

  Future<void> close() async {
    _isConnected = false;
    _heartbeatTimer?.cancel();
    _reconnectTimer?.cancel();
    _channel?.sink.close();
  }

  bool get isConnected => _isConnected;
}
