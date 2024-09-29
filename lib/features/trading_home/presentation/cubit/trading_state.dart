part of 'trading_cubit.dart';

abstract class TradingState {
  const TradingState();

  List<Object?> get props => [];
}

class TradingInitial extends TradingState {}

class TradingLoading extends TradingState {}

class TradingLoaded extends TradingState {
  final List<TradingInstrument> instruments;

  TradingLoaded(
    this.instruments,
  );

  @override
  List<Object?> get props => [instruments];
}

class TradingError extends TradingState {
  final String error;

  TradingError(this.error);

  @override
  List<Object?> get props => [error];
}
