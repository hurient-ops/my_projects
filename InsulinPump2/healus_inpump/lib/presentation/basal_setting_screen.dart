// lib/presentation/basal_setting_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BasalSettingScreen extends ConsumerStatefulWidget {
  const BasalSettingScreen({super.key});

  @override
  ConsumerState<BasalSettingScreen> createState() => _BasalSettingScreenState();
}

class _BasalSettingScreenState extends ConsumerState<BasalSettingScreen> {
  final List<double> _hourlyBasal = List.filled(24, 0.0);
  final TextEditingController _intPartController = TextEditingController(text: '0');
  final TextEditingController _decPartController = TextEditingController(text: '00');
  final Set<int> _selectedHours = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('기초 설정'),
        actions: [
          IconButton(icon: const Icon(Icons.sync), onPressed: () {}),
          IconButton(icon: const Icon(Icons.bluetooth), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildInfoBox(),
            const SizedBox(height: 16),
            _buildInputGroup(),
            const SizedBox(height: 24),
            _buildTimeSettingHeader(),
            const SizedBox(height: 12),
            _build24HourGrid(),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  ),
                  onPressed: () {
                    // TODO: 마일스톤 2의 BT_TIME_BASE_SET_REQ (0x0F) 6분할 전송 로직 호출
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('기초량이 설정되었습니다.')),
                    );
                    Navigator.pop(context);
                  },
                  child: const Text('저장'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text('닫기'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoBox() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info, color: Colors.blue),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              "기초 설정은 24시간을 기본으로 설정합니다.\n- 1시간 단위 동일량 설정\n- 1시간 단위 필요 시간대별 설정",
              style: TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputGroup() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Align(
              alignment: Alignment.centerRight,
              child: Text("최대: 3 (단위: U)", style: TextStyle(color: Colors.grey, fontSize: 12)),
            ),
            Row(
              children: [
                const Text("기초 설정", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(width: 16),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _intPartController,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.right,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 8),
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4.0),
                        child: Text("."),
                      ),
                      Expanded(
                        child: TextField(
                          controller: _decPartController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 8),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text("U"),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _applyValueToSelected,
                  child: const Text('설정'),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSettingHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text("시간 설정", style: TextStyle(fontWeight: FontWeight.bold)),
        Row(
          children: [
            TextButton(
              onPressed: () {
                setState(() {
                  _selectedHours.addAll(List.generate(24, (i) => i));
                });
              },
              child: const Text("전체 선택"),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _selectedHours.clear();
                });
              },
              child: const Text("전체 해제"),
            ),
          ],
        )
      ],
    );
  }

  Widget _build24HourGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 24,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 1.5,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemBuilder: (context, index) {
        final isSelected = _selectedHours.contains(index);
        final val = _hourlyBasal[index];
        return InkWell(
          onTap: () {
            setState(() {
              if (isSelected) {
                _selectedHours.remove(index);
              } else {
                _selectedHours.add(index);
              }
            });
          },
          child: Container(
            decoration: BoxDecoration(
              color: isSelected ? Theme.of(context).colorScheme.primaryContainer : Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected ? Theme.of(context).colorScheme.primary : Colors.transparent,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("${index}~${index + 1}", style: TextStyle(fontSize: 12, color: isSelected ? Theme.of(context).colorScheme.onPrimaryContainer : Colors.black54)),
                Text("${val.toStringAsFixed(2)}U", style: TextStyle(fontWeight: FontWeight.bold, color: isSelected ? Theme.of(context).colorScheme.onPrimaryContainer : Colors.black87)),
              ],
            ),
          ),
        );
      },
    );
  }

  void _applyValueToSelected() {
    final intVal = int.tryParse(_intPartController.text) ?? 0;
    final decVal = int.tryParse(_decPartController.text) ?? 0;
    final double val = intVal + (decVal / 100.0);
    
    if (val > 3.0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('최대 3U까지만 설정 가능합니다.')));
      return;
    }

    setState(() {
      for (int i in _selectedHours) {
        _hourlyBasal[i] = val;
      }
      _selectedHours.clear();
    });
  }
}
