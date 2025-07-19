import 'package:flutter/material.dart';
import 'app_theme.dart';

class DarkTheme extends AppTheme {
  @override
  String get id => 'dark';

  @override
  CustomColors get customColors => const CustomColors(
    // 기본 다크 색상들
    primary: Color(0xFF6366F1), // 인디고 보라색 (강조색)
    extraLight: Color(0xFF1F2937), // 매우 어두운 회색
    light: Color(0xFF374151), // 어두운 회색
    dark: Color(0xFF111827), // 매우 어두운 회색
    accent: Color(0xFF8B5CF6), // 보라색 액센트
    // 텍스트 색상들
    text: Color(0xFFF9FAFB), // 밝은 텍스트 색상
    textLight: Color(0xFFD1D5DB), // 보조 텍스트 색상
    // 배경 색상들
    background: Color(0xFF0F172A), // 깊이 있는 다크 블루 그레이
    surface: Color(0xFF1E293B), // 카드/표면 배경색
    // 강조 색상들
    divider: Color(0xFF334155), // 구분선 색상
    highlight: Color(0xFF60A5FA), // 하이라이트 색상 (밝은 파란색)
    // 상태 색상들
    success: Color(0xFF34D399), // 성공/긍정 색상 (밝은 초록색)
    warning: Color(0xFFFBBF24), // 경고 색상 (밝은 주황색)
    error: Color(0xFFF87171), // 오류 색상 (밝은 빨간색)
    info: Color(0xFF60A5FA), // 정보 색상 (밝은 파란색)
  );

  @override
  ThemeData get themeData => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: customColors.background,
    primaryColor: customColors.primary,
    appBarTheme: AppBarTheme(
      backgroundColor: customColors.light,
      foregroundColor: customColors.text,
    ),
    textTheme: TextTheme(
      bodyLarge: TextStyle(color: customColors.text),
      bodyMedium: TextStyle(color: customColors.text),
      titleLarge: TextStyle(color: customColors.text),
      titleMedium: TextStyle(color: customColors.text),
      titleSmall: TextStyle(color: customColors.text),
    ),
    colorScheme: ColorScheme.dark(
      primary: customColors.primary,
      secondary: customColors.accent,
      background: customColors.background,
      surface: customColors.surface,
      error: customColors.error,
      onPrimary: customColors.text,
      onSecondary: customColors.text,
      onBackground: customColors.text,
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
