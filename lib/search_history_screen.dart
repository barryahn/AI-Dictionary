import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/search_history_service.dart';
import 'services/theme_service.dart';
import 'services/auth_service.dart';
import 'services/pro_service.dart';
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
  bool _isLoadingMore = false;
  bool _hasMore = true;
  final int _pageSize = 10;
  bool _isPauseHistoryEnabled = false; // 일시 중지 상태 확인용
  final ScrollController _scrollController = ScrollController();
  AuthService? _authService;
  VoidCallback? _authListener;

  @override
  void initState() {
    super.initState();
    refresh();
    _scrollController.addListener(_onScroll);
    // 인증 상태 변경을 구독하여 로그인/로그아웃/계정 전환 시 즉시 새로고침
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _authService = context.read<AuthService>();
      _authListener = () {
        if (mounted) refresh();
      };
      _authService?.addListener(_authListener!);
    });
  }

  Future<void> refresh() async {
    if (!mounted) return;

    setState(() {
      // 키보드 숨기기
      FocusScope.of(context).unfocus();
      _isLoading = true;
      _isLoadingMore = false;
      _hasMore = true;
      _searchSessions = [];
    });

    try {
      // 검색 기록 일시 중지 상태 확인
      final isPaused = await SearchHistoryService.isPauseHistoryEnabled();
      final sessions = await _searchHistoryService.getSearchSessionsPage(
        limit: _pageSize,
      );
      if (!mounted) return;
      setState(() {
        _searchSessions = sessions;
        _isPauseHistoryEnabled = isPaused;
        _isLoading = false;
        _hasMore = sessions.length >= _pageSize;
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

  void _onScroll() {
    if (!_scrollController.hasClients ||
        _isLoading ||
        _isLoadingMore ||
        !_hasMore) {
      return;
    }
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (!mounted || _isLoadingMore || !_hasMore) return;
    setState(() {
      _isLoadingMore = true;
    });

    try {
      final DateTime? startAfter = _searchSessions.isNotEmpty
          ? _searchSessions.last.updatedAt
          : null;

      final more = await _searchHistoryService.getSearchSessionsPage(
        limit: _pageSize,
        startAfter: startAfter,
      );

      if (!mounted) return;
      setState(() {
        _searchSessions.addAll(more);
        _hasMore = more.length >= _pageSize;
        _isLoadingMore = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingMore = false;
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
    if (_authListener != null && _authService != null) {
      _authService!.removeListener(_authListener!);
    }
    _scrollController.removeListener(_onScroll);
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
          Consumer<ProService>(
            builder: (context, pro, _) {
              if (pro.isPro) {
                return const SizedBox.shrink();
              }
              return Tooltip(
                margin: const EdgeInsets.only(top: 2),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                message: AppLocalizations.of(
                  context,
                ).free_version_history_limit_tooltip,
                triggerMode: TooltipTriggerMode.tap,
                showDuration: const Duration(seconds: 2),
                waitDuration: const Duration(milliseconds: 100),
                preferBelow: false,
                verticalOffset: 12,
                decoration: BoxDecoration(
                  color: colors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                textStyle: TextStyle(
                  color: colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: Icon(
                    Icons.info_outline,
                    color: colors.primary,
                    size: 22,
                  ),
                ),
              );
            },
          ),
          if (_searchSessions.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(right: 8),
              child: IconButton(
                icon: Icon(Icons.delete_sweep, color: colors.warning),
                onPressed: () => _clearAllHistory(colors),
              ),
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
                      itemCount:
                          _searchSessions.length + (_isLoadingMore ? 3 : 0),
                      itemBuilder: (context, index) {
                        if (index >= _searchSessions.length) {
                          return _buildSkeletonItem(colors);
                        }
                        final session = _searchSessions[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          elevation: 2,
                          color: colors.white,
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            title: session.cards.length == 1
                                ? Text(
                                    session.cards.first.query,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
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
                                            fontWeight: FontWeight.w600,
                                            color: colors.text,
                                          ),
                                        ),
                                        TextSpan(
                                          text:
                                              ' ${AppLocalizations.of(context).and_others} ${session.cards.length - 1}${AppLocalizations.of(context).items}',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: colors.primary,
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
                                  _formatDateTime(session.updatedAt),
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
                                    color: colors.textLight,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                /* Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  child: Text(
                                    '${session.cards.length}개',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: colors.secondary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8), */
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

  Widget _buildSkeletonItem(CustomColors colors) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      color: colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 16,
              width: 180,
              decoration: BoxDecoration(
                color: colors.textLight.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 12,
              width: 120,
              decoration: BoxDecoration(
                color: colors.textLight.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              height: 14,
              width: double.infinity,
              decoration: BoxDecoration(
                color: colors.textLight.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 6),
            Container(
              height: 14,
              width: double.infinity,
              decoration: BoxDecoration(
                color: colors.textLight.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
