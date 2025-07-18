import 'package:flutter/material.dart';
import 'app_colors.dart';

/// 추천(베이지) 색상 팔레트
/// AI Dictionary 앱의 추천 테마 색상을 관리합니다.
class RecommendedColors implements AppColors {
  // 기본 베이지 색상들
  static const Color _primary = Color(0xFFD4C4A8); // 메인 베이지
  static const Color _extraLight = Color(0xFFF9F5ED); // 더 밝은 베이지
  static const Color _light = Color(0xFFF5F1E8); // 밝은 베이지
  static const Color _dark = Color(0xFFB8A898); // 어두운 베이지
  static const Color _accent = Color(0xFFE8DCC0); // 액센트 베이지

  // 텍스트 색상들
  static const Color _text = Color(0xFF5D4E37); // 주요 텍스트 색상
  static const Color _textLight = Color(0xFF8B7355); // 보조 텍스트 색상

  // 배경 색상들
  static const Color _background = Color(0xFFFDFBF7); // 메인 배경색
  static const Color _surface = Color(0xFFF5F1E8); // 카드/표면 배경색

  // 강조 색상들
  static const Color _divider = Color(0xFFE07A5F); // 구분선 색상
  static const Color _highlight = Color(0xFFE07A5F); // 하이라이트 색상

  // 상태 색상들
  static const Color _success = Color(0xFF81B29A); // 성공/긍정 색상
  static const Color _warning = Color(0xFFF2CC8F); // 경고 색상
  static const Color _error = Color(0xFFE07A5F); // 오류 색상
  static const Color _info = Color(0xFF81B29A); // 정보 색상

  // AppColors 구현
  @override
  Color get primary => _primary;
  @override
  Color get extraLight => _extraLight;
  @override
  Color get light => _light;
  @override
  Color get dark => _dark;
  @override
  Color get accent => _accent;
  @override
  Color get text => _text;
  @override
  Color get textLight => _textLight;
  @override
  Color get background => _background;
  @override
  Color get surface => _surface;
  @override
  Color get divider => _divider;
  @override
  Color get highlight => _highlight;
  @override
  Color get success => _success;
  @override
  Color get warning => _warning;
  @override
  Color get error => _error;
  @override
  Color get info => _info;

  @override
  Color get primaryWithOpacity20 => _primary.withValues(alpha: 0.2);
  @override
  Color get primaryWithOpacity40 => _primary.withValues(alpha: 0.4);
  @override
  Color get darkWithOpacity20 => _dark.withValues(alpha: 0.2);
  @override
  Color get darkWithOpacity30 => _dark.withValues(alpha: 0.3);
  @override
  Color get darkWithOpacity40 => _dark.withValues(alpha: 0.4);
  @override
  Color get backgroundWithOpacity80 => _background.withValues(alpha: 0.8);

  @override
  List<Color> get primaryGradient => [_accent, _light];
  @override
  List<Color> get highlightGradient => [_highlight, _primary];
  @override
  List<Color> get backgroundGradient => [_background, _extraLight];

  /// 색상 팔레트 정보를 반환합니다.
  static Map<String, Color> get palette => {
    'primary': _primary,
    'extraLight': _extraLight,
    'light': _light,
    'dark': _dark,
    'accent': _accent,
    'text': _text,
    'textLight': _textLight,
    'background': _background,
    'surface': _surface,
    'divider': _divider,
    'highlight': _highlight,
    'success': _success,
    'warning': _warning,
    'error': _error,
    'info': _info,
  };

  /// 색상 팔레트를 콘솔에 출력합니다. (디버깅용)
  static void printPalette() {
    print('=== RecommendedColors Palette ===');
    palette.forEach((name, color) {
      print(
        '$name:  [33m [1m [4m${color.value.toRadixString(16).toUpperCase()}\u001b[0m',
      );
    });
    print('==========================');
  }
}
