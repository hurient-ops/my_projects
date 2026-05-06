import { InsulinPumpBLE } from './bleService.js';

const ble = new InsulinPumpBLE();

// DOM Elements
const btnConnect = document.getElementById('ble-connect-btn');
const bleMac = document.getElementById('ble-mac');
const bleName = document.getElementById('ble-name');
const emergencyBtn = document.getElementById('emergency-stop-btn');

// Modals
const modals = {
  mealModal: document.getElementById('mealModal'),
  addModal: document.getElementById('addModal'),
  meetingModal: document.getElementById('meetingModal'),
  exerciseModal: document.getElementById('exerciseModal'),
};

// BLE Callbacks
ble.onConnected = (name) => {
  bleMac.textContent = "연결됨";
  bleMac.style.color = "#207B7F";
  bleName.textContent = name;
  document.querySelector('.ble-info i').style.color = "#207B7F";
  btnConnect.style.color = "#207B7F";
};

ble.onDisconnected = () => {
  bleMac.textContent = "연결 안됨";
  bleMac.style.color = "#aaa";
  bleName.textContent = "Heal Us";
  document.querySelector('.ble-info i').style.color = "#5f6368";
  btnConnect.style.color = "#5f6368";
};

ble.onDataReceived = (data) => {
  console.log("Data received:", data);
  // UI 업데이트 로직 (예: 잔량, 배터리)
};

// Connect Button Event
btnConnect.addEventListener('click', () => {
  if (ble.device && ble.device.gatt.connected || ble.isMock) {
    ble.disconnect();
  } else {
    ble.connect();
  }
});

// Modal Open/Close Logic
document.querySelectorAll('.menu-btn').forEach(btn => {
  btn.addEventListener('click', (e) => {
    const modalId = e.currentTarget.getAttribute('data-modal');
    modals[modalId].classList.add('show');
  });
});

document.querySelectorAll('.close-modal').forEach(btn => {
  btn.addEventListener('click', (e) => {
    e.target.closest('.modal').classList.remove('show');
  });
});

// Injection & Apply Actions
document.getElementById('btn-meal-inject').addEventListener('click', () => {
  const m = document.getElementById('meal-morning').value;
  // 임시로 아침 값만 보냄
  ble.sendInjectionRequest(0, m);
  modals.mealModal.classList.remove('show');
  alert("식사 주입이 완료되었습니다.");
});

document.getElementById('btn-add-inject').addEventListener('click', () => {
  const unitInt = document.getElementById('add-unit-int').value;
  const unitDec = document.getElementById('add-unit-dec').value;
  const value = parseFloat(unitInt + unitDec);
  ble.sendInjectionRequest(1, value);
  modals.addModal.classList.remove('show');
  alert(`추가 주입(${value}U)이 완료되었습니다.`);
});

document.getElementById('btn-meet-apply').addEventListener('click', () => {
  const hours = document.getElementById('meet-time').value;
  ble.sendMeetingMode(1, 1, 1, hours);
  modals.meetingModal.classList.remove('show');
  alert(`회식 모드(${hours}시간)가 적용되었습니다.`);
});

document.getElementById('btn-ex-apply').addEventListener('click', () => {
  const hours = document.getElementById('ex-time').value;
  const rate = document.getElementById('ex-rate').value;
  ble.sendExerciseMode(hours, rate);
  modals.exerciseModal.classList.remove('show');
  alert(`운동 모드(${hours}시간, ${rate}% 감량)가 적용되었습니다.`);
});

emergencyBtn.addEventListener('click', () => {
  if (confirm('정말 긴급 정지하시겠습니까?')) {
    ble.sendEmergencyStop();
    alert('긴급 정지 명령이 전송되었습니다.');
  }
});
