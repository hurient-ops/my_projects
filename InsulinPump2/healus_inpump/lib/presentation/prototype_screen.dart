import 'package:flutter/material.dart';

class TapArea {
  final double leftRatio;
  final double topRatio;
  final double widthRatio;
  final double heightRatio;
  final VoidCallback onTap;

  TapArea({
    required this.leftRatio,
    required this.topRatio,
    required this.widthRatio,
    required this.heightRatio,
    required this.onTap,
  });
}

class PrototypeScreen extends StatelessWidget {
  final String imagePath;
  final List<TapArea> tapAreas;
  final VoidCallback? onFullScreenTap;

  const PrototypeScreen({
    super.key,
    required this.imagePath,
    this.tapAreas = const [],
    this.onFullScreenTap,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final height = constraints.maxHeight;

          return Stack(
            children: [
              // 전체 화면 탭 처리 (TapAreas 이외의 곳을 눌렀을 때의 기본 동작)
              GestureDetector(
                onTap: onFullScreenTap,
                child: SizedBox(
                  width: width,
                  height: height,
                  child: Image.asset(
                    imagePath,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              
              // 개별 탭 영역 (메뉴 등)
              ...tapAreas.map((area) {
                return Positioned(
                  left: width * area.leftRatio,
                  top: height * area.topRatio,
                  width: width * area.widthRatio,
                  height: height * area.heightRatio,
                  child: GestureDetector(
                    onTap: area.onTap,
                    child: Container(
                      color: Colors.transparent, // 투명 영역 (디버깅 시 Colors.red.withOpacity(0.3)로 변경 가능)
                    ),
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }
}
