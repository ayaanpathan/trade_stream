import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trade_stream/features/trading_home/data/repository/trading_repository_interface.dart';
import 'package:trade_stream/features/trading_home/domain/entities/trading_instrument.dart';

part 'trading_state.dart';

class TradingCubit extends Cubit<TradingState> {
  final TradingRepository repository;

  TradingCubit(this.repository) : super(TradingInitial());

  StreamSubscription? _subscription;
  List<TradingInstrument> _currentInstruments = [];

  Future<void> subscribeToSymbol(String symbol) async {
    print('Subscribing to $symbol');
    await repository.subscribe(symbol);
  }

  Future<void> unsubscribeFromSymbol(String symbol) async {
    print('Unsubscribing from $symbol');
    await repository.unsubscribe(symbol);
  }

  Future<void> subscribeAll() async {
    for (final instrument in _currentInstruments) {
      await subscribeToSymbol(instrument.symbol);
    }
  }

  Future<void> unsubscribeAll() async {
    emit(TradingLoading());
    for (final instrument in _currentInstruments) {
      await unsubscribeFromSymbol(instrument.symbol);
    }
    _currentInstruments = [];
  }

  Future<void> reconnect() async {
    print('Reconnecting');
    await _subscription?.cancel();
    _subscription = null;
    emit(TradingLoaded(_currentInstruments));
  }

  Future<void> getTradingInstruments(String market) async {
    emit(TradingLoading());
    try {
      repository.getPriceForTradingInstruments().listen(
        (priceData) {
          // if (priceData.isEmpty) return;
          print(
              'symbolwss: ${priceData.first.symbol} price: ${priceData.first.price}');

          for (final price in priceData) {
            final instrument = _currentInstruments
                .where((element) => element.symbol == price.symbol)
                .first;
            if (instrument.price != price.price) {
              instrument.previousTickPrice = instrument.price;
              instrument.price = price.price;
              instrument.volume = price.volume;
            }
          }

          emit(TradingLoaded(_currentInstruments));
        },
        onError: (error) {
          print('Stream error: $error');
          emit(TradingError('Error updating prices. Please try again.'));
        },
      );

      emit(TradingLoaded(_currentInstruments));
    } catch (error, stackTrace) {
      print('Error: $error');
      print('StackTrace: $stackTrace');
      emit(TradingError(
          'Error fetching trading instruments. Please try again.'));
    }
  }

  Future<void> getSymbols(String market) async {
    emit(TradingLoading());
    await unsubscribeAll();
    final instruments = await repository.getTradingInstruments(market);
    _currentInstruments = instruments;
    await subscribeAll();
    emit(TradingLoaded(_currentInstruments));
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
