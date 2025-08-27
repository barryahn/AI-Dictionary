import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProService extends ChangeNotifier {
  ProService._internal();
  static final ProService _instance = ProService._internal();
  factory ProService() => _instance;

  static const String _prefsKeyIsPro = 'is_pro';

  bool _isPro = false;
  bool get isPro => _isPro;

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _isPro = prefs.getBool(_prefsKeyIsPro) ?? false;
    notifyListeners();

    // 로그인되어 있으면 Firestore에서 최신 isPro 동기화
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await syncFromFirestore(user.uid);
      }
    } catch (_) {}
  }

  Future<void> setPro(bool value) async {
    if (_isPro == value) return;
    _isPro = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefsKeyIsPro, value);

    // 서버 동기화 (로그인 상태일 때)
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'isPro': value,
        }, SetOptions(merge: true));
      }
    } catch (_) {}
  }

  Future<void> syncFromFirestore(String uid) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
      final data = doc.data();
      if (data != null && data.containsKey('isPro')) {
        await setPro(data['isPro'] == true);
      }
    } catch (e) {
      // 무시: 네트워크 오류 등은 로컬 상태 유지
    }
  }
}
