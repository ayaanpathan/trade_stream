import 'dart:async';
import 'dart:developer' as dev;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trade_stream/features/trading_home/data/models/trading_instrument_model.dart';
import 'package:trade_stream/features/trading_home/data/repository/trading_repository_interface.dart';

part 'trading_state.dart';

/// Manages the state and business logic for trading operations.
///
/// This Cubit handles operations such as subscribing to trading symbols,
/// fetching trading instruments, and managing real-time price updates.
class TradingCubit extends Cubit<TradingState> {
  /// The repository used to interact with trading data.
  final TradingRepository repository;

  /// Subscription to the price updates stream.
  StreamSubscription? _subscription;

  /// List of currently tracked trading instruments.
  List<TradingInstrumentModel> _currentInstruments = [];

  /// Timer used to periodically apply pending updates.
  Timer? _updateTimer;

  /// The interval at which pending updates are applied.
  final Duration _updateInterval = const Duration(milliseconds: 500);

  /// Map to store pending updates for trading instruments.
  final Map<String, TradingInstrumentModel> _pendingUpdates = {};

  /// Creates a new instance of [TradingCubit].
  ///
  /// [repository] is required to interact with trading data.
  TradingCubit(this.repository) : super(TradingInitial()) {
    _startUpdateTimer();
  }

  /// Starts the timer to periodically apply pending updates.
  void _startUpdateTimer() {
    _updateTimer = Timer.periodic(_updateInterval, (_) {
      if (_pendingUpdates.isNotEmpty) {
        _applyPendingUpdates();
      }
    });
  }

  /// Subscribes to price updates for a specific trading symbol.
  ///
  /// [symbol] is the unique identifier for the trading instrument.
  Future<void> subscribeToSymbol(String symbol) async {
    dev.log('Subscribing to $symbol');
    await repository.subscribe(symbol);
  }

  /// Unsubscribes from price updates for a specific trading symbol.
  ///
  /// [symbol] is the unique identifier for the trading instrument.
  Future<void> unsubscribeFromSymbol(String symbol) async {
    dev.log('Unsubscribing from $symbol');
    await repository.unsubscribe(symbol);
  }

  /// Subscribes to all currently tracked trading instruments.
  Future<void> subscribeAll() async {
    for (final instrument in _currentInstruments) {
      await subscribeToSymbol(instrument.symbol);
    }
  }

  /// Updates the state with the current list of trading instruments.
  void updateState() {
    emit(TradingLoaded(_currentInstruments));
  }

  /// Unsubscribes from all currently tracked trading instruments.
  Future<void> unsubscribeAll() async {
    emit(TradingLoading());
    for (final instrument in _currentInstruments) {
      await unsubscribeFromSymbol(instrument.symbol);
    }
    _currentInstruments = [];
  }

  /// Reconnects to the trading data stream.
  ///
  /// This method cancels the existing subscription and emits a new state.
  Future<void> reconnect() async {
    dev.log('Reconnecting');
    await _subscription?.cancel();
    _subscription = null;
    emit(TradingLoaded(_currentInstruments));
  }

  /// Fetches trading instruments for a specific market and sets up price update listeners.
  ///
  /// [market] is the identifier for the market (e.g., 'forex', 'crypto').
  Future<void> getTradingInstruments(String market) async {
    dev.log('Getting trading instruments for market: $market');
    emit(TradingLoading());
    try {
      _currentInstruments = await repository.getTradingInstruments(market);
      emit(TradingLoaded(_currentInstruments));

      repository.getPriceForTradingInstruments().listen(
        (priceData) {
          if (priceData.isEmpty) return;
          dev.log(
              'symbol: ${priceData.first.symbol} price: ${priceData.first.price}');

          for (final price in priceData) {
            final instrumentIndex = _currentInstruments
                .indexWhere((element) => element.symbol == price.symbol);
            if (instrumentIndex != -1) {
              final instrument = _currentInstruments[instrumentIndex];
              if (instrument.price != price.price) {
                _pendingUpdates[price.symbol] = TradingInstrumentModel(
                  symbol: instrument.symbol,
                  previousTickPrice: instrument.price,
                  price: price.price,
                  volume: price.volume,
                  description: instrument.description,
                  displaySymbol: instrument.displaySymbol,
                );
              }
            }
          }
        },
        onError: (error) {
          dev.log('Stream error: $error');
          emit(TradingError('Error updating prices. Please try again.'));
        },
      );
    } catch (error, stackTrace) {
      dev.log('Error: $error');
      dev.log('StackTrace: $stackTrace');
      emit(TradingError(
          'Error fetching trading instruments. Please try again.'));
    }
  }

  /// Fetches and subscribes to trading symbols for a specific market.
  ///
  /// [market] is the identifier for the market (e.g., 'forex', 'crypto').
  Future<void> getSymbols(String market) async {
    emit(TradingLoading());
    await unsubscribeAll();
    try {
      final instruments = await repository.getTradingInstruments(market);
      _currentInstruments = instruments;
      await subscribeAll();
      emit(TradingLoaded(_currentInstruments));
    } catch (error) {
      dev.log('Error fetching trading instruments: $error');
      emit(TradingError(
          'Failed to fetch trading instruments. Please try again.'));
      return;
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    _updateTimer?.cancel();
    return super.close();
  }

  /// Applies pending updates to the current instruments and emits a new state.
  void _applyPendingUpdates() {
    if (_pendingUpdates.isNotEmpty) {
      for (var symbol in _pendingUpdates.keys) {
        final index = _currentInstruments
            .indexWhere((element) => element.symbol == symbol);
        if (index != -1) {
          _currentInstruments[index] = _pendingUpdates[symbol]!;
        }
      }
      _pendingUpdates.clear();
      emit(TradingLoaded(_currentInstruments));
    }
  }
}
