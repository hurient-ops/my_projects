// lib/presentation/reception_mode_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/injection_service.dart';

class ReceptionModeScreen extends ConsumerStatefulWidget {
  const ReceptionModeScreen({super.key});

  @override
  ConsumerState<ReceptionModeScreen> createState() => _ReceptionModeScreenState();
}

class _ReceptionModeScreenState extends ConsumerState<ReceptionModeScreen> {
  final TextEditingController _totalBolusController = TextEditingController(text: '0');
  int _durationHours = 2; // 회식 모드는 기본적으로 2~4시간에 걸쳐 주입

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('회식 모드'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildInfoBox(),
            const SizedBox(height: 24),
            _buildBolusInput(),
            const SizedBox(height: 24),
            _buildSliderSetting("주입 지속 시간 (시간)", _durationHours.toDouble(), 1, 8, 1, (v) {
              setState(() => _durationHours = v.toInt());
            }),
            const Spacer(),
            ElevatedButton.icon(
              icon: const Icon(Icons.local_dining),
              label: const Text("회식 모드 주입 시작"),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
              ),
              onPressed: () {
                final bolus = double.tryParse(_totalBolusController.text) ?? 0;
                if (bolus <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('올바른 주입량을 입력하세요.')));
                  return;
                }
                
                // TODO: 회식 모드 패킷 전송 로직 연동 (Extended Bolus)
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('회식 모드 주입이 시작되었습니다. ($bolus U, ${_durationHours}시간)')),
                );
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoBox() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber, color: Theme.of(context).colorScheme.onSecondaryContainer),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              "장시간 지속되는 식사(회식) 상황에 맞춰 총 주입량을 설정한 시간에 걸쳐 나누어 주입합니다.",
              style: TextStyle(color: Theme.of(context).colorScheme.onSecondaryContainer),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBolusInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("총 주입량 (U)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        TextField(
          controller: _totalBolusController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: "예: 5.0",
            suffixText: "U",
          ),
        ),
      ],
    );
  }

  Widget _buildSliderSetting(String label, double value, double min, double max, int divisions, ValueChanged<double> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Text("${value.toInt()}시간", style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: ((max - min) ~/ divisions),
          label: value.toInt().toString(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
