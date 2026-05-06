import 'package:flutter/material.dart';
import 'prototype_screen.dart';

// 앱 구동 시 초기 시작 화면 (장치 연결)
class PrototypeDeviceConnect extends StatelessWidget {
  const PrototypeDeviceConnect({super.key});

  @override
  Widget build(BuildContext context) {
    return PrototypeScreen(
      imagePath: 'assets/images/screen_장치연결.png',
      onFullScreenTap: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const PrototypePassword()),
        );
      },
    );
  }
}

// 암호 입력 화면
class PrototypePassword extends StatelessWidget {
  const PrototypePassword({super.key});

  @override
  Widget build(BuildContext context) {
    return PrototypeScreen(
      imagePath: 'assets/images/screen_암호입력.png',
      onFullScreenTap: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const PrototypeMain()),
        );
      },
    );
  }
}

// 메인 화면 (다양한 메뉴로 이동)
class PrototypeMain extends StatelessWidget {
  const PrototypeMain({super.key});

  @override
  Widget build(BuildContext context) {
    // 임의의 영역을 나눕니다.
    // 화면을 세로 3등분, 가로 2등분으로 대략적인 영역을 잡겠습니다.
    return PrototypeScreen(
      imagePath: 'assets/images/screen_메인화면.png',
      tapAreas: [
        // 상단 뒤로가기/메뉴 영역 무시
        // 중간/하단에 위치할 메뉴 버튼들 (대략적인 위치)
        // 1. 기초설정
        TapArea(
          leftRatio: 0.05, topRatio: 0.2, widthRatio: 0.4, heightRatio: 0.2,
          onTap: () => _navigateTo(context, 'assets/images/screen_기초설정.png'),
        ),
        // 2. 식사설정
        TapArea(
          leftRatio: 0.55, topRatio: 0.2, widthRatio: 0.4, heightRatio: 0.2,
          onTap: () => _navigateTo(context, 'assets/images/screen_식사설정.png'),
        ),
        // 3. 식사주입
        TapArea(
          leftRatio: 0.05, topRatio: 0.45, widthRatio: 0.4, heightRatio: 0.2,
          onTap: () => _navigateTo(context, 'assets/images/screen_식사주입.png'),
        ),
        // 4. 추가주입
        TapArea(
          leftRatio: 0.55, topRatio: 0.45, widthRatio: 0.4, heightRatio: 0.2,
          onTap: () => _navigateTo(context, 'assets/images/screen_추가주입.png'),
        ),
        // 5. 운동적용
        TapArea(
          leftRatio: 0.05, topRatio: 0.7, widthRatio: 0.4, heightRatio: 0.2,
          onTap: () => _navigateTo(context, 'assets/images/screen_운동적용.png'),
        ),
        // 6. 회식적용
        TapArea(
          leftRatio: 0.55, topRatio: 0.7, widthRatio: 0.4, heightRatio: 0.2,
          onTap: () => _navigateTo(context, 'assets/images/screen_회식적용.png'),
        ),
      ],
      // 기본적으로 남는 공간을 누르면 화면 전환을 돕기 위해 다이얼로그 제공
      onFullScreenTap: () {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('메뉴 선택'),
            content: const Text('원하시는 메뉴를 선택하세요.'),
            actions: [
              TextButton(onPressed: () { Navigator.pop(context); _navigateTo(context, 'assets/images/screen_기초설정.png'); }, child: const Text('기초설정')),
              TextButton(onPressed: () { Navigator.pop(context); _navigateTo(context, 'assets/images/screen_식사설정.png'); }, child: const Text('식사설정')),
              TextButton(onPressed: () { Navigator.pop(context); _navigateTo(context, 'assets/images/screen_식사주입.png'); }, child: const Text('식사주입')),
              TextButton(onPressed: () { Navigator.pop(context); _navigateTo(context, 'assets/images/screen_추가주입.png'); }, child: const Text('추가주입')),
              TextButton(onPressed: () { Navigator.pop(context); _navigateTo(context, 'assets/images/screen_운동적용.png'); }, child: const Text('운동적용')),
              TextButton(onPressed: () { Navigator.pop(context); _navigateTo(context, 'assets/images/screen_회식적용.png'); }, child: const Text('회식적용')),
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소')),
            ],
          ),
        );
      },
    );
  }

  void _navigateTo(BuildContext context, String imagePath) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PrototypeSubScreen(imagePath: imagePath)),
    );
  }
}

// 하위 상세 화면 (클릭 시 메인화면으로 복귀)
class PrototypeSubScreen extends StatelessWidget {
  final String imagePath;
  const PrototypeSubScreen({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return PrototypeScreen(
      imagePath: imagePath,
      // 뒤로가기 버튼 영역 (상단 좌측)
      tapAreas: [
        TapArea(
          leftRatio: 0.0, topRatio: 0.0, widthRatio: 0.3, heightRatio: 0.15,
          onTap: () => Navigator.pop(context),
        ),
        // 완료 버튼 영역 등으로 사용 가능한 다른 버튼은 생략
      ],
      // 화면 아무 곳이나 누르면 뒤로 가기 (프로토타입 편의성)
      onFullScreenTap: () {
        Navigator.pop(context);
      },
    );
  }
}
