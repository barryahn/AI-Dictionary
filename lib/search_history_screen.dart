import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/search_history_service.dart';
import 'services/theme_service.dart';
import 'models/unified_search_session.dart';
import 'search_result_screen.dart';
import 'theme/app_theme.dart';
import 'l10n/app_localizations.dart';

class SearchHistoryScreen extends StatefulWidget {
  const SearchHistoryScreen({super.key});

  static Future<void> clearAllHistory(
    BuildContext context,
    CustomColors colors,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context).clear_all_history),
        content: Text(AppLocalizations.of(context).clear_all_confirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(AppLocalizations.of(context).cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              AppLocalizations.of(context).delete,
              style: TextStyle(color: colors.warning),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final searchHistoryService = SearchHistoryService();
        await searchHistoryService.clearAllSearchHistory();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context).all_history_deleted,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: colors.snackbar_text,
              ),
            ),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${AppLocalizations.of(context).delete_failed}: $e',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: colors.snackbar_text,
              ),
            ),
          ),
        );
      }
    }
  }

  @override
  SearchHistoryScreenState createState() => SearchHistoryScreenState();
}

class SearchHistoryScreenState extends State<SearchHistoryScreen> {
  final SearchHistoryService _searchHistoryService = SearchHistoryService();
  List<UnifiedSearchSession> _searchSessions = [];
  bool _isLoading = true;
  bool _isPauseHistoryEnabled = false; // 일시 중지 상태 확인용
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    refresh();
  }

  Future<void> refresh() async {
    if (!mounted) return;

    // 현재 스크롤 위치 저장
    final currentScrollOffset = _scrollController.hasClients
        ? _scrollController.offset
        : 0.0;

    setState(() {
      _isLoading = true;
    });

    try {
      // 검색 기록 일시 중지 상태 확인
      final isPaused = await SearchHistoryService.isPauseHistoryEnabled();
      final sessions = await _searchHistoryService.getAllSearchSessions();
      if (!mounted) return;
      setState(() {
        _searchSessions = sessions;
        _isPauseHistoryEnabled = isPaused;
        _isLoading = false;
      });

      // 데이터 로드 완료 후 이전 스크롤 위치로 복원
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients && currentScrollOffset > 0) {
          _scrollController.jumpTo(currentScrollOffset);
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${AppLocalizations.of(context).delete_failed}: $e'),
        ),
      );
    }
  }

  Future<void> _deleteSession(dynamic sessionId, CustomColors colors) async {
    try {
      await _searchHistoryService.deleteSearchSession(sessionId);
      await refresh(); // 삭제 후 새로고침
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context).delete_history,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: colors.snackbar_text,
            ),
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${AppLocalizations.of(context).delete_failed}: $e',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: colors.snackbar_text,
            ),
          ),
        ),
      );
    }
  }

  Future<void> _clearAllHistory(CustomColors colors) async {
    await SearchHistoryScreen.clearAllHistory(context, colors);
    await refresh(); // 전체 삭제 후 새로고침
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return AppLocalizations.of(
        context,
      ).getWithParams('days_ago', {'days': difference.inDays.toString()});
    } else if (difference.inHours > 0) {
      return AppLocalizations.of(
        context,
      ).getWithParams('hours_ago', {'hours': difference.inHours.toString()});
    } else if (difference.inMinutes > 0) {
      return AppLocalizations.of(context).getWithParams('minutes_ago', {
        'minutes': difference.inMinutes.toString(),
      });
    } else {
      return AppLocalizations.of(context).just_now;
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeService = context.watch<ThemeService>();
    final colors = themeService.colors;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        iconTheme: IconThemeData(color: colors.text),
        title: Text(
          AppLocalizations.of(context).search_history,
          style: TextStyle(color: colors.text, fontWeight: FontWeight.bold),
        ),
        actions: [
          if (_searchSessions.isNotEmpty)
            IconButton(
              icon: Icon(Icons.delete_sweep, color: colors.warning),
              onPressed: () => _clearAllHistory(colors),
            ),
        ],
      ),
      body: Column(
        children: [
          // 검색 기록 일시 중지 상태 알림
          if (_isPauseHistoryEnabled)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(top: 10, left: 16, right: 16),
              decoration: BoxDecoration(
                color: colors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      AppLocalizations.of(context).get('search_history_paused'),
                      style: TextStyle(
                        color: colors.error,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          // 기존 body 내용
          Expanded(
            child: _isLoading
                ? Center(
                    child: CircularProgressIndicator(color: colors.textLight),
                  )
                : _searchSessions.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.history, size: 64, color: colors.textLight),
                        const SizedBox(height: 16),
                        Text(
                          AppLocalizations.of(context).no_history,
                          style: TextStyle(
                            fontSize: 18,
                            color: colors.textLight,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          AppLocalizations.of(context).history_description,
                          style: TextStyle(
                            fontSize: 14,
                            color: colors.textLight,
                          ),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: refresh,
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: _searchSessions.length,
                      itemBuilder: (context, index) {
                        final session = _searchSessions[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          elevation: 2,
                          color: colors.extraLight,
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            title: session.cards.length == 1
                                ? Text(
                                    session.cards.first.query,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: colors.text,
                                    ),
                                  )
                                : RichText(
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                          text: session.cards.first.query,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: colors.text,
                                          ),
                                        ),
                                        TextSpan(
                                          text:
                                              ' ${AppLocalizations.of(context).and_others} ${session.cards.length - 1}${AppLocalizations.of(context).items}',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: colors.text,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text(
                                  _formatDateTime(session.createdAt),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: colors.textLight,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  session.cards
                                      .map((card) => card.query)
                                      .join(', '),
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: colors.highlight,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: colors.accent,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '${session.cards.length}개',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: colors.text,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: Icon(
                                    Icons.delete,
                                    color: colors.warning,
                                    size: 20,
                                  ),
                                  onPressed: () =>
                                      _deleteSession(session.id!, colors),
                                ),
                              ],
                            ),
                            onTap: () {
                              // 포커스 해제하여 키보드가 나타나지 않도록 함
                              FocusScope.of(context).unfocus();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SearchResultScreen(
                                    searchSession: session,
                                  ),
                                ),
                              ).then((_) => refresh());
                            },
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
