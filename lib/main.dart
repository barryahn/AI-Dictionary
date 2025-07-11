import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'dart:async';
import 'search_result_screen.dart';
import 'search_history_screen.dart';
import 'profile_screen.dart';
import 'login_screen.dart';
import 'services/language_service.dart';
import 'services/openai_service.dart';
import 'services/auth_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'theme/beige_colors.dart';
import 'l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// 앱의 진입점
void main() async {
  await dotenv.load(fileName: ".env");
  await LanguageService.initialize(); // 언어 서비스 초기화
  await OpenAIService.initialize(); // OpenAI 서비스 초기화
  await AuthService().initialize(); // 인증 서비스 초기화
  runApp(const MyApp());
}

// 앱의 기본 설정을 정의하는 StatefulWidget
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale _locale = _createLocale(LanguageService.currentLanguage);

  @override
  void initState() {
    super.initState();
    LanguageService.languageStream.listen((data) {
      if (data.containsKey('appLanguage')) {
        setState(() {
          _locale = _createLocale(data['appLanguage']!);
        });
      }
    });
  }

  // 로케일 생성 헬퍼 메서드
  static Locale _createLocale(String languageCode) {
    if (languageCode == 'zh-TW') {
      return const Locale('zh', 'TW');
    }
    return Locale(languageCode);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AuthService(),
      child: MaterialApp(
        title: 'AI Dictionary',
        locale: _locale,
        supportedLocales: const [
          Locale('ko'),
          Locale('en'),
          Locale('zh'),
          Locale('zh', 'TW'),
          Locale('fr'),
          Locale('es'),
        ],
        localizationsDelegates: [
          const AppLocalizationsDelegate(),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: BeigeColors.primary,
            brightness: Brightness.light,
          ),
          scaffoldBackgroundColor: BeigeColors.background,
          appBarTheme: const AppBarTheme(
            backgroundColor: BeigeColors.background,
            foregroundColor: BeigeColors.text,
            elevation: 0,
            titleTextStyle: TextStyle(
              color: BeigeColors.text,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          bottomNavigationBarTheme: const BottomNavigationBarThemeData(
            backgroundColor: BeigeColors.background,
            selectedItemColor: BeigeColors.text,
            unselectedItemColor: BeigeColors.textLight,
          ),
          textTheme: const TextTheme(
            bodyLarge: TextStyle(color: BeigeColors.text),
            bodyMedium: TextStyle(color: BeigeColors.text),
          ),
        ),
        home: const AuthWrapper(),
      ),
    );
  }
}

// 메인 화면을 정의하는 StatefulWidget
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  final GlobalKey<SearchHistoryScreenState> _historyScreenKey =
      GlobalKey<SearchHistoryScreenState>();

  late final List<Widget> _widgetOptions;

  @override
  void initState() {
    super.initState();
    _widgetOptions = <Widget>[
      const _HomeTab(),
      SearchHistoryScreen(key: _historyScreenKey),
      const ProfileScreen(),
    ];
  }

  void _onItemTapped(int index) {
    // 기록 탭(index 1)을 누를 때마다 새로고침
    if (index == 1) {
      _historyScreenKey.currentState?.refresh();
    }
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BeigeColors.background,
      body: IndexedStack(index: _selectedIndex, children: _widgetOptions),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
        ],
        selectedItemColor: BeigeColors.text,
        unselectedItemColor: BeigeColors.textLight,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
        backgroundColor: BeigeColors.background,
      ),
    );
  }
}

class _HomeTab extends StatefulWidget {
  const _HomeTab();

