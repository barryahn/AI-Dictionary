import 'package:flutter/material.dart';

/// 앱 전체에서 사용할 색상 테마 추상 클래스
abstract class AppColors {
  Color get primary;
  Color get extraLight;
  Color get light;
  Color get dark;
  Color get accent;
  Color get text;
  Color get textLight;
  Color get background;
  Color get surface;
  Color get divider;
  Color get highlight;
  Color get success;
  Color get warning;
  Color get error;
  Color get info;

  Color get primaryWithOpacity20;
  Color get primaryWithOpacity40;
  Color get darkWithOpacity20;
  Color get darkWithOpacity30;
  Color get darkWithOpacity40;
  Color get backgroundWithOpacity80;

  List<Color> get primaryGradient;
  List<Color> get highlightGradient;
  List<Color> get backgroundGradient;
}
