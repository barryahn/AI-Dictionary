import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class AuthService extends ChangeNotifier {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  bool _isLoggedIn = false;
  String? _userEmail;
  String? _userName;
  String? _accessToken;

  bool get isLoggedIn => _isLoggedIn;
  String? get userEmail => _userEmail;
  String? get userName => _userName;
  String? get accessToken => _accessToken;

  // 초기화
  Future<void> initialize() async {
    await _loadUserData();
  }

  // 사용자 데이터 로드
  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
      _userEmail = prefs.getString('userEmail');
      _userName = prefs.getString('userName');
      _accessToken = prefs.getString('accessToken');
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('사용자 데이터 로드 실패: $e');
      }
    }
  }

  // 로그인
  Future<bool> login(String email, String password) async {
    try {
      // 실제 구현에서는 서버 API 호출
      // 여기서는 시뮬레이션
      await Future.delayed(const Duration(seconds: 1));

      // 임시 로그인 로직 (실제로는 서버 검증 필요)
      if (email.isNotEmpty && password.isNotEmpty) {
        _isLoggedIn = true;
        _userEmail = email;
        _userName = email.split('@')[0]; // 이메일에서 사용자명 추출
        _accessToken = 'temp_token_${DateTime.now().millisecondsSinceEpoch}';

        // 데이터 저장
        await _saveUserData();
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      if (kDebugMode) {
        print('로그인 실패: $e');
      }
      return false;
    }
  }

  // 회원가입
  Future<bool> register(String email, String password, String name) async {
    try {
      // 실제 구현에서는 서버 API 호출
      await Future.delayed(const Duration(seconds: 1));

      // 임시 회원가입 로직
      if (email.isNotEmpty && password.isNotEmpty && name.isNotEmpty) {
        _isLoggedIn = true;
        _userEmail = email;
        _userName = name;
        _accessToken = 'temp_token_${DateTime.now().millisecondsSinceEpoch}';

        // 데이터 저장
        await _saveUserData();
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      if (kDebugMode) {
        print('회원가입 실패: $e');
      }
      return false;
    }
  }

  // 로그아웃
  Future<void> logout() async {
    try {
      _isLoggedIn = false;
      _userEmail = null;
      _userName = null;
      _accessToken = null;

      // 데이터 삭제
      await _clearUserData();
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('로그아웃 실패: $e');
      }
    }
  }

  // 사용자 데이터 저장
  Future<void> _saveUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', _isLoggedIn);
      await prefs.setString('userEmail', _userEmail ?? '');
      await prefs.setString('userName', _userName ?? '');
      await prefs.setString('accessToken', _accessToken ?? '');
    } catch (e) {
      if (kDebugMode) {
        print('사용자 데이터 저장 실패: $e');
      }
    }
  }

  // 사용자 데이터 삭제
  Future<void> _clearUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('isLoggedIn');
      await prefs.remove('userEmail');
      await prefs.remove('userName');
      await prefs.remove('accessToken');
    } catch (e) {
      if (kDebugMode) {
        print('사용자 데이터 삭제 실패: $e');
      }
    }
  }

  // 사용자 정보 업데이트
  Future<bool> updateUserInfo(String name) async {
    try {
      _userName = name;
      await _saveUserData();
      notifyListeners();
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('사용자 정보 업데이트 실패: $e');
      }
      return false;
    }
  }
}
