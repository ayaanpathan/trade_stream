import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

part 'connectivity_state.dart';

/// A Cubit that manages the connectivity state of the application.
///
/// This Cubit uses the `connectivity_plus` package to monitor network connectivity
/// changes and emits appropriate states based on the current connectivity status.
class ConnectivityCubit extends Cubit<ConnectivityState> {
  /// The Connectivity instance used to check and monitor network connectivity.
  final Connectivity _connectivity = Connectivity();

  /// A subscription to the connectivity changes stream.
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  /// Creates a new instance of [ConnectivityCubit].
  ///
  /// Initializes the connectivity state and sets up a listener for connectivity changes.
  ConnectivityCubit() : super(ConnectivityInitial()) {
    _initConnectivity();
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      (result) => _updateConnectionStatus(result.first),
    );
  }

  /// Initializes the connectivity state.
  ///
  /// Checks the current connectivity status and updates the state accordingly.
  /// If there's an error during the check, it emits a [ConnectivityError] state.
  Future<void> _initConnectivity() async {
    try {
      final results = await _connectivity.checkConnectivity();
      _updateConnectionStatus(results.first);
    } catch (e) {
      emit(ConnectivityError('Failed to get connectivity.'));
      return;
    }
  }

  /// Updates the connection status based on the given [ConnectivityResult].
  ///
  /// Emits a [ConnectivitySuccess] state for WiFi, mobile, or ethernet connections.
  /// Emits a [ConnectivityFailure] state for no connection or unknown connection types.
  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    switch (result) {
      case ConnectivityResult.wifi:
      case ConnectivityResult.mobile:
      case ConnectivityResult.ethernet:
        emit(ConnectivitySuccess());
        break;
      case ConnectivityResult.none:
        emit(ConnectivityFailure());
        break;
      default:
        emit(ConnectivityFailure());
    }
  }

  /// Closes the connectivity subscription when the Cubit is closed.
  @override
  Future<void> close() {
    _connectivitySubscription.cancel();
    return super.close();
  }
}
