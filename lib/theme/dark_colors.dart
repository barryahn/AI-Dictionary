import 'package:flutter/material.dart';
import 'app_colors.dart';

/// 다크 색상 팔레트
/// AI Dictionary 앱의 다크 테마 색상을 관리합니다.
class DarkColors implements AppColors {
  static const Color _primary = Color(0xFF23272F); // 메인 다크
  static const Color _extraLight = Color(0xFF353A40); // 밝은 다크
  static const Color _light = Color(0xFF2C313A); // 밝은 다크
  static const Color _dark = Color(0xFF181A20); // 가장 어두운 다크
  static const Color _accent = Color(0xFF3A3F47); // 액센트 다크

  static const Color _text = Color(0xFFF5F6FA); // 주요 텍스트 색상
  static const Color _textLight = Color(0xFFB0B3B8); // 보조 텍스트 색상

  static const Color _background = Color(0xFF181A20); // 메인 배경색
  static const Color _surface = Color(0xFF23272F); // 카드/표면 배경색

  static const Color _divider = Color(0xFF44474F); // 구분선 색상
  static const Color _highlight = Color(0xFF3A3F47); // 하이라이트 색상

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
    print('=== DarkColors Palette ===');
    palette.forEach((name, color) {
      print(
        '$name:  [33m [1m [4m${color.value.toRadixString(16).toUpperCase()}\u001b[0m',
      );
    });
    print('==========================');
  }
}
