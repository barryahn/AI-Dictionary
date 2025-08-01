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
  static const String taiwanese = 'zh-TW';
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
    String? savedLanguage = prefs.getString(_languageKey);
    if (savedLanguage == null) {
      // 시스템 로케일을 확인하여 언어 결정
      Locale systemLocale = WidgetsBinding.instance.platformDispatcher.locale;
      String langCode = systemLocale.languageCode;
      String? countryCode = systemLocale.countryCode;

      // 시스템 로케일 출력
      print('systemLocale: \\${systemLocale.toString()}');
      print('langCode: \\${langCode}');
      print('countryCode: \\${countryCode}');

      if (langCode == 'ko') {
        _currentLanguage = korean;
      } else if (langCode == 'en') {
        _currentLanguage = english;
      } else if (langCode == 'zh' && countryCode == 'TW') {
        _currentLanguage = taiwanese;
      } else if (langCode == 'zh') {
        _currentLanguage = chinese;
      } else if (langCode == 'fr') {
        _currentLanguage = french;
      } else if (langCode == 'es') {
        _currentLanguage = spanish;
      } else {
        _currentLanguage = english;
      }
      await prefs.setString(_languageKey, _currentLanguage);
    } else {
      _currentLanguage = savedLanguage;
    }
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
        return 'zh-TW';
      case '프랑스어':
        return 'fr';
      case '스페인어':
        return 'es';
      default:
        return 'null';
    }
  }

  static List<String> getSupportedLanguagesCode() {
    return ['ko', 'en', 'zh', 'zh-TW', 'fr', 'es'];
  }

  // 언어 이름 가져오기
  static String getLanguageName(String languageCode) {
    switch (languageCode) {
      case korean || 'ko':
        return '한국어';
      case english || 'en':
        return 'English';
      case chinese || 'zh':
        return '中文';
      case taiwanese || 'zh-TW':
        return '繁體中文';
      case french || 'fr':
        return 'Français';
      case spanish || 'es':
        return 'Español';
      default:
        return '한국어';
    }
  }

  static String getLanguageNameInKorean(String languageCode) {
    switch (languageCode) {
      case korean || 'ko':
        return '한국어';
      case english || 'en':
        return '영어';
      case chinese || 'zh':
        return '중국어';
      case taiwanese || 'zh-TW':
        return '대만어';
      case french || 'fr':
        return '프랑스어';
      case spanish || 'es':
        return '스페인어';
      default:
        return 'nothing';
    }
  }

  // 로케일 생성 헬퍼 메서드
  static Locale createLocale(String languageCode) {
    if (languageCode == 'zh-TW') {
      return const Locale('zh', 'TW');
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
