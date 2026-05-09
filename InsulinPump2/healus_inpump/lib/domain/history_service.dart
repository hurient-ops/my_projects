// lib/domain/history_service.dart

import 'dart:typed_data';
import 'package:hive/hive.dart';
import 'history_model.dart';
import '../protocol/protocol_constants.dart';
import '../protocol/packet_serializer.dart';

class HistoryService {
  late Box<HistoryModel> _historyBox;
  bool _isReceivingStream = false;

  Future<void> initDB() async {
    _historyBox = await Hive.openBox<HistoryModel>('historyBox');
  }

  /// 15일치 데이터 동기화 요청 (0x1D)
  Future<void> requestHistoryLog() async {
    final packet = PacketSerializer.serialize(ProtocolConstants.BT_LOG_REQ);
    // await _bleService.sendCommand(packet);
    print("Requested 15-day History Log (0x1D)");
  }

  /// BLE 패킷 스트림 핸들러 내부에서 호출됨
  void onLogPacketReceived(Uint8List packet) {
    if (packet[1] == ProtocolConstants.LOG_STREAM_START) {
      _isReceivingStream = true;
      print("Log stream started.");
      return;
    }

    if (packet[1] == ProtocolConstants.LOG_STREAM_END) {
      _isReceivingStream = false;
      print("Log stream ended. Synchronization complete.");
      return;
    }

    if (_isReceivingStream) {
      // 14 byte payload from packet[3] to packet[16]
      // 예제: 0~3 Date (Unix Timestamp), 4~5 Basal, 6~7 Meal, 8~9 Bolus
      if (packet[2] >= 14) {
        final timestampInt = PacketSerializer.littleEndianToInt(packet, 3, 4);
        final basal = PacketSerializer.littleEndianToInt(packet, 7, 2);
        final meal = PacketSerializer.littleEndianToInt(packet, 9, 2);
        final bolus = PacketSerializer.littleEndianToInt(packet, 11, 2);

        final model = HistoryModel(
          timestamp: DateTime.fromMillisecondsSinceEpoch(timestampInt * 1000),
          totalBasal: basal,
          totalMeal: meal,
          totalBolus: bolus,
        );

        _historyBox.add(model);
        print("Saved history entry: ${model.timestamp}");
      }
    }
  }
}
