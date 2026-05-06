// lib/presentation/exercise_mode_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/injection_service.dart';

class ExerciseModeScreen extends ConsumerStatefulWidget {
  const ExerciseModeScreen({super.key});

  @override
  ConsumerState<ExerciseModeScreen> createState() => _ExerciseModeScreenState();
}

class _ExerciseModeScreenState extends ConsumerState<ExerciseModeScreen> {
  double _reductionPercentage = 20.0;
  int _durationHours = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('운동 모드'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildInfoBox(),
            const SizedBox(height: 24),
            _buildSliderSetting("기초량 감량 비율 (%)", _reductionPercentage, 10, 50, 10, (v) {
              setState(() => _reductionPercentage = v);
            }),
            const SizedBox(height: 24),
            _buildSliderSetting("지속 시간 (시간)", _durationHours.toDouble(), 1, 4, 1, (v) {
              setState(() => _durationHours = v.toInt());
            }),
            const Spacer(),
            ElevatedButton.icon(
              icon: const Icon(Icons.directions_run),
              label: const Text("운동 모드 시작"),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
              ),
              onPressed: () {
                // TODO: 펌프에 임시 기초량(TBR) 적용 패킷 전송 (마일스톤 3 확장)
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('운동 모드가 시작되었습니다. (-${_reductionPercentage.toInt()}%, ${_durationHours}시간)')),
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
        color: Theme.of(context).colorScheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.directions_run, color: Theme.of(context).colorScheme.onTertiaryContainer),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              "운동 중 저혈당을 예방하기 위해 설정된 비율만큼 기초 주입량을 감량합니다.",
              style: TextStyle(color: Theme.of(context).colorScheme.onTertiaryContainer),
            ),
          ),
        ],
      ),
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
            Text(label.contains('%') ? "${value.toInt()}%" : "${value.toInt()}시간", style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 18)),
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
