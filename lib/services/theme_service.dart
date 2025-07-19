import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';
import '../theme/recommended_theme.dart';
import '../theme/light_theme.dart';
import '../theme/dark_theme.dart';

class ThemeService extends ChangeNotifier {
  static const String _themeKey = 'selected_theme';
  static ThemeService? _instance;

  AppTheme _currentTheme = RecommendedTheme();

  // 싱글톤 패턴
  static ThemeService get instance {
    _instance ??= ThemeService._();
    return _instance!;
  }

  ThemeService._();

  // 초기화 메서드 추가
  static Future<void> initialize() async {
    await instance._loadTheme();
  }

  // 현재 테마 가져오기
  AppTheme get currentTheme => _currentTheme;

  // 현재 테마의 CustomColors 가져오기
  CustomColors get colors => _currentTheme.customColors;

  // 현재 테마의 ThemeData 가져오기
  ThemeData get themeData => _currentTheme.themeData;

  // 현재 테마 ID 가져오기
  String get currentThemeId => _currentTheme.id;

  // 사용 가능한 테마 목록
  static List<AppTheme> get availableThemes => [
    RecommendedTheme(),
    LightTheme(),
    DarkTheme(),
  ];

  // 테마 ID로 테마 찾기
  static AppTheme getThemeById(String themeId) {
    switch (themeId) {
      case 'recommended':
        return RecommendedTheme();
      case 'light':
        return LightTheme();
      case 'dark':
        return DarkTheme();
      default:
        return RecommendedTheme();
    }
  }

  // 테마 변경
  Future<void> setTheme(String themeId) async {
    final newTheme = getThemeById(themeId);
    if (_currentTheme.id != newTheme.id) {
      _currentTheme = newTheme;
      await _saveTheme(themeId);
      notifyListeners();
    }
  }

  // 저장된 테마 로드
  Future<void> _loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeId = prefs.getString(_themeKey) ?? 'recommended';
      _currentTheme = getThemeById(themeId);
      notifyListeners();
    } catch (e) {
      // 오류 발생 시 기본 테마 사용
      _currentTheme = RecommendedTheme();
      notifyListeners();
    }
  }

  // 테마 저장
  Future<void> _saveTheme(String themeId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_themeKey, themeId);
    } catch (e) {
      // 저장 실패 시 무시
    }
  }

  // 테마 이름 가져오기
  String getThemeName(String themeId) {
    switch (themeId) {
      case 'recommended':
        return '추천 테마';
      case 'light':
        return '라이트 테마';
      case 'dark':
        return '다크 테마';
      default:
        return '추천 테마';
    }
  }

  // 테마 아이콘 가져오기
  IconData getThemeIcon(String themeId) {
    switch (themeId) {
      case 'recommended':
        return Icons.favorite;
      case 'light':
        return Icons.light_mode;
      case 'dark':
        return Icons.dark_mode;
      default:
        return Icons.favorite;
    }
  }

  // 테마 설명 가져오기
  String getThemeDescription(String themeId) {
    switch (themeId) {
      case 'recommended':
        return '베이지 색상의 따뜻한 테마';
      case 'light':
        return '밝고 깔끔한 라이트 테마';
      case 'dark':
        return '세련된 다크 테마';
      default:
        return '베이지 색상의 따뜻한 테마';
    }
  }
}
