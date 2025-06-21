import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'services/search_history_service.dart';
import 'database/database_helper.dart';

// 검색 결과와 검색 입력을 모두 처리하는 화면
class SearchResultScreen extends StatefulWidget {
  final String? initialQuery;
  final SearchSession? searchSession;
  const SearchResultScreen({super.key, this.initialQuery, this.searchSession});

  @override
  State<SearchResultScreen> createState() => _SearchResultScreenState();
}

class _SearchResultScreenState extends State<SearchResultScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final List<String> _searchQueries = [];
  final List<Widget> _searchResults = [];
  final List<bool> _isLoading = [];
  final AutoScrollController _scrollController = AutoScrollController();
  final SearchHistoryService _searchHistoryService = SearchHistoryService();
  bool _isSessionStarted = false;
  bool _isSearching = false;
  bool _isFetching = false; // 현재 API 호출이 진행 중인지 여부
  int? _currentSessionId; // 현재 세션 ID를 저장

  @override
  void initState() {
    super.initState();
    if (widget.searchSession != null) {
      _populateWithSessionData(widget.searchSession!);
    } else if (widget.initialQuery != null && widget.initialQuery!.isNotEmpty) {
      _searchController.text = widget.initialQuery!;
      _startSearch();
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        FocusScope.of(context).requestFocus(_focusNode);
      });
    }
  }

  void _populateWithSessionData(SearchSession session) {
    setState(() {
      _isSearching = true;
      _isSessionStarted = true;
      _isFetching = false;
      _currentSessionId = session.id; // 현재 세션 ID 저장

      final initialIndex = _searchQueries.length;
      for (var i = 0; i < session.cards.length; i++) {
        final card = session.cards[i];
        final currentIndex = initialIndex + i;

        _searchQueries.add(card.query);
        _isLoading.add(card.isLoading);
        if (card.isLoading) {
          _searchResults.add(_buildLoadingSection(card.query, currentIndex));
        } else if (card.result.isEmpty && !card.isLoading) {
          _searchResults.add(_buildErrorSection(card.query, currentIndex));
        } else {
          _searchResults.add(
            _buildResultSection(card.query, card.result, currentIndex),
          );
        }
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _searchResults.isNotEmpty) {
        _scrollController.scrollToIndex(
          _searchResults.length - 1,
          duration: const Duration(milliseconds: 300),
          preferPosition: AutoScrollPosition.begin,
        );
      }
    });
  }

  void _startSearch() {
    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      setState(() {
        _isSearching = true;
      });
      _addSearchResult(query);
      _focusNode.unfocus();
    }
  }

  void _stopFetching() {
    setState(() {
      _isFetching = false;
      // 마지막 로딩 상태를 에러나 다른 상태로 바꿀 수 있습니다.
      // 여기서는 간단히 로딩을 멈추고 추가 검색이 가능하도록 합니다.
      if (_isLoading.isNotEmpty && _isLoading.last) {
        final index = _isLoading.length - 1;
        _isLoading[index] = false;
        _searchResults[index] = _buildErrorSection(
          _searchQueries.last,
          index,
          message: "검색이 중단되었습니다.",
        );
      }
    });
  }

  void _addSearchResult(String query) {
    setState(() {
      final index = _searchQueries.length;
      _searchQueries.add(query);
      _isLoading.add(true);
      _searchResults.add(_buildLoadingSection(query, index));
      _isFetching = true; // 검색 시작
    });

    if (!_isSessionStarted) {
      // 새로운 세션 시작
      _isSessionStarted = true;
    }

    _fetchSearchResult(query, _searchQueries.length - 1);
  }

  Future<void> _saveSearchCard(
    String query,
    String result,
    bool isLoading,
  ) async {
    try {
      if (_currentSessionId != null) {
        // 기존 세션에 카드 추가
        await _searchHistoryService.addSearchCardToExistingSession(
          _currentSessionId!,
          query,
          result,
          isLoading,
        );
      } else {
        // 새로운 세션에 카드 추가
        await _searchHistoryService.addSearchCard(query, result, isLoading);
      }
    } catch (e) {
      print('검색 카드 저장 실패: $e');
    }
  }

  Future<void> _fetchSearchResult(String query, int index) async {
    try {
      final result = await _generateDummyData(query);
      if (!mounted || !_isFetching) return; // 중단되었는지 확인

      setState(() {
        _isLoading[index] = false;
        _searchResults[index] = _buildResultSection(query, result, index);
        if (index == _searchQueries.length - 1) {
          _isFetching = false; // 마지막 검색 완료
        }
      });
      await _saveSearchCard(query, result, false);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _scrollController.scrollToIndex(
            index,
            duration: const Duration(milliseconds: 500),
            preferPosition: AutoScrollPosition.begin,
          );
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading[index] = false;
        _searchResults[index] = _buildErrorSection(query, index);
        if (index == _searchQueries.length - 1) {
          _isFetching = false; // 에러 발생 시에도 검색 상태 종료
        }
      });
    }
  }

  @override
  void dispose() {
    _searchHistoryService.completeCurrentSession();
    _searchController.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // --- UI Builder Methods ---

  Widget _buildInitialView() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _searchController,
            focusNode: _focusNode,
            style: const TextStyle(fontSize: 28, color: Colors.black54),
            decoration: const InputDecoration(
              hintText: '무엇이든 물어보세요',
              border: InputBorder.none,
            ),
            onSubmitted: (_) => _startSearch(),
          ),
          const Divider(thickness: 1),
        ],
      ),
    );
  }

  Widget _buildResultView() {
    return ListView(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      children: _searchResults,
    );
  }

  @override
  Widget build(BuildContext context) {
    // 하단 바를 동적으로 변경
    Widget bottomBar;
    if (!_isSearching) {
      // 초기 검색 화면의 하단 바
      bottomBar = BottomAppBar(
        child: Row(
          children: [
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.search),
                label: const Text('검색'),
                onPressed: _startSearch,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    } else if (_isFetching) {
      // 검색 중일 때의 "중단" 버튼
      bottomBar = BottomAppBar(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.stop_circle_outlined),
              label: const Text('중단'),
              onPressed: _stopFetching,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ),
        ),
      );
    } else {
      // 검색 완료 후의 "추가 검색하기" 창
      bottomBar = SafeArea(
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
                    controller: _searchController..clear(),
                    focusNode: _focusNode,
                    decoration: const InputDecoration(
                      hintText: '추가 검색하기',
                      border: InputBorder.none,
                      icon: Icon(Icons.search),
                    ),
                    onSubmitted: (value) {
                      final newQuery = value.trim();
                      if (newQuery.isNotEmpty) {
                        _addSearchResult(newQuery);
                        _searchController.clear();
                        FocusScope.of(context).unfocus();
                      }
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    final newQuery = _searchController.text.trim();
                    if (newQuery.isNotEmpty) {
                      _addSearchResult(newQuery);
                      _searchController.clear();
                      FocusScope.of(context).unfocus();
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: _isSearching ? _buildResultView() : _buildInitialView(),
      bottomNavigationBar: Padding(
        padding: MediaQuery.of(context).viewInsets,
        child: bottomBar,
      ),
    );
  }

  Widget _buildLoadingSection(String query, int index) {
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

  Widget _buildErrorSection(
    String query,
    int index, {
    String message = '검색 결과를 가져오는데 실패했습니다.',
  }) {
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
          Center(
            child: Text(
              message,
              style: const TextStyle(fontSize: 16, color: Colors.red),
            ),
          ),
          const SizedBox(height: 16),
          const Divider(thickness: 2, color: Colors.blue),
        ],
      ),
    );
  }

  Widget _buildResultSection(String query, String aiResponse, int index) {
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
