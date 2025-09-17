import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';

// 검색 카드 모델
class SearchCard {
  final int? id;
  final String query;
  final String result;
  final bool isLoading;
  final DateTime createdAt;
  final String fromLanguage;
  final String toLanguage;

  SearchCard({
    this.id,
    required this.query,
    required this.result,
    required this.isLoading,
    required this.createdAt,
    required this.fromLanguage,
    required this.toLanguage,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'query': query,
      'result': result,
      'is_loading': isLoading ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'from_language': fromLanguage,
      'to_language': toLanguage,
    };
  }

  factory SearchCard.fromMap(Map<String, dynamic> map) {
    return SearchCard(
      id: map['id'],
      query: map['query'],
      result: map['result'],
      isLoading: map['is_loading'] == 1,
      createdAt: DateTime.parse(map['created_at']),
      fromLanguage: (map['from_language'] ?? '').toString(),
      toLanguage: (map['to_language'] ?? '').toString(),
    );
  }
}

// 검색 세션 모델 (카드 리스트 단위)
class SearchSession {
  final int? id;
  final String sessionName;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<SearchCard> cards;

  SearchSession({
    this.id,
    required this.sessionName,
    required this.createdAt,
    required this.updatedAt,
    required this.cards,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'session_name': sessionName,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory SearchSession.fromMap(Map<String, dynamic> map) {
    return SearchSession(
      id: map['id'],
      sessionName: map['session_name'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at'] ?? map['created_at']),
      cards: [], // 카드는 별도로 로드
    );
  }
}

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'search_history.db');
    return await openDatabase(
      path,
      version: 3,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // 검색 세션 테이블
    await db.execute('''
      CREATE TABLE search_sessions(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        session_name TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // 검색 카드 테이블
    await db.execute('''
      CREATE TABLE search_cards(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        session_id INTEGER NOT NULL,
        query TEXT NOT NULL,
        result TEXT NOT NULL,
        is_loading INTEGER NOT NULL,
        created_at TEXT NOT NULL,
        from_language TEXT NOT NULL,
        to_language TEXT NOT NULL,
        FOREIGN KEY (session_id) REFERENCES search_sessions (id) ON DELETE CASCADE
      )
    ''');

    // 인덱스 생성
    await db.execute('CREATE INDEX idx_session_id ON search_cards(session_id)');
    await db.execute(
      'CREATE INDEX idx_session_created_at ON search_sessions(created_at)',
    );
    await db.execute(
      'CREATE INDEX idx_session_updated_at ON search_sessions(updated_at)',
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // updated_at 컬럼 추가 및 초기값 채우기
      await db.execute(
        'ALTER TABLE search_sessions ADD COLUMN updated_at TEXT',
      );
      await db.execute('UPDATE search_sessions SET updated_at = created_at');
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_session_updated_at ON search_sessions(updated_at)',
      );
    }
    if (oldVersion < 3) {
      // 검색 카드에 언어 컬럼 추가
      await db.execute(
        'ALTER TABLE search_cards ADD COLUMN from_language TEXT',
      );
      await db.execute('ALTER TABLE search_cards ADD COLUMN to_language TEXT');
      // NULL 값에 기본값 채우기
      await db.execute(
        "UPDATE search_cards SET from_language = COALESCE(from_language, '')",
      );
      await db.execute(
        "UPDATE search_cards SET to_language = COALESCE(to_language, '')",
      );
    }
  }

  // 새로운 검색 세션 생성
  Future<int> createSearchSession(String sessionName) async {
    final db = await database;
    final session = SearchSession(
      sessionName: sessionName,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      cards: [],
    );
    return await db.insert('search_sessions', session.toMap());
  }

  // 검색 카드 추가 (항상 새 레코드로 추가)
  Future<int> addSearchCard(int sessionId, SearchCard card) async {
    final db = await database;
    // 항상 새로운 카드로 추가
    final cardMap = card.toMap();
    cardMap['session_id'] = sessionId;
    final result = await db.insert('search_cards', cardMap);
    // 카드 추가 시 세션의 updated_at 갱신
    await db.update(
      'search_sessions',
      {'updated_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [sessionId],
    );
    return result;
  }

  // 기존 검색 카드 업데이트 (id 기준)
  Future<int> updateSearchCardById(int id, SearchCard card) async {
    final db = await database;
    final updatedMap = Map<String, dynamic>.from(card.toMap());
    // id는 변경하지 않음
    updatedMap.remove('id');
    final updated = await db.update(
      'search_cards',
      updatedMap,
      where: 'id = ?',
      whereArgs: [id],
    );
    // 카드 갱신 시 부모 세션의 updated_at 갱신
    final maps = await db.query(
      'search_cards',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      final sessionIdMaps = await db.query(
        'search_cards',
        columns: ['session_id'],
        where: 'id = ?',
        whereArgs: [id],
      );
      if (sessionIdMaps.isNotEmpty) {
        final sessionId = sessionIdMaps.first['session_id'] as int;
        await db.update(
          'search_sessions',
          {'updated_at': DateTime.now().toIso8601String()},
          where: 'id = ?',
          whereArgs: [sessionId],
        );
      }
    }
    return updated;
  }

  // 세션의 모든 카드 가져오기
  Future<List<SearchCard>> getCardsBySessionId(int sessionId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'search_cards',
      where: 'session_id = ?',
      whereArgs: [sessionId],
      orderBy: 'created_at ASC',
    );
    return List.generate(maps.length, (i) => SearchCard.fromMap(maps[i]));
  }

  // 모든 검색 세션 가져오기
  Future<List<SearchSession>> getAllSearchSessions() async {
    final db = await database;
    final List<Map<String, dynamic>> sessionMaps = await db.query(
      'search_sessions',
      orderBy: 'updated_at DESC',
    );

    List<SearchSession> sessions = [];
    for (var sessionMap in sessionMaps) {
      final session = SearchSession.fromMap(sessionMap);
      final cards = await getCardsBySessionId(session.id!);
      sessions.add(
        SearchSession(
          id: session.id,
          sessionName: session.sessionName,
          createdAt: session.createdAt,
          updatedAt: session.updatedAt,
          cards: cards,
        ),
      );
    }
    return sessions;
  }

  // 페이징: 최근 검색 세션 페이지 단위로 가져오기
  Future<List<SearchSession>> getSearchSessionsPage({
    int limit = 10,
    DateTime? startAfter,
  }) async {
    final db = await database;

    // updated_at 내림차순, startAfter가 있으면 그보다 과거(<)만
    final String orderBy = 'updated_at DESC';
    List<Map<String, dynamic>> sessionMaps;
    if (startAfter != null) {
      sessionMaps = await db.query(
        'search_sessions',
        where: 'updated_at < ?',
        whereArgs: [startAfter.toIso8601String()],
        orderBy: orderBy,
        limit: limit,
      );
    } else {
      sessionMaps = await db.query(
        'search_sessions',
        orderBy: orderBy,
        limit: limit,
      );
    }

    List<SearchSession> sessions = [];
    for (var sessionMap in sessionMaps) {
      final session = SearchSession.fromMap(sessionMap);
      final cards = await getCardsBySessionId(session.id!);
      sessions.add(
        SearchSession(
          id: session.id,
          sessionName: session.sessionName,
          createdAt: session.createdAt,
          updatedAt: session.updatedAt,
          cards: cards,
        ),
      );
    }

    return sessions;
  }

  // 특정 세션 가져오기
  Future<SearchSession?> getSearchSessionById(int sessionId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'search_sessions',
      where: 'id = ?',
      whereArgs: [sessionId],
    );

    if (maps.isEmpty) return null;

    final session = SearchSession.fromMap(maps.first);
    final cards = await getCardsBySessionId(sessionId);
    return SearchSession(
      id: session.id,
      sessionName: session.sessionName,
      createdAt: session.createdAt,
      updatedAt: session.updatedAt,
      cards: cards,
    );
  }

  // 검색 세션 삭제
  Future<int> deleteSearchSession(int sessionId) async {
    final db = await database;
    // 카드들이 CASCADE로 자동 삭제됨
    return await db.delete(
      'search_sessions',
      where: 'id = ?',
      whereArgs: [sessionId],
    );
  }

  // 모든 검색 기록 삭제
  Future<void> deleteAllSearchHistory() async {
    final db = await database;
    await db.delete('search_sessions');
  }

  // 세션을 최대 maxCount개만 유지하고, 초과분(오래된 것) 삭제
  Future<void> trimSessionsToMax(int maxCount) async {
    final db = await database;
    // 최신순으로 모두 조회 후 초과분 id 수집
    final List<Map<String, dynamic>> sessionMaps = await db.query(
      'search_sessions',
      orderBy: 'updated_at DESC',
    );

    if (sessionMaps.length <= maxCount) return;

    final excess = sessionMaps.skip(maxCount).toList();
    final batch = db.batch();
    for (final m in excess) {
      final id = m['id'] as int?;
      if (id != null) {
        batch.delete('search_sessions', where: 'id = ?', whereArgs: [id]);
      }
    }
    await batch.commit(noResult: true);
  }

  // 최근 검색 세션 가져오기 (최대 10개)
  Future<List<SearchSession>> getRecentSearchSessions({int limit = 10}) async {
    final allSessions = await getAllSearchSessions();
    return allSessions.take(limit).toList();
  }

  // 데이터베이스 닫기
  Future<void> close() async {
    final db = await database;
    db.close();
  }
}
