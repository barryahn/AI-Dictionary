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
      backgroundColor: customColors.surface,
      foregroundColor: customColors.text,
      elevation: 0,
      shadowColor: Colors.transparent,
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
    colorScheme: ColorScheme.dark(
      primary: customColors.primary,
      secondary: customColors.accent,
      background: customColors.background,
      surface: customColors.surface,
      error: customColors.error,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onBackground: customColors.text,
      onSurface: customColors.text,
      onError: Colors.white,
    ),
    cardTheme: CardThemeData(
      color: customColors.surface,
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.3),
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
        elevation: 2,
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
      fillColor: customColors.light,
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
      backgroundColor: customColors.surface,
      selectedItemColor: customColors.primary,
      unselectedItemColor: customColors.textLight,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: customColors.primary,
      foregroundColor: Colors.white,
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: customColors.light,
      selectedColor: customColors.primary,
      labelStyle: TextStyle(color: customColors.text),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: customColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      titleTextStyle: TextStyle(
        color: customColors.text,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
      contentTextStyle: TextStyle(color: customColors.textLight, fontSize: 14),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: customColors.surface,
      contentTextStyle: TextStyle(color: customColors.text),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return customColors.primary;
        }
        return customColors.textLight;
      }),
      trackColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return customColors.primary.withValues(alpha: 0.3);
        }
        return customColors.divider;
      }),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return customColors.primary;
        }
        return Colors.transparent;
      }),
      checkColor: MaterialStateProperty.all(Colors.white),
      side: BorderSide(color: customColors.divider),
    ),
    radioTheme: RadioThemeData(
      fillColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return customColors.primary;
        }
        return customColors.textLight;
      }),
    ),
  );
}
