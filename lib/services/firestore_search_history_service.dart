import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_service.dart';

class FirestoreSearchHistoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 현재 로그인된 사용자 ID 가져오기
  String? get _currentUserId => _auth.currentUser?.uid;

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

  // 모든 검색 세션 가져오기
  Future<List<Map<String, dynamic>>> getAllSearchSessions() async {
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
