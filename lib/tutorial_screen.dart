import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'l10n/app_localizations.dart';
import 'services/theme_service.dart';
import 'theme/app_theme.dart';

class TutorialScreen extends StatefulWidget {
  const TutorialScreen({super.key});

  @override
  State<TutorialScreen> createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen> {
  int _currentPage = 0;
  final PageController _pageController = PageController();

  final List<TutorialStep> _tutorialSteps = [
    TutorialStep(
      title: 'tutorial_welcome',
      description: 'tutorial_welcome_desc',
      icon: Icons.waving_hand,
      showSpeechBubble: true,
    ),
    TutorialStep(
      title: 'tutorial_search_title',
      description: 'tutorial_search_desc',
      icon: Icons.search,
      showSpeechBubble: true,
    ),
    TutorialStep(
      title: 'tutorial_language_title',
      description: 'tutorial_language_desc',
      icon: Icons.language,
      showSpeechBubble: true,
    ),
    TutorialStep(
      title: 'tutorial_history_title',
      description: 'tutorial_history_desc',
      icon: Icons.history,
      showSpeechBubble: true,
    ),
    TutorialStep(
      title: 'tutorial_translate_title',
      description: 'tutorial_translate_desc',
      icon: Icons.translate,
      showSpeechBubble: true,
    ),
    TutorialStep(
      title: 'tutorial_profile_title',
      description: 'tutorial_profile_desc',
      icon: Icons.person,
      showSpeechBubble: true,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _tutorialSteps.length - 1) {
      setState(() {
        _currentPage++;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _finishTutorial();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      setState(() {
        _currentPage--;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _skipTutorial() {
    _finishTutorial();
  }

  Future<void> _finishTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('tutorial_completed', true);

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeService = context.watch<ThemeService>();
    final colors = themeService.colors;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          children: [
            // 상단 스킵 버튼
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextButton(
                  onPressed: _skipTutorial,
                  child: Text(
                    l10n.get('tutorial_skip'),
                    style: TextStyle(color: colors.textLight, fontSize: 16),
                  ),
                ),
              ),
            ),

            // 페이지뷰 영역
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _tutorialSteps.length,
                itemBuilder: (context, index) {
                  final step = _tutorialSteps[index];
                  return _buildTutorialStep(step, colors, l10n);
                },
              ),
            ),

            // 하단 네비게이션
            _buildBottomNavigation(colors, l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildTutorialStep(
    TutorialStep step,
    CustomColors colors,
    AppLocalizations l10n,
  ) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 아이콘과 말풍선
          Stack(
            alignment: Alignment.center,
            children: [
              // 배경 원
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: colors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
              ),

              // 아이콘
              Icon(step.icon, size: 80, color: colors.primary),

              // 말풍선 (첫 번째 페이지가 아닌 경우)
              if (step.showSpeechBubble && _currentPage > 0)
                Positioned(
                  top: 20,
                  right: 20,
                  child: _buildSpeechBubble(colors, l10n),
                ),
            ],
          ),

          const SizedBox(height: 40),

          // 제목
          Text(
            l10n.get(step.title),
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: colors.text,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 16),

          // 설명
          Text(
            l10n.get(step.description),
            style: TextStyle(
              fontSize: 18,
              color: colors.textLight,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSpeechBubble(CustomColors colors, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.primary,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colors.primary.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text('👋', style: const TextStyle(fontSize: 20)),
    );
  }

  Widget _buildBottomNavigation(CustomColors colors, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 이전 버튼
          if (_currentPage > 0)
            TextButton(
              onPressed: _previousPage,
              child: Text(
                '이전',
                style: TextStyle(color: colors.textLight, fontSize: 16),
              ),
            )
          else
            const SizedBox(width: 60),

          // 페이지 인디케이터
          Row(
            children: List.generate(
              _tutorialSteps.length,
              (index) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: index == _currentPage
                      ? colors.primary
                      : colors.textLight.withOpacity(0.3),
                ),
              ),
            ),
          ),

          // 다음/시작 버튼
          ElevatedButton(
            onPressed: _nextPage,
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Text(
              _currentPage == _tutorialSteps.length - 1
                  ? l10n.get('tutorial_finish')
                  : l10n.get('tutorial_next'),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class TutorialStep {
  final String title;
  final String description;
  final IconData icon;
  final bool showSpeechBubble;

  TutorialStep({
    required this.title,
    required this.description,
    required this.icon,
    this.showSpeechBubble = false,
  });
}

// 도움말 서비스 클래스
class TutorialService {
  static const String _tutorialCompletedKey = 'tutorial_completed';
  static const String _dontShowAgainKey = 'tutorial_dont_show_again';

  // 튜토리얼 완료 여부 확인
  static Future<bool> isTutorialCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_tutorialCompletedKey) ?? false;
  }

  // 튜토리얼 완료 표시
  static Future<void> markTutorialCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_tutorialCompletedKey, true);
  }

  // 다시 보지 않기 설정 확인
  static Future<bool> shouldShowTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    return !(prefs.getBool(_dontShowAgainKey) ?? false);
  }

  // 다시 보지 않기 설정
  static Future<void> setDontShowAgain(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_dontShowAgainKey, value);
  }

  // 튜토리얼 재설정
  static Future<void> resetTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tutorialCompletedKey);
    await prefs.remove(_dontShowAgainKey);
  }
}
