import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QuotaService extends ChangeNotifier {
  QuotaService._internal();
  static final QuotaService _instance = QuotaService._internal();
  factory QuotaService() => _instance;

  static const String _prefsKeyDate = 'quota_date';
  static const String _prefsKeyUsed = 'quota_used';

  static const int dailyLimit = 5;

  int _usedToday = 0;
  String _todayKey = _formatDate(DateTime.now());

  int get usedToday => _usedToday;
  int get remainingToday => max(0, dailyLimit - _usedToday);

  static String _formatDate(DateTime dt) => DateFormat('yyyy-MM-dd').format(dt);

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _todayKey = _formatDate(DateTime.now());
    final storedDate = prefs.getString(_prefsKeyDate);
    if (storedDate == _todayKey) {
      _usedToday = prefs.getInt(_prefsKeyUsed) ?? 0;
    } else {
      // 새로운 날이면 초기화
      _usedToday = 0;
      await prefs.setString(_prefsKeyDate, _todayKey);
      await prefs.setInt(_prefsKeyUsed, _usedToday);
    }
    notifyListeners();
  }

  Future<void> _persist(SharedPreferences prefs) async {
    await prefs.setString(_prefsKeyDate, _todayKey);
    await prefs.setInt(_prefsKeyUsed, _usedToday);
  }

  Future<void> _ensureToday(SharedPreferences prefs) async {
    final currentKey = _formatDate(DateTime.now());
    if (_todayKey != currentKey) {
      _todayKey = currentKey;
      _usedToday = 0;
      await _persist(prefs);
      notifyListeners();
    }
  }

  bool get hasHighTierRemaining => remainingToday > 0;

  // 고급 모델 1회 사용 시도. 성공 시 true, 남은 횟수 없으면 false
  Future<bool> tryConsumeHighTierOnce() async {
    final prefs = await SharedPreferences.getInstance();
    await _ensureToday(prefs);
    if (_usedToday >= dailyLimit) return false;
    _usedToday += 1;
    await _persist(prefs);
    notifyListeners();
    return true;
  }
}
