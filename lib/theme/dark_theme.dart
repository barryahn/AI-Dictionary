import 'package:flutter/material.dart';
import 'app_theme.dart';

class DarkTheme extends AppTheme {
  @override
  String get id => 'dark';

  @override
  CustomColors get customColors => const CustomColors(
    // 기본 다크 색상들 - 어두운 회색과 검정 계열
    primary: Color(0xFF4A5568), // 메인 어두운 회색
    extraLight: Color(0xFF1A202C), // 매우 어두운 회색
    light: Color(0xFF2D3748), // 어두운 회색
    dark: Color(0xFF5A6166), // 매우 어두운 검정
    accent: Color(0xFF718096), // 액센트 회색
    // 텍스트 색상들
    text: Color(0xFFE2E8F0), // 밝은 텍스트 색상
    textLight: Color(0xFFA0AEC0), // 보조 텍스트 색상
    // 배경 색상들
    background: Color(0xFF0F1419), // 깊이 있는 다크 배경
    surface: Color(0xFF1A202C), // 카드/표면 배경색
    // 강조 색상들
    divider: Color(0xFFA0AEC0), // 구분선 색상
    highlight: Color(0xFFF9A4A0), // 하이라이트 색상 (회색)
    // 상태 색상들
    success: Color(0xFF48BB78), // 성공/긍정 색상 (초록색)
    warning: Color(0xFFF26175), // 경고 색상 (주황색)
    error: Color(0xFFD73F2F), // 오류 색상 (빨간색)
    info: Color(0xFF0088DC), // 정보 색상 (파란색)
    conversation_A: Color(0xFF3F6FAF), // 대화 색상 A
    conversation_B: Color(0xFF4B754B), // 대화 색상 B
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
