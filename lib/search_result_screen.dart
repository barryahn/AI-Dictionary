import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'services/search_history_service.dart';

// 검색 결과 화면 위젯 (Stateful로 변경)
class SearchResultScreen extends StatefulWidget {
  final String query;
  const SearchResultScreen({super.key, required this.query});

  @override
  State<SearchResultScreen> createState() => _SearchResultScreenState();
}

class _SearchResultScreenState extends State<SearchResultScreen> {
  final List<String> _searchQueries = [];
  final List<Widget> _searchResults = [];
  final List<bool> _isLoading = []; // 각 검색 결과의 로딩 상태
  final TextEditingController _floatingController = TextEditingController();
  final AutoScrollController _scrollController = AutoScrollController();

  // 검색 기록 서비스
  final SearchHistoryService _searchHistoryService = SearchHistoryService();
  bool _isSessionStarted = false;

  @override
  void initState() {
    super.initState();
    // 첫 검색어로 결과 추가
    _addSearchResult(widget.query);
  }

  void _addSearchResult(String query) {
    setState(() {
      _searchQueries.add(query);
      _isLoading.add(true); // 로딩 상태로 시작
      _searchResults.add(_buildLoadingSection(query));
    });

    // 첫 번째 검색어인 경우 세션 시작
    if (!_isSessionStarted) {
      _startSearchSession(query);
      _isSessionStarted = true;
    }

    // AI API 호출하여 실제 결과 가져오기 (로딩 시에는 저장하지 않음)
    _fetchSearchResult(query, _searchQueries.length - 1);
  }

  void _startSearchSession(String firstQuery) {
    final sessionName = _searchHistoryService.generateSessionName(firstQuery);
    _searchHistoryService.startNewSession(sessionName);
  }

  Future<void> _saveSearchCard(
    String query,
    String result,
    bool isLoading,
  ) async {
    try {
      await _searchHistoryService.addSearchCard(query, result, isLoading);
    } catch (e) {
      print('검색 카드 저장 실패: $e');
    }
  }

