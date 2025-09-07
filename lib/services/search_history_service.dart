import '../database/database_helper.dart';
import 'auth_service.dart';
import 'firestore_search_history_service.dart';
import '../models/unified_search_session.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SearchHistoryService {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  final FirestoreSearchHistoryService _firestoreService =
      FirestoreSearchHistoryService();
  final AuthService _authService = AuthService();

  int? _currentSessionId;
  String? _currentFirestoreSessionId;

  // 검색 기록 일시 중지 관련 상수
  static const String _pauseHistoryKey = 'pause_search_history';

  // 검색 기록 일시 중지 상태 가져오기
  static Future<bool> isPauseHistoryEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_pauseHistoryKey) ?? false;
  }

  // 검색 기록 일시 중지 상태 설정
  static Future<void> setPauseHistoryEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_pauseHistoryKey, enabled);
  }

  // 캐시 초기화 (백그라운드에서 호출)
  Future<void> initializeCache() async {
    if (_authService.isLoggedIn) {
      await _firestoreService.initializeCache();
    }
  }

  // 캐시 정리
  void disposeCache() {
    if (_authService.isLoggedIn) {
      _firestoreService.dispose();
    }
  }

  // AuthService 상태 변경 리스너 등록용
  void _authListener() {
    if (_authService.isLoggedIn) {
      initializeCache();
    } else {
      disposeCache();
    }
  }

  SearchHistoryService() {
    // 로그인 상태 변경 시 캐시 관리
    _authService.addListener(_authListener);
    // 초기 상태도 반영
    _authListener();
  }

  void dispose() {
    _authService.removeListener(_authListener);
    disposeCache();
  }

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
    // 검색 기록이 일시 중지된 경우 저장하지 않음
    if (await isPauseHistoryEnabled()) {
      print('검색 기록이 일시 중지되어 카드를 저장하지 않습니다.');
      return;
    }

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
    // 검색 기록이 일시 중지된 경우 저장하지 않음
    if (await isPauseHistoryEnabled()) {
      print('검색 기록이 일시 중지되어 기존 세션에 카드를 저장하지 않습니다.');
      return;
    }

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

  // 기존 카드 한 장을 (같은 세션 내에서) 과거 쿼리 기준으로 찾아
  // 쿼리와 결과를 동시에 업데이트
  Future<void> updateSearchCardByOldQuery(
    dynamic sessionId,
    String oldQuery,
    String newQuery,
    String newResult,
  ) async {
    // 검색 기록이 일시 중지된 경우 저장하지 않음
    if (await isPauseHistoryEnabled()) {
      print('검색 기록이 일시 중지되어 기존 카드 업데이트를 수행하지 않습니다.');
      return;
    }

    if (_authService.isLoggedIn) {
      // Firestore 에서 과거 쿼리 기반으로 찾아 업데이트
      await _firestoreService.updateSearchCardByOldQuery(
        sessionId.toString(),
        oldQuery,
        newQuery,
        newResult,
      );
    } else {
      // 로컬 DB에서 세션 카드 목록을 조회하여 마지막 매칭 카드를 업데이트
      final cards = await _databaseHelper.getCardsBySessionId(sessionId as int);
      final targetCard = cards.where((c) => c.query == oldQuery).lastOrNull;
      if (targetCard == null) return;

      final updated = SearchCard(
        id: targetCard.id,
        query: newQuery,
        result: newResult,
        isLoading: false,
        createdAt: targetCard.createdAt, // 기존 생성 시간 유지
      );
      await _databaseHelper.updateSearchCardById(targetCard.id!, updated);
    }
  }

  // 카드 ID 기반 업데이트 (가능하면 ID로 업데이트하는 것이 가장 안전)
  Future<void> updateSearchCardById(
    dynamic sessionId,
    dynamic cardId,
    String newQuery,
    String newResult,
  ) async {
    // 검색 기록이 일시 중지된 경우 저장하지 않음
    if (await isPauseHistoryEnabled()) {
      print('검색 기록이 일시 중지되어 카드 ID 기반 업데이트를 수행하지 않습니다.');
      return;
    }

    if (_authService.isLoggedIn) {
      await _firestoreService.updateSearchCardById(
        sessionId.toString(),
        cardId.toString(),
        newQuery,
        newResult,
      );
    } else {
      if (cardId == null) return;
      final cards = await _databaseHelper.getCardsBySessionId(sessionId as int);
      final targetCard = cards.where((c) => c.id == cardId as int).lastOrNull;
      if (targetCard == null) return;

      final updated = SearchCard(
        id: targetCard.id,
        query: newQuery,
        result: newResult,
        isLoading: false,
        createdAt: targetCard.createdAt,
      );
      await _databaseHelper.updateSearchCardById(targetCard.id!, updated);
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

  // 페이징: 최근 검색 세션 페이지 단위로 가져오기
  Future<List<UnifiedSearchSession>> getSearchSessionsPage({
    int limit = 10,
    DateTime? startAfter,
  }) async {
    if (_authService.isLoggedIn) {
      final firestoreSessions = await _firestoreService.getSearchSessionsPage(
        limit: limit,
        startAfter: startAfter,
      );
      return firestoreSessions
          .map((data) => UnifiedSearchSession.fromFirestoreData(data))
          .toList();
    } else {
      final localSessions = await _databaseHelper.getSearchSessionsPage(
        limit: limit,
        startAfter: startAfter,
      );
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
