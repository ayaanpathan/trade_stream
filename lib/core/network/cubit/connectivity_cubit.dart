import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

part 'connectivity_state.dart';

class ConnectivityCubit extends Cubit<ConnectivityState> {
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  ConnectivityCubit() : super(ConnectivityInitial()) {
    _initConnectivity();
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      (result) => _updateConnectionStatus(result.first),
    );
  }

  Future<void> _initConnectivity() async {
    try {
      final results = await _connectivity.checkConnectivity();
      _updateConnectionStatus(results.first);
    } catch (e) {
      emit(ConnectivityError('Failed to get connectivity.'));
      return;
    }
  }

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

  @override
  Future<void> close() {
    _connectivitySubscription.cancel();
    return super.close();
  }
}
