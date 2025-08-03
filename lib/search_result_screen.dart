import 'package:flutter/material.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'dart:convert';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:provider/provider.dart';
import 'services/search_history_service.dart';
import 'services/openai_service.dart';
import 'models/unified_search_session.dart';
import 'services/language_service.dart';
import 'services/theme_service.dart';
import 'theme/app_theme.dart';
import 'l10n/app_localizations.dart';
import 'package:google_mlkit_language_id/google_mlkit_language_id.dart';
import 'package:gpt_markdown/gpt_markdown.dart';

// 검색 결과와 검색 입력을 모두 처리하는 화면
class SearchResultScreen extends StatefulWidget {
  final String? initialQuery;
  final UnifiedSearchSession? searchSession;
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
  dynamic _currentSessionId; // 현재 세션 ID를 저장

  // 언어 판별
  final languageIdentifier = LanguageIdentifier(confidenceThreshold: 0.005);

  // 언어 선택을 위한 상태 변수들
  late String _fromLanguage = LanguageService.fromLanguage;
  late String _toLanguage = LanguageService.toLanguage;

  @override
  void initState() {
    super.initState();

    // 백그라운드에서 캐시 초기화
    _initializeBackgroundCache();

    Future.delayed(const Duration(milliseconds: 50), () {
      if (widget.searchSession != null) {
        _populateWithSessionData(widget.searchSession!);
      } else if (widget.initialQuery != null &&
          widget.initialQuery!.isNotEmpty) {
        _searchController.text = widget.initialQuery!;
        _startSearch();
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          FocusScope.of(context).requestFocus(_focusNode);
        });
      }
    });
  }

  // 백그라운드 캐시 초기화
  void _initializeBackgroundCache() {
    // 백그라운드에서 캐시 초기화 (UI 블로킹 방지)
    Future.microtask(() async {
      try {
        await _searchHistoryService.initializeCache();
        print('백그라운드 캐시 초기화 완료');
      } catch (e) {
        print('백그라운드 캐시 초기화 실패: $e');
      }
    });
  }

  void _populateWithSessionData(UnifiedSearchSession session) {
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
          message: AppLocalizations.of(context).search_stopped,
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

  Future<List<String>> _identifyLanguage(String query) async {
    final List<IdentifiedLanguage> possibleLanguages = await languageIdentifier
        .identifyPossibleLanguages(query);

    final supportedLanguages = LanguageService.getSupportedLanguagesCode();
    final List<String> languages = [];

    /* for (final lang in possibleLanguages) {
      print('lang: ${lang.languageTag}');
      print('lang: ${lang.confidence}');
    } */

    for (final language in possibleLanguages) {
      if (supportedLanguages.contains(language.languageTag)) {
        languages.add(language.languageTag);
      }
    }
    return languages;
  }

  Future<void> _fetchSearchResult(String query, int index) async {
    try {
      /* final result = await OpenAIService.getWordDefinitionSimple(
        query,
        _fromLanguage,
        _toLanguage,
      ); */

      final languages = await _identifyLanguage(query);
      print('languages: $languages');

      if (languages.isEmpty) {
        return;
      }

      String result = '';
      bool isCompleted = false;

      if (languages.first == LanguageService.getLanguageCode(_toLanguage) ||
          languages.contains(LanguageService.getLanguageCode(_toLanguage))) {
        OpenAIService.getL2WordDefinition(
          query,
          _fromLanguage,
          _toLanguage,
          (delta) {
            if (!mounted || !_isFetching) return;
            setState(() {
              result += delta;
              // 실시간으로 결과 업데이트
              if (index < _searchResults.length) {
                _searchResults[index] = _buildResultSection(
                  query,
                  result,
                  index,
                );
              }
            });
          },
          () {
            if (!mounted || !_isFetching) return;
            isCompleted = true;
            _handleSearchComplete(query, result, index);
          },
          (error) {
            if (!mounted || !_isFetching) return;
            print('OpenAI API 오류: $error');
            setState(() {
              if (index < _isLoading.length) {
                _isLoading[index] = false;
              }
              if (index < _searchResults.length) {
                _searchResults[index] = _buildErrorSection(query, index);
              }
              if (index == _searchQueries.length - 1) {
                _isFetching = false;
              }
            });
          },
        );
      } else if (languages.first ==
          LanguageService.getLanguageCode(_fromLanguage)) {
        OpenAIService.getL1WordDefinition(
          query,
          _fromLanguage,
          _toLanguage,
          (delta) {
            if (!mounted || !_isFetching) return;
            setState(() {
              result += delta;
              // 실시간으로 결과 업데이트
              if (index < _searchResults.length) {
                _searchResults[index] = _buildResultSection(
                  query,
                  result,
                  index,
                );
              }
            });
          },
          () {
            if (!mounted || !_isFetching) return;
            isCompleted = true;
            _handleSearchComplete(query, result, index);
          },
          (error) {
            if (!mounted || !_isFetching) return;
            print('OpenAI API 오류: $error');
            setState(() {
              if (index < _isLoading.length) {
                _isLoading[index] = false;
              }
              if (index < _searchResults.length) {
                _searchResults[index] = _buildErrorSection(query, index);
              }
              if (index == _searchQueries.length - 1) {
                _isFetching = false;
              }
            });
          },
        );
      } else {
        OpenAIService.getL2WordDefinition(
          query,
          _fromLanguage,
          LanguageService.getLanguageNameInKorean(languages.first),
          (delta) {
            if (!mounted || !_isFetching) return;
            setState(() {
              result += delta;
              // 실시간으로 결과 업데이트
              if (index < _searchResults.length) {
                _searchResults[index] = _buildResultSection(
                  query,
                  result,
                  index,
                );
              }
            });
          },
          () {
            if (!mounted || !_isFetching) return;
            isCompleted = true;
            _handleSearchComplete(query, result, index);
          },
          (error) {
            if (!mounted || !_isFetching) return;
            print('OpenAI API 오류: $error');
            setState(() {
              if (index < _isLoading.length) {
                _isLoading[index] = false;
              }
              if (index < _searchResults.length) {
                _searchResults[index] = _buildErrorSection(query, index);
              }
              if (index == _searchQueries.length - 1) {
                _isFetching = false;
              }
            });
          },
        );
      }

      // 스트리밍 방식이므로 여기서는 즉시 반환
      return;
    } catch (e) {
      print('AI 응답 오류: $e');
      if (!mounted) return;

      setState(() {
        // 키보드 숨기기
        FocusScope.of(context).unfocus();

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
    _searchHistoryService.disposeCache();
    _searchController.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // --- UI Builder Methods ---

  Widget _buildInitialView(CustomColors colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PopScope(
            canPop: true,
            onPopInvokedWithResult: (didPop, result) async {
              if (!didPop) {
                FocusScope.of(context).unfocus();
              }
            },
            child: TextField(
              controller: _searchController,
              focusNode: _focusNode,
              style: TextStyle(fontSize: 28, color: colors.text),
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context).search_hint,
                hintStyle: TextStyle(
                  color: colors.textLight,
                  fontWeight: FontWeight.w400,
                ),
                border: InputBorder.none,
              ),
              onSubmitted: (_) => _startSearch(),
            ),
          ),
          Divider(thickness: 1, color: colors.dark),
        ],
      ),
    );
  }

  Widget _buildResultView(CustomColors colors) {
    return ListView(
      controller: _scrollController,
      padding: const EdgeInsets.only(left: 20, right: 20, top: 8, bottom: 96),
      children: _searchResults.asMap().entries.map((entry) {
        final index = entry.key;
        final widget = entry.value;
        //print('결과 위젯 $index: ${widget.runtimeType}');
        return widget;
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeService = context.watch<ThemeService>();
    final colors = themeService.colors;

    // 하단 바를 동적으로 변경
    Widget bottomBar;
    if (!_isSearching) {
      // 초기 검색 화면의 하단 바
      bottomBar = BottomAppBar(
        color: colors.light,
        height: 64,
        child: Row(
          children: [
            const Spacer(),
            ElevatedButton(
              onPressed: _startSearch,
              style: ElevatedButton.styleFrom(
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(2),
                backgroundColor: colors.background,
              ),
              child: Padding(
                padding: const EdgeInsets.only(left: 2),
                child: Icon(Icons.send, color: colors.text, size: 24),
              ),
            ),
          ],
        ),
      );
    } else if (_isFetching) {
      // 검색 중일 때의 "중단" 버튼
      print('검색 중 하단 바 표시');
      bottomBar = BottomAppBar(
        color: colors.background,
        child: Center(
          child: ElevatedButton.icon(
            icon: const Icon(Icons.stop_circle_outlined),
            label: Text(
              AppLocalizations.of(context).stop_search,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            onPressed: _stopFetching,
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.text,
              foregroundColor: colors.background,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
              color: colors.light,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: colors.dark),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController..clear(),
                    focusNode: _focusNode,
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context).additional_search,
                      hintStyle: TextStyle(
                        color: colors.text,
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),
                      border: InputBorder.none,
                      icon: Icon(Icons.search, color: colors.text),
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
                  icon: Icon(Icons.send, color: colors.text),
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

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: colors.background,
        appBar: AppBar(
          foregroundColor: colors.text,
          leading: IconButton(
            icon: Icon(Icons.close, color: colors.text),
            onPressed: () => {
              Navigator.pop(context),

              // 키보드 숨기기
              FocusScope.of(context).unfocus(),
            },
          ),
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 출발 언어 드롭다운
              SizedBox(
                width: 108,
                child: DropdownButtonHideUnderline(
                  child: DropdownButton2<String>(
                    isExpanded: true,
                    hint: Text(
                      AppLocalizations.of(context).language,
                      style: TextStyle(fontSize: 14, color: colors.textLight),
                    ),
                    items:
                        LanguageService.getLocalizedTranslationLanguages(
                              AppLocalizations.of(context),
                            )
                            .map(
                              (Map<String, String> item) =>
                                  DropdownMenuItem<String>(
                                    value: item['code']!,
                                    child: Text(
                                      item['name']!,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                        color: colors.text,
                                      ),
                                    ),
                                  ),
                            )
                            .toList(),
                    value: _fromLanguage,
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        // 같은 언어가 선택된 경우 자동으로 위치를 바꿈
                        if (newValue == _toLanguage) {
                          _updateLanguages(_toLanguage, _fromLanguage);
                        } else {
                          _updateLanguages(newValue, _toLanguage);
                        }
                      }
                    },
                    buttonStyleData: ButtonStyleData(
                      padding: const EdgeInsets.only(left: 12, right: 6),
                      height: 36,
                      width: 80,
                      decoration: BoxDecoration(
                        color: colors.extraLight,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: colors.dark, width: 1),
                      ),
                    ),
                    menuItemStyleData: const MenuItemStyleData(height: 48),
                    dropdownStyleData: DropdownStyleData(
                      decoration: BoxDecoration(
                        color: colors.background,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              // 화살표 버튼 (언어 위치 바꾸기)
              GestureDetector(
                onTap: () {
                  _updateLanguages(_toLanguage, _fromLanguage);
                },
                child: Container(
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios,
                    size: 12,
                    color: colors.text,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              // 도착 언어 드롭다운
              SizedBox(
                width: 108,
                child: DropdownButtonHideUnderline(
                  child: DropdownButton2<String>(
                    isExpanded: true,
                    hint: Text(
                      AppLocalizations.of(context).language,
                      style: TextStyle(fontSize: 14, color: colors.textLight),
                    ),
                    items:
                        LanguageService.getLocalizedTranslationLanguages(
                              AppLocalizations.of(context),
                            )
                            .map(
                              (Map<String, String> item) =>
                                  DropdownMenuItem<String>(
                                    value: item['code']!,
                                    child: Text(
                                      item['name']!,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                        color: colors.text,
                                      ),
                                    ),
                                  ),
                            )
                            .toList(),
                    value: _toLanguage,
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        // 같은 언어가 선택된 경우 자동으로 위치를 바꿈
                        if (newValue == _fromLanguage) {
                          _updateLanguages(_toLanguage, _fromLanguage);
                        } else {
                          _updateLanguages(_fromLanguage, newValue);
                        }
                      }
                    },
                    buttonStyleData: ButtonStyleData(
                      padding: const EdgeInsets.only(left: 12, right: 6),
                      height: 36,
                      width: 80,
                      decoration: BoxDecoration(
                        color: colors.extraLight,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: colors.dark, width: 1),
                      ),
                    ),
                    menuItemStyleData: const MenuItemStyleData(height: 48),
                    dropdownStyleData: DropdownStyleData(
                      decoration: BoxDecoration(
                        color: colors.background,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          elevation: 0,
        ),
        body: Stack(
          children: [
            _isSearching ? _buildResultView(colors) : _buildInitialView(colors),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: IgnorePointer(
                ignoring: false,
                child: Container(
                  padding: const EdgeInsets.only(top: 20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        const Color.fromARGB(0, 255, 255, 255), // 완전 투명 흰색
                        colors.light,
                      ],
                    ),
                  ),
                  child: bottomBar,
                ),
              ),
            ),
          ],
        ),
        // bottomNavigationBar: Padding(
        //   padding: MediaQuery.of(context).viewInsets,
        //   child: bottomBar,
        // ),
      ),
    );
  }

  Widget _buildLoadingSection(String query, int index) {
    final themeService = context.read<ThemeService>();
    final colors = themeService.colors;
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final appBarHeight = statusBarHeight + 56;

    return AutoScrollTag(
      key: Key(index.toString()),
      controller: _scrollController,
      index: index,
      child: SizedBox(
        height:
            MediaQuery.of(context).size.height -
            appBarHeight, // 화면 높이에서 상단 여백 제외
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
                    style: TextStyle(fontSize: 28, color: colors.text),
                    decoration: const InputDecoration(border: InputBorder.none),
                    readOnly: true,
                  ),
                ),
              ],
            ),
            Divider(thickness: 1, color: colors.dark),
            // 로딩 인디케이터 - 남은 공간을 모두 차지
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: colors.textLight),
                    const SizedBox(height: 16),
                    Text(
                      AppLocalizations.of(context).searching,
                      style: TextStyle(fontSize: 18, color: colors.textLight),
                    ),
                  ],
                ),
              ),
            ),
            Divider(thickness: 2, color: colors.divider),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorSection(String query, int index, {String? message}) {
    final themeService = context.read<ThemeService>();
    final colors = themeService.colors;
    final errorMessage = message ?? AppLocalizations.of(context).search_failed;

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
                  style: TextStyle(fontSize: 28, color: colors.text),
                  decoration: const InputDecoration(border: InputBorder.none),
                  readOnly: true,
                ),
              ),
            ],
          ),
          Divider(thickness: 1, color: colors.dark),
          // 에러 메시지
          Center(
            child: Text(
              errorMessage,
              style: TextStyle(
                fontSize: 16,
                color: colors.error,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Divider(thickness: 2, color: colors.divider),
        ],
      ),
    );
  }

  Widget _buildNoResultSection(String query, int index, String message) {
    final themeService = context.read<ThemeService>();
    final colors = themeService.colors;

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
                  style: TextStyle(fontSize: 28, color: colors.text),
                  decoration: const InputDecoration(border: InputBorder.none),
                  readOnly: true,
                ),
              ),
            ],
          ),
          Divider(thickness: 1, color: colors.dark),

          const SizedBox(height: 24),

          Center(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 16,
                height: 1.5,
                color: colors.error,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 64),

          Divider(thickness: 2, color: colors.divider),
        ],
      ),
    );
  }

  Widget _buildResultSection(String query, String aiResponse, int index) {
    final themeService = context.read<ThemeService>();
    final colors = themeService.colors;
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final appBarHeight = statusBarHeight + 56;

    // NDJSON 파싱 시도 (여러 JSON 객체를 하나로 합치기)
    Map<String, dynamic>? parsedData;
    try {
      // NDJSON 형식 파싱 (각 줄이 개별 JSON 객체)
      final lines = aiResponse.trim().split('\n');
      final Map<String, dynamic> combinedData = {};
      final Map<String, List<dynamic>> listData = {};

      for (final line in lines) {
        if (line.trim().isEmpty) continue;

        try {
          final jsonData = jsonDecode(line.trim());
          if (jsonData is Map<String, dynamic>) {
            // 각 키-값을 처리
            jsonData.forEach((key, value) {
              if (key == '사전적_뜻' || key == '대화_예시' || key == '비슷한_표현') {
                // 리스트로 처리해야 하는 키들은 별도로 수집
                if (!listData.containsKey(key)) {
                  listData[key] = [];
                }
                listData[key]!.add(value);
              } else {
                // 일반 키-값은 combinedData에 저장 (나중 값이 이전 값을 덮어씀)
                combinedData[key] = value;
              }
            });
          }
        } catch (e) {
          // 개별 라인 파싱 실패는 무시하고 계속 진행
          continue;
        }
      }

      // 리스트 데이터를 combinedData에 추가
      listData.forEach((key, value) {
        combinedData[key] = value;
      });

      // 병합된 데이터가 비어있지 않은 경우에만 사용
      if (combinedData.isNotEmpty) {
        parsedData = combinedData;
        //print('=== NDJSON 파싱 성공 (인덱스: $index) ===');
        //print('파싱된 데이터: $parsedData');
      } else {
        //print('=== NDJSON 파싱 실패 - 빈 데이터 (인덱스: $index) ===');
        return _buildFallbackResultSection(query, aiResponse, index);
      }
    } catch (e) {
      print('=== NDJSON 파싱 실패 (인덱스: $index) ===');
      print('파싱 오류: $e');
      return _buildFallbackResultSection(query, aiResponse, index);
    }

    // L1 형식인지 L2 형식인지 판별
    bool isL1Format = _isL1Format(parsedData!);

    if (isL1Format) {
      return _buildL1ResultSection(
        query,
        parsedData,
        index,
        colors,
        appBarHeight,
      );
    } else {
      return _buildL2ResultSection(
        query,
        parsedData,
        index,
        colors,
        appBarHeight,
      );
    }
  }

  bool _isL1Format(Map<String, dynamic> parsedData) {
    // L1 형식은 "번역" 키가 있고 그 안에 "번역단어"가 있는 구조
    if (parsedData['사전적_뜻'] != null) {
      if (parsedData['사전적_뜻'] is List) {
        for (var meaning in parsedData['사전적_뜻']) {
          if (meaning is Map<String, dynamic> &&
              meaning['번역'] != null &&
              meaning['번역'] is Map<String, dynamic> &&
              meaning['번역']['번역단어'] != null) {
            return true;
          }
        }
      } else if (parsedData['사전적_뜻'] is Map<String, dynamic> &&
          parsedData['사전적_뜻']['번역'] != null &&
          parsedData['사전적_뜻']['번역'] is Map<String, dynamic> &&
          parsedData['사전적_뜻']['번역']['번역단어'] != null) {
        return true;
      }
    }
    return false;
  }

  Widget _buildL1ResultSection(
    String query,
    Map<String, dynamic> parsedData,
    int index,
    CustomColors colors,
    double appBarHeight,
  ) {
    return AutoScrollTag(
      key: Key(index.toString()),
      controller: _scrollController,
      index: index,
      child: Container(
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height - appBarHeight,
        ),
        child: SingleChildScrollView(
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
                      style: TextStyle(fontSize: 28, color: colors.text),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                      ),
                      readOnly: true,
                    ),
                  ),
                ],
              ),
              Divider(thickness: 1, color: colors.dark),

              // 검색어(큰 글씨) - JSON에서 단어 필드 사용
              if (parsedData['단어'] != null) ...[
                SelectableText(
                  parsedData['단어'].toString(),
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: colors.text,
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // 사전적 뜻
              if (parsedData['사전적_뜻'] != null) ...[
                _buildSectionTitle(
                  AppLocalizations.of(context).dictionary_meaning,
                  colors,
                ),
                const SizedBox(height: 12),
                _buildDictionaryMeanings(parsedData['사전적_뜻'], colors),
                const SizedBox(height: 24),
              ],

              // 뉘앙스
              if (parsedData['뉘앙스'] != null) ...[
                _buildSectionTitle(AppLocalizations.of(context).nuance, colors),
                const SizedBox(height: 8),
                SelectableText(
                  parsedData['뉘앙스'].toString(),
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.5,
                    color: colors.text,
                  ),
                ),
                const SizedBox(height: 48),
              ],

              // 대화 예시
              if (parsedData['대화_예시'] != null) ...[
                _buildSectionTitle(
                  AppLocalizations.of(context).conversation_examples,
                  colors,
                ),
                const SizedBox(height: 12),
                _buildConversationExamples(
                  parsedData['대화_예시'],
                  _fromLanguage,
                  _toLanguage,
                  colors,
                ),
                const SizedBox(height: 24),
              ],

              // 비슷한 표현
              if (parsedData['비슷한_표현'] != null) ...[
                _buildSectionTitle(
                  AppLocalizations.of(context).similar_expressions,
                  colors,
                ),
                const SizedBox(height: 12),
                _buildSimilarExpressions(parsedData['비슷한_표현'], colors),
                const SizedBox(height: 48),
              ],

              Divider(thickness: 2, color: colors.divider),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildL2ResultSection(
    String query,
    Map<String, dynamic> parsedData,
    int index,
    CustomColors colors,
    double appBarHeight,
  ) {
    return AutoScrollTag(
      key: Key(index.toString()),
      controller: _scrollController,
      index: index,
      child: Container(
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height - appBarHeight,
        ),
        child: SingleChildScrollView(
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
                      style: TextStyle(fontSize: 28, color: colors.text),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                      ),
                      readOnly: true,
                    ),
                  ),
                ],
              ),
              Divider(thickness: 1, color: colors.dark),

              // 검색어(큰 글씨) - JSON에서 단어 필드 사용
              if (parsedData['단어'] != null) ...[
                SelectableText(
                  parsedData['단어'].toString(),
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: colors.text,
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // 사전적 뜻
              if (parsedData['사전적_뜻'] != null) ...[
                _buildSectionTitle(
                  AppLocalizations.of(context).dictionary_meaning,
                  colors,
                ),
                const SizedBox(height: 12),
                _buildDictionaryMeanings(parsedData['사전적_뜻'], colors),
                const SizedBox(height: 24),
              ],

              // 뉘앙스
              if (parsedData['뉘앙스'] != null) ...[
                _buildSectionTitle(AppLocalizations.of(context).nuance, colors),
                const SizedBox(height: 8),
                SelectableText(
                  parsedData['뉘앙스'].toString(),
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.5,
                    color: colors.text,
                  ),
                ),
                const SizedBox(height: 48),
              ],

              // 대화 예시
              if (parsedData['대화_예시'] != null) ...[
                _buildSectionTitle(
                  AppLocalizations.of(context).conversation_examples,
                  colors,
                ),
                const SizedBox(height: 12),
                _buildConversationExamples(
                  parsedData['대화_예시'],
                  _fromLanguage,
                  _toLanguage,
                  colors,
                ),
                const SizedBox(height: 24),
              ],

              // 비슷한 표현
              if (parsedData['비슷한_표현'] != null) ...[
                _buildSectionTitle(
                  AppLocalizations.of(context).similar_expressions,
                  colors,
                ),
                const SizedBox(height: 12),
                _buildSimilarExpressions(parsedData['비슷한_표현'], colors),
                const SizedBox(height: 48),
              ],

              Divider(thickness: 2, color: colors.divider),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFallbackResultSection(
    String query,
    String aiResponse,
    int index,
  ) {
    final themeService = context.read<ThemeService>();
    final colors = themeService.colors;
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final appBarHeight = statusBarHeight + 56;

    return AutoScrollTag(
      key: Key(index.toString()),
      controller: _scrollController,
      index: index,
      child: Container(
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height - appBarHeight,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: TextEditingController(text: query),
                      style: TextStyle(fontSize: 28, color: colors.text),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                      ),
                      readOnly: true,
                    ),
                  ),
                ],
              ),
              Divider(thickness: 1, color: colors.dark),
              Text(
                query,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: colors.text,
                ),
              ),
              const SizedBox(height: 20),
              GptMarkdown(
                aiResponse,
                style: TextStyle(fontSize: 16, height: 1.5, color: colors.text),
              ),
              const SizedBox(height: 4),
              Divider(thickness: 2, color: colors.divider),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, CustomColors colors) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: colors.text,
      ),
    );
  }

  Widget _buildDictionaryMeanings(dynamic meanings, CustomColors colors) {
    // NDJSON 형식에 맞게 처리
    if (meanings is Map<String, dynamic>) {
      // 단일 사전적 뜻 객체 처리
      return _buildSingleDictionaryMeaning(meanings, colors);
    } else if (meanings is List) {
      // 여러 사전적 뜻 객체 처리
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: meanings.map<Widget>((meaning) {
          if (meaning is Map<String, dynamic>) {
            return _buildSingleDictionaryMeaning(meaning, colors);
          }
          return const SizedBox.shrink();
        }).toList(),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildSingleDictionaryMeaning(
    Map<String, dynamic> meaning,
    CustomColors colors,
  ) {
    final partOfSpeech = meaning['품사']?.toString() ?? '';
    final definitionsRaw = meaning['번역'] ?? meaning['뜻'];

    // definitions 처리
    List<String> definitions = [];
    if (definitionsRaw is Map<String, dynamic>) {
      // L1 형식: {"번역": {"번역단어": "change", "뉘앙스": "..."}}
      final word = definitionsRaw['번역단어']?.toString() ?? '';
      final nuance = definitionsRaw['뉘앙스']?.toString() ?? '';
      if (word.isNotEmpty) {
        definitions.add(word);
        if (nuance.isNotEmpty) {
          definitions.add(nuance);
        }
      }
    } else if (definitionsRaw is List) {
      definitions = definitionsRaw.map((e) => e.toString()).toList();
    } else if (definitionsRaw != null) {
      definitions = [definitionsRaw.toString()];
    }

    if (definitions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (partOfSpeech.isNotEmpty) ...[
            Text(
              partOfSpeech,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: colors.highlight,
              ),
            ),
            const SizedBox(height: 8),
          ],
          ...definitions.map<Widget>(
            (def) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '• ',
                    style: TextStyle(fontSize: 16, color: colors.text),
                  ),
                  Expanded(
                    child: SelectableText(
                      def,
                      style: TextStyle(
                        fontSize: 20,
                        height: 1.4,
                        color: colors.text,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConversationExamples(
    dynamic examples,
    String fromLanguage,
    String toLanguage,
    CustomColors colors,
  ) {
    // NDJSON 형식에 맞게 처리
    if (examples is Map<String, dynamic>) {
      // 단일 대화 예시 객체 처리
      return _buildSingleConversationExample(
        examples,
        fromLanguage,
        toLanguage,
        colors,
        0,
      );
    } else if (examples is List) {
      // 여러 대화 예시 객체 처리
      return Column(
        children: examples.asMap().entries.map<Widget>((entry) {
          final index = entry.key;
          final example = entry.value;

          if (example is Map<String, dynamic>) {
            return _buildSingleConversationExample(
              example,
              fromLanguage,
              toLanguage,
              colors,
              index,
            );
          }
          return const SizedBox.shrink();
        }).toList(),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildSingleConversationExample(
    Map<String, dynamic> example,
    String fromLanguage,
    String toLanguage,
    CustomColors colors,
    int index,
  ) {
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
      final lists = example.values.whereType<List>().toList();
      if (lists.length >= 2) {
        l2Lines = lists[0];
        l1Lines = lists[1];
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${AppLocalizations.of(context).conversation} ${index + 1}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: colors.highlight,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colors.background,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: colors.dark),
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
                              color: colors.conversation_A,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              speaker,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: colors.text,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: SelectableText(
                              text,
                              style: TextStyle(
                                fontSize: 15,
                                color: colors.text,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  Divider(height: 16, color: colors.dark),
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
                              color: colors.conversation_B,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              speaker,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: colors.text,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: SelectableText(
                              text,
                              style: TextStyle(
                                fontSize: 15,
                                color: colors.text,
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
  }

  Widget _buildSimilarExpressions(dynamic expressions, CustomColors colors) {
    // NDJSON 형식에 맞게 처리
    if (expressions is Map<String, dynamic>) {
      // 단일 비슷한 표현 객체 처리
      return _buildSingleSimilarExpression(expressions, colors);
    } else if (expressions is List) {
      // 여러 비슷한 표현 객체 처리
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: expressions.map<Widget>((expr) {
          if (expr is Map<String, dynamic>) {
            return _buildSingleSimilarExpression(expr, colors);
          }
          return const SizedBox.shrink();
        }).toList(),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildSingleSimilarExpression(
    Map<String, dynamic> expr,
    CustomColors colors,
  ) {
    final word = expr['단어']?.toString() ?? '';
    final meaning = expr['뜻']?.toString() ?? '';

    if (word.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.dark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SelectableText(
            word,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: colors.text,
            ),
          ),
          if (meaning.isNotEmpty) ...[
            const SizedBox(height: 2),
            SelectableText(
              meaning,
              style: TextStyle(fontSize: 12, color: colors.text),
            ),
          ],
        ],
      ),
    );
  }

  void _handleSearchComplete(String query, String result, int index) async {
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

      // "No result" 응답 처리
      if (result.trim() == "No result") {
        if (index < _searchResults.length) {
          _searchResults[index] = _buildNoResultSection(
            query,
            index,
            AppLocalizations.of(context).no_search_result,
          );
          print('No result 응답 처리: 인덱스 $index');
        }
      } else {
        // 결과 업데이트
        if (index < _searchResults.length) {
          _searchResults[index] = _buildResultSection(query, result, index);
          print('결과 섹션 업데이트: 인덱스 $index');
        }
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

    // 검색 결과가 없는 경우 저장하지 않음
    if (result.trim() == "No result") {
      return;
    }

    // 검색 결과가 있는 경우 저장
    print('검색 카드 저장 시작');
    await _saveSearchCard(query, result, false);
    print('검색 카드 저장 완료');

    print('AI 응답 처리 완료: $query');
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
