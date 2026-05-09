// lib/presentation/device_connection_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../hardware/ble_service.dart';
import '../domain/pump_controller.dart';
import '../domain/pump_state.dart';

class DeviceConnectionScreen extends ConsumerStatefulWidget {
  const DeviceConnectionScreen({super.key});

  @override
  ConsumerState<DeviceConnectionScreen> createState() => _DeviceConnectionScreenState();
}

class _DeviceConnectionScreenState extends ConsumerState<DeviceConnectionScreen> {
  final TextEditingController _passwordController = TextEditingController();
  bool _isScanning = false;

  @override
  Widget build(BuildContext context) {
    final pumpState = ref.watch(pumpControllerProvider);
    final bleService = ref.read(bleServiceProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('펌프 장치 연결')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.bluetooth_searching, size: 64, color: Colors.blue),
            const SizedBox(height: 16),
            const Text(
              "인슐린 펌프 기기 연결",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              pumpState.connectionStatus == ConnectionStatus.connected
                  ? "기기와 성공적으로 연결되었습니다."
                  : "주변의 'Heal Us' 기기를 검색합니다.",
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 32),
            if (pumpState.connectionStatus != ConnectionStatus.connected) ...[
              _buildPasswordInput(),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isScanning
                    ? null
                    : () async {
                        setState(() => _isScanning = true);
                        ref.read(pumpControllerProvider.notifier).setConnectionStatus(ConnectionStatus.scanning);
                        
                        // BLE 스캔 및 연결 시도
                        await bleService.scanAndConnect();
                        
                        setState(() => _isScanning = false);
                      },
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                child: _isScanning ? const CircularProgressIndicator(color: Colors.white) : const Text("장치 스캔 및 연결"),
              ),
            ] else ...[
              ElevatedButton(
                onPressed: () {
                  // 완료 후 메인 홈으로 이동 로직
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                child: const Text("연결 완료"),
              )
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("초기 연결 암호", style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextField(
          controller: _passwordController,
          obscureText: true,
          maxLength: 6,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: "기본 암호: 000000",
            counterText: "",
          ),
          onChanged: (val) {
            // TODO: 사용자가 입력한 비밀번호를 bleService에 동적으로 전달하는 로직 확장 가능
          },
        ),
      ],
    );
  }
}
