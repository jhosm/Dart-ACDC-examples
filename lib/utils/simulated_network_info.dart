import 'dart:async';

import 'package:dart_acdc/dart_acdc.dart';

/// A [NetworkInfo] implementation that allows simulating network status.
class SimulatedNetworkInfo implements NetworkInfo {
  final _controller = StreamController<NetworkStatus>.broadcast();
  bool _isConnected;

  SimulatedNetworkInfo({bool isConnected = true}) : _isConnected = isConnected;

  @override
  bool get isConnected => _isConnected;

  @override
  Stream<NetworkStatus> get onStatusChange => _controller.stream;

  /// Updates the simulated network status.
  void setStatus(bool isConnected) {
    if (_isConnected != isConnected) {
      _isConnected = isConnected;
      _controller.add(
        isConnected ? NetworkStatus.online : NetworkStatus.offline,
      );
    }
  }

  @override
  void dispose() {
    _controller.close();
  }
}
