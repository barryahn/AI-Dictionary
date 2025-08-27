import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'pro_service.dart';

ValueNotifier<AuthService> authService = ValueNotifier(AuthService());

class AuthService extends ChangeNotifier {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  bool _isLoggedIn = false;
  String? _userEmail;
  String? _userName;
  String? _accessToken;
  String? _userPhotoUrl;

  bool get isLoggedIn => _isLoggedIn;
  String? get userEmail => _userEmail;
  String? get userName => _userName;
  String? get accessToken => _accessToken;
  String? get userPhotoUrl => _userPhotoUrl;

  // 초기화
  Future<void> initialize() async {
    // Google Sign In 초기화
    await _googleSignIn.initialize();

    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      _isLoggedIn = true;
      _userEmail = currentUser.email;
      _userName = currentUser.displayName;
      _userPhotoUrl = currentUser.photoURL;
      _accessToken = await currentUser.getIdToken();
      await _saveUserData();
      // Pro 상태 동기화 (앱 시작 시 로그인 유저가 있는 경우)
      await ProService().syncFromFirestore(currentUser.uid);
    } else {
      await _loadUserData();
    }
    notifyListeners();
  }

  // 사용자 데이터 로드
  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
      _userEmail = prefs.getString('userEmail');
      _userName = prefs.getString('userName');
      _userPhotoUrl = prefs.getString('userPhotoUrl');
      _accessToken = prefs.getString('accessToken');
    } catch (e) {
      if (kDebugMode) {
        print('사용자 데이터 로드 실패: $e');
      }
    }
  }

  // 구글 로그인
  Future<bool> googleLogin() async {
    try {
      final GoogleSignInAccount googleSignInAccount = await _googleSignIn
          .authenticate();

      final GoogleSignInAuthentication googleSignInAuthentication =
          googleSignInAccount.authentication;

      final credential = GoogleAuthProvider.credential(
        idToken: googleSignInAuthentication.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;
      if (user != null) {
        _isLoggedIn = true;
        _userEmail = user.email;
        _userName = user.displayName;
        _userPhotoUrl = user.photoURL;
        _accessToken = await user.getIdToken();

        // Firestore에 user email이 없을 때만 데이터 저장
        final userDoc = await _firestore
            .collection('users')
            .doc(user.uid)
            .get();
        if (!userDoc.exists) {
          await _firestore.collection('users').doc(user.uid).set({
            'email': user.email,
            'name': user.displayName,
            'photoUrl': user.photoURL,
            'isPro': false,
            'createdAt': FieldValue.serverTimestamp(),
          });
        }

        // Pro 상태 동기화 (로그인 시 최신값으로 세팅)
        await ProService().syncFromFirestore(user.uid);

        await _saveUserData();
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      if (kDebugMode) {
        print('구글 로그인 실패: $e');
      }
      return false;
    }
  }

  // 로그인
  Future<bool> login(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user != null) {
        _isLoggedIn = true;
        _userEmail = user.email;

        // Firestore에서 추가 정보 가져오기
        final doc = await _firestore.collection('users').doc(user.uid).get();
        _userName =
            doc.data()?['name'] ?? user.displayName ?? email.split('@')[0];
        _userPhotoUrl = doc.data()?['photoUrl'] ?? user.photoURL;
        _accessToken = await user.getIdToken();

        // Pro 상태 동기화 (로그인 시 최신값으로 세팅)
        await ProService().syncFromFirestore(user.uid);

        await _saveUserData();
        notifyListeners();
        return true;
      }
      return false;
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print('로그인 실패: ${e.message}');
      }
      return false;
    }
  }

  // 회원가입
  Future<bool> register(String email, String password, String name) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      final user = userCredential.user;
      if (user != null) {
        await user.updateDisplayName(name);

        await _firestore.collection('users').doc(user.uid).set({
          'email': email,
          'name': name,
          'isPro': false,
          'createdAt': FieldValue.serverTimestamp(),
        });

        _isLoggedIn = true;
        _userEmail = user.email;
        _userName = name;
        _userPhotoUrl = user.photoURL;
        _accessToken = await user.getIdToken();

        // Pro 상태 초기화 동기화
        await ProService().syncFromFirestore(user.uid);

        await _saveUserData();
        notifyListeners();
        return true;
      }
      return false;
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print('회원가입 실패: ${e.message}');
      }
      return false;
    }
  }

  // 로그아웃
  Future<void> logout() async {
    try {
      await _auth.signOut();

      _isLoggedIn = false;
      _userEmail = null;
      _userName = null;
      _userPhotoUrl = null;
      _accessToken = null;

      await _clearUserData();
      // Pro 상태 초기화 (로그아웃 시 비로그인 상태이므로 false)
      await ProService().setPro(false);
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
      await prefs.setString('userPhotoUrl', _userPhotoUrl ?? '');
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
      await prefs.remove('userPhotoUrl');
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
      final user = _auth.currentUser;
      if (user != null) {
        await user.updateDisplayName(name);
        await _firestore.collection('users').doc(user.uid).update({
          'name': name,
        });

        _userName = name;
        await _saveUserData();
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      if (kDebugMode) {
        print('사용자 정보 업데이트 실패: $e');
      }
      return false;
    }
  }

  // 비밀번호로 재인증
  Future<bool> reauthenticateWithPassword(String password) async {
    try {
      final user = _auth.currentUser;
      if (user != null && user.email != null) {
        final credential = EmailAuthProvider.credential(
          email: user.email!,
          password: password,
        );
        await user.reauthenticateWithCredential(credential);
        return true;
      }
      return false;
    } catch (e) {
      if (kDebugMode) {
        print('비밀번호 재인증 실패: $e');
      }
      return false;
    }
  }

  // 비밀번호 재설정 이메일 보내기
  Future<bool> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('비밀번호 재설정 이메일 전송 실패: $e');
      }
      return false;
    }
  }

  // 계정 삭제 (재인증 포함)
  Future<bool> deleteAccount({String? password}) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        // 재인증을 위한 credential 생성
        AuthCredential? credential;

        // 사용자의 로그인 방식 확인
        final providerData = user.providerData;
        if (providerData.isNotEmpty) {
          final provider = providerData.first.providerId;

          if (provider == 'google.com') {
            // 구글 로그인 사용자
            try {
              // 새로운 구글 로그인을 통해 재인증
              final GoogleSignInAccount googleSignInAccount =
                  await _googleSignIn.authenticate();

              final GoogleSignInAuthentication googleSignInAuthentication =
                  await googleSignInAccount.authentication;

              credential = GoogleAuthProvider.credential(
                idToken: googleSignInAuthentication.idToken,
              );
            } catch (e) {
              if (kDebugMode) {
                print('구글 재인증 credential 생성 실패: $e');
              }
            }
          } else if (provider == 'password') {
            // 이메일/비밀번호 로그인 사용자
            if (password != null) {
              try {
                credential = EmailAuthProvider.credential(
                  email: user.email!,
                  password: password,
                );
              } catch (e) {
                if (kDebugMode) {
                  print('비밀번호 재인증 credential 생성 실패: $e');
                }
              }
            } else {
              // 비밀번호가 제공되지 않은 경우
              if (kDebugMode) {
                print('이메일 로그인 사용자는 비밀번호가 필요합니다.');
              }
              return false;
            }
          }
        }

        // 재인증 수행
        if (credential != null) {
          await user.reauthenticateWithCredential(credential);
        } else {
          // 재인증 credential을 생성할 수 없는 경우
          if (kDebugMode) {
            print('재인증을 위한 credential을 생성할 수 없습니다.');
          }
          return false;
        }

        // Firestore에서 사용자 데이터 삭제
        await _firestore.collection('users').doc(user.uid).delete();

        // Firebase Auth에서 계정 삭제
        await user.delete();

        // 로컬 데이터 정리
        _isLoggedIn = false;
        _userEmail = null;
        _userName = null;
        _userPhotoUrl = null;
        _accessToken = null;

        await _clearUserData();
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      if (kDebugMode) {
        print('계정 삭제 실패: $e');
      }
      return false;
    }
  }
}
