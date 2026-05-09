// lib/hardware/ble_service.dart

import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../protocol/protocol_constants.dart';
import '../protocol/packet_serializer.dart';

final bleServiceProvider = Provider<BleService>((ref) {
  return BleService();
});

class BleService {
  BluetoothDevice? _connectedDevice;
  BluetoothCharacteristic? _writeChar;
  BluetoothCharacteristic? _notifyChar;
  
  StreamSubscription<BluetoothConnectionState>? _connectionStateSub;
  StreamSubscription<List<int>>? _notifySub;

  final String targetDeviceName = "Heal Us";
  final String devicePassword = "000000"; // Hardcoded for initial milestone
  
  int _reconnectAttempts = 0;
  static const int maxReconnectAttempts = 5;

  /// 스캔 시작 및 기기 연결
  Future<void> scanAndConnect() async {
    if (await FlutterBluePlus.isSupported == false) {
      print("Bluetooth not supported");
      return;
    }

    print("Start scanning...");
    await FlutterBluePlus.startScan(
      withNames: [targetDeviceName],
      timeout: const Duration(seconds: 15),
    );

    FlutterBluePlus.scanResults.listen((results) async {
      for (ScanResult r in results) {
        if (r.device.platformName == targetDeviceName) {
          print("Found target device: ${r.device.remoteId}");
          await FlutterBluePlus.stopScan();
          await _connectToDevice(r.device);
          break;
        }
      }
    });
  }

  Future<void> _connectToDevice(BluetoothDevice device) async {
    _connectedDevice = device;
    try {
      print("Connecting with 5s timeout...");
      await device.connect(timeout: const Duration(seconds: 5));
      _reconnectAttempts = 0; // Reset
      
      _connectionStateSub = device.connectionState.listen((BluetoothConnectionState state) {
        if (state == BluetoothConnectionState.disconnected) {
          print("Device disconnected. Initiating reconnect...");
          _handleDisconnection();
        } else if (state == BluetoothConnectionState.connected) {
          print("Device connected successfully.");
        }
      });

      await _discoverServicesAndHandshake();

    } catch (e) {
      print("Connection failed: $e");
      _handleDisconnection();
    }
  }

  void _handleDisconnection() async {
    if (_reconnectAttempts < maxReconnectAttempts) {
      _reconnectAttempts++;
      final backoff = pow(2, _reconnectAttempts).toInt(); // Exponential backoff (2, 4, 8, 16, 32 sec)
      print("Waiting $backoff seconds before reconnecting (Attempt $_reconnectAttempts)");
      await Future.delayed(Duration(seconds: backoff));
      if (_connectedDevice != null) {
        await _connectToDevice(_connectedDevice!);
      }
    } else {
      print("Max reconnect attempts reached. Please check the pump.");
    }
  }

  Future<void> _discoverServicesAndHandshake() async {
    if (_connectedDevice == null) return;
    
    // Request MTU to ensure 20 bytes can pass easily (though default is 23, which is enough)
    await _connectedDevice!.requestMtu(23);

    List<BluetoothService> services = await _connectedDevice!.discoverServices();
    
    for (BluetoothService service in services) {
      // Find proper characteristics. Replace with actual UUIDs if known.
      for (BluetoothCharacteristic c in service.characteristics) {
        if (c.properties.write || c.properties.writeWithoutResponse) {
          _writeChar = c;
        }
        if (c.properties.notify || c.properties.indicate) {
          _notifyChar = c;
          await c.setNotifyValue(true);
          _notifySub = c.onValueReceived.listen(_onDataReceived);
        }
      }
    }

    if (_writeChar != null) {
      print("Services discovered. Initiating Handshake.");
      await _sendConnectableCtrlReq();
    }
  }

  Future<void> _sendConnectableCtrlReq() async {
    // 0x02 BT_CONNECTABLE_CTRL_REQ
    final packet = PacketSerializer.serialize(ProtocolConstants.BT_CONNECTABLE_CTRL_REQ);
    await _writePacket(packet);
    print("Sent BT_CONNECTABLE_CTRL_REQ (0x02)");
    // Typically, we wait for RES_OK, then send Auth. For simplicity, we trigger Auth upon connection.
    // Ideally, _onDataReceived handles the OK and then calls _sendAuthReq.
  }

  Future<void> _sendAuthReq() async {
    // 0x3C BT_PRS_APP_PASSWD_IND (password "000000" mapped to bytes, assuming ASCII)
    final passBytes = devicePassword.codeUnits;
    final packet = PacketSerializer.serialize(
      ProtocolConstants.BT_PRS_APP_PASSWD_IND,
      data: passBytes,
    );
    await _writePacket(packet);
    print("Sent Auth Request (0x3C)");
  }

  Future<void> _writePacket(Uint8List packet) async {
    if (_writeChar != null) {
      await _writeChar!.write(packet, withoutResponse: false);
    }
  }

  void _onDataReceived(List<int> value) {
    final packet = Uint8List.fromList(value);
    if (!PacketSerializer.validate(packet)) {
      print("Invalid packet received.");
      return;
    }

    final typeCode = packet[1];
    print("Received packet type: 0x${typeCode.toRadixString(16).padLeft(2, '0')}");
    
    // Handle handshake response
    if (typeCode == 0x00) { // Assuming 0x00 is RES_OK for generic requests
      // Here we should check what request this is a response to.
      // If it was for 0x02, we should send 0x3C next.
      // For this skeleton, we'll just trigger _sendAuthReq if it's the first connection.
      _sendAuthReq(); // In a real state machine, we track current state.
    }
    
    // TODO: Delegate to Protocol Transformation Layer / State Machine (Riverpod)
  }

  void dispose() {
    _connectionStateSub?.cancel();
    _notifySub?.cancel();
    _connectedDevice?.disconnect();
  }
}
