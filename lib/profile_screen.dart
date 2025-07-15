import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/search_history_service.dart';
import 'services/language_service.dart';
import 'services/auth_service.dart';
import 'login_screen.dart';
import 'theme/beige_colors.dart';
import 'l10n/app_localizations.dart';

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
    return Scaffold(
      backgroundColor: BeigeColors.background,
      appBar: AppBar(
        backgroundColor: BeigeColors.background,
        elevation: 0,
        title: Text(
          loc.get('profile_title'),
          style: const TextStyle(
            color: BeigeColors.text,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: BeigeColors.text),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(color: BeigeColors.textLight),
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
  }

  Widget _buildProfileHeader(AppLocalizations loc) {
    return Consumer<AuthService>(
      builder: (context, authService, child) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
          decoration: BoxDecoration(color: BeigeColors.background),
          child: Column(
            children: [
              const SizedBox(height: 20),
              // 프로필 이미지
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: BeigeColors.accent,
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
                              color: BeigeColors.text,
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
                                color: BeigeColors.text,
                              ),
                            );
                          },
                        ),
                      )
                    : Icon(Icons.person, size: 40, color: BeigeColors.text),
              ),
              const SizedBox(height: 16),
              // 사용자 이름
              Text(
                authService.isLoggedIn
                    ? (authService.userName ?? loc.get('ai_dictionary_user'))
                    : loc.get('guest_user'),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: BeigeColors.text,
                ),
              ),
              const SizedBox(height: 4),
              // 사용자 이메일
              Text(
                authService.isLoggedIn
                    ? (authService.userEmail ?? 'user@example.com')
                    : loc.get('guest_description'),
                style: TextStyle(fontSize: 14, color: BeigeColors.textLight),
              ),
              /*
              const SizedBox(height: 16)
              // 로그인/편집 버튼
              if (authService.isLoggedIn)
                OutlinedButton(
                  onPressed: () {
                    _showEditProfileDialog(loc);
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: BeigeColors.text,
                    side: BorderSide(color: BeigeColors.dark),
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
                    backgroundColor: BeigeColors.accent,
                    foregroundColor: BeigeColors.text,
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

  Widget _buildSettingsMenu(AppLocalizations loc) {
    return Consumer<AuthService>(
      builder: (context, authService, child) {
        return Container(
          margin: const EdgeInsets.only(bottom: 20),
          child: Column(
            children: [
              _buildMenuHeader(title: "시스템"),

              _buildMenuItem(
                icon: Icons.language,
                title: loc.get('app_language_setting'),
                subtitle: LanguageService.currentLanguageName,
                onTap: () => _showLanguageSettings(loc),
              ),

              _buildMenuItem(
                icon: Icons.dark_mode,
                title: loc.get('dark_mode'),
                subtitle: loc.get('dark_mode_description'),
                onTap: () => _toggleDarkMode(loc),
              ),

              _buildMenuItem(
                icon: Icons.storage,
                title: loc.get('storage'),
                subtitle: loc.get('storage_description'),
                onTap: () => _showStorageSettings(loc),
              ),

              _buildMenuHeader(title: "정보"),

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
                onTap: () => _showAppInfo(loc),
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
  }

  Widget _buildMenuHeader({required String title}) {
    return Container(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.only(left: 24, top: 40, bottom: 10),
      child: Text(
        title,
        style: TextStyle(
          color: BeigeColors.textLight,
          fontWeight: FontWeight.bold,
        ),
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
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Icon(icon, color: textColor ?? BeigeColors.text),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: textColor ?? BeigeColors.text,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: textColor?.withValues(alpha: 0.7) ?? BeigeColors.text,
          fontSize: 12,
        ),
      ),
      trailing: Icon(Icons.chevron_right, color: BeigeColors.textLight),
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      indent: 56,
      endIndent: 20,
      color: BeigeColors.dark.withValues(alpha: 0.4),
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
                _showLanguageChangedDialog(loc, language['name']!);
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

  void _showLanguageChangedDialog(AppLocalizations loc, String languageName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          loc.get('language_changed').replaceAll('{language}', languageName),
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(loc.get('confirm')),
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

  void _showStorageSettings(AppLocalizations loc) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(loc.get('storage')),
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

  void _showAppInfo(AppLocalizations loc) {
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