  @override
  State<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<_HomeTab> {
  // 언어 선택을 위한 상태 변수들
  String selectedFromLanguage = '영어';
  String selectedToLanguage = '한국어';
  StreamSubscription? _languageSubscription;

  @override
  void initState() {
    super.initState();
    // LanguageService에서 저장된 언어 설정 불러오기
    selectedFromLanguage = LanguageService.fromLanguage;
    selectedToLanguage = LanguageService.toLanguage;

    // 언어 변경 스트림 구독
    _languageSubscription = LanguageService.languageStream.listen((languages) {
      setState(() {
        selectedFromLanguage = languages['fromLanguage']!;
        selectedToLanguage = languages['toLanguage']!;
      });
    });
  }

  @override
  void dispose() {
    _languageSubscription?.cancel();
    super.dispose();
  }

  void _updateLanguages(String fromLang, String toLang) {
    setState(() {
      selectedFromLanguage = fromLang;
      selectedToLanguage = toLang;
    });
    // LanguageService에 저장
    LanguageService.setTranslationLanguages(fromLang, toLang);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BeigeColors.background,
      appBar: AppBar(
        title: const Text(
          'AI Dictionary',
          style: TextStyle(
            color: BeigeColors.text,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: BeigeColors.background,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // 언어 선택 영역
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // 출발 언어 선택 드롭다운
                SizedBox(
                  width: 140,
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton2<String>(
                      isExpanded: true,
                      hint: Text(
                        'Select Item',
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).hintColor,
                        ),
                      ),
                      items:
                          LanguageService.getLocalizedTranslationLanguages(
                                AppLocalizations.of(context),
                              )
                              .map(
                                (Map<String, String> item) =>
                                    DropdownMenuItem<String>(
                                      value: item['code']!,
                                      child: Text(
                                        item['name']!,
                                        style: const TextStyle(
                                          fontSize: 20,
                                          color: BeigeColors.text,
                                        ),
                                      ),
                                    ),
                              )
                              .toList(),
                      value: selectedFromLanguage,
                      onChanged: (String? newValue) {
                        if (newValue == null) return;
                        _updateLanguages(newValue, selectedToLanguage);
                      },
                      buttonStyleData: const ButtonStyleData(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        height: 40,
                        width: 140,
                      ),
                      menuItemStyleData: const MenuItemStyleData(height: 40),
                      dropdownStyleData: DropdownStyleData(
                        decoration: BoxDecoration(
                          color: BeigeColors.light,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                GestureDetector(
                  onTap: () {
                    _updateLanguages(selectedToLanguage, selectedFromLanguage);
                  },
                  child: Icon(Icons.arrow_forward_ios, color: BeigeColors.text),
                ),
                const SizedBox(width: 20),
                // 도착 언어 선택 드롭다운
                SizedBox(
                  width: 140,
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton2<String>(
                      isExpanded: true,
                      hint: Text(
                        'Select Item',
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).hintColor,
                        ),
                      ),
                      items:
                          LanguageService.getLocalizedTranslationLanguages(
                                AppLocalizations.of(context),
                              )
                              // .where((item) => item != selectedFromLanguage) // 이 부분을 잠시 제거하여 모든 언어 표시
                              .map(
                                (Map<String, String> item) =>
                                    DropdownMenuItem<String>(
                                      value: item['code']!,
                                      child: Text(
                                        item['name']!,
                                        style: const TextStyle(
                                          fontSize: 20,
                                          color: BeigeColors.text,
                                        ),
                                      ),
                                    ),
                              )
                              .toList(),
                      value: selectedToLanguage,
                      onChanged: (String? newValue) {
                        if (newValue == null) return;
                        _updateLanguages(selectedFromLanguage, newValue);
                      },
                      buttonStyleData: const ButtonStyleData(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        height: 40,
                        width: 140,
                      ),
                      menuItemStyleData: const MenuItemStyleData(height: 40),
                      dropdownStyleData: DropdownStyleData(
                        decoration: BoxDecoration(
                          color: BeigeColors.light,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // 검색창 영역 수정
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SearchResultScreen(
                      fromLanguage: selectedFromLanguage,
                      toLanguage: selectedToLanguage,
                    ),
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: BeigeColors.light,
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 4,
                ),
                child: IgnorePointer(
                  child: TextField(
                    decoration: InputDecoration(
                      icon: Icon(Icons.search, color: BeigeColors.text),
                      hintText: AppLocalizations.of(context).main_search_hint,
                      hintStyle: TextStyle(
                        color: BeigeColors.text,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

// 인증 상태에 따라 화면을 전환하는 래퍼 위젯
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, authService, child) {
        // 로그인 상태와 관계없이 메인 화면을 보여줌
        return const MyHomePage(title: 'AI Dictionary');
      },
    );
  }
}
