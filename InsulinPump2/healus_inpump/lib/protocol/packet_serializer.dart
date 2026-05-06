// lib/protocol/packet_serializer.dart

import 'dart:typed_data';
import 'protocol_constants.dart';

class PacketSerializer {
  /// Create a 20-byte packet with the given typeCode and data payload
  static Uint8List serialize(int typeCode, {List<int>? data}) {
    final packet = Uint8List(ProtocolConstants.packetSize);
    
    // 0: Start Code
    packet[0] = ProtocolConstants.startCode;
    // 1: Type Code
    packet[1] = typeCode;
    
    // 2: Data Length
    final dataLen = data?.length ?? 0;
    if (dataLen > 17) {
      throw ArgumentError('Data length cannot exceed 17 bytes.');
    }
    packet[2] = dataLen;
    
    // 3 ~ 19: Data Payload
    if (data != null) {
      for (int i = 0; i < dataLen; i++) {
        packet[3 + i] = data[i];
      }
    }
    
    return packet;
  }

  /// Int 값을 Little-endian 바이트 배열로 변환
  static List<int> intToLittleEndian(int value, int numBytes) {
    final result = <int>[];
    for (int i = 0; i < numBytes; i++) {
      result.add((value >> (8 * i)) & 0xFF);
    }
    return result;
  }

  /// Little-endian 바이트 배열을 Int 값으로 변환
  static int littleEndianToInt(Uint8List data, int offset, int numBytes) {
    int result = 0;
    for (int i = 0; i < numBytes; i++) {
      result |= (data[offset + i] << (8 * i));
    }
    return result;
  }

  /// 수신된 패킷 유효성 검증
  static bool validate(Uint8List packet) {
    if (packet.length != ProtocolConstants.packetSize) return false;
    if (packet[0] != ProtocolConstants.startCode) return false;
    
    final expectedDataLen = packet[2];
    // This is a basic validation. In a real scenario, you might have specific
    // data length requirements per type code.
    if (expectedDataLen > 17) return false;
    
    return true;
  }
}
