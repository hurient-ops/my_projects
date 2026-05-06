// lib/domain/pump_controller.dart

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'pump_state.dart';
import '../hardware/ble_service.dart';

final pumpControllerProvider = StateNotifierProvider<PumpController, PumpState>((ref) {
  final bleService = ref.watch(bleServiceProvider);
  return PumpController(bleService);
});

class PumpController extends StateNotifier<PumpState> {
  final BleService _bleService;
  Timer? _heartbeatTimer;

  PumpController(this._bleService) : super(PumpState());

  void setConnectionStatus(ConnectionStatus status) {
    state = state.copyWith(connectionStatus: status);
    if (status == ConnectionStatus.connected) {
      _startHeartbeat();
    } else {
      _stopHeartbeat();
    }
  }

  void updateBattery(int level) {
    state = state.copyWith(batteryLevel: level);
  }

  void updateInsulin(int remain) {
    state = state.copyWith(insulinRemain: remain);
  }

  void setInjecting(bool injecting) {
    state = state.copyWith(isInjecting: injecting);
  }

  void setErrorCode(int code) {
    state = state.copyWith(lastErrorCode: code);
  }

  void _startHeartbeat() {
    _stopHeartbeat();
    // 30초마다 BT_STATE_REQ (0x04) 송신
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (state.connectionStatus == ConnectionStatus.connected) {
        // BLE 서비스를 통해 상태 요청 패킷 전송 (구현은 BLE Service 내에 래핑 필요)
        print("Sending Heartbeat: BT_STATE_REQ");
      }
    });
  }

  void _stopHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
  }

  @override
  void dispose() {
    _stopHeartbeat();
    super.dispose();
  }
}
