import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_colors.dart';
import '../theme/recommended_colors.dart';
import '../theme/light_colors.dart';
import '../theme/dark_colors.dart';

/// 테마 관리 서비스
/// 앱의 테마 설정을 관리하고 저장합니다.
class ThemeService extends ChangeNotifier {
  static const String _themeKey = 'selected_theme';
  static const String _recommendedTheme = 'recommended_theme';
  static const String _lightTheme = 'light_theme';
  static const String _darkTheme = 'dark_theme';

  AppColors _currentTheme = RecommendedColors();
  late SharedPreferences _prefs;

  /// 현재 테마
  AppColors get currentTheme => _currentTheme;

  /// 지원되는 테마 목록
  static const List<Map<String, String>> supportedThemes = [
    {'key': _recommendedTheme, 'name': '추천 테마'},
    {'key': _lightTheme, 'name': '라이트 테마'},
    {'key': _darkTheme, 'name': '다크 테마'},
  ];

  /// 초기화
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadTheme();
  }

  /// 테마 로드
  Future<void> _loadTheme() async {
    final themeKey = _prefs.getString(_themeKey) ?? _recommendedTheme;
    await setTheme(themeKey);
  }

  /// 테마 설정
  Future<void> setTheme(String themeKey) async {
    AppColors newTheme;

    switch (themeKey) {
      case _lightTheme:
        newTheme = LightColors();
        break;
      case _darkTheme:
        newTheme = DarkColors();
        break;
      case _recommendedTheme:
      default:
        newTheme = RecommendedColors();
        break;
    }

    if (_currentTheme.runtimeType != newTheme.runtimeType) {
      _currentTheme = newTheme;
      await _prefs.setString(_themeKey, themeKey);
      notifyListeners();
    }
  }

  /// 현재 테마 키 반환
  String get currentThemeKey {
    if (_currentTheme is LightColors) return _lightTheme;
    if (_currentTheme is DarkColors) return _darkTheme;
    return _recommendedTheme;
  }

  /// 테마가 추천 테마인지 확인
  bool get isRecommendedTheme => _currentTheme is RecommendedColors;

  /// 테마가 라이트 테마인지 확인
  bool get isLightTheme => _currentTheme is LightColors;

  /// 테마가 다크 테마인지 확인
  bool get isDarkTheme => _currentTheme is DarkColors;

  /// 테마 이름 반환
  String get currentThemeName {
    if (isLightTheme) return '라이트 테마';
    if (isDarkTheme) return '다크 테마';
    return '추천 테마';
  }

  /// 테마 변경 (키로)
  Future<void> changeTheme(String themeKey) async {
    await setTheme(themeKey);
  }

  /// 추천 테마로 변경
  Future<void> setRecommendedTheme() async {
    await setTheme(_recommendedTheme);
  }

  /// 라이트 테마로 변경
  Future<void> setLightTheme() async {
    await setTheme(_lightTheme);
  }

  /// 다크 테마로 변경
  Future<void> setDarkTheme() async {
    await setTheme(_darkTheme);
  }

  /// 테마 순환 (다음 테마로 변경)
  Future<void> cycleTheme() async {
    switch (currentThemeKey) {
      case _recommendedTheme:
        await setLightTheme();
        break;
      case _lightTheme:
        await setDarkTheme();
        break;
      case _darkTheme:
        await setRecommendedTheme();
        break;
    }
  }

  /// 저장된 테마 키 반환
  Future<String> getSavedThemeKey() async {
    return _prefs.getString(_themeKey) ?? _recommendedTheme;
  }

  /// 테마 설정 초기화
  Future<void> resetTheme() async {
    await setTheme(_recommendedTheme);
  }
}
