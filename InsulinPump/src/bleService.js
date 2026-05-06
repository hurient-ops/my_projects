// bleService.js
// Bluetooth Service & Characteristic UUID placeholders
const SERVICE_UUID = 0xFFE0; // 임시 UUID
const CHARACTERISTIC_UUID = 0xFFE1; // 임시 UUID

export class InsulinPumpBLE {
  constructor() {
    this.device = null;
    this.server = null;
    this.service = null;
    this.characteristic = null;
    this.onConnected = null;
    this.onDisconnected = null;
    this.onDataReceived = null;
    
    // Mock state for UI demonstration
    this.isMock = false;
  }

  async connect() {
    try {
      if (!navigator.bluetooth) {
        console.warn("Web Bluetooth API is not supported in this browser. Falling back to Mock mode.");
        return this.connectMock();
      }

      this.device = await navigator.bluetooth.requestDevice({
        acceptAllDevices: true,
        optionalServices: [SERVICE_UUID]
      });

      this.device.addEventListener('gattserverdisconnected', this.handleDisconnect.bind(this));
      this.server = await this.device.gatt.connect();
      this.service = await this.server.getPrimaryService(SERVICE_UUID);
      this.characteristic = await this.service.getCharacteristic(CHARACTERISTIC_UUID);
      
      await this.characteristic.startNotifications();
      this.characteristic.addEventListener('characteristicvaluechanged', this.handleData.bind(this));

      if (this.onConnected) this.onConnected(this.device.name);
      return true;

    } catch (error) {
      console.error("BLE Connect error:", error);
      // Fallback to Mock
      return this.connectMock();
    }
  }

  connectMock() {
    this.isMock = true;
    console.log("Mock BLE Connected");
    if (this.onConnected) this.onConnected("Heal Us (Mock)");
    return true;
  }

  disconnect() {
    if (this.isMock) {
      this.isMock = false;
      this.handleDisconnect();
      return;
    }

    if (this.device && this.device.gatt.connected) {
      this.device.gatt.disconnect();
    }
  }

  handleDisconnect() {
    console.log("Device disconnected");
    if (this.onDisconnected) this.onDisconnected();
  }

  handleData(event) {
    const value = event.target.value;
    // 파싱 로직 (규격서 기반)
    if (this.onDataReceived) {
      this.onDataReceived(value);
    }
  }

  async writeData(dataArray) {
    if (this.isMock) {
      console.log("Mock Sending BLE Data:", dataArray);
      return;
    }

    if (!this.characteristic) {
      console.error("Characteristic is not ready.");
      return;
    }

    const data = new Uint8Array(dataArray);
    try {
      await this.characteristic.writeValue(data);
      console.log("BLE Data sent:", dataArray);
    } catch (error) {
      console.error("Write error:", error);
    }
  }

  // BT_INJ_REQ: 식사/추가 주입 요청
  // inj_sel (0: 식사, 1: 추가), inj_val (2 bytes)
  async sendInjectionRequest(sel, value) {
    // value를 정수로 변환 (예: 1.00U -> 100)
    const intValue = Math.floor(parseFloat(value) * 100);
    const data = [
      0x04, // Message ID: BT_INJ_REQ (임의로 0x04 지정)
      sel,  // 0 or 1
      (intValue >> 8) & 0xFF,
      intValue & 0xFF
    ];
    await this.writeData(data);
  }

  // BT_EXERCISE_SET_REQ
  async sendExerciseMode(hours, rate) {
    const data = [
      0x10, // 임의 Message ID
      parseInt(hours),
      parseInt(rate)
    ];
    await this.writeData(data);
  }

  // BT_RECEPTION_SET_REQ (회식)
  async sendMeetingMode(morning, lunch, dinner, hours) {
    const data = [
      0x11, // 임의 Message ID
      parseInt(hours),
      // 값 변환 생략 (단순 데모용)
    ];
    await this.writeData(data);
  }

  async sendEmergencyStop() {
    // 긴급 정지 패킷
    const data = [0xFF, 0x00, 0x00];
    await this.writeData(data);
  }
}
