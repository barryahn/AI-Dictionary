import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/search_history_service.dart';
import 'services/language_service.dart';
import 'services/auth_service.dart';
import 'services/theme_service.dart';
import 'theme/app_theme.dart';
import 'login_screen.dart';
import 'l10n/app_localizations.dart';
import 'search_history_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final SearchHistoryService _searchHistoryService = SearchHistoryService();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeLanguage();
  }

  Future<void> _initializeLanguage() async {
    await LanguageService.initialize();
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final themeService = context.watch<ThemeService>();
    final colors = themeService.colors;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        title: Text(
          loc.get('profile_title'),
          style: TextStyle(color: colors.text, fontWeight: FontWeight.bold),
        ),
        iconTheme: IconThemeData(color: colors.text),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: colors.textLight))
          : SingleChildScrollView(
              child: Column(
                children: [
                  // 프로필 헤더
                  _buildProfileHeader(loc, colors),
                  const SizedBox(height: 20),
                  // 설정 메뉴
                  _buildSettingsMenu(loc, colors),
                ],
              ),
            ),
    );
  }

  Widget _buildProfileHeader(AppLocalizations loc, CustomColors colors) {
    return Consumer<AuthService>(
      builder: (context, authService, child) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
          decoration: BoxDecoration(color: colors.background),
          child: Column(
            children: [
              const SizedBox(height: 20),
              // 프로필 이미지
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: colors.accent,
                  shape: BoxShape.circle,
                ),
                child:
                    authService.userPhotoUrl != null &&
                        authService.userPhotoUrl!.isNotEmpty
                    ? ClipOval(
                        child: Image.network(
                          authService.userPhotoUrl!,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.person,
                              size: 40,
                              color: colors.text,
                            );
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value:
                                    loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                    : null,
                                color: colors.text,
                              ),
                            );
                          },
                        ),
                      )
                    : Icon(Icons.person, size: 40, color: colors.text),
              ),
              const SizedBox(height: 16),
              // 사용자 이름
              Text(
                authService.isLoggedIn
                    ? (authService.userName ?? loc.get('ai_dictionary_user'))
                    : loc.get('guest_user'),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: colors.text,
                ),
              ),
              const SizedBox(height: 4),
              // 사용자 이메일
              Text(
                authService.isLoggedIn
                    ? (authService.userEmail ?? 'user@example.com')
                    : loc.get('guest_description'),
                style: TextStyle(fontSize: 14, color: colors.textLight),
              ),
              if (!authService.isLoggedIn) ...[
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    _showLoginDialog(loc);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.accent,
                    foregroundColor: colors.text,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(loc.get('login')),
                ),
              ],
              /*
              const SizedBox(height: 16)
              // 로그인/편집 버튼
              if (authService.isLoggedIn)
                OutlinedButton(
                  onPressed: () {
                    _showEditProfileDialog(loc);
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colors.text,
                    side: BorderSide(color: colors.dark),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(loc.get('edit_profile')),
                )
              else
                ElevatedButton(
                  onPressed: () {
                    _showLoginDialog(loc);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.accent,
                    foregroundColor: colors.text,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(loc.get('login')),
                ), */
            ],
          ),
        );
      },
    );
  }

  Widget _buildSettingsMenu(AppLocalizations loc, CustomColors colors) {
    return Consumer<AuthService>(
      builder: (context, authService, child) {
        return Container(
          margin: const EdgeInsets.only(bottom: 20),
          child: Column(
            children: [
              _buildMenuHeader(title: loc.get('system'), colors: colors),

              _buildMenuItem(
                icon: Icons.language,
                title: loc.get('app_language_setting'),
                subtitle: LanguageService.currentLanguageName,
                onTap: () => _showLanguageSettings(loc),
                colors: colors,
              ),

              /* _buildMenuItem(
                icon: Icons.dark_mode,
                title: loc.get('dark_mode'),
                subtitle: loc.get('dark_mode_description'),
                onTap: () => _toggleDarkMode(loc),
              ), */
              _buildMenuItem(
                icon: Icons.storage,
                title: loc.get('data'), // 'storage' -> 'data'로 변경
                subtitle: loc.get('data_description'),
                onTap: () => _openDataSettingsScreen(loc), // 새 창으로 이동
                colors: colors,
              ),

              _buildMenuHeader(title: loc.get('theme'), colors: colors),

              _buildThemeItems(loc, colors),

              _buildMenuHeader(title: loc.get('information'), colors: colors),

              _buildMenuItem(
                icon: Icons.help,
                title: loc.get('help'),
                subtitle: loc.get('help_description'),
                onTap: () => _showHelp(loc),
                colors: colors,
              ),

              _buildMenuItem(
                icon: Icons.info,
                title: loc.get('app_info'),
                subtitle: loc.get('app_version'),
                onTap: () {},
                colors: colors,
              ),
              if (authService.isLoggedIn) ...[
                const SizedBox(height: 20),
                _buildMenuItem(
                  icon: Icons.logout,
                  title: loc.get('logout'),
                  subtitle: loc.get('logout_description'),
                  onTap: () => _showLogoutDialog(loc, colors),
                  textColor: colors.warning,
                  colors: colors,
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildMenuHeader({
    required String title,
    required CustomColors colors,
  }) {
    return Container(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.only(left: 24, top: 40, bottom: 10),
      child: Text(
        title,
        style: TextStyle(color: colors.textLight, fontWeight: FontWeight.bold),
        textAlign: TextAlign.left,
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? textColor,
    required CustomColors colors,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Icon(icon, color: textColor ?? colors.text),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: textColor ?? colors.text,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: textColor?.withValues(alpha: 0.7) ?? colors.text,
          fontSize: 12,
        ),
      ),
      trailing: Icon(Icons.chevron_right, color: colors.textLight),
      onTap: onTap,
    );
  }

  Widget _buildThemeItems(AppLocalizations loc, CustomColors colors) {
    return Container(
      padding: const EdgeInsets.only(left: 24, right: 24, top: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: _buildThemeItem(
              loc,
              Icons.favorite,
              loc.get('recommended_theme'),
              'recommended',
              colors,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildThemeItem(
              loc,
              Icons.light_mode,
              loc.get('light_theme'),
              'light',
              colors,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildThemeItem(
              loc,
              Icons.dark_mode,
              loc.get('dark_theme'),
              'dark',
              colors,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeItem(
    AppLocalizations loc,
    IconData icon,
    String title,
    String themeKey,
    CustomColors colors,
  ) {
    final themeService = context.watch<ThemeService>();
    final isSelected = themeService.currentThemeId == themeKey;
    return GestureDetector(
      onTap: () async {
        await themeService.setTheme(themeKey);
        setState(() {});
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.only(left: 30, right: 30),
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected ? colors.accent : colors.primary,
                width: isSelected ? 2 : 1,
              ),
              color: isSelected ? colors.light : Colors.transparent,
            ),
            child: Icon(icon, color: colors.text, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(color: colors.text, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(CustomColors colors) {
    return Divider(
      height: 1,
      indent: 56,
      endIndent: 20,
      color: colors.dark.withValues(alpha: 0.4),
    );
  }

  // 다이얼로그 및 설정 메서드들
  void _showEditProfileDialog(AppLocalizations loc) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(loc.get('edit_profile')),
        content: Text(loc.get('feature_coming_soon')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(loc.get('confirm')),
          ),
        ],
      ),
    );
  }

  void _showLanguageSettings(AppLocalizations loc) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(loc.get('app_language_setting')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: LanguageService.supportedLanguages.map((language) {
            final isSelected =
                LanguageService.currentLanguage == language['code'];
            return ListTile(
              title: Text(language['name']!),
              trailing: isSelected
                  ? const Icon(Icons.check, color: Colors.blue)
                  : null,
              onTap: () async {
                // 포커스 해제하여 키보드가 나타나지 않도록 함
                FocusScope.of(context).unfocus();
                await LanguageService.setLanguage(language['code']!);
                setState(() {}); // UI 업데이트
                Navigator.pop(context);
                _showLanguageChangedDialog(language['name']!);
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(loc.get('cancel')),
          ),
        ],
      ),
    );
  }

  void _showLanguageChangedDialog(String languageName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          AppLocalizations.of(
            context,
          ).get('language_changed').replaceAll('{language}', languageName),
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context).get('confirm')),
          ),
        ],
      ),
    );
  }

  void _showNotificationSettings(AppLocalizations loc) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(loc.get('notification_setting')),
        content: Text(loc.get('feature_coming_soon')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(loc.get('confirm')),
          ),
        ],
      ),
    );
  }

  void _toggleDarkMode(AppLocalizations loc) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(loc.get('dark_mode')),
        content: Text(loc.get('feature_coming_soon')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(loc.get('confirm')),
          ),
        ],
      ),
    );
  }

  // 기존 _showStorageSettings 제거 및 아래 함수 추가
  void _openDataSettingsScreen(AppLocalizations loc) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DataSettingsScreen(loc: loc)),
    );
  }

  void _showHelp(AppLocalizations loc) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(loc.get('help')),
        content: Text(loc.get('feature_coming_soon')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(loc.get('confirm')),
          ),
        ],
      ),
    );
  }

  /* void _showAppInfo(AppLocalizations loc) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(loc.get('app_info')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(loc.get('app_name')),
            const SizedBox(height: 8),
            Text('${loc.get('version')}: 1.0.0'),
            const SizedBox(height: 8),
            Text('${loc.get('developer')}: ${loc.get('ai_dictionary_team')}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(loc.get('confirm')),
          ),
        ],
      ),
    );
  } */

  void _showLogoutDialog(AppLocalizations loc, CustomColors colors) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(loc.get('logout')),
        content: Text(loc.get('logout_confirm')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              loc.get('cancel'),
              style: TextStyle(color: colors.text),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              // 로그아웃 로직
              final authService = Provider.of<AuthService>(
                context,
                listen: false,
              );
              await authService.logout();

              // 로그아웃 완료 메시지
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      loc.get('logout_success'),
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: colors.snackbar_text,
                      ),
                    ),
                    backgroundColor: colors.success,
                  ),
                );
              }
            },
            child: Text(
              loc.get('logout'),
              style: TextStyle(color: colors.warning),
            ),
          ),
        ],
      ),
    );
  }

  void _showLoginDialog(AppLocalizations loc) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }
}

