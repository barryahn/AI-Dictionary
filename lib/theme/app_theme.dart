import 'package:flutter/material.dart';

abstract class AppTheme {
  ThemeData get themeData;
  CustomColors get customColors;
  String get id;
}

class CustomColors {
  final Color primary;
  final Color secondary;
  final Color complementary;
  final Color background;
  final Color text;
  final Color accent;

  // 베이지 색상 팔레트 추가
  final Color white;
  final Color extraLight;
  final Color light;
  final Color dark;
  final Color textLight;
  final Color surface;
  final Color divider;
  final Color highlight;
  final Color success;
  final Color warning;
  final Color light_warning;
  final Color error;
  final Color info;
  final Color conversation_A;
  final Color conversation_B;
  final Color google_login;
  final Color snackbar_text;

  const CustomColors({
    required this.primary,
    required this.secondary,
    required this.complementary,
    required this.white,
    required this.extraLight,
    required this.background,
    required this.text,
    required this.accent,
    required this.light,
    required this.dark,
    required this.textLight,
    required this.surface,
    required this.divider,
    required this.highlight,
    required this.success,
    required this.warning,
    required this.light_warning,
    required this.error,
    required this.info,
    required this.conversation_A,
    required this.conversation_B,
    required this.google_login,
    required this.snackbar_text,
  });

  // 투명도가 적용된 색상들
  Color get primaryWithOpacity20 => primary.withValues(alpha: 0.2);
  Color get primaryWithOpacity40 => primary.withValues(alpha: 0.4);
  Color get darkWithOpacity20 => dark.withValues(alpha: 0.2);
  Color get darkWithOpacity30 => dark.withValues(alpha: 0.3);
  Color get darkWithOpacity40 => dark.withValues(alpha: 0.4);
  Color get backgroundWithOpacity80 => background.withValues(alpha: 0.8);

  // 그라데이션 색상 조합들
  List<Color> get primaryGradient => [accent, light];
  List<Color> get highlightGradient => [highlight, primary];
  List<Color> get backgroundGradient => [background, extraLight];

  /// 색상 팔레트 정보를 반환합니다.
  Map<String, Color> get palette => {
    'primary': primary,
    'secondary': secondary,
    'complementary': complementary,
    'extraLight': extraLight,
    'light': light,
    'dark': dark,
    'accent': accent,
    'text': text,
    'textLight': textLight,
    'background': background,
    'surface': surface,
    'divider': divider,
    'highlight': highlight,
    'success': success,
    'warning': warning,
    'light_warning': light_warning,
    'error': error,
    'info': info,
    'conversation_A': conversation_A,
    'conversation_B': conversation_B,
    'google_login': google_login,
  };

  /// 색상 팔레트를 콘솔에 출력합니다. (디버깅용)
  void printPalette() {
    print('=== CustomColors Palette ===');
    palette.forEach((name, color) {
      print('$name: ${color.value.toRadixString(16).toUpperCase()}');
    });
    print('==========================');
  }
}
