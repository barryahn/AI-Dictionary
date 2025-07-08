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

  SearchCard({
    this.id,
    required this.query,
    required this.result,
    required this.isLoading,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'query': query,
      'result': result,
      'is_loading': isLoading ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory SearchCard.fromMap(Map<String, dynamic> map) {
    return SearchCard(
      id: map['id'],
      query: map['query'],
      result: map['result'],
      isLoading: map['is_loading'] == 1,
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}

// 검색 세션 모델 (카드 리스트 단위)
class SearchSession {
  final int? id;
  final String sessionName;
  final DateTime createdAt;
  final List<SearchCard> cards;

  SearchSession({
    this.id,
    required this.sessionName,
    required this.createdAt,
    required this.cards,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'session_name': sessionName,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory SearchSession.fromMap(Map<String, dynamic> map) {
    return SearchSession(
      id: map['id'],
      sessionName: map['session_name'],
      createdAt: DateTime.parse(map['created_at']),
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
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    // 검색 세션 테이블
    await db.execute('''
      CREATE TABLE search_sessions(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        session_name TEXT NOT NULL,
        created_at TEXT NOT NULL
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
        FOREIGN KEY (session_id) REFERENCES search_sessions (id) ON DELETE CASCADE
      )
    ''');

    // 인덱스 생성
    await db.execute('CREATE INDEX idx_session_id ON search_cards(session_id)');
    await db.execute(
      'CREATE INDEX idx_session_created_at ON search_sessions(created_at)',
    );
  }

  // 새로운 검색 세션 생성
  Future<int> createSearchSession(String sessionName) async {
    final db = await database;
    final session = SearchSession(
      sessionName: sessionName,
      createdAt: DateTime.now(),
      cards: [],
    );
    return await db.insert('search_sessions', session.toMap());
  }

  // 검색 카드 추가 (중복 확인 후 추가)
  Future<int> addSearchCard(int sessionId, SearchCard card) async {
    final db = await database;

    // 같은 세션에서 같은 검색어가 있는지 확인
    final existingCards = await db.query(
      'search_cards',
      where: 'session_id = ? AND query = ?',
      whereArgs: [sessionId, card.query],
    );

    if (existingCards.isNotEmpty) {
      // 기존 카드가 있으면 업데이트
      final existingCard = existingCards.first;
      final updatedCard = SearchCard(
        id: existingCard['id'] as int?,
        query: card.query,
        result: card.result,
        isLoading: card.isLoading,
        createdAt: DateTime.parse(existingCard['created_at'] as String),
      );

      return await db.update(
        'search_cards',
        updatedCard.toMap(),
        where: 'id = ?',
        whereArgs: [existingCard['id']],
      );
    } else {
      // 새로운 카드 추가
      final cardMap = card.toMap();
      cardMap['session_id'] = sessionId;
      return await db.insert('search_cards', cardMap);
    }
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
      orderBy: 'created_at DESC',
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
