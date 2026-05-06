// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'domain/history_model.dart';
import 'domain/history_service.dart';
import 'presentation/home_screen.dart';
import 'presentation/prototype_flow.dart'; // Add this line

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Hive 초기화 (ePHI 보안 준수를 위한 로컬 스토리지 준비)
  await Hive.initFlutter();
  Hive.registerAdapter(HistoryModelAdapter());
  
  final historyService = HistoryService();
  await historyService.initDB();

  runApp(
    ProviderScope(
      child: MyApp(),
    ),
  );
}

// HistoryModelAdapter (원래는 build_runner로 생성되나 골격 제공을 위해 수동 뼈대만 작성)
class HistoryModelAdapter extends TypeAdapter<HistoryModel> {
  @override
  final int typeId = 0;

  @override
  HistoryModel read(BinaryReader reader) {
    return HistoryModel(
      timestamp: DateTime.now(),
      totalBasal: 0,
      totalMeal: 0,
      totalBolus: 0,
    ); // Dummy for skeletal execution
  }

  @override
  void write(BinaryWriter writer, HistoryModel obj) {
    // Write logic
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HealUS INPUMP',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0D47A1), // 의학용 신뢰감 있는 블루 컬러
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0D47A1),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const PrototypeDeviceConnect(), // Changed to PrototypeDeviceConnect
    );
  }
}
