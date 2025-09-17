import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  TtsService._();

  static final FlutterTts _tts = FlutterTts();
  static bool _initialized = false;
  static String? _currentLocale;

  static Future<void> _initializeIfNeeded() async {
    if (_initialized) return;
    // 기본 음성 설정
    try {
      await _tts.setVolume(1.0);
    } catch (_) {}
    try {
      await _tts.setSpeechRate(0.45); // 자연스러운 기본 속도
    } catch (_) {}
    try {
      await _tts.setPitch(1.0);
    } catch (_) {}
    _initialized = true;
  }

  static Future<void> _setLanguageBestEffort(String code) async {
    // 먼저 그대로 시도 (예: 'en', 'ko', 'zh')
    try {
      await _tts.setLanguage(code);
      _currentLocale = code;
      return;
    } catch (_) {}

    // 사용 가능한 언어 목록에서 접두사 매칭 (예: 'en' → 'en-US')
    try {
      final langs = await _tts.getLanguages;
      if (langs is List) {
        final List<String> locales = langs.map((e) => e.toString()).toList();
        final lower = code.toLowerCase();
        String? match = locales.firstWhere(
          (l) => l.toLowerCase().startsWith(lower),
          orElse: () => '',
        );
        if (match.isNotEmpty) {
          await _tts.setLanguage(match);
          _currentLocale = match;
          return;
        }
      }
    } catch (_) {}

    // 간단한 폴백 (중국어 등)
    if (code == 'zh') {
      try {
        await _tts.setLanguage('zh-CN');
        _currentLocale = 'zh-CN';
        return;
      } catch (_) {}
    }
  }

  static Future<void> speak(String text, {String? languageCode}) async {
    if (text.trim().isEmpty) return;
    await _initializeIfNeeded();
    if (languageCode != null) {
      await _setLanguageBestEffort(languageCode);
    }
    try {
      await _tts.stop();
    } catch (e) {
      print('TTS 초기화 중 오류 발생: $e');
    }
    await _tts.speak(text);
  }

  static Future<void> stop() async {
    try {
      await _tts.stop();
    } catch (e) {
      print('TTS 초기화 중 오류 발생: $e');
    }
  }

  static String localeForLanguageName(String languageName) {
    switch (languageName) {
      case '한국어':
        return 'ko-KR';
      case '영어':
        return 'en-US';
      case '중국어':
        return 'zh-CN';
      case '대만 중국어':
        return 'zh-TW';
      case '프랑스어':
        return 'fr-FR';
      case '스페인어':
        return 'es-ES';
      default:
        return 'en-US';
    }
  }
}
