import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

class LanguageService {
  static const String _languageKey = 'app_language';
  static const String _fromLanguageKey = 'from_language';
  static const String _toLanguageKey = 'to_language';
  static const String korean = 'ko';
  static const String english = 'en';
  static const String chinese = 'zh';
  static const String taiwanese = 'zh-tw';
  static const String french = 'fr';
  static const String spanish = 'es';

  static String _currentLanguage = korean; // 기본값은 한국어
  static String _fromLanguage = '영어'; // 기본 출발 언어
  static String _toLanguage = '한국어'; // 기본 도착 언어

  // 언어 변경 알림을 위한 스트림 컨트롤러
  static final StreamController<Map<String, String>> _languageController =
      StreamController<Map<String, String>>.broadcast();

  // 언어 변경 스트림
  static Stream<Map<String, String>> get languageStream =>
      _languageController.stream;

  // 현재 언어 가져오기
  static String get currentLanguage => _currentLanguage;

  // 번역 언어 가져오기
  static String get fromLanguage => _fromLanguage;
  static String get toLanguage => _toLanguage;

  // 언어 초기화 (저장된 설정 불러오기)
  static Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _currentLanguage = prefs.getString(_languageKey) ?? korean;
    _fromLanguage = prefs.getString(_fromLanguageKey) ?? '영어';
    _toLanguage = prefs.getString(_toLanguageKey) ?? '한국어';
  }

  // 언어 변경
  static Future<void> setLanguage(String language) async {
    if (![
      korean,
      english,
      chinese,
      taiwanese,
      french,
      spanish,
    ].contains(language)) {
      return;
    }

    _currentLanguage = language;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, language);

    // 앱 언어 변경 알림 전송
    _languageController.add({'appLanguage': language});
  }

  // 번역 언어 변경
  static Future<void> setTranslationLanguages(
    String fromLang,
    String toLang,
  ) async {
    // 같은 언어가 선택된 경우 자동으로 위치를 바꿈
    if (fromLang == toLang) {
      final temp = _fromLanguage;
      _fromLanguage = _toLanguage;
      _toLanguage = temp;
    } else {
      _fromLanguage = fromLang;
      _toLanguage = toLang;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_fromLanguageKey, _fromLanguage);
    await prefs.setString(_toLanguageKey, _toLanguage);

    // 언어 변경 알림 전송
    _languageController.add({
      'fromLanguage': _fromLanguage,
      'toLanguage': _toLanguage,
    });
  }

  // 언어 코드 가져오기
  static String getLanguageCode(String languageName) {
    switch (languageName) {
      case '한국어':
        return 'ko';
      case '영어':
        return 'en';
      case '중국어':
        return 'zh';
      case '대만어':
        return 'zh-tw';
      case '프랑스어':
        return 'fr';
      case '스페인어':
        return 'es';
      default:
        return 'null';
    }
  }

  // 언어 이름 가져오기
  static String getLanguageName(String languageCode) {
    switch (languageCode) {
      case korean:
        return '한국어';
      case english:
        return 'English';
      case chinese:
        return '中文';
      case taiwanese:
        return '繁體中文';
      case french:
        return 'Français';
      case spanish:
        return 'Español';
      default:
        return '한국어';
    }
  }

  // 로케일 생성 헬퍼 메서드
  static Locale createLocale(String languageCode) {
    if (languageCode == 'zh-tw') {
      return const Locale('zh', 'tw');
    }
    return Locale(languageCode);
  }

  // 현재 언어 이름 가져오기
  static String get currentLanguageName => getLanguageName(_currentLanguage);

  // 지원하는 언어 목록
  static List<Map<String, String>> get supportedLanguages => [
    {'code': korean, 'name': '한국어'},
    {'code': english, 'name': 'English'},
    {'code': chinese, 'name': '中文'},
    {'code': taiwanese, 'name': '繁體中文'},
    {'code': french, 'name': 'Français'},
    {'code': spanish, 'name': 'Español'},
  ];

  // 번역 지원 언어 목록 (다국어 지원)
  static List<Map<String, String>> getLocalizedTranslationLanguages(
    AppLocalizations loc,
  ) => [
    {'code': '영어', 'name': loc.english},
    {'code': '한국어', 'name': loc.korean},
    {'code': '중국어', 'name': loc.chinese},
    {'code': '대만어', 'name': loc.taiwanese},
    {'code': '스페인어', 'name': loc.spanish},
    {'code': '프랑스어', 'name': loc.french},
  ];

  // 번역 지원 언어 목록 (기본 - 하위 호환성)
  static List<String> get translationLanguages => [
    '영어',
    '한국어',
    '중국어',
    '대만어',
    '스페인어',
    '프랑스어',
  ];

  // 리소스 정리
  static void dispose() {
    _languageController.close();
  }
}
