import '../database/database_helper.dart';
import 'auth_service.dart';
import 'firestore_search_history_service.dart';
import '../models/unified_search_session.dart';

class SearchHistoryService {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  final FirestoreSearchHistoryService _firestoreService =
      FirestoreSearchHistoryService();
  final AuthService _authService = AuthService();

  int? _currentSessionId;
  String? _currentFirestoreSessionId;

  // 새로운 검색 세션 시작
  Future<void> startNewSession(String sessionName) async {
    if (_authService.isLoggedIn) {
      // 로그인된 경우 Firestore에 저장
      _currentFirestoreSessionId = await _firestoreService.startNewSession(
        sessionName,
      );
      _currentSessionId = null;
    } else {
      // 게스트인 경우 로컬에 저장
      _currentSessionId = await _databaseHelper.createSearchSession(
        sessionName,
      );
      _currentFirestoreSessionId = null;
    }
  }

  // 현재 세션에 검색 카드 추가
  Future<void> addSearchCard(
    String query,
    String result,
    bool isLoading,
  ) async {
    if (_authService.isLoggedIn) {
      // 로그인된 경우 Firestore에 저장
      if (_currentFirestoreSessionId == null) {
        await startNewSession(DateTime.now().toString().substring(0, 19));
      }
      await _firestoreService.addSearchCard(
        _currentFirestoreSessionId!,
        query,
        result,
        isLoading,
      );
    } else {
      // 게스트인 경우 로컬에 저장
      if (_currentSessionId == null) {
        await startNewSession(DateTime.now().toString().substring(0, 19));
      }

      final card = SearchCard(
        query: query,
        result: result,
        isLoading: isLoading,
        createdAt: DateTime.now(),
      );

      await _databaseHelper.addSearchCard(_currentSessionId!, card);
    }
  }

  // 기존 세션에 검색 카드 추가
  Future<void> addSearchCardToExistingSession(
    dynamic sessionId,
    String query,
    String result,
    bool isLoading,
  ) async {
    if (_authService.isLoggedIn) {
      // 로그인된 경우 Firestore에 저장
      await _firestoreService.addSearchCard(
        sessionId.toString(),
        query,
        result,
        isLoading,
      );
    } else {
      // 게스트인 경우 로컬에 저장
      final card = SearchCard(
        query: query,
        result: result,
        isLoading: isLoading,
        createdAt: DateTime.now(),
      );

      await _databaseHelper.addSearchCard(sessionId as int, card);
    }
  }

  // 검색 카드 업데이트 (로딩 상태에서 결과 상태로)
  Future<void> updateSearchCard(String query, String result) async {
    if (_authService.isLoggedIn) {
      // 로그인된 경우 Firestore에 저장
      if (_currentFirestoreSessionId != null) {
        await _firestoreService.updateSearchCard(
          _currentFirestoreSessionId!,
          query,
          result,
        );
      }
    } else {
      // 게스트인 경우 로컬에 저장
      if (_currentSessionId != null) {
        final cards = await _databaseHelper.getCardsBySessionId(
          _currentSessionId!,
        );
        final targetCard = cards
            .where((card) => card.query == query)
            .lastOrNull;

        if (targetCard != null) {
          final updatedCard = SearchCard(
            id: targetCard.id,
            query: query,
            result: result,
            isLoading: false,
            createdAt: targetCard.createdAt,
          );

          // 기존 카드 삭제 후 새 카드 추가
          await _databaseHelper.addSearchCard(_currentSessionId!, updatedCard);
        }
      }
    }
  }

  // 현재 세션 완료
  void completeCurrentSession() {
    _currentSessionId = null;
    _currentFirestoreSessionId = null;
  }

  // 모든 검색 세션 가져오기
  Future<List<UnifiedSearchSession>> getAllSearchSessions() async {
    if (_authService.isLoggedIn) {
      // 로그인된 경우 Firestore에서 가져오기
      final firestoreSessions = await _firestoreService.getAllSearchSessions();
      return firestoreSessions
          .map((data) => UnifiedSearchSession.fromFirestoreData(data))
          .toList();
    } else {
      // 게스트인 경우 로컬에서 가져오기
      final localSessions = await _databaseHelper.getAllSearchSessions();
      return localSessions
          .map(
            (session) => UnifiedSearchSession.fromLocalSearchSession(session),
          )
          .toList();
    }
  }

  // 특정 검색 세션 가져오기
  Future<UnifiedSearchSession?> getSearchSessionById(dynamic sessionId) async {
    if (_authService.isLoggedIn) {
      // 로그인된 경우 Firestore에서 가져오기
      final firestoreSession = await _firestoreService.getSearchSessionById(
        sessionId.toString(),
      );
      if (firestoreSession != null) {
        return UnifiedSearchSession.fromFirestoreData(firestoreSession);
      }
      return null;
    } else {
      // 게스트인 경우 로컬에서 가져오기
      final localSession = await _databaseHelper.getSearchSessionById(
        sessionId as int,
      );
      if (localSession != null) {
        return UnifiedSearchSession.fromLocalSearchSession(localSession);
      }
      return null;
    }
  }

  // 검색 세션 삭제
  Future<void> deleteSearchSession(dynamic sessionId) async {
    if (_authService.isLoggedIn) {
      // 로그인된 경우 Firestore에서 삭제
      await _firestoreService.deleteSearchSession(sessionId.toString());
    } else {
      // 게스트인 경우 로컬에서 삭제
      await _databaseHelper.deleteSearchSession(sessionId as int);
    }
  }

  // 모든 검색 기록 삭제
  Future<void> clearAllSearchHistory() async {
    if (_authService.isLoggedIn) {
      // 로그인된 경우 Firestore에서 삭제
      await _firestoreService.clearAllSearchHistory();
    } else {
      // 게스트인 경우 로컬에서 삭제
      await _databaseHelper.deleteAllSearchHistory();
    }
  }

  // 최근 검색 세션 가져오기
  Future<List<UnifiedSearchSession>> getRecentSearchSessions({
    int limit = 10,
  }) async {
    if (_authService.isLoggedIn) {
      // 로그인된 경우 Firestore에서 가져오기
      final firestoreSessions = await _firestoreService.getRecentSearchSessions(
        limit: limit,
      );
      return firestoreSessions
          .map((data) => UnifiedSearchSession.fromFirestoreData(data))
          .toList();
    } else {
      // 게스트인 경우 로컬에서 가져오기
      final localSessions = await _databaseHelper.getRecentSearchSessions(
        limit: limit,
      );
      return localSessions
          .map(
            (session) => UnifiedSearchSession.fromLocalSearchSession(session),
          )
          .toList();
    }
  }

  // 현재 세션 ID 가져오기
  dynamic get currentSessionId =>
      _authService.isLoggedIn ? _currentFirestoreSessionId : _currentSessionId;

  // 세션 이름 생성 (첫 번째 검색어 기반)
  String generateSessionName(String firstQuery) {
    final now = DateTime.now();
    final timeString =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    return '$firstQuery ($timeString)';
  }
}
