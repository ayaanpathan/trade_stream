part of 'connectivity_cubit.dart';

/// Base class for all connectivity states.
abstract class ConnectivityState {}

/// Represents the initial state of connectivity.
///
/// This state is used when the connectivity status is not yet determined.
class ConnectivityInitial extends ConnectivityState {}

/// Represents a successful connection state.
///
/// This state is emitted when the device has an active internet connection
/// (e.g., WiFi, mobile data, or ethernet).
class ConnectivitySuccess extends ConnectivityState {}

/// Represents a failed connection state.
///
/// This state is emitted when the device has no active internet connection
/// or when the connection type is unknown.
class ConnectivityFailure extends ConnectivityState {}

/// Represents an error state in connectivity checking.
///
/// This state is emitted when there's an error while checking
/// or monitoring the connectivity status.
class ConnectivityError extends ConnectivityState {
  /// A message describing the error that occurred.
  final String message;

  /// Creates a new [ConnectivityError] instance with the given [message].
  ConnectivityError(this.message);
}
