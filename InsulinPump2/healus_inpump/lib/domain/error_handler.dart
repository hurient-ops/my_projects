// lib/domain/error_handler.dart

import '../protocol/protocol_constants.dart';

class ErrorHandler {
  /// 에러 코드에 따른 사용자 친화적 메시지 및 조치 가이드 반환
  static Map<String, String> getErrorMessage(int errorCode) {
    switch (errorCode) {
      case ProtocolConstants.ERR_CLOGGED:
        return {
          "title": "바늘 막힘 경고",
          "message": "인슐린 주입이 원활하지 않습니다. 주사 부위 및 캐뉼라를 확인하고 교체해 주세요.",
          "level": "CRITICAL"
        };
      case ProtocolConstants.ERR_LOW_BATT:
        return {
          "title": "배터리 부족",
          "message": "펌프 배터리가 부족합니다. 즉시 배터리를 교체해 주세요.",
          "level": "WARNING"
        };
      case ProtocolConstants.ERR_LOW_INSULIN:
        return {
          "title": "인슐린 부족",
          "message": "카트리지의 인슐린 잔량이 부족합니다. 리필을 준비하세요.",
          "level": "INFO"
        };
      default:
        return {
          "title": "시스템 알림",
          "message": "알 수 없는 에러가 발생했습니다 (코드: 0x${errorCode.toRadixString(16)}).",
          "level": "INFO"
        };
    }
  }

  /// 타임스탬프와 함께 변조 불가능한 감사 로그(Audit Trail) 기록
  static Future<void> logAuditTrail(String action, String details) async {
    final timestamp = DateTime.now().toIso8601String();
    // 로컬 안전한 파일 저장소나 암호화 DB (Hive) 에 저장
    final logEntry = "[$timestamp] ACTION: $action | DETAILS: $details";
    print("AUDIT_TRAIL: $logEntry");
    // 실제 구현 시 Hive의 'auditBox'에 기록
  }
}
