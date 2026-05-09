// lib/domain/pump_state.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ConnectionStatus { disconnected, scanning, connecting, connected }

class PumpState {
  final ConnectionStatus connectionStatus;
  final int batteryLevel; // 0 to 4 (5 stages) or percentage
  final int insulinRemain;
  final bool isInjecting;
  final int lastErrorCode;

  PumpState({
    this.connectionStatus = ConnectionStatus.disconnected,
    this.batteryLevel = 0,
    this.insulinRemain = 0,
    this.isInjecting = false,
    this.lastErrorCode = 0,
  });

  PumpState copyWith({
    ConnectionStatus? connectionStatus,
    int? batteryLevel,
    int? insulinRemain,
    bool? isInjecting,
    int? lastErrorCode,
  }) {
    return PumpState(
      connectionStatus: connectionStatus ?? this.connectionStatus,
      batteryLevel: batteryLevel ?? this.batteryLevel,
      insulinRemain: insulinRemain ?? this.insulinRemain,
      isInjecting: isInjecting ?? this.isInjecting,
      lastErrorCode: lastErrorCode ?? this.lastErrorCode,
    );
  }
}
