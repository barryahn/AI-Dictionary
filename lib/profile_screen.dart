import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/search_history_service.dart';
import 'services/language_service.dart';
import 'services/auth_service.dart';
import 'services/theme_service.dart';
import 'login_screen.dart';
import 'theme/app_colors.dart';
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
    return Consumer<ThemeService>(
      builder: (context, themeService, child) {
        final currentTheme = themeService.currentTheme;

        return Scaffold(
          backgroundColor: currentTheme.background,
          appBar: AppBar(
            backgroundColor: currentTheme.background,
            elevation: 0,
            title: Text(
              loc.get('profile_title'),
              style: TextStyle(
                color: currentTheme.text,
                fontWeight: FontWeight.bold,
              ),
            ),
            iconTheme: IconThemeData(color: currentTheme.text),
          ),
          body: _isLoading
              ? Center(
                  child: CircularProgressIndicator(
                    color: currentTheme.textLight,
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      // 프로필 헤더
                      _buildProfileHeader(loc),
                      const SizedBox(height: 20),
                      // 설정 메뉴
                      _buildSettingsMenu(loc),
                    ],
                  ),
                ),
        );
      },
    );
  }

  Widget _buildProfileHeader(AppLocalizations loc) {
    return Consumer<AuthService>(
      builder: (context, authService, child) {
        return Consumer<ThemeService>(
          builder: (context, themeService, child) {
            final currentTheme = themeService.currentTheme;

            return Container(
              width: double.infinity,
              padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
              decoration: BoxDecoration(color: currentTheme.background),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // 프로필 이미지
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: currentTheme.accent,
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
                                  color: currentTheme.text,
                                );
                              },
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Center(
                                      child: CircularProgressIndicator(
                                        value:
                                            loadingProgress
                                                    .expectedTotalBytes !=
                                                null
                                            ? loadingProgress
                                                      .cumulativeBytesLoaded /
                                                  loadingProgress
                                                      .expectedTotalBytes!
                                            : null,
                                        color: currentTheme.text,
                                      ),
                                    );
                                  },
                            ),
                          )
                        : Icon(
                            Icons.person,
                            size: 40,
                            color: currentTheme.text,
                          ),
                  ),
                  const SizedBox(height: 16),
                  // 사용자 이름
                  Text(
                    authService.isLoggedIn
                        ? (authService.userName ??
                              loc.get('ai_dictionary_user'))
                        : loc.get('guest_user'),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: currentTheme.text,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // 사용자 이메일
                  Text(
                    authService.isLoggedIn
                        ? (authService.userEmail ?? 'user@example.com')
                        : loc.get('guest_description'),
                    style: TextStyle(
                      fontSize: 14,
                      color: currentTheme.textLight,
                    ),
                  ),
                  if (!authService.isLoggedIn) ...[
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        _showLoginDialog(loc);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: currentTheme.accent,
                        foregroundColor: currentTheme.text,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Text(loc.get('login')),
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSettingsMenu(AppLocalizations loc) {
    return Consumer<AuthService>(
      builder: (context, authService, child) {
        return Consumer<ThemeService>(
          builder: (context, themeService, child) {
            final currentTheme = themeService.currentTheme;

            return Container(
              margin: const EdgeInsets.only(bottom: 20),
              child: Column(
                children: [
                  _buildMenuHeader(title: loc.get('system')),

                  _buildMenuItem(
                    icon: Icons.language,
                    title: loc.get('app_language_setting'),
                    subtitle: LanguageService.currentLanguageName,
                    onTap: () => _showLanguageSettings(loc),
                  ),

                  _buildMenuItem(
                    icon: Icons.storage,
                    title: loc.get('data'),
                    subtitle: loc.get('data_description'),
                    onTap: () => _openDataSettingsScreen(loc),
                  ),

                  _buildMenuHeader(title: loc.get('theme')),

                  _buildThemeItems(loc),

                  _buildMenuHeader(title: loc.get('information')),

                  _buildMenuItem(
                    icon: Icons.help,
                    title: loc.get('help'),
                    subtitle: loc.get('help_description'),
                    onTap: () => _showHelp(loc),
                  ),

                  _buildMenuItem(
                    icon: Icons.info,
                    title: loc.get('app_info'),
                    subtitle: loc.get('app_version'),
                    onTap: () {},
                  ),
                  if (authService.isLoggedIn) ...[
                    const SizedBox(height: 20),
                    _buildMenuItem(
                      icon: Icons.logout,
                      title: loc.get('logout'),
                      subtitle: loc.get('logout_description'),
                      onTap: () => _showLogoutDialog(loc),
                      textColor: Colors.red[400],
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildMenuHeader({required String title}) {
    return Consumer<ThemeService>(
      builder: (context, themeService, child) {
        final currentTheme = themeService.currentTheme;

        return Container(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.only(left: 24, top: 40, bottom: 10),
          child: Text(
            title,
            style: TextStyle(
              color: currentTheme.textLight,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.left,
          ),
        );
      },
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? textColor,
  }) {
    return Consumer<ThemeService>(
      builder: (context, themeService, child) {
        final currentTheme = themeService.currentTheme;

        return ListTile(
          leading: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Icon(icon, color: textColor ?? currentTheme.text),
          ),
          title: Text(
            title,
            style: TextStyle(
              color: textColor ?? currentTheme.text,
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: TextStyle(
              color: textColor?.withOpacity(0.7) ?? currentTheme.text,
              fontSize: 12,
            ),
          ),
          trailing: Icon(Icons.chevron_right, color: currentTheme.textLight),
          onTap: onTap,
        );
      },
    );
  }

  Widget _buildThemeItems(AppLocalizations loc) {
    return Consumer<ThemeService>(
      builder: (context, themeService, child) {
        final currentTheme = themeService.currentTheme;
        final currentThemeKey = themeService.currentThemeKey;

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
                  'recommended_theme',
                  currentThemeKey == 'recommended_theme',
                  () => themeService.setRecommendedTheme(),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildThemeItem(
                  loc,
                  Icons.light_mode,
                  loc.get('light_theme'),
                  'light_theme',
                  currentThemeKey == 'light_theme',
                  () => themeService.setLightTheme(),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildThemeItem(
                  loc,
                  Icons.dark_mode,
                  loc.get('dark_theme'),
                  'dark_theme',
                  currentThemeKey == 'dark_theme',
                  () => themeService.setDarkTheme(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildThemeItem(
    AppLocalizations loc,
    IconData icon,
    String title,
    String themeKey,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return Consumer<ThemeService>(
      builder: (context, themeService, child) {
        final currentTheme = themeService.currentTheme;

        return GestureDetector(
          onTap: onTap,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.only(left: 30, right: 30),
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected
                        ? currentTheme.accent
                        : currentTheme.primary,
                    width: isSelected ? 2 : 1,
                  ),
                  color: isSelected ? Colors.white : Colors.transparent,
                ),
                child: Icon(icon, color: currentTheme.text, size: 24),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  color: currentTheme.text,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDivider() {
    return Consumer<ThemeService>(
      builder: (context, themeService, child) {
        final currentTheme = themeService.currentTheme;

        return Divider(
          height: 1,
          indent: 56,
          endIndent: 20,
          color: currentTheme.dark.withOpacity(0.4),
        );
      },
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

  void _showLogoutDialog(AppLocalizations loc) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(loc.get('logout')),
        content: Text(loc.get('logout_confirm')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(loc.get('cancel')),
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
                    content: Text(loc.get('logout_success')),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: Text(
              loc.get('logout'),
              style: const TextStyle(color: Colors.red),
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
    return Consumer<ThemeService>(
      builder: (context, themeService, child) {
        final currentTheme = themeService.currentTheme;

        return Scaffold(
          appBar: AppBar(
            title: Text(loc.get('data')),
            backgroundColor: currentTheme.background,
            iconTheme: IconThemeData(color: currentTheme.text),
            elevation: 0,
          ),
          backgroundColor: currentTheme.background,
          body: Column(
            children: [
              ListTile(
                title: Text(
                  loc.get('pause_search_history'),
                  style: TextStyle(
                    color: currentTheme.text,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: Text(
                  loc.get('pause_search_history_description'),
                  style: TextStyle(color: currentTheme.text, fontSize: 12),
                ),
                trailing: Switch(
                  value: _isPauseHistoryEnabled,
                  onChanged: _setPauseHistoryState,
                  activeColor: currentTheme.text,
                ),
                onTap: () {
                  _setPauseHistoryState(!_isPauseHistoryEnabled);
                },
              ),
              _buildMenuItem(
                title: loc.get('delete_all_history'),
                onTap: () => {SearchHistoryScreen.clearAllHistory(context)},
              ),
              _buildMenuItem(title: loc.get('delete_account'), onTap: () => {}),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMenuItem({required String title, required VoidCallback onTap}) {
    return Consumer<ThemeService>(
      builder: (context, themeService, child) {
        final currentTheme = themeService.currentTheme;

        return ListTile(
          title: Text(
            title,
            style: TextStyle(
              color: currentTheme.error,
              fontWeight: FontWeight.w500,
            ),
          ),
          onTap: onTap,
        );
      },
    );
  }
}