  Future<void> _fetchSearchResult(String query, int index) async {
    try {
      // 실제 API 호출 부분을 주석 처리하고 더미 데이터 사용
      // final result = await getAIResponse(query);

      // 더미 데이터 생성
      final result = _generateDummyData(query);

      setState(() {
        _isLoading[index] = false;
        _searchResults[index] = _buildResultSection(query, result);
      });

      // 결과가 완성된 후에만 데이터베이스에 저장
      await _saveSearchCard(query, result, false);

      // 새로 생성된 카드로 스크롤
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.scrollToIndex(
          index,
          duration: const Duration(milliseconds: 500),
          preferPosition: AutoScrollPosition.begin,
        );
      });
    } catch (e) {
      setState(() {
        _isLoading[index] = false;
        _searchResults[index] = _buildErrorSection(query);
      });

      // 에러 발생 시에는 데이터베이스에 저장하지 않음
    }
  }

  @override
  void dispose() {
    // 화면이 종료될 때 세션 완료
    _searchHistoryService.completeCurrentSession();
    super.dispose();
  }

  Widget _buildLoadingSection(String query) {
    final index = _searchResults.length - 1;
    return AutoScrollTag(
      key: Key(index.toString()),
      controller: _scrollController,
      index: index,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          // 검색 입력창(읽기 전용)
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: TextEditingController(text: query),
                  style: const TextStyle(fontSize: 28, color: Colors.black),
                  decoration: const InputDecoration(border: InputBorder.none),
                  readOnly: true,
                ),
              ),
            ],
          ),
          const Divider(thickness: 1),
          // 검색어(큰 글씨)
          Text(
            query,
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          // 로딩 인디케이터
          const Center(
            child: Column(
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 8),
                Text(
                  '검색 중...',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Divider(thickness: 2, color: Colors.blue),
        ],
      ),
    );
  }

  Widget _buildErrorSection(String query) {
    final index = _searchResults.length - 1;
    return AutoScrollTag(
      key: Key(index.toString()),
      controller: _scrollController,
      index: index,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          // 검색 입력창(읽기 전용)
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: TextEditingController(text: query),
                  style: const TextStyle(fontSize: 28, color: Colors.black),
                  decoration: const InputDecoration(border: InputBorder.none),
                  readOnly: true,
                ),
              ),
            ],
          ),
          const Divider(thickness: 1),
          // 검색어(큰 글씨)
          Text(
            query,
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          // 에러 메시지
          const Center(
            child: Text(
              '검색 결과를 가져오는데 실패했습니다.',
              style: TextStyle(fontSize: 16, color: Colors.red),
            ),
          ),
          const SizedBox(height: 16),
          const Divider(thickness: 2, color: Colors.blue),
        ],
      ),
    );
  }

  Widget _buildResultSection(String query, String aiResponse) {
    final index = _searchResults.length - 1;
    return AutoScrollTag(
      key: Key(index.toString()),
      controller: _scrollController,
      index: index,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          // 검색 입력창(읽기 전용)
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: TextEditingController(text: query),
                  style: const TextStyle(fontSize: 28, color: Colors.black),
                  decoration: const InputDecoration(border: InputBorder.none),
                  readOnly: true,
                ),
              ),
            ],
          ),
          const Divider(thickness: 1),
          // 검색어(큰 글씨)
          Text(
            query,
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          // 품사 정보 (AI 응답에서 추출하거나 기본값)
          const Text(
            '단어',
            style: TextStyle(fontSize: 18, color: Colors.black54),
          ),
          // AI 응답 내용
          const SizedBox(height: 16),
          Text(aiResponse, style: const TextStyle(fontSize: 16, height: 1.5)),
          const SizedBox(height: 4),
          const Divider(thickness: 2, color: Colors.blue),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        leading: IconButton(
          icon: const Icon(Icons.home),
          onPressed: () {
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
        ),
        actions: [IconButton(icon: const Icon(Icons.copy), onPressed: () {})],
      ),
      body: ListView(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        children: _searchResults,
      ),
      // 하단 플로팅 검색창
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(30),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _floatingController,
                    decoration: const InputDecoration(
                      hintText: '추가 검색하기',
                      border: InputBorder.none,
                      icon: Icon(Icons.search),
                    ),
                    onSubmitted: (value) {
                      final newQuery = value.trim();
                      if (newQuery.isNotEmpty) {
                        _addSearchResult(newQuery);
                        _floatingController.clear();
                      }
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () {
                    final newQuery = _floatingController.text.trim();
                    if (newQuery.isNotEmpty) {
                      _addSearchResult(newQuery);
                      _floatingController.clear();
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 더미 데이터 생성 함수
  String _generateDummyData(String query) {
    final dummyResponses = {
      'hello': '''"Hello"는 인사말로 사용되는 영어 단어입니다.

**의미:**
- 안녕하세요, 안녕
- 친근한 인사말

**예문:**
1. Hello, how are you today?
   안녕하세요, 오늘 어떠세요?

2. Hello there! Nice to meet you.
   안녕하세요! 만나서 반갑습니다.

3. She said hello to everyone in the room.
   그녀는 방 안의 모든 사람에게 인사를 했다.''',

      'world': '''"World"는 세상, 세계를 의미하는 영어 단어입니다.

**의미:**
- 세상, 세계
- 지구, 천하

**예문:**
1. The world is changing rapidly.
   세상이 빠르게 변하고 있다.

2. She traveled around the world.
   그녀는 세계를 여행했다.

3. It's a beautiful world we live in.
   우리가 사는 세상은 아름답다.''',

      'flutter': '''"Flutter"는 여러 의미를 가진 영어 단어입니다.

**의미:**
- 펄럭이다, 날개를 치다
- 떨다, 흔들리다
- Flutter (구글의 모바일 앱 개발 프레임워크)

**예문:**
1. The butterfly fluttered its wings.
   나비가 날개를 펄럭였다.

2. Her heart fluttered with excitement.
   그녀의 마음이 흥분으로 떨렸다.

3. Flutter is a popular framework for mobile development.
   Flutter는 모바일 개발에 인기 있는 프레임워크이다.''',
    };

    // 쿼리에 해당하는 더미 데이터가 있으면 반환, 없으면 기본 응답
    return dummyResponses[query.toLowerCase()] ??
        '''"$query"에 대한 검색 결과입니다.

**의미:**
- 이 단어의 기본적인 의미와 용법

**예문:**
1. Example sentence 1
   예문 번역 1

2. Example sentence 2
   예문 번역 2

3. Example sentence 3
   예문 번역 3''';
  }
}

// 예문(영어/한글) 표시용 위젯
class _ExampleRow extends StatelessWidget {
  final String en;
  final String ko;
  const _ExampleRow({required this.en, required this.ko});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(en, style: const TextStyle(fontSize: 16)),
          Text(ko, style: const TextStyle(fontSize: 16, color: Colors.black54)),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}

Future<String> getAIResponse(String word) async {
  final apiKey = dotenv.env['OPENAI_API_KEY'];
  final url = Uri.parse('https://api.openai.com/v1/chat/completions');

  final response = await http.post(
    url,
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $apiKey',
    },
    body: jsonEncode({
      "model": "gpt-3.5-turbo",
      "messages": [
        {"role": "system", "content": "You are an English teacher."},
        {
          "role": "user",
          "content":
              "Give me a simple explanation and example sentences for the word '$word'.",
        },
      ],
      "temperature": 0.7,
    }),
  );

  if (response.statusCode == 200) {
    final decoded = jsonDecode(response.body);
    final content = decoded['choices'][0]['message']['content'];
    return content.trim();
  } else {
    print('Failed: ${response.body}');
    return 'Sorry, I couldn\'t get a response.';
  }
}
