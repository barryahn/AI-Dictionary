import 'package:flutter/material.dart';
import 'app_theme.dart';

class RecommendedTheme extends AppTheme {
  @override
  String get id => 'recommended';

  @override
  CustomColors get customColors => const CustomColors(
    // 기본 베이지 색상들
    primary: Color(0xFF29b56a), // 메인 베이지
    // Secondary
    secondary: Color(0xFFAAC133), // 메인 베이지
    complementary: Color(0xFFB52974), // 보색

    white: Colors.white,
    light: Color(0xFFf9e9db), // 밝은 베이지
    extraLight: Color(0xFFf5f7f4), // 더 밝은 베이지
    dark: Color(0xFF646160), // 어두운 베이지
    accent: Color(0xFFE8DCC0), // 액센트 베이지
    // 텍스트 색상들
    text: Color(0xFF323030), // 주요 텍스트 색상
    textLight: Color(0xFF74706F), // 보조 텍스트 색상
    // 배경 색상들
    background: Color(0xFFF8FAF7), // 메인 배경색
    surface: Colors.white, // 카드/표면 배경색
    // 강조 색상들
    divider: Color(0xFFE07A5F), // 구분선 색상
    highlight: Color(0xFFE07A5F), // 하이라이트 색상
    // 상태 색상들
    success: Color(0xFF44916F), // 성공/긍정 색상
    warning: Color(0xFFE45141), // 경고 색상
    light_warning: Color(0xFFDC7F4A), // 경고 색상
    error: Color(0xFFE45141), // 오류 색상
    info: Color(0xFF81B29A), // 정보 색상
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
      style: TextButton.styleFrom(foregroundColor: customColors.text),
    ),
  );
}
