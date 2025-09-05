import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

class FirestoreSearchHistoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 캐시 관련 변수들
  List<Map<String, dynamic>> _cachedSessions = [];
  bool _isCacheInitialized = false;
  String? _initializedUserId;
  StreamSubscription<QuerySnapshot>? _sessionsListener;
  final Map<String, StreamSubscription<QuerySnapshot>> _cardsListeners = {};

  // 현재 로그인된 사용자 ID 가져오기
  String? get _currentUserId => _auth.currentUser?.uid;

  // 캐시 초기화 및 실시간 리스너 시작
  Future<void> initializeCache() async {
    final userId = _currentUserId;
    if (userId == null) return;

    // 이미 초기화되었지만 다른 사용자로 전환된 경우 리스너를 재설정
    if (_isCacheInitialized && _initializedUserId == userId) {
      return;
    }

    try {
      // 기존 리스너들 정리
      _disposeAllListeners();
      // 사용자 전환 시 캐시 비우기 (이전 사용자 데이터 노출 방지)
      _cachedSessions.clear();

      // 세션 리스너 시작
      _sessionsListener = _firestore
          .collection('users')
          .doc(userId)
          .collection('search_sessions')
          .orderBy('createdAt', descending: true)
          .snapshots()
          .listen(_onSessionsChanged);

      _isCacheInitialized = true;
      _initializedUserId = userId;
      print('Firestore 캐시 초기화 완료');
    } catch (e) {
      print('Firestore 캐시 초기화 실패: $e');
    }
  }

  // 세션 변경 감지
  void _onSessionsChanged(QuerySnapshot snapshot) async {
    final userId = _currentUserId;
    if (userId == null) return;

    try {
      List<Map<String, dynamic>> sessions = [];

      for (var doc in snapshot.docs) {
        final sessionData = doc.data() as Map<String, dynamic>;
        sessionData['id'] = doc.id;

        // 각 세션의 카드들 가져오기 (캐시된 데이터 사용)
        final cards = await _getCachedCardsForSession(doc.id);
        sessionData['cards'] = cards;
        sessions.add(sessionData);

        // 카드 리스너 시작 (아직 시작되지 않은 경우)
        if (!_cardsListeners.containsKey(doc.id)) {
          _startCardsListener(doc.id);
        }
      }

      _cachedSessions = sessions;
      print('세션 캐시 업데이트 완료: ${sessions.length}개 세션');
    } catch (e) {
      print('세션 캐시 업데이트 실패: $e');
    }
  }

  // 특정 세션의 카드 리스너 시작
  void _startCardsListener(String sessionId) {
    final userId = _currentUserId;
    if (userId == null) return;

    _cardsListeners[sessionId] = _firestore
        .collection('users')
        .doc(userId)
        .collection('search_sessions')
        .doc(sessionId)
        .collection('search_cards')
        .snapshots()
        .listen((snapshot) => _onCardsChanged(sessionId, snapshot));
  }

  // 카드 변경 감지
  void _onCardsChanged(String sessionId, QuerySnapshot snapshot) {
    final cards = snapshot.docs.map((cardDoc) {
      final cardData = cardDoc.data() as Map<String, dynamic>;
      cardData['id'] = cardDoc.id;
      return cardData;
    }).toList();

    // createdAt 순서대로 정렬 (오름차순)
    cards.sort((a, b) {
      final aCreatedAt = a['createdAt'] as Timestamp?;
      final bCreatedAt = b['createdAt'] as Timestamp?;

      if (aCreatedAt == null && bCreatedAt == null) return 0;
      if (aCreatedAt == null) return -1;
      if (bCreatedAt == null) return 1;

      return aCreatedAt.compareTo(bCreatedAt);
    });

    // 캐시된 세션에서 해당 세션의 카드 업데이트
    final sessionIndex = _cachedSessions.indexWhere(
      (session) => session['id'] == sessionId,
    );
    if (sessionIndex != -1) {
      _cachedSessions[sessionIndex]['cards'] = cards;
      print('카드 캐시 업데이트 완료: 세션 $sessionId, ${cards.length}개 카드 (정렬됨)');
    }
  }

  // 캐시된 카드 데이터 가져오기
  Future<List<Map<String, dynamic>>> _getCachedCardsForSession(
    String sessionId,
  ) async {
    final userId = _currentUserId;
    if (userId == null) return [];

    try {
      final cardsSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('search_sessions')
          .doc(sessionId)
          .collection('search_cards')
          .get();

      final cards = cardsSnapshot.docs.map((cardDoc) {
        final cardData = cardDoc.data();
        cardData['id'] = cardDoc.id;
        return cardData;
      }).toList();

      // createdAt 순서대로 정렬 (오름차순)
      cards.sort((a, b) {
        final aCreatedAt = a['createdAt'] as Timestamp?;
        final bCreatedAt = b['createdAt'] as Timestamp?;

        if (aCreatedAt == null && bCreatedAt == null) return 0;
        if (aCreatedAt == null) return -1;
        if (bCreatedAt == null) return 1;

        return aCreatedAt.compareTo(bCreatedAt);
      });

      return cards;
    } catch (e) {
      print('카드 데이터 가져오기 실패: $e');
      return [];
    }
  }

  // 모든 리스너 정리
  void _disposeAllListeners() {
    _sessionsListener?.cancel();
    _sessionsListener = null;

    for (var listener in _cardsListeners.values) {
      listener.cancel();
    }
    _cardsListeners.clear();
  }

  // 캐시 정리
  void dispose() {
    _disposeAllListeners();
    _cachedSessions.clear();
    _isCacheInitialized = false;
    _initializedUserId = null;
  }

  // 캐시된 데이터 가져오기
  List<Map<String, dynamic>> getCachedSessions() {
    return List.from(_cachedSessions);
  }

  // 새로운 검색 세션 시작
  Future<String?> startNewSession(String sessionName) async {
    final userId = _currentUserId;
    if (userId == null) return null;

    try {
      final docRef = await _firestore
          .collection('users')
          .doc(userId)
          .collection('search_sessions')
          .add({
            'sessionName': sessionName,
            'createdAt': FieldValue.serverTimestamp(),
          });
      return docRef.id;
    } catch (e) {
      print('Firestore 세션 생성 실패: $e');
      return null;
    }
  }

  // 검색 카드 추가
  Future<void> addSearchCard(
    String sessionId,
    String query,
    String result,
    bool isLoading,
  ) async {
    final userId = _currentUserId;
    if (userId == null) return;

    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('search_sessions')
          .doc(sessionId)
          .collection('search_cards')
          .add({
            'query': query,
            'result': result,
            'isLoading': isLoading,
            'createdAt': FieldValue.serverTimestamp(),
          });
    } catch (e) {
      print('Firestore 카드 추가 실패: $e');
    }
  }

  // 검색 카드 업데이트
  Future<void> updateSearchCard(
    String sessionId,
    String query,
    String result,
  ) async {
    final userId = _currentUserId;
    if (userId == null) return;

    try {
      // 해당 쿼리의 카드 찾기
      final querySnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('search_sessions')
          .doc(sessionId)
          .collection('search_cards')
          .where('query', isEqualTo: query)
          .orderBy('createdAt', descending: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final docId = querySnapshot.docs.first.id;
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('search_sessions')
            .doc(sessionId)
            .collection('search_cards')
            .doc(docId)
            .update({'result': result, 'isLoading': false});
      }
    } catch (e) {
      print('Firestore 카드 업데이트 실패: $e');
    }
  }

  // 모든 검색 세션 가져오기 (캐시 우선)
  Future<List<Map<String, dynamic>>> getAllSearchSessions() async {
    // 캐시가 초기화되지 않았다면 초기화
    if (!_isCacheInitialized) {
      await initializeCache();
    }

    // 캐시된 데이터가 있으면 반환
    if (_cachedSessions.isNotEmpty) {
      print('캐시된 데이터 반환: ${_cachedSessions.length}개 세션');
      return List.from(_cachedSessions);
    }

    // 캐시가 비어있으면 기존 방식으로 가져오기
    final userId = _currentUserId;
    if (userId == null) return [];

    try {
      final querySnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('search_sessions')
          .orderBy('createdAt', descending: true)
          .get();

      List<Map<String, dynamic>> sessions = [];
      for (var doc in querySnapshot.docs) {
        final sessionData = doc.data();
        sessionData['id'] = doc.id;

        // 각 세션의 카드들 가져오기
        final cardsSnapshot = await doc.reference
            .collection('search_cards')
            .get();
        final cards = cardsSnapshot.docs.map((cardDoc) {
          final cardData = cardDoc.data();
          cardData['id'] = cardDoc.id;
          return cardData;
        }).toList();

        sessionData['cards'] = cards;
        sessions.add(sessionData);
      }

      return sessions;
    } catch (e) {
      print('Firestore 세션 가져오기 실패: $e');
      return [];
    }
  }

  // 특정 검색 세션 가져오기
  Future<Map<String, dynamic>?> getSearchSessionById(String sessionId) async {
    final userId = _currentUserId;
    if (userId == null) return null;

    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('search_sessions')
          .doc(sessionId)
          .get();

      if (!doc.exists) return null;

      final sessionData = doc.data()!;
      sessionData['id'] = doc.id;

      // 카드들 가져오기
      final cardsSnapshot = await doc.reference
          .collection('search_cards')
          .get();
      final cards = cardsSnapshot.docs.map((cardDoc) {
        final cardData = cardDoc.data();
        cardData['id'] = cardDoc.id;
        return cardData;
      }).toList();

      sessionData['cards'] = cards;
      return sessionData;
    } catch (e) {
      print('Firestore 세션 가져오기 실패: $e');
      return null;
    }
  }

  // 검색 세션 삭제
  Future<void> deleteSearchSession(String sessionId) async {
    final userId = _currentUserId;
    if (userId == null) return;

    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('search_sessions')
          .doc(sessionId)
          .delete();
    } catch (e) {
      print('Firestore 세션 삭제 실패: $e');
    }
  }

  // 모든 검색 기록 삭제
  Future<void> clearAllSearchHistory() async {
    final userId = _currentUserId;
    if (userId == null) return;

    try {
      final querySnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('search_sessions')
          .get();

      final batch = _firestore.batch();
      for (var doc in querySnapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      print('Firestore 전체 히스토리 삭제 실패: $e');
    }
  }

  // 최근 검색 세션 가져오기
  Future<List<Map<String, dynamic>>> getRecentSearchSessions({
    int limit = 10,
  }) async {
    // 캐시가 초기화되지 않았다면 초기화
    if (!_isCacheInitialized) {
      await initializeCache();
    }

    // 캐시된 데이터에서 최근 세션 반환
    if (_cachedSessions.isNotEmpty) {
      final recentSessions = _cachedSessions.take(limit).toList();
      print('캐시된 최근 세션 반환: ${recentSessions.length}개 세션');
      return recentSessions;
    }

    // 캐시가 비어있으면 기존 방식으로 가져오기
    final userId = _currentUserId;
    if (userId == null) return [];

    try {
      final querySnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('search_sessions')
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      List<Map<String, dynamic>> sessions = [];
      for (var doc in querySnapshot.docs) {
        final sessionData = doc.data();
        sessionData['id'] = doc.id;

        // 각 세션의 카드들 가져오기
        final cardsSnapshot = await doc.reference
            .collection('search_cards')
            .get();
        final cards = cardsSnapshot.docs.map((cardDoc) {
          final cardData = cardDoc.data();
          cardData['id'] = cardDoc.id;
          return cardData;
        }).toList();

        sessionData['cards'] = cards;
        sessions.add(sessionData);
      }

      return sessions;
    } catch (e) {
      print('Firestore 최근 세션 가져오기 실패: $e');
      return [];
    }
  }
}
