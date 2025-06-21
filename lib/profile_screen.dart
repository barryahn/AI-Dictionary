import 'package:flutter/material.dart';
import 'services/search_history_service.dart';
import 'services/language_service.dart';

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
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          '프로필',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  // 프로필 헤더
                  _buildProfileHeader(),
                  const SizedBox(height: 20),

                  // 설정 메뉴
                  _buildSettingsMenu(),
                ],
              ),
            ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          // 프로필 이미지
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.blue[100],
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person, size: 40, color: Colors.blue),
          ),
          const SizedBox(height: 16),

          // 사용자 이름
          const Text(
            'AI Dictionary 사용자',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),

          // 사용자 이메일
          Text(
            'user@example.com',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),

          // 편집 버튼
          OutlinedButton(
            onPressed: () {
              // 프로필 편집 기능
              _showEditProfileDialog();
            },
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text('프로필 편집'),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsMenu() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildMenuItem(
            icon: Icons.language,
            title: '앱 언어 설정',
            subtitle: LanguageService.currentLanguageName,
            onTap: () => _showLanguageSettings(),
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.notifications,
            title: '알림 설정',
            subtitle: '학습 알림 받기',
            onTap: () => _showNotificationSettings(),
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.dark_mode,
            title: '다크 모드',
            subtitle: '시스템 설정 따름',
            onTap: () => _toggleDarkMode(),
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.storage,
            title: '저장 공간',
            subtitle: '검색 기록 관리',
            onTap: () => _showStorageSettings(),
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.help,
            title: '도움말',
            subtitle: '사용법 및 FAQ',
            onTap: () => _showHelp(),
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.info,
            title: '앱 정보',
            subtitle: '버전 1.0.0',
            onTap: () => _showAppInfo(),
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.logout,
            title: '로그아웃',
            subtitle: '계정에서 로그아웃',
            onTap: () => _showLogoutDialog(),
            textColor: Colors.red,
          ),
        ],
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
      leading: Icon(icon, color: textColor ?? Colors.grey[700]),
      title: Text(
        title,
        style: TextStyle(color: textColor, fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: textColor?.withOpacity(0.7) ?? Colors.grey[600],
          fontSize: 12,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return const Divider(height: 1, indent: 56);
  }

  // 다이얼로그 및 설정 메서드들
  void _showEditProfileDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('프로필 편집'),
        content: const Text('프로필 편집 기능은 준비 중입니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  void _showLanguageSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('앱 언어 설정'),
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
            child: const Text('취소'),
          ),
        ],
      ),
    );
  }

  void _showLanguageChangedDialog(String languageName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('언어 변경'),
        content: Text('앱 언어가 $languageName로 변경되었습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  void _showNotificationSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('알림 설정'),
        content: const Text('알림 설정 기능은 준비 중입니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  void _toggleDarkMode() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('다크 모드'),
        content: const Text('다크 모드 기능은 준비 중입니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  void _showStorageSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('저장 공간'),
        content: const Text('저장 공간 관리 기능은 준비 중입니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  void _showHelp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('도움말'),
        content: const Text('도움말 기능은 준비 중입니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  void _showAppInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('앱 정보'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('AI Dictionary'),
            SizedBox(height: 8),
            Text('버전: 1.0.0'),
            SizedBox(height: 8),
            Text('개발자: AI Dictionary Team'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('로그아웃'),
        content: const Text('정말 로그아웃하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // 로그아웃 로직
            },
            child: const Text('로그아웃', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
