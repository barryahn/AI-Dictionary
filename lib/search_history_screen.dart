import 'package:flutter/material.dart';
import 'services/search_history_service.dart';
import 'models/unified_search_session.dart';
import 'search_result_screen.dart';
import 'theme/beige_colors.dart';
import 'l10n/app_localizations.dart';

class SearchHistoryScreen extends StatefulWidget {
  const SearchHistoryScreen({super.key});

  @override
  SearchHistoryScreenState createState() => SearchHistoryScreenState();
}

class SearchHistoryScreenState extends State<SearchHistoryScreen> {
  final SearchHistoryService _searchHistoryService = SearchHistoryService();
  List<UnifiedSearchSession> _searchSessions = [];
  bool _isLoading = true;

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
      final sessions = await _searchHistoryService.getAllSearchSessions();
      if (!mounted) return;
      setState(() {
        _searchSessions = sessions;
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
        await _searchHistoryService.clearAllSearchHistory();
        await refresh(); // 전체 삭제 후 새로고침
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
    return Scaffold(
      backgroundColor: BeigeColors.background,
      appBar: AppBar(
        backgroundColor: BeigeColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: BeigeColors.text),
        title: Text(
          AppLocalizations.of(context).search_history,
          style: TextStyle(
            color: BeigeColors.text,
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
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(color: BeigeColors.textLight),
            )
          : _searchSessions.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 64, color: BeigeColors.textLight),
                  const SizedBox(height: 16),
                  Text(
                    AppLocalizations.of(context).no_history,
                    style: TextStyle(
                      fontSize: 18,
                      color: BeigeColors.textLight,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppLocalizations.of(context).history_description,
                    style: TextStyle(
                      fontSize: 14,
                      color: BeigeColors.textLight,
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
                  color: BeigeColors.extraLight,
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    title: session.cards.length == 1
                        ? Text(
                            session.cards.first.query,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: BeigeColors.text,
                            ),
                          )
                        : RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: session.cards.first.query,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: BeigeColors.text,
                                  ),
                                ),
                                TextSpan(
                                  text:
                                      ' ${AppLocalizations.of(context).and_others} ${session.cards.length - 1}${AppLocalizations.of(context).items}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: BeigeColors.text,
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
                            color: BeigeColors.textLight,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          session.cards.map((card) => card.query).join(', '),
                          style: TextStyle(
                            fontSize: 14,
                            color: BeigeColors.highlight,
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
                            color: BeigeColors.accent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${session.cards.length}개',
                            style: TextStyle(
                              fontSize: 12,
                              color: BeigeColors.text,
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
                          onPressed: () => _deleteSession(session.id!),
                        ),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              SearchResultScreen(searchSession: session),
                        ),
                      ).then((_) => refresh());
                    },
                  ),
                );
              },
            ),
    );
  }
}