class DataSettingsScreen extends StatefulWidget {
  final AppLocalizations loc;
  const DataSettingsScreen({super.key, required this.loc});

  @override
  State<DataSettingsScreen> createState() => _DataSettingsScreenState();
}

class _DataSettingsScreenState extends State<DataSettingsScreen> {
  bool _isPauseHistoryEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadPauseHistoryState();
  }

  // 검색 기록 일시 중지 상태 로드
  Future<void> _loadPauseHistoryState() async {
    final isEnabled = await SearchHistoryService.isPauseHistoryEnabled();
    setState(() {
      _isPauseHistoryEnabled = isEnabled;
    });
  }

  // 검색 기록 일시 중지 상태 변경
  Future<void> _setPauseHistoryState(bool enabled) async {
    await SearchHistoryService.setPauseHistoryEnabled(enabled);
    setState(() {
      _isPauseHistoryEnabled = enabled;
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final themeService = context.watch<ThemeService>();
    final colors = themeService.colors;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.get('data')),
        backgroundColor: colors.background,
        iconTheme: IconThemeData(color: colors.text),
        elevation: 0,
      ),
      backgroundColor: colors.background,
      body: Column(
        children: [
          ListTile(
            title: Text(
              loc.get('pause_search_history'),
              style: TextStyle(color: colors.text, fontWeight: FontWeight.w500),
            ),
            subtitle: Text(
              loc.get('pause_search_history_description'),
              style: TextStyle(color: colors.text, fontSize: 12),
            ),
            trailing: Switch(
              value: _isPauseHistoryEnabled,
              onChanged: _setPauseHistoryState,
              activeColor: colors.text,
            ),
            onTap: () {
              _setPauseHistoryState(!_isPauseHistoryEnabled);
            },
          ),
          _buildMenuItem(
            title: loc.get('delete_all_history'),
            onTap: () => {SearchHistoryScreen.clearAllHistory(context, colors)},
            colors: colors,
          ),
          _buildMenuItem(
            title: loc.get('delete_account'),
            onTap: () => _showDeleteAccountDialog(loc, colors),
            colors: colors,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required String title,
    required VoidCallback onTap,
    required CustomColors colors,
  }) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(color: colors.error, fontWeight: FontWeight.w500),
      ),
      onTap: onTap,
    );
  }

  void _showDeleteAccountDialog(AppLocalizations loc, CustomColors colors) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(loc.get('delete_account')),
        content: Text(
          loc.get('delete_account_confirm'),
          style: TextStyle(color: colors.warning, fontWeight: FontWeight.w500),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              loc.get('cancel'),
              style: TextStyle(color: colors.text),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              // 계정 삭제 로직
              final authService = Provider.of<AuthService>(
                context,
                listen: false,
              );

              try {
                final success = await authService.deleteAccount();

                if (success && mounted) {
                  // 계정 삭제 성공 메시지
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        loc.get('delete_account_success'),
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: colors.snackbar_text,
                        ),
                      ),
                      backgroundColor: colors.success,
                    ),
                  );

                  // 데이터 설정 화면 닫기
                  Navigator.of(context).pop();
                } else if (mounted) {
                  // 계정 삭제 실패 메시지
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        loc.get('delete_account_failed'),
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: colors.snackbar_text,
                        ),
                      ),
                      backgroundColor: colors.error,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '${loc.get('delete_account_failed')}: $e',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: colors.snackbar_text,
                        ),
                      ),
                      backgroundColor: colors.error,
                    ),
                  );
                }
              }
            },
            child: Text(
              loc.get('delete'),
              style: TextStyle(color: colors.error),
            ),
          ),
        ],
      ),
    );
  }
}
