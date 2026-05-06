// lib/domain/history_model.dart

import 'package:hive/hive.dart';

part 'history_model.g.dart';

@HiveType(typeId: 0)
class HistoryModel extends HiveObject {
  @HiveField(0)
  final DateTime timestamp;

  @HiveField(1)
  final int totalBasal; // 하루 기초량 총합 (또는 이벤트별)

  @HiveField(2)
  final int totalMeal;  // 식사 주입량

  @HiveField(3)
  final int totalBolus; // 추가 주입량

  HistoryModel({
    required this.timestamp,
    required this.totalBasal,
    required this.totalMeal,
    required this.totalBolus,
  });
}
