import 'package:flutter/material.dart';

/// 베이지 색상 팔레트
/// AI Dictionary 앱의 전체적인 테마 색상을 관리합니다.
class BeigeColors {
  // 기본 베이지 색상들
  static const Color primary = Color(0xFFD4C4A8); // 메인 베이지
  static const Color extraLight = Color(0xFFF9F5ED); // 더 밝은 베이지
  static const Color light = Color(0xFFF5F1E8); // 밝은 베이지
  static const Color dark = Color(0xFFB8A898); // 어두운 베이지
  static const Color accent = Color(0xFFE8DCC0); // 액센트 베이지

  // 텍스트 색상들
  static const Color text = Color(0xFF5D4E37); // 주요 텍스트 색상
  static const Color textLight = Color(0xFF8B7355); // 보조 텍스트 색상

  // 배경 색상들
  static const Color background = Color(0xFFFDFBF7); // 메인 배경색
  static const Color surface = Color(0xFFF5F1E8); // 카드/표면 배경색

  // 강조 색상들
  static const Color divider = Color(0xFFE07A5F); // 구분선 색상
  static const Color highlight = Color(0xFFE07A5F); // 하이라이트 색상

  // 상태 색상들
  static const Color success = Color(0xFF81B29A); // 성공/긍정 색상
  static const Color warning = Color(0xFFF2CC8F); // 경고 색상
  static const Color error = Color(0xFFE07A5F); // 오류 색상
  static const Color info = Color(0xFF81B29A); // 정보 색상

  // 투명도가 적용된 색상들
  static Color get primaryWithOpacity20 => primary.withValues(alpha: 0.2);
  static Color get primaryWithOpacity40 => primary.withValues(alpha: 0.4);
  static Color get darkWithOpacity20 => dark.withValues(alpha: 0.2);
  static Color get darkWithOpacity30 => dark.withValues(alpha: 0.3);
  static Color get darkWithOpacity40 => dark.withValues(alpha: 0.4);
  static Color get backgroundWithOpacity80 => background.withValues(alpha: 0.8);

  // 그라데이션 색상 조합들
  static const List<Color> primaryGradient = [accent, light];
  static const List<Color> highlightGradient = [highlight, primary];
  static const List<Color> backgroundGradient = [background, extraLight];

  /// 색상 팔레트 정보를 반환합니다.
  static Map<String, Color> get palette => {
    'primary': primary,
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
    'error': error,
    'info': info,
  };

  /// 색상 팔레트를 콘솔에 출력합니다. (디버깅용)
  static void printPalette() {
    print('=== BeigeColors Palette ===');
    palette.forEach((name, color) {
      print('$name: ${color.value.toRadixString(16).toUpperCase()}');
    });
    print('==========================');
  }
}
