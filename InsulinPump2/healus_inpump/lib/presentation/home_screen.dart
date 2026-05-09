// lib/presentation/home_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/pump_controller.dart';
import '../domain/pump_state.dart';
import '../hardware/ble_service.dart';
import '../domain/injection_service.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pumpState = ref.watch(pumpControllerProvider);
    final bleService = ref.read(bleServiceProvider);
    final injectionService = ref.read(injectionServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('HealUS INPUMP'),
        actions: [
          IconButton(
            icon: Icon(
              pumpState.connectionStatus == ConnectionStatus.connected 
                ? Icons.bluetooth_connected
                : Icons.bluetooth_disabled
            ),
            onPressed: () {
              if (pumpState.connectionStatus != ConnectionStatus.connected) {
                bleService.scanAndConnect();
                ref.read(pumpControllerProvider.notifier).setConnectionStatus(ConnectionStatus.scanning);
              }
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildStatusCard(pumpState, context),
            const SizedBox(height: 24),
            _buildActionButtons(pumpState, injectionService, context),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(PumpState state, BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Text(
              "펌프 상태",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatusItem("배터리", "${state.batteryLevel}/4", Icons.battery_charging_full),
                _buildStatusItem("잔량", "${state.insulinRemain}U", Icons.water_drop),
                _buildStatusItem("상태", state.connectionStatus.name, Icons.wifi),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildStatusItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 32, color: Colors.blueAccent),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget _buildActionButtons(PumpState state, InjectionService injService, BuildContext context) {
    bool isConnected = state.connectionStatus == ConnectionStatus.connected;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton.icon(
          icon: const Icon(Icons.restaurant),
          label: const Text("식사 주입 (Meal Bolus)"),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor: isConnected ? null : Colors.grey,
          ),
          onPressed: isConnected ? () => _showInjectionConfirmDialog(context, injService, 0) : null,
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          icon: const Icon(Icons.add_circle),
          label: const Text("추가 주입 (Correction Bolus)"),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor: isConnected ? null : Colors.grey,
          ),
          onPressed: isConnected ? () => _showInjectionConfirmDialog(context, injService, 1) : null,
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          icon: const Icon(Icons.stop_circle, color: Colors.white),
          label: const Text("긴급 주입 정지", style: TextStyle(color: Colors.white)),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor: Colors.red,
          ),
          onPressed: isConnected ? () => injService.emergencyStop() : null,
        ),
      ],
    );
  }

  void _showInjectionConfirmDialog(BuildContext context, InjectionService injService, int mode) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(mode == 0 ? "식사 주입 확인" : "추가 주입 확인"),
        content: const Text("인슐린을 주입하시겠습니까?\n이중 확인을 위해 '주입' 버튼을 길게 누르세요. (안전 가드레일)"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("취소"),
          ),
          // Long Press to Inject (안전 장치)
          GestureDetector(
            onLongPress: () {
              Navigator.pop(ctx);
              injService.requestInjection(mode, 10); // Example 10 units
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("주입이 요청되었습니다.")),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text("길게 눌러 주입", style: TextStyle(color: Colors.white)),
            ),
          )
        ],
      ),
    );
  }
}
