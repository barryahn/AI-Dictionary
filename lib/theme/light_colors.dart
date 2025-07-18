import 'package:flutter/material.dart';
import 'app_colors.dart';

/// 라이트(밝은) 색상 팔레트
/// AI Dictionary 앱의 라이트 테마 색상을 관리합니다.
class LightColors implements AppColors {
  static const Color _primary = Color(0xFFF5F6FA); // 메인 밝은 회색
  static const Color _extraLight = Color(0xFFFFFFFF); // 완전 화이트
  static const Color _light = Color(0xFFF0F1F6); // 밝은 회색
  static const Color _dark = Color(0xFFB0B3B8); // 어두운 회색
  static const Color _accent = Color(0xFFE3E6ED); // 액센트 밝은 회색

  static const Color _text = Color(0xFF222222); // 주요 텍스트 색상
  static const Color _textLight = Color(0xFF888888); // 보조 텍스트 색상

  static const Color _background = Color(0xFFF8F9FB); // 메인 배경색
  static const Color _surface = Color(0xFFFFFFFF); // 카드/표면 배경색

  static const Color _divider = Color(0xFFCED0D4); // 구분선 색상
  static const Color _highlight = Color(0xFFB0B3B8); // 하이라이트 색상

  static const Color _success = Color(0xFF4CAF50); // 성공/긍정 색상
  static const Color _warning = Color(0xFFFFC107); // 경고 색상
  static const Color _error = Color(0xFFF44336); // 오류 색상
  static const Color _info = Color(0xFF2196F3); // 정보 색상

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
  Color get primaryWithOpacity20 => _primary.withOpacity(0.2);
  @override
  Color get primaryWithOpacity40 => _primary.withOpacity(0.4);
  @override
  Color get darkWithOpacity20 => _dark.withOpacity(0.2);
  @override
  Color get darkWithOpacity30 => _dark.withOpacity(0.3);
  @override
  Color get darkWithOpacity40 => _dark.withOpacity(0.4);
  @override
  Color get backgroundWithOpacity80 => _background.withOpacity(0.8);

  @override
  List<Color> get primaryGradient => [_accent, _light];
  @override
  List<Color> get highlightGradient => [_highlight, _primary];
  @override
  List<Color> get backgroundGradient => [_background, _extraLight];

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

  static void printPalette() {
    print('=== LightColors Palette ===');
    palette.forEach((name, color) {
      print(
        '$name:  [33m [1m [4m${color.value.toRadixString(16).toUpperCase()}\u001b[0m',
      );
    });
    print('==========================');
  }
}
