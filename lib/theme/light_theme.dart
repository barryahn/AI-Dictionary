import 'package:flutter/material.dart';
import 'app_theme.dart';

class LightTheme extends AppTheme {
  @override
  String get id => 'light';

  @override
  CustomColors get customColors => const CustomColors(
    // 기본 회색 색상들
    primary: Color(0xFF6B7280), // 메인 회색
    extraLight: Color(0xFFF9FAFB), // 매우 밝은 회색
    light: Color(0xFFF3F4F6), // 밝은 회색
    dark: Color(0xFF4B5563), // 어두운 회색
    accent: Color(0xFF9CA3AF), // 액센트 회색
    // 텍스트 색상들
    text: Color(0xFF1F2937), // 주요 텍스트 색상
    textLight: Color(0xFF6B7280), // 보조 텍스트 색상
    // 배경 색상들
    background: Color(0xFFFFFFFF), // 순백 배경색
    surface: Color(0xFFF9FAFB), // 카드/표면 배경색
    // 강조 색상들
    divider: Color(0xFFE5E7EB), // 구분선 색상
    highlight: Color(0xFF3B82F6), // 하이라이트 색상 (파란색)
    // 상태 색상들
    success: Color(0xFF10B981), // 성공/긍정 색상 (초록색)
    warning: Color(0xFFF59E0B), // 경고 색상 (주황색)
    error: Color(0xFFEF4444), // 오류 색상 (빨간색)
    info: Color(0xFF3B82F6), // 정보 색상 (파란색)
  );

  @override
  ThemeData get themeData => ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: customColors.background,
    primaryColor: customColors.primary,
    appBarTheme: AppBarTheme(
      backgroundColor: customColors.background,
      foregroundColor: customColors.text,
      elevation: 0,
      shadowColor: customColors.divider,
      titleTextStyle: TextStyle(
        color: customColors.text,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),
    textTheme: TextTheme(
      bodyLarge: TextStyle(
        color: customColors.text,
        fontSize: 16,
        fontWeight: FontWeight.normal,
      ),
      bodyMedium: TextStyle(
        color: customColors.text,
        fontSize: 14,
        fontWeight: FontWeight.normal,
      ),
      titleLarge: TextStyle(
        color: customColors.text,
        fontSize: 22,
        fontWeight: FontWeight.w600,
      ),
      titleMedium: TextStyle(
        color: customColors.text,
        fontSize: 18,
        fontWeight: FontWeight.w500,
      ),
      titleSmall: TextStyle(
        color: customColors.text,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      labelLarge: TextStyle(
        color: customColors.textLight,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    ),
    colorScheme: ColorScheme.light(
      primary: customColors.primary,
      secondary: customColors.accent,
      background: customColors.background,
      surface: customColors.surface,
      error: customColors.error,
      onPrimary: Colors.white,
      onSecondary: customColors.text,
      onBackground: customColors.text,
      onSurface: customColors.text,
      onError: Colors.white,
    ),
    cardTheme: CardThemeData(
      color: customColors.surface,
      elevation: 1,
      shadowColor: customColors.divider,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    dividerTheme: DividerThemeData(
      color: customColors.divider,
      thickness: 1,
      space: 1,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: customColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: customColors.primary,
        side: BorderSide(color: customColors.primary),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: customColors.primary,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: customColors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: customColors.divider),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: customColors.divider),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: customColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: customColors.error),
      ),
      labelStyle: TextStyle(color: customColors.textLight, fontSize: 14),
      hintStyle: TextStyle(color: customColors.textLight, fontSize: 14),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: customColors.background,
      selectedItemColor: customColors.primary,
      unselectedItemColor: customColors.textLight,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: customColors.primary,
      foregroundColor: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: customColors.light,
      selectedColor: customColors.primary,
      labelStyle: TextStyle(color: customColors.text),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
  );
}
