import 'package:flutter/material.dart';
import 'app_theme.dart';

class DarkTheme extends AppTheme {
  @override
  String get id => 'dark';

  @override
  CustomColors get customColors => const CustomColors(
    // 기본 다크 색상들 - 어두운 회색과 검정 계열
    // primary: Color(0xFFB67CFA), // 메인 보라색
    // secondary: Color(0xFF7724cc), // 보조 보라색
    primary: Color(0xFF3EB489), // 메인 베이지
    secondary: Color(0xFFAAC133), // 메인 베이지
    complementary: Color(0xFFC96389), // 보색

    white: Color(0xFF191919),
    extraLight: Color(0xFF1D1D1D), // 매우 어두운 회색
    light: Color(0xFF2A2A2A), // 어두운 회색
    dark: Color(0xFF373737), // 살짝 어두운 회색
    accent: Color(0xFF718096), // 액센트 회색
    // 텍스트 색상들
    text: Color(0xFFF0F0F0), // 밝은 텍스트 색상
    textLight: Color(0xFF9B9B9B), // 보조 텍스트 색상
    // 배경 색상들
    background: Color(0xFF232323), // 깊이 있는 다크 배경
    surface: Color(0xFF232323), // 카드/표면 배경색
    // 강조 색상들
    divider: Color(0xFFA0AEC0), // 구분선 색상
    highlight: Color(0xFFF9A4A0), // 하이라이트 색상 (밝은 주황색)
    // 상태 색상들
    success: Color(0xFF06402B), // 성공/긍정 색상 (초록색)
    warning: Color(0xFFF54B64), // 경고 색상 (주황색)
    light_warning: Color(0xFFF78361), // 경고 색상
    error: Color(0xFFF78361), // 오류 색상 (코랄색)
    info: Color(0xFF0088DC), // 정보 색상 (파란색)
    conversation_A: Color(0xFF3F6FAF), // 대화 색상 A
    conversation_B: Color(0xFF4B754B), // 대화 색상 B
    google_login: Color(0xFF2D3748), // 구글 로그인 색상
    snackbar_text: Color(0xFFE2E8F0), // 스낵바 텍스트 색상
  );

  @override
  ThemeData get themeData => ThemeData(
    brightness: Brightness.dark,
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
    colorScheme: ColorScheme.dark(
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
