import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'services/search_history_service.dart';
import 'services/language_service.dart';
import 'services/auth_service.dart';
import 'services/theme_service.dart';
import 'theme/app_theme.dart';
import 'login_screen.dart';
import 'l10n/app_localizations.dart';
import 'search_history_screen.dart';
// import 'tutorial_screen.dart';
import 'terms_of_service_content.dart';
// import 'package:showcaseview/showcaseview.dart';
import 'main.dart';
import 'services/tutorial_service.dart';
import 'pro_upgrade_screen.dart';

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
                  color: colors.white,
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
                            return Image.asset(
                              'assets/WordVibe_appIcon_letters.png',
                              width: 40,
                              height: 40,
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
                    : Image.asset(
                        'assets/WordVibe_appIcon_letters.png',
                        width: 40,
                        height: 40,
                      ),
              ),
              const SizedBox(height: 16),
              // 사용자 이름
              Text(
                authService.isLoggedIn
                    ? (authService.userName ?? loc.get('ai_dictionary_user'))
                    : loc.get('guest_user'),
                style: TextStyle(
                  fontSize: 18,
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
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: colors.textLight),
              ),
              if (!authService.isLoggedIn) ...[
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: () {
                    _showLoginDialog(loc);
                  },
                  style: OutlinedButton.styleFrom(
                    backgroundColor: colors.white,
                    foregroundColor: colors.text,
                    side: BorderSide(
                      color: colors.text.withValues(alpha: 0.2),
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(
                    loc.get('login'),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: colors.primary,
                    ),
                  ),
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
                icon: Icons.workspace_premium,
                title: loc.get('pro_upgrade'),
                subtitle: loc.get('pro_upgrade_description'),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProUpgradeScreen(),
                  ),
                ),
                colors: colors,
              ),

              _buildMenuItem(
                icon: Icons.help,
                title: loc.get('help'),
                subtitle: loc.get('help_description'),
                onTap: () => _showHelp(loc),
                colors: colors,
              ),

              _buildMenuItem(
                icon: Icons.description,
                title: loc.get('terms_of_service'),
                subtitle: loc.get('terms_of_service_description'),
                onTap: () => _showTermsOfService(loc),
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
      padding: const EdgeInsets.only(left: 20, top: 40, bottom: 10),
      child: Text(
        title,
        style: TextStyle(
          color: colors.textLight,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
        textAlign: TextAlign.left,
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    Color? textColor,
    required CustomColors colors,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.only(left: 6, right: 8),
        child: Icon(icon, color: textColor ?? colors.text),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: textColor ?? colors.text,
          fontWeight: FontWeight.w500,
          fontSize: 15,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(
                color: textColor?.withValues(alpha: 0.7) ?? colors.text,
                fontSize: 12,
              ),
            )
          : null,
      trailing: Icon(Icons.chevron_right, color: colors.textLight),
      onTap: onTap,
    );
  }

  Widget _buildThemeItems(AppLocalizations loc, CustomColors colors) {
    return Container(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 10),
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
                color: isSelected
                    ? colors.textLight.withValues(alpha: 0.6)
                    : colors.textLight.withValues(alpha: 0.2),
                width: isSelected ? 2 : 1.4,
              ),
              color: isSelected ? colors.white : Colors.transparent,
            ),
            child: isSelected
                ? Icon(icon, color: colors.primary, size: 24)
                : Icon(icon, color: colors.text, size: 24),
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
    // 사용자의 시스템 로케일 가져오기
    Locale systemLocale = WidgetsBinding.instance.platformDispatcher.locale;
    String langCode = systemLocale.languageCode;
    String? countryCode = systemLocale.countryCode;

    // 시스템 로케일에 따른 언어 코드 결정
    String systemLanguageCode;
    if (langCode == 'ko') {
      systemLanguageCode = 'ko';
    } else if (langCode == 'en') {
      systemLanguageCode = 'en';
    } else if (langCode == 'zh' && countryCode == 'TW') {
      systemLanguageCode = 'zh-TW';
    } else if (langCode == 'zh') {
      systemLanguageCode = 'zh';
    } else if (langCode == 'fr') {
      systemLanguageCode = 'fr';
    } else if (langCode == 'es') {
      systemLanguageCode = 'es';
    } else {
      systemLanguageCode = 'en'; // 기본값
    }

    // 시스템 언어를 1순위로, 나머지는 기존 순서대로 정렬
    List<Map<String, String>> sortedLanguages = [];
    List<Map<String, String>> otherLanguages = [];

    for (var language in LanguageService.supportedLanguages) {
      if (language['code'] == systemLanguageCode) {
        sortedLanguages.add(language);
      } else {
        otherLanguages.add(language);
      }
    }

    // 시스템 언어가 없으면 기존 순서 유지
    if (sortedLanguages.isEmpty) {
      sortedLanguages = otherLanguages;
    } else {
      sortedLanguages.addAll(otherLanguages);
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          loc.get('app_language_setting'),
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: sortedLanguages.map((language) {
            final isSelected =
                LanguageService.currentLanguage == language['code'];
            return ListTile(
              title: Text(language['name']!, style: TextStyle(fontSize: 15)),
              trailing: isSelected ? Icon(Icons.check) : null,
              onTap: () async {
                // 포커스 해제하여 키보드가 나타나지 않도록 함
                FocusScope.of(context).unfocus();
                await LanguageService.setLanguage(language['code']!);
                await LanguageService.setTranslationLanguages(
                  LanguageService.getLanguageNameInKorean(language['code']!),
                  LanguageService.toLanguage,
                );
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
    // 튜토리얼 초기화
    TutorialService.resetTutorial();

    // 메인 홈 탭에서 쇼케이스를 시작하도록 전역 트리거 설정
    TutorialService.requestMainShowcase();
    // 메인 홈 탭에서 쇼케이스를 시작하도록 전역 트리거 호출
    triggerHomeShowCase();

    // 튜토리얼 완료 표시
    TutorialService.markTutorialCompleted();
  }

  void _showTermsOfService(AppLocalizations loc) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TermsOfServiceScreen()),
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

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final themeService = context.watch<ThemeService>();
    final colors = themeService.colors;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.get('terms_of_service')),
        backgroundColor: colors.background,
        iconTheme: IconThemeData(color: colors.text),
        elevation: 0,
      ),
      backgroundColor: colors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          TermsOfServiceContent.content,
          style: TextStyle(fontSize: 14, color: colors.text, height: 1.6),
        ),
      ),
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

  void _showDeleteAccountDialog(
    AppLocalizations loc,
    CustomColors colors,
  ) async {
    final authService = Provider.of<AuthService>(context, listen: false);

    // 사용자의 로그인 방식 확인을 위해 Firebase Auth에서 직접 가져오기
    final user = FirebaseAuth.instance.currentUser;

    // 사용자의 로그인 방식 확인
    String? loginProvider;
    if (user != null && user.providerData.isNotEmpty) {
      loginProvider = user.providerData.first.providerId;
    }

    // 이메일 로그인 사용자인 경우 비밀번호 입력 다이얼로그 표시
    if (loginProvider == 'password') {
      _showPasswordInputDialog(loc, colors, authService);
    } else {
      // 구글 로그인 사용자 또는 기타 사용자는 바로 삭제 진행
      _showDeleteConfirmationDialog(loc, colors, authService);
    }
  }

  void _showPasswordInputDialog(
    AppLocalizations loc,
    CustomColors colors,
    AuthService authService,
  ) {
    final passwordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(loc.get('delete_account')),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                loc.get('password_required_for_delete'),
                style: TextStyle(
                  color: colors.warning,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: loc.get('password'),
                  hintText: loc.get('password_hint_for_delete'),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return loc.get('password_required');
                  }
                  return null;
                },
              ),
            ],
          ),
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
              if (formKey.currentState!.validate()) {
                Navigator.pop(context);
                await _performAccountDeletion(
                  loc,
                  colors,
                  authService,
                  password: passwordController.text,
                );
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

  void _showDeleteConfirmationDialog(
    AppLocalizations loc,
    CustomColors colors,
    AuthService authService,
  ) {
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
              await _performAccountDeletion(loc, colors, authService);
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

  Future<void> _performAccountDeletion(
    AppLocalizations loc,
    CustomColors colors,
    AuthService authService, {
    String? password,
  }) async {
    try {
      final success = await authService.deleteAccount(password: password);

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
  }
}
