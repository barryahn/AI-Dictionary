import 'package:flutter/material.dart';

class PricingService {
  /// 국가/언어별 월 구독 가격 숫자(통화/단위 제외) 관리
  /// 기본값은 '3,000'. 필요 시 백엔드 연동/원격 구성으로 확장 가능
  static int getMonthlyPriceNumber(Locale locale) {
    final lang = locale.languageCode;
    final country = locale.countryCode ?? '';

    // 예시 매핑: 각 국가/언어별로 손쉽게 변경 가능
    // 현재는 모두 동일한 '3,000'을 반환. 필요 시 국가별로 다르게 조정
    if (lang == 'ko') return 3000;
    if (lang == 'zh' && country == 'TW') return 3000;
    if (lang == 'zh') return 3000;
    if (lang == 'es') return 3000;
    if (lang == 'fr') return 3000;
    if (lang == 'en') return 3;
    return 3000;
  }

  /// 국가/언어별 연 구독 가격 숫자(통화/단위 제외) 관리
  /// 기본값은 '20,000'. 필요 시 국가별 가격 차등을 적용하세요
  static int getYearlyPriceNumber(Locale locale) {
    final lang = locale.languageCode;
    final country = locale.countryCode ?? '';

    // 예시: 모두 동일한 가격. 필요 시 조건 분기하여 변경
    if (lang == 'ko') return 20000;
    if (lang == 'zh' && country == 'TW') return 20000;
    if (lang == 'zh') return 20000;
    if (lang == 'es') return 20000;
    if (lang == 'fr') return 20000;
    if (lang == 'en') return 20;
    return 20000;
  }

  /// 국가/언어별 통화 기호 반환
  /// 간단한 매핑만 포함하며, 필요 시 국가(ISO 3166-1 alpha-2) 목록을 확장하세요
  static String getCurrencySymbol(Locale locale) {
    final lang = locale.languageCode;
    final country = (locale.countryCode ?? '').toUpperCase();

    // 한국 원화
    if (country == 'KR' || lang == 'ko') return '₩';

    // 대만 신타이완달러
    if (country == 'TW') return 'NT\$';

    // 중국 위안화(간체 중국어 포함)
    if (country == 'CN' || (lang == 'zh' && country.isEmpty)) return '¥';

    // 일본 엔화
    if (country == 'JP') return '¥';

    // 유로존 대표 (프랑스/스페인 등)
    const euroCountries = {
      'FR',
      'ES',
      'DE',
      'IT',
      'NL',
      'BE',
      'PT',
      'IE',
      'FI',
      'GR',
      'AT',
      'LU',
      'SI',
      'SK',
      'LV',
      'LT',
      'EE',
      'CY',
      'MT',
    };
    if (euroCountries.contains(country)) return '€';

    // 영국 파운드
    if (country == 'GB') return '£';

    // 기본: 달러
    return '\$'; // Fallback: '$'
  }
}
