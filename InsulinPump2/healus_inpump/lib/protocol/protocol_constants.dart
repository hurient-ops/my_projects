// lib/protocol/protocol_constants.dart

class ProtocolConstants {
  // Common
  static const int packetSize = 20;
  static const int startCode = 0xEF;

  // Request & Indication Types
  static const int BT_CONNECTABLE_CTRL_REQ = 0x02;
  static const int BT_STATE_REQ = 0x04;
  static const int BT_STATE_IND = 0x05;
  static const int BT_TIME_BASE_SET_REQ = 0x0F;
  static const int BT_INJ_INFO_REQ = 0x15;
  static const int BT_INJ_REQ = 0x17;
  static const int BT_ERR_IND = 0x19;
  static const int BT_LOG_REQ = 0x1D;
  static const int BT_INJ_STOP_REQ = 0x37;
  static const int BT_INJ_START_IND = 0x3A;
  static const int BT_INJ_STOP_IND = 0x3B;
  static const int BT_PRS_APP_PASSWD_IND = 0x3C;
  static const int BT_BATT_DATA_IND = 0x71;

  // Log Stream Types
  static const int LOG_STREAM_START = 0x0B;
  static const int LOG_STREAM_END = 0x0C;

  // Response Codes (RES_CODE)
  static const int RES_OK = 0x00;
  static const int RES_INVALID_STATUS = 0x01;
  static const int RES_INVALID_PARAM = 0x02;
  static const int RES_CAN_NOT_HANDLE_MSG = 0x04;

  // Error Codes (from BT_ERR_IND 0x19)
  static const int ERR_CLOGGED = 0x01;
  static const int ERR_LOW_BATT = 0x03;
  static const int ERR_LOW_INSULIN = 0x05;
  // Others omitted for brevity, mapping will be added in Milestone 5
}
