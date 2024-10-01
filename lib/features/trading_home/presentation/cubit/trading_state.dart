part of 'trading_cubit.dart';

/// Abstract base class for all trading states.
///
/// This class defines the common structure for all trading states
/// and provides a default implementation for the [props] getter.
abstract class TradingState {
  const TradingState();

  /// Returns a list of objects that will be used to determine whether
  /// two [TradingState] instances are equal.
  ///
  /// By default, this returns an empty list, meaning that all instances
  /// of the same concrete [TradingState] subclass are considered equal.
  List<Object?> get props => [];
}

/// Represents the initial state of the trading feature.
///
/// This state is typically used when the trading feature is first initialized.
class TradingInitial extends TradingState {}

/// Represents the loading state of the trading feature.
///
/// This state is used when data is being fetched or processed.
class TradingLoading extends TradingState {}

/// Represents the loaded state of the trading feature.
///
/// This state contains a list of trading instruments that have been successfully loaded.
class TradingLoaded extends TradingState {
  final List<TradingInstrumentModel> instruments;

  TradingLoaded(this.instruments);

  @override
  List<Object?> get props => [instruments];
}

/// Represents an error state in the trading feature.
///
/// This state is used when an error occurs during data fetching or processing.
class TradingError extends TradingState {
  /// The error message describing what went wrong.
  final String error;

  /// Creates a new instance of [TradingError] with the given [error] message.
  TradingError(this.error);

  @override
  List<Object?> get props => [error];
}
