import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

// 도움말 서비스 클래스
class TutorialService {
  static const String _tutorialCompletedKey = 'tutorial_completed';
  static const String _dontShowAgainKey = 'tutorial_dont_show_again';
  static const String _searchShowcaseShownKey = 'search_showcase_shown';
  static const String _translationShowcaseShownKey =
      'translation_showcase_shown';

  // 런타임 트리거 (전역)
  static bool _triggerMainShowcase = false;
  static bool _triggerSearchShowcase = false;
  static bool _triggerTranslationShowcase = false;
  static final ValueNotifier<bool> mainShowcaseNotifier = ValueNotifier(false);
  static final ValueNotifier<bool> searchShowcaseNotifier = ValueNotifier(
    false,
  );
  static final ValueNotifier<bool> translationShowcaseNotifier = ValueNotifier(
    false,
  );

  // 튜토리얼 완료 여부 확인
  static Future<bool> isTutorialCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_tutorialCompletedKey) ?? false;
  }

  // 튜토리얼 완료 표시
  static Future<void> markTutorialCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_tutorialCompletedKey, true);
  }

  // 다시 보지 않기 설정 확인
  static Future<bool> shouldShowTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    return !(prefs.getBool(_dontShowAgainKey) ?? false);
  }

  // 다시 보지 않기 설정
  static Future<void> setDontShowAgain(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_dontShowAgainKey, value);
  }

  // 튜토리얼 재설정
  static Future<void> resetTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tutorialCompletedKey);
    await prefs.remove(_dontShowAgainKey);
    await prefs.remove(_searchShowcaseShownKey);
    await prefs.remove(_translationShowcaseShownKey);
  }

  // --- Showcase 트리거 제어 ---
  static void requestMainShowcase() {
    _triggerMainShowcase = true;
    // 항상 토글해서 리스너가 확실히 동작하도록 함
    mainShowcaseNotifier.value = !mainShowcaseNotifier.value;
  }

  static void requestSearchShowcase() {
    _triggerSearchShowcase = true;
    // 항상 토글해서 리스너가 확실히 동작하도록 함
    searchShowcaseNotifier.value = !searchShowcaseNotifier.value;
  }

  static bool consumeMainShowcaseTrigger() {
    if (_triggerMainShowcase) {
      _triggerMainShowcase = false;
      return true;
    }
    return false;
  }

  static bool consumeSearchShowcaseTrigger() {
    if (_triggerSearchShowcase) {
      _triggerSearchShowcase = false;
      return true;
    }
    return false;
  }

  static void requestTranslationShowcase() {
    _triggerTranslationShowcase = true;
    // 항상 토글해서 리스너가 확실히 동작하도록 함
    translationShowcaseNotifier.value = !translationShowcaseNotifier.value;
  }

  static bool consumeTranslationShowcaseTrigger() {
    if (_triggerTranslationShowcase) {
      _triggerTranslationShowcase = false;
      return true;
    }
    return false;
  }

  // --- Persisted flags: Search Showcase shown ---
  static Future<bool> wasSearchShowcaseShown() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_searchShowcaseShownKey) ?? false;
  }

  static Future<void> markSearchShowcaseShown() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_searchShowcaseShownKey, true);
  }

  static Future<bool> wasTranslationShowcaseShown() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_translationShowcaseShownKey) ?? false;
  }

  static Future<void> markTranslationShowcaseShown() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_translationShowcaseShownKey, true);
  }
}
