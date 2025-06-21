import '../database/database_helper.dart';

class SearchHistoryService {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  int? _currentSessionId;

  // 새로운 검색 세션 시작
  Future<void> startNewSession(String sessionName) async {
    _currentSessionId = await _databaseHelper.createSearchSession(sessionName);
  }

  // 현재 세션에 검색 카드 추가
  Future<void> addSearchCard(
    String query,
    String result,
    bool isLoading,
  ) async {
    if (_currentSessionId == null) {
      // 세션이 없으면 자동으로 생성
      await startNewSession(
        '검색 세션 ${DateTime.now().toString().substring(0, 19)}',
      );
    }

    final card = SearchCard(
      query: query,
      result: result,
      isLoading: isLoading,
      createdAt: DateTime.now(),
    );

    await _databaseHelper.addSearchCard(_currentSessionId!, card);
  }

  // 기존 세션에 검색 카드 추가
  Future<void> addSearchCardToExistingSession(
    int sessionId,
    String query,
    String result,
    bool isLoading,
  ) async {
    final card = SearchCard(
      query: query,
      result: result,
      isLoading: isLoading,
      createdAt: DateTime.now(),
    );

    await _databaseHelper.addSearchCard(sessionId, card);
  }

  // 검색 카드 업데이트 (로딩 상태에서 결과 상태로)
  Future<void> updateSearchCard(String query, String result) async {
    // 현재 세션의 카드들을 가져와서 업데이트
    if (_currentSessionId != null) {
      final cards = await _databaseHelper.getCardsBySessionId(
        _currentSessionId!,
      );
      final targetCard = cards.where((card) => card.query == query).lastOrNull;

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

  // 현재 세션 완료
  void completeCurrentSession() {
    _currentSessionId = null;
  }

  // 모든 검색 세션 가져오기
  Future<List<SearchSession>> getAllSearchSessions() async {
    return await _databaseHelper.getAllSearchSessions();
  }

  // 특정 검색 세션 가져오기
  Future<SearchSession?> getSearchSessionById(int sessionId) async {
    return await _databaseHelper.getSearchSessionById(sessionId);
  }

  // 검색 세션 삭제
  Future<void> deleteSearchSession(int sessionId) async {
    await _databaseHelper.deleteSearchSession(sessionId);
  }

  // 모든 검색 기록 삭제
  Future<void> clearAllSearchHistory() async {
    await _databaseHelper.deleteAllSearchHistory();
  }

  // 최근 검색 세션 가져오기
  Future<List<SearchSession>> getRecentSearchSessions({int limit = 10}) async {
    return await _databaseHelper.getRecentSearchSessions(limit: limit);
  }

  // 현재 세션 ID 가져오기
  int? get currentSessionId => _currentSessionId;

  // 세션 이름 생성 (첫 번째 검색어 기반)
  String generateSessionName(String firstQuery) {
    final now = DateTime.now();
    final timeString =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    return '$firstQuery ($timeString)';
  }
}
