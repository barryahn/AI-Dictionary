import 'package:shared_preferences/shared_preferences.dart';

class LanguageService {
  static const String _languageKey = 'app_language';
  static const String korean = 'ko';
  static const String english = 'en';

  static String _currentLanguage = korean; // 기본값은 한국어

  // 현재 언어 가져오기
  static String get currentLanguage => _currentLanguage;

  // 언어 초기화 (저장된 설정 불러오기)
  static Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _currentLanguage = prefs.getString(_languageKey) ?? korean;
  }

  // 언어 변경
  static Future<void> setLanguage(String language) async {
    if (language != korean && language != english) return;

    _currentLanguage = language;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, language);
  }

  // 언어 이름 가져오기
  static String getLanguageName(String languageCode) {
    switch (languageCode) {
      case korean:
        return '한국어';
      case english:
        return 'English';
      default:
        return '한국어';
    }
  }

  // 현재 언어 이름 가져오기
  static String get currentLanguageName => getLanguageName(_currentLanguage);

  // 지원하는 언어 목록
  static List<Map<String, String>> get supportedLanguages => [
    {'code': korean, 'name': '한국어'},
    {'code': english, 'name': 'English'},
  ];
}
