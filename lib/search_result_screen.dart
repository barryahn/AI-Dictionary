import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'services/search_history_service.dart';
import 'services/openai_service.dart';
import 'database/database_helper.dart';
import 'services/language_service.dart';

// 검색 결과와 검색 입력을 모두 처리하는 화면
class SearchResultScreen extends StatefulWidget {
  final String? initialQuery;
  final SearchSession? searchSession;
  final String fromLanguage;
  final String toLanguage;

  const SearchResultScreen({
    super.key,
    this.initialQuery,
    this.searchSession,
    this.fromLanguage = '영어',
    this.toLanguage = '한국어',
  });

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

  // 언어 선택을 위한 상태 변수들
  late String _fromLanguage;
  late String _toLanguage;
  final List<String> _languages = ['영어', '한국어', '중국어', '스페인어', '프랑스어'];

  @override
  void initState() {
    super.initState();

    // LanguageService에서 저장된 언어 설정 불러오기
    _fromLanguage = LanguageService.fromLanguage;
    _toLanguage = LanguageService.toLanguage;

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
    print('검색 중단 요청');
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
        print('검색 중단 완료: 인덱스 $index');
      }
    });
  }

  void _addSearchResult(String query) {
    print('새 검색 추가: $query');
    setState(() {
      final index = _searchQueries.length;
      _searchQueries.add(query);
      _isLoading.add(true);
      _searchResults.add(_buildLoadingSection(query, index));
      _isFetching = true; // 검색 시작
      print('검색 상태 설정: _isFetching = true, 로딩 인덱스 = $index');
    });

    if (!_isSessionStarted) {
      // 새로운 세션 시작
      _isSessionStarted = true;
    }

    // 새 검색 추가 직후 스크롤
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _scrollController.scrollToIndex(
          _searchQueries.length - 1,
          duration: const Duration(milliseconds: 300),
          preferPosition: AutoScrollPosition.begin,
        );
      }
    });

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
      final result = await OpenAIService.getWordDefinitionSimple(
        query,
        _fromLanguage,
        _toLanguage,
      );

      // API 응답 결과 출력
      print('=== API 응답 결과 (인덱스: $index) ===');
      print('검색어: $query');
      print('응답: $result');
      print('=====================================');

      if (!mounted || !_isFetching) return; // 중단되었는지 확인

      print('상태 업데이트 시작: 로딩 해제 및 결과 표시');
      setState(() {
        // 로딩 상태 해제
        if (index < _isLoading.length) {
          _isLoading[index] = false;
          print('로딩 상태 해제: 인덱스 $index');
        }

        // 결과 업데이트
        if (index < _searchResults.length) {
          _searchResults[index] = _buildResultSection(query, result, index);
          print('결과 섹션 업데이트: 인덱스 $index');
        }

        // 마지막 검색이 완료되면 전체 검색 상태 해제
        if (index == _searchQueries.length - 1) {
          _isFetching = false;
          print('모든 검색 완료 - _isFetching = false');
        }
      });

      // 강제로 위젯 다시 빌드
      if (mounted) {
        setState(() {});
      }

      print('검색 카드 저장 시작');
      await _saveSearchCard(query, result, false);
      print('검색 카드 저장 완료');

      print('AI 응답 처리 완료: $query');
    } catch (e) {
      print('AI 응답 오류: $e');
      if (!mounted) return;

      setState(() {
        // 에러 발생 시에도 로딩 상태 해제
        if (index < _isLoading.length) {
          _isLoading[index] = false;
        }

        // 에러 섹션으로 업데이트
        if (index < _searchResults.length) {
          _searchResults[index] = _buildErrorSection(query, index);
        }

        // 마지막 검색이 에러로 끝나면 전체 검색 상태 해제
        if (index == _searchQueries.length - 1) {
          _isFetching = false;
          print('검색 에러로 완료 - _isFetching = false');
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
      children: _searchResults.asMap().entries.map((entry) {
        final index = entry.key;
        final widget = entry.value;
        print('결과 위젯 $index: ${widget.runtimeType}');
        return widget;
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 하단 바를 동적으로 변경
    Widget bottomBar;
    if (!_isSearching) {
      // 초기 검색 화면의 하단 바
      bottomBar = BottomAppBar(
        color: Colors.grey[200],
        height: 64,
        child: Row(
          children: [
            const Spacer(),
            ElevatedButton(
              onPressed: _startSearch,
              style: ElevatedButton.styleFrom(
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(2),
                backgroundColor: Colors.white,
              ),
              child: Padding(
                padding: const EdgeInsets.only(left: 2),
                child: Icon(Icons.send, color: Colors.grey[800], size: 24),
              ),
            ),
          ],
        ),
      );
    } else if (_isFetching) {
      // 검색 중일 때의 "중단" 버튼
      print('검색 중 하단 바 표시');
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
      print('검색 완료 후 하단 바 표시');
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
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 출발 언어 드롭다운
            Container(
              height: 32,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[300]!, width: 1),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _fromLanguage,
                  items: _languages
                      .where((lang) => lang != _toLanguage)
                      .map(
                        (lang) => DropdownMenuItem(
                          value: lang,
                          child: Text(
                            lang,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      _updateLanguages(newValue, _toLanguage);
                    }
                  },
                  icon: const Icon(
                    Icons.keyboard_arrow_down,
                    size: 18,
                    color: Colors.grey,
                  ),
                  style: const TextStyle(color: Colors.black87),
                  dropdownColor: Colors.white,
                  elevation: 2,
                ),
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Icon(
                Icons.arrow_forward_ios,
                size: 12,
                color: Colors.grey,
              ),
            ),
            const SizedBox(width: 6),
            // 도착 언어 드롭다운
            Container(
              height: 32,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[300]!, width: 1),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _toLanguage,
                  items: _languages
                      .where((lang) => lang != _fromLanguage)
                      .map(
                        (lang) => DropdownMenuItem(
                          value: lang,
                          child: Text(
                            lang,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      _updateLanguages(_fromLanguage, newValue);
                    }
                  },
                  icon: const Icon(
                    Icons.keyboard_arrow_down,
                    size: 18,
                    color: Colors.grey,
                  ),
                  style: const TextStyle(color: Colors.black87),
                  dropdownColor: Colors.white,
                  elevation: 2,
                ),
              ),
            ),
          ],
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
      child: SizedBox(
        height: MediaQuery.of(context).size.height - 200, // 화면 높이에서 상단 여백 제외
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
            // 로딩 인디케이터 - 남은 공간을 모두 차지
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    const Text(
                      '검색 중...',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
            const Divider(thickness: 2, color: Colors.blue),
          ],
        ),
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
    // JSON 파싱 시도
    Map<String, dynamic>? parsedData;
    try {
      parsedData = jsonDecode(aiResponse);
      print('=== JSON 파싱 성공 (인덱스: $index) ===');
      print('파싱된 데이터: $parsedData');
      print('=====================================');

      // 파싱된 데이터가 Map인지 확인
      if (parsedData is! Map<String, dynamic>) {
        print('=== JSON 데이터가 Map이 아님 (인덱스: $index) ===');
        return _buildFallbackResultSection(query, aiResponse, index);
      }
    } catch (e) {
      print('=== JSON 파싱 실패 (인덱스: $index) ===');
      print('파싱 오류: $e');
      print('원본 응답: $aiResponse');
      print('=====================================');
      // JSON 파싱 실패 시 기존 방식으로 표시
      return _buildFallbackResultSection(query, aiResponse, index);
    }

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

          // 검색어(큰 글씨) - JSON에서 단어 필드 사용
          if (parsedData['단어'] != null) ...[
            Text(
              parsedData['단어'].toString(),
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
          ],

          // 사전적 뜻
          if (parsedData['사전적_뜻'] != null && parsedData['사전적_뜻'] is List) ...[
            _buildSectionTitle('사전적 뜻'),
            const SizedBox(height: 12),
            _buildDictionaryMeanings(parsedData['사전적_뜻'] as List<dynamic>),
            const SizedBox(height: 24),
          ],

          // 뉘앙스
          if (parsedData['뉘앙스'] != null) ...[
            _buildSectionTitle('뉘앙스'),
            const SizedBox(height: 8),
            Text(
              parsedData['뉘앙스'].toString(),
              style: const TextStyle(
                fontSize: 16,
                height: 1.5,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 24),
          ],

          // 대화 예시
          if (parsedData['대화_예시'] != null && parsedData['대화_예시'] is List) ...[
            _buildSectionTitle('대화 예시'),
            const SizedBox(height: 12),
            _buildConversationExamples(
              parsedData['대화_예시'] as List<dynamic>,
              _fromLanguage,
              _toLanguage,
            ),
            const SizedBox(height: 24),
          ],

          // 비슷한 표현
          if (parsedData['비슷한_표현'] != null && parsedData['비슷한_표현'] is List) ...[
            _buildSectionTitle('비슷한 표현'),
            const SizedBox(height: 12),
            _buildSimilarExpressions(parsedData['비슷한_표현'] as List<dynamic>),
            const SizedBox(height: 16),
          ],

          const Divider(thickness: 2, color: Colors.blue),
        ],
      ),
    );
  }

  Widget _buildFallbackResultSection(
    String query,
    String aiResponse,
    int index,
  ) {
    return AutoScrollTag(
      key: Key(index.toString()),
      controller: _scrollController,
      index: index,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
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
          Text(
            query,
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          const Text(
            '단어',
            style: TextStyle(fontSize: 18, color: Colors.black54),
          ),
          const SizedBox(height: 16),
          Text(aiResponse, style: const TextStyle(fontSize: 16, height: 1.5)),
          const SizedBox(height: 4),
          const Divider(thickness: 2, color: Colors.blue),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    );
  }

  Widget _buildDictionaryMeanings(List<dynamic> meanings) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: meanings.map<Widget>((meaning) {
        // 안전한 타입 캐스팅
        if (meaning is! Map<String, dynamic>) {
          return const SizedBox.shrink();
        }

        final partOfSpeech = meaning['품사']?.toString() ?? '';
        final definitionsRaw = meaning['번역'];

        // definitions가 null이거나 리스트가 아닌 경우 처리
        List<dynamic> definitions = [];
        if (definitionsRaw is List) {
          definitions = definitionsRaw;
        } else if (definitionsRaw != null) {
          definitions = [definitionsRaw.toString()];
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                partOfSpeech,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue[700],
                ),
              ),
              const SizedBox(height: 8),
              ...definitions.map<Widget>(
                (def) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('• ', style: TextStyle(fontSize: 16)),
                      Expanded(
                        child: Text(
                          def.toString(),
                          style: const TextStyle(fontSize: 16, height: 1.4),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildConversationExamples(
    List<dynamic> examples,
    String fromLanguage,
    String toLanguage,
  ) {
    return Column(
      children: examples.asMap().entries.map<Widget>((entry) {
        final index = entry.key;
        final exampleRaw = entry.value;

        // 안전한 타입 캐스팅
        if (exampleRaw is! Map<String, dynamic>) {
          return const SizedBox.shrink();
        }

        final example = exampleRaw;

        // 프롬프트에서 실제 언어명을 키로 사용하므로, 동적으로 찾기
        List<dynamic> l2Lines = [];
        List<dynamic> l1Lines = [];

        // 모든 키를 확인하여 언어별 대화 찾기
        example.forEach((key, value) {
          if (value is List) {
            // 키가 언어명인지 확인 (간단한 체크)
            if (key.contains(toLanguage) ||
                key.contains('중국어') ||
                key.contains('영어') ||
                key.contains('한국어')) {
              l2Lines = value;
            } else if (key.contains(fromLanguage) ||
                key.contains('중국어') ||
                key.contains('영어') ||
                key.contains('한국어')) {
              l1Lines = value;
            }
          }
        });

        // 만약 위 방법으로 찾지 못했다면, 첫 번째와 두 번째 리스트를 사용
        if (l2Lines.isEmpty || l1Lines.isEmpty) {
          final lists = example.values.where((value) => value is List).toList();
          if (lists.length >= 2) {
            l2Lines = lists[0] as List<dynamic>;
            l1Lines = lists[1] as List<dynamic>;
          }
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '대화 ${index + 1}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue[700],
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  children: [
                    // L2 언어 대화 (예: 중국어)
                    if (l2Lines.isNotEmpty) ...[
                      ...l2Lines.map<Widget>((line) {
                        // 안전한 타입 캐스팅
                        if (line is! Map<String, dynamic>) {
                          return const SizedBox.shrink();
                        }

                        final speaker = line['speaker']?.toString() ?? '';
                        final text = line['line']?.toString() ?? '';

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.blue[100],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  speaker,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.blue[700],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  text,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                      const Divider(height: 16, color: Colors.grey),
                    ],
                    // L1 언어 대화 (예: 영어)
                    if (l1Lines.isNotEmpty) ...[
                      ...l1Lines.map<Widget>((line) {
                        // 안전한 타입 캐스팅
                        if (line is! Map<String, dynamic>) {
                          return const SizedBox.shrink();
                        }

                        final speaker = line['speaker']?.toString() ?? '';
                        final text = line['line']?.toString() ?? '';

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green[100],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  speaker,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.green[700],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  text,
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.grey[600],
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSimilarExpressions(List<dynamic> expressions) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: expressions.map<Widget>((expr) {
        // 안전한 타입 캐스팅
        if (expr is! Map<String, dynamic>) {
          return const SizedBox.shrink();
        }

        final word = expr['단어']?.toString() ?? '';
        final meaning = expr['뜻']?.toString() ?? '';

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                word,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              Text(
                meaning,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  void _updateLanguages(String fromLang, String toLang) {
    setState(() {
      _fromLanguage = fromLang;
      _toLanguage = toLang;
    });
    // LanguageService에 저장
    LanguageService.setTranslationLanguages(fromLang, toLang);
  }
}
