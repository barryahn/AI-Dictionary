import 'package:flutter/material.dart';
import 'services/search_history_service.dart';
import 'services/theme_service.dart';
import 'models/unified_search_session.dart';
import 'search_result_screen.dart';
import 'l10n/app_localizations.dart';
import 'package:provider/provider.dart';

class SearchHistoryScreen extends StatefulWidget {
  const SearchHistoryScreen({super.key});

  static Future<void> clearAllHistory(BuildContext context) async {
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
              style: TextStyle(color: Colors.red),
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
            content: Text(AppLocalizations.of(context).all_history_deleted),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppLocalizations.of(context).delete_failed}: $e'),
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

  @override
  void initState() {
    super.initState();
    refresh();
  }

  Future<void> refresh() async {
    if (!mounted) return;
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

  Future<void> _deleteSession(int sessionId) async {
    try {
      await _searchHistoryService.deleteSearchSession(sessionId);
      await refresh(); // 삭제 후 새로고침
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).delete_history)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${AppLocalizations.of(context).delete_failed}: $e'),
        ),
      );
    }
  }

  Future<void> _clearAllHistory() async {
    await SearchHistoryScreen.clearAllHistory(context);
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
  Widget build(BuildContext context) {
    return Consumer<ThemeService>(
      builder: (context, themeService, child) {
        final currentTheme = themeService.currentTheme;

        return Scaffold(
          backgroundColor: currentTheme.background,
          appBar: AppBar(
            backgroundColor: currentTheme.background,
            elevation: 0,
            iconTheme: IconThemeData(color: currentTheme.text),
            title: Text(
              AppLocalizations.of(context).search_history,
              style: TextStyle(
                color: currentTheme.text,
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              if (_searchSessions.isNotEmpty)
                IconButton(
                  icon: Icon(Icons.delete_sweep, color: Colors.red[400]),
                  onPressed: _clearAllHistory,
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
                    color: currentTheme.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          AppLocalizations.of(
                            context,
                          ).get('search_history_paused'),
                          style: TextStyle(
                            color: currentTheme.error,
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
                        child: CircularProgressIndicator(
                          color: currentTheme.textLight,
                        ),
                      )
                    : _searchSessions.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.history,
                              size: 64,
                              color: currentTheme.textLight,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              AppLocalizations.of(context).no_history,
                              style: TextStyle(
                                fontSize: 18,
                                color: currentTheme.textLight,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              AppLocalizations.of(context).history_description,
                              style: TextStyle(
                                fontSize: 14,
                                color: currentTheme.textLight,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _searchSessions.length,
                        itemBuilder: (context, index) {
                          final session = _searchSessions[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            elevation: 2,
                            color: currentTheme.extraLight,
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16),
                              title: session.cards.length == 1
                                  ? Text(
                                      session.cards.first.query,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: currentTheme.text,
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
                                              color: currentTheme.text,
                                            ),
                                          ),
                                          TextSpan(
                                            text:
                                                ' ${AppLocalizations.of(context).and_others} ${session.cards.length - 1}${AppLocalizations.of(context).items}',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: currentTheme.text,
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
                                      color: currentTheme.textLight,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    session.cards
                                        .map((card) => card.query)
                                        .join(', '),
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: currentTheme.highlight,
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
                                      color: currentTheme.accent,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      '${session.cards.length}개',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: currentTheme.text,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  IconButton(
                                    icon: Icon(
                                      Icons.delete,
                                      color: Colors.red[400],
                                      size: 20,
                                    ),
                                    onPressed: () =>
                                        _deleteSession(session.id!),
                                  ),
                                ],
                              ),
                              onTap: () {
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
            ],
          ),
        );
      },
    );
  }
}
