import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

class LanguageService {
  static const String _languageKey = 'app_language';
  static const String _fromLanguageKey = 'from_language';
  static const String _toLanguageKey = 'to_language';
  // 번역 화면(TranslationScreen) 전용 키: 전역 from/to와 분리 보관
  static const String _tsFromLanguageKey = 'ts_from_language';
  static const String _tsToLanguageKey = 'ts_to_language';
  static const String korean = 'ko';
  static const String english = 'en';
  static const String chinese = 'zh';
  static const String taiwanMandarin = 'zh-TW';
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
      print('langCode: \\$langCode');
      print('countryCode: \\$countryCode');

      if (langCode == 'ko') {
        _currentLanguage = korean;
      } else if (langCode == 'en') {
        _currentLanguage = english;
      } else if (langCode == 'zh' && countryCode == 'TW') {
        _currentLanguage = taiwanMandarin;
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
    if (_currentLanguage == english) {
      _toLanguage = prefs.getString(_toLanguageKey) ?? '한국어';
    } else {
      _toLanguage = prefs.getString(_toLanguageKey) ?? '영어';
    }
  }

  // 언어 변경
  static Future<void> setLanguage(String language) async {
    if (![
      korean,
      english,
      chinese,
      taiwanMandarin,
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
  /// fromLang 또는 toLang만 입력될 수도 있으므로, null 허용 및 분기 처리
  static Future<void> setTranslationLanguages([
    String? fromLang,
    String? toLang,
  ]) async {
    final prefs = await SharedPreferences.getInstance();

    // 둘 다 null이면 아무것도 하지 않음
    if (fromLang == null && toLang == null) {
      return;
    }

    if (fromLang != null) {
      _fromLanguage = fromLang;
      await prefs.setString(_fromLanguageKey, _fromLanguage);
    }
    if (toLang != null) {
      _toLanguage = toLang;
      await prefs.setString(_toLanguageKey, _toLanguage);
    }

    // 언어 변경 알림 전송
    _languageController.add({
      'fromLanguage': _fromLanguage,
      'toLanguage': _toLanguage,
    });
  }

  // 번역 화면(TranslationScreen) 전용 언어 저장/로드 (전역 from/to와 분리)
  static Future<String> getTranslationScreenFromLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tsFromLanguageKey) ??
        getLanguageNameInKorean(_currentLanguage);
  }

  static Future<String> getTranslationScreenToLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    if (_currentLanguage == english) {
      return prefs.getString(_tsToLanguageKey) ?? '한국어';
    } else {
      return prefs.getString(_tsToLanguageKey) ?? '영어';
    }
  }

  static Future<void> setTranslationScreenLanguages([
    String? fromLang,
    String? toLang,
  ]) async {
    // 둘 다 null이면 아무것도 하지 않음
    if (fromLang == null && toLang == null) return;

    final prefs = await SharedPreferences.getInstance();
    if (fromLang != null) {
      await prefs.setString(_tsFromLanguageKey, fromLang);
    }
    if (toLang != null) {
      await prefs.setString(_tsToLanguageKey, toLang);
    }
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
      case '대만 중국어':
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
      case taiwanMandarin || 'zh-TW':
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
      case korean || 'ko' || '한국어':
        return '한국어';
      case english || 'en' || 'English':
        return '영어';
      case chinese || 'zh' || '中文':
        return '중국어';
      case taiwanMandarin || 'zh-TW' || '繁體中文':
        return '대만 중국어';
      case french || 'fr' || 'Français':
        return '프랑스어';
      case spanish || 'es' || 'Español':
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
    {'code': taiwanMandarin, 'name': '繁體中文'},
    {'code': french, 'name': 'Français'},
    {'code': spanish, 'name': 'Español'},
  ];

  // 번역 지원 언어 목록 (다국어 지원)
  static List<Map<String, String>> getLocalizedTranslationLanguages(
    AppLocalizations loc,
  ) {
    final List<Map<String, String>> languages = [
      {'code': '영어', 'name': loc.english},
      {'code': '한국어', 'name': loc.korean},
      {'code': '중국어', 'name': loc.chinese},
      {'code': '대만 중국어', 'name': loc.taiwanMandarin},
      {'code': '스페인어', 'name': loc.spanish},
      {'code': '프랑스어', 'name': loc.french},
    ];

    // 사용자의 시스템 로케일 확인
    try {
      final systemLocale = WidgetsBinding.instance.platformDispatcher.locale;
      final langCode = systemLocale.languageCode;
      final countryCode = systemLocale.countryCode;

      // 시스템 로케일에 해당하는 언어 코드 찾기
      String? userLanguageCode;
      if (langCode == 'ko') {
        userLanguageCode = '한국어';
      } else if (langCode == 'en') {
        userLanguageCode = '영어';
      } else if (langCode == 'zh' && countryCode == 'TW') {
        userLanguageCode = '대만 중국어';
      } else if (langCode == 'zh') {
        userLanguageCode = '중국어';
      } else if (langCode == 'fr') {
        userLanguageCode = '프랑스어';
      } else if (langCode == 'es') {
        userLanguageCode = '스페인어';
      }

      // 사용자 언어를 가장 위로 정렬
      if (userLanguageCode != null) {
        final userLanguage = languages.firstWhere(
          (lang) => lang['code'] == userLanguageCode,
          orElse: () => languages.first,
        );

        final sortedLanguages = <Map<String, String>>[];
        sortedLanguages.add(userLanguage);

        for (final lang in languages) {
          if (lang['code'] != userLanguageCode) {
            sortedLanguages.add(lang);
          }
        }

        return sortedLanguages;
      }
    } catch (e) {
      // 에러 발생 시 기본 순서 반환
      print('언어 정렬 중 오류 발생: $e');
    }

    return languages;
  }

  // 번역 지원 언어 목록 (기본 - 하위 호환성)
  static List<String> get translationLanguages => [
    '영어',
    '한국어',
    '중국어',
    '대만 중국어',
    '스페인어',
    '프랑스어',
  ];

  // 리소스 정리
  static void dispose() {
    _languageController.close();
  }
}
