import 'package:flutter/material.dart';
import 'app_theme.dart';

class LightTheme extends AppTheme {
  @override
  String get id => 'light';

  @override
  CustomColors get customColors => const CustomColors(
    // 기본 회색 색상들
    primary: Color(0xFFE07A5F), // 메인 회색
    secondary: Color(0xFFAAC133), // 메인 베이지
    complementary: Color(0xFF5FC5E0), // 보색

    white: Colors.white,
    extraLight: Color(0xFFF9FAFB), // 매우 밝은 회색
    light: Color(0xFFF3F4F6), // 밝은 회색
    dark: Color(0xFF4B5563), // 어두운 회색
    accent: Color(0xFFC6C6C6), // 액센트 회색
    // 텍스트 색상들
    text: Color(0xFF1F2937), // 주요 텍스트 색상
    textLight: Color(0xFF6B7280), // 보조 텍스트 색상
    // 배경 색상들
    background: Color(0xFFf5f5f5), // 순백 배경색
    surface: Color(0xFFF9FAFB), // 카드/표면 배경색
    // 강조 색상들
    divider: Color(0xFF3B82F6), // 구분선 색상
    highlight: Color(0xFF3B82F6), // 하이라이트 색상 (파란색)
    // 상태 색상들
    success: Color(0xFF44916F), // 성공/긍정 색상 (초록색)
    warning: Color(0xFFEF4444), // 경고 색상 (주황색)
    light_warning: Color(0xFFFFA16C), // 경고 색상
    error: Color(0xFFEF4444), // 오류 색상 (빨간색)
    info: Color(0xFF3B82F6), // 정보 색상 (파란색)
    conversation_A: Color(0xFFBBDEFB), // 대화 색상 A
    conversation_B: Color(0xFFC8E6C9), // 대화 색상 B
    google_login: Color(0xFFFFFFFF), // 구글 로그인 색상
    snackbar_text: Color(0xFFFFFFFF), // 스낵바 텍스트 색상
  );

  @override
  ThemeData get themeData => ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: customColors.background,
    primaryColor: customColors.primary,
    appBarTheme: AppBarTheme(
      backgroundColor: customColors.background,
      foregroundColor: customColors.text,
      surfaceTintColor: customColors.background,
      shadowColor: customColors.background,
    ),
    textTheme: TextTheme(
      bodyLarge: TextStyle(color: customColors.text),
      bodyMedium: TextStyle(color: customColors.text),
      titleLarge: TextStyle(color: customColors.text),
      titleMedium: TextStyle(color: customColors.text),
      titleSmall: TextStyle(color: customColors.text),
    ),
    colorScheme: ColorScheme.light(
      primary: customColors.primary,
      secondary: customColors.accent,
      surface: customColors.surface,
      error: customColors.error,
      onPrimary: customColors.text,
      onSecondary: customColors.text,
      onSurface: customColors.text,
      onError: Colors.white,
    ),
    cardTheme: CardThemeData(color: customColors.surface, elevation: 2),
    dividerTheme: DividerThemeData(color: customColors.divider, thickness: 1),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: customColors.primary,
        foregroundColor: customColors.text,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: customColors.primary,
        side: BorderSide(color: customColors.primary),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: customColors.primary),
    ),
  );
}
