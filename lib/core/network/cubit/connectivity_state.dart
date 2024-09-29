part of 'connectivity_cubit.dart';

abstract class ConnectivityState {}

class ConnectivityInitial extends ConnectivityState {}

class ConnectivitySuccess extends ConnectivityState {}

class ConnectivityFailure extends ConnectivityState {}

class ConnectivityError extends ConnectivityState {
  final String message;

  ConnectivityError(this.message);
}
