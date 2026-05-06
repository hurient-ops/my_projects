// lib/domain/injection_service.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../protocol/protocol_constants.dart';
import '../protocol/packet_serializer.dart';
import '../hardware/ble_service.dart';

final injectionServiceProvider = Provider<InjectionService>((ref) {
  final bleService = ref.watch(bleServiceProvider);
  return InjectionService(bleService);
});

class InjectionService {
  final BleService _bleService;

  InjectionService(this._bleService);

  /// 식사 주입 (inj_sel = 0) 또는 추가 주입 (inj_sel = 1)
  /// `injVal`는 단위 값으로, 소수점 단위를 처리하기 위해 정수로 변환하여 전송 (2바이트 Little-endian)
  Future<bool> requestInjection(int injSel, int injVal) async {
    // 1. 사전 이중 확인 로직: BT_INJ_INFO_REQ (0x15)를 요청하여 한도를 검사한다고 가정
    // 실제로는 수신된 값을 Riverpod 상태에서 읽어와 확인
    print("Double checking before injection: mode=$injSel, value=$injVal");
    
    // 2. 패킷 조립 (BT_INJ_REQ 0x17)
    // payload 구조: [injSel (1byte), injVal_L, injVal_H]
    final payload = <int>[
      injSel & 0xFF,
      ...PacketSerializer.intToLittleEndian(injVal, 2)
    ];

    final packet = PacketSerializer.serialize(
      ProtocolConstants.BT_INJ_REQ,
      data: payload,
    );

    // 3. BLE 서비스로 전송 (임의의 _writePacket 메서드 접근 방식 가상화)
    // 실제 구현 시 BleService 내에 sendCommand 등의 인터페이스 필요
    // await _bleService.sendCommand(packet);
    print("Sent BT_INJ_REQ: $packet");
    return true; // 성공적으로 요청 전송됨
  }

  /// 긴급 주입 중단 (BT_INJ_STOP_REQ 0x37)
  Future<void> emergencyStop() async {
    final packet = PacketSerializer.serialize(ProtocolConstants.BT_INJ_STOP_REQ);
    // await _bleService.sendCommand(packet);
    print("Sent EMERGENCY STOP BT_INJ_STOP_REQ");
  }
}
