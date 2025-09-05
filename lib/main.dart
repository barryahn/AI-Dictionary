import 'dart:ui';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'search_result_screen.dart';
import 'search_history_screen.dart';
import 'profile_screen.dart';
import 'translation_screen.dart';
import 'services/tutorial_service.dart';
import 'services/language_service.dart';
import 'services/openai_service.dart';
import 'services/auth_service.dart';
import 'services/theme_service.dart';
import 'services/pro_service.dart';
import 'services/quota_service.dart';
import 'services/purchase_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'pro_upgrade_screen.dart';

// ShowcaseView 키들
GlobalKey _one = GlobalKey();
GlobalKey _two = GlobalKey();
GlobalKey _three = GlobalKey();
GlobalKey _four = GlobalKey();
// 홈 탭의 ShowCaseWidget 컨텍스트 보관용
BuildContext? homeShowcaseContext;
// 메인 페이지 상태 접근 키 (탭 전환 및 쇼케이스 시작용)
final GlobalKey<_MyHomePageState> myHomePageKey = GlobalKey<_MyHomePageState>();

// 외부(예: 프로필 화면)에서 홈 탭으로 전환 후 쇼케이스를 시작하는 공개 함수
void triggerHomeShowCase() {
  final state = myHomePageKey.currentState;
  if (state == null) return;
  state.navigateToHomeAndStartShowcase();
}

// 앱의 진입점
void main() async {
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // 여러 서비스 초기화를 병렬로 처리
  await Future.wait([
    LanguageService.initialize(),
    OpenAIService.initialize(),
    AuthService().initialize(),
    ThemeService.initialize(),
    PurchaseService().initialize(),
  ]);

  // Google Mobile Ads 초기화
  await MobileAds.instance.initialize();

  // Firebase crashlytics 초기화
  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

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
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthService()),
        ChangeNotifierProvider.value(value: ThemeService.instance),
        ChangeNotifierProvider(create: (_) => ProService()..initialize()),
        ChangeNotifierProvider(create: (_) => QuotaService()..initialize()),
        ChangeNotifierProvider.value(value: PurchaseService()),
      ],
      child: Consumer<ThemeService>(
        builder: (context, themeService, child) {
          return MaterialApp(
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
            theme: themeService.themeData,
            home: const AuthWrapper(),
          );
        },
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
      // const 제거: 상태 접근/리스너가 정상 동작하도록
      TranslationScreen(),
      const ProfileScreen(),
    ];
  }

  void _onItemTapped(int index) {
    // 탭 전환 시 다른 페이지의 키보드 포커스가 남지 않도록 전역 포커스 해제
    FocusManager.instance.primaryFocus?.unfocus();
    // 기록 탭(index 1)을 누를 때마다 새로고침
    if (index == 1) {
      _historyScreenKey.currentState?.refresh();
    }
    // 번역 탭(index 2) 진입 시 번역 화면 쇼케이스 요청
    if (index == 2) {
      TutorialService.requestTranslationShowcase();
    }
    setState(() {
      _selectedIndex = index;
    });
  }

  // 외부에서 호출: 홈 탭으로 전환 후 쇼케이스 실행
  void navigateToHomeAndStartShowcase() {
    if (mounted) {
      setState(() {
        _selectedIndex = 0;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (homeShowcaseContext != null) {
          ShowCaseWidget.of(
            homeShowcaseContext!,
          ).startShowCase([_one, _two, _three, _four]);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeService = context.watch<ThemeService>();
    final colors = themeService.colors;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (_selectedIndex != 0) {
          // 메인 탭으로 이동 시 포커스 해제
          FocusManager.instance.primaryFocus?.unfocus();
          setState(() {
            _selectedIndex = 0;
          });
        } else {
          // 종료
          SystemNavigator.pop();
        }
      },
      child: ShowCaseWidget(
        builder: (context) {
          // 홈 쇼케이스 컨텍스트 저장 및 트리거 시 자동 실행
          homeShowcaseContext = context;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (TutorialService.consumeMainShowcaseTrigger() &&
                _selectedIndex == 0) {
              ShowCaseWidget.of(
                context,
              ).startShowCase([_one, _two, _three, _four]);
            }
          });
          return Scaffold(
            backgroundColor: colors.background,
            body: IndexedStack(index: _selectedIndex, children: _widgetOptions),
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: _selectedIndex,
              onTap: _onItemTapped,
              items: <BottomNavigationBarItem>[
                const BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: '',
                ),
                BottomNavigationBarItem(
                  icon: Showcase(
                    key: _three,
                    title: AppLocalizations.of(context).tutorial_history_title,
                    description:
                        AppLocalizations.of(context).tutorial_history_desc +
                        'ㅤ',
                    titleTextAlign: TextAlign.center,
                    titleTextStyle: TextStyle(
                      color: colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                    titlePadding: EdgeInsets.only(top: 8),
                    descTextStyle: TextStyle(color: colors.white, fontSize: 13),
                    descriptionPadding: EdgeInsets.only(top: 4),
                    descriptionTextAlign: TextAlign.center,
                    targetPadding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 10,
                    ),
                    tooltipBackgroundColor: colors.primary,
                    tooltipActions: [
                      TooltipActionButton(
                        type: TooltipDefaultActionType.skip,
                        padding: EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 2,
                        ),
                        name: AppLocalizations.of(context).tutorial_skip_all,
                        textStyle: TextStyle(
                          color: colors.white.withValues(alpha: 0.5),
                        ),
                        backgroundColor: Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      TooltipActionButton(
                        type: TooltipDefaultActionType.next,
                        padding: EdgeInsets.only(top: 3, right: 8),
                        name: '3/4',
                        textStyle: TextStyle(
                          color: colors.white.withValues(alpha: 0.5),
                          fontSize: 12,
                        ),
                        backgroundColor: Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      TooltipActionButton(
                        type: TooltipDefaultActionType.next,
                        padding: EdgeInsets.only(
                          left: 10,
                          right: 14,
                          top: 2,
                          bottom: 2,
                        ),
                        name: AppLocalizations.of(context).tutorial_next,
                        textStyle: TextStyle(color: colors.white),
                        backgroundColor: Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ],
                    tooltipActionConfig: const TooltipActionConfig(
                      alignment: MainAxisAlignment.spaceBetween,
                      gapBetweenContentAndAction: 10,
                      position: TooltipActionPosition.outside,
                    ),
                    child: const Icon(Icons.history),
                  ),
                  label: '',
                ),
                BottomNavigationBarItem(
                  icon: Showcase(
                    key: _four,
                    title: AppLocalizations.of(
                      context,
                    ).tutorial_translate_title,
                    description:
                        AppLocalizations.of(context).tutorial_translate_desc +
                        'ㅤ',
                    titleTextAlign: TextAlign.center,
                    titleTextStyle: TextStyle(
                      color: colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                    titlePadding: EdgeInsets.only(top: 8),
                    targetPadding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 10,
                    ),
                    descTextStyle: TextStyle(color: colors.white, fontSize: 13),
                    descriptionPadding: EdgeInsets.only(top: 4),
                    descriptionTextAlign: TextAlign.center,
                    tooltipBackgroundColor: colors.primary,
                    tooltipActions: [
                      TooltipActionButton(
                        type: TooltipDefaultActionType.skip,
                        padding: EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 2,
                        ),
                        name: AppLocalizations.of(context).tutorial_skip_all,
                        textStyle: TextStyle(
                          color: colors.white.withValues(alpha: 0.5),
                        ),
                        backgroundColor: Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      TooltipActionButton(
                        type: TooltipDefaultActionType.next,
                        padding: EdgeInsets.only(top: 3, right: 2),
                        name: '4/4',
                        textStyle: TextStyle(
                          color: colors.white.withValues(alpha: 0.5),
                          fontSize: 12,
                        ),
                        backgroundColor: Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      TooltipActionButton(
                        type: TooltipDefaultActionType.next,
                        padding: EdgeInsets.only(
                          left: 10,
                          right: 14,
                          top: 2,
                          bottom: 2,
                        ),
                        name: AppLocalizations.of(context).tutorial_next,
                        textStyle: TextStyle(color: colors.white),
                        backgroundColor: Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ],
                    tooltipActionConfig: const TooltipActionConfig(
                      alignment: MainAxisAlignment.spaceBetween,
                      gapBetweenContentAndAction: 10,
                      position: TooltipActionPosition.outside,
                    ),
                    child: const Icon(Icons.translate),
                  ),
                  label: '',
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: '',
                ),
              ],
              selectedItemColor: colors.text,
              unselectedItemColor: colors.textLight,
              showSelectedLabels: false,
              showUnselectedLabels: false,
              type: BottomNavigationBarType.fixed,
              backgroundColor: colors.white,
            ),
          );
        },
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
    final themeService = context.watch<ThemeService>();
    final colors = themeService.colors;

    return Scaffold(
      backgroundColor: colors.white,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context).get('app_title'),
          style: TextStyle(
            color: colors.primary,
            fontSize: 24,
            fontFamily: 'MaruBuri',
            fontWeight: FontWeight.w400,
          ),
        ),
        backgroundColor: colors.white,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Consumer<ProService>(
              builder: (context, pro, _) {
                final bool isPro = pro.isPro;
                return TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ProUpgradeScreen(),
                      ),
                    );
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: colors.white,
                    foregroundColor: colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: colors.primary, width: 1.4),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    child: isPro
                        ? Icon(Icons.star, size: 20, color: colors.primary)
                        : Text(
                            'PRO',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: colors.primary,
                            ),
                          ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Align(
              alignment: Alignment.centerLeft,
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: AppLocalizations.of(context).which_language_part1,
                      style: TextStyle(fontSize: 20, color: colors.primary),
                    ),
                    TextSpan(
                      text: AppLocalizations.of(context).which_language_part2,
                      style: TextStyle(fontSize: 20, color: colors.text),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 언어 선택 영역
            // 도착 언어 선택 드롭다운
            Showcase.withWidget(
              key: _two,
              width: MediaQuery.of(context).size.width - 32,
              height: 100,
              container: Container(
                decoration: BoxDecoration(
                  color: colors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Column(
                  children: [
                    Text(
                      AppLocalizations.of(context).tutorial_language_title,
                      style: TextStyle(
                        color: colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      AppLocalizations.of(context).tutorial_language_desc + "ㅤ",
                      style: TextStyle(color: colors.white, fontSize: 13),
                    ),
                    const SizedBox(height: 12),
                    Divider(
                      height: 1,
                      thickness: 1,
                      color: colors.white.withValues(alpha: 0.2),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Text('💡'),
                        const SizedBox(width: 8),
                        Text(
                          AppLocalizations.of(
                            context,
                          ).tutorial_language_desc_detail,
                          style: TextStyle(color: colors.white, fontSize: 13),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              tooltipActions: [
                TooltipActionButton(
                  type: TooltipDefaultActionType.skip,
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                  name: AppLocalizations.of(context).tutorial_skip_all,
                  textStyle: TextStyle(
                    color: colors.white.withValues(alpha: 0.5),
                  ),
                  backgroundColor: Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                TooltipActionButton(
                  type: TooltipDefaultActionType.next,
                  padding: EdgeInsets.only(top: 3, right: 8),
                  name: '2/4',
                  textStyle: TextStyle(
                    color: colors.white.withValues(alpha: 0.5),
                    fontSize: 12,
                  ),
                  backgroundColor: Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                TooltipActionButton(
                  type: TooltipDefaultActionType.next,
                  padding: EdgeInsets.only(
                    left: 10,
                    right: 14,
                    top: 2,
                    bottom: 2,
                  ),
                  name: AppLocalizations.of(context).tutorial_next,
                  textStyle: TextStyle(color: colors.white),
                  backgroundColor: Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
              ],
              tooltipActionConfig: const TooltipActionConfig(
                alignment: MainAxisAlignment.spaceBetween,
                gapBetweenContentAndAction: 10,
                position: TooltipActionPosition.outside,
              ),

              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    backgroundColor: colors.white,
                    isScrollControlled: true,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                    builder: (context) {
                      return FractionallySizedBox(
                        heightFactor: 0.6,
                        child: Column(
                          children: [
                            const SizedBox(height: 12),
                            Container(
                              width: 40,
                              height: 5,
                              margin: const EdgeInsets.only(top: 8, bottom: 12),
                              decoration: BoxDecoration(
                                color: colors.text.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            Text(
                              AppLocalizations.of(context).language,
                              style: TextStyle(
                                fontSize: 16,
                                color: colors.text,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Divider(
                              height: 1,
                              thickness: 1,
                              color: colors.text.withValues(alpha: 0.1),
                            ),

                            Expanded(
                              child: ListView(
                                children:
                                    LanguageService.getLocalizedTranslationLanguages(
                                          AppLocalizations.of(context),
                                        )
                                        .map(
                                          (Map<String, String> item) => Column(
                                            children: [
                                              InkWell(
                                                onTap: () {
                                                  Navigator.pop(
                                                    context,
                                                  ); // 모달 닫기
                                                  _updateLanguages(
                                                    selectedFromLanguage,
                                                    item['code']!,
                                                  );
                                                },
                                                child: Container(
                                                  width: double.infinity,
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        vertical: 14.0,
                                                        horizontal: 36.0,
                                                      ),
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text(
                                                        item['name']!,
                                                        style: TextStyle(
                                                          fontSize: 16,
                                                          color: colors.text,
                                                        ),
                                                        textAlign:
                                                            TextAlign.left,
                                                      ),
                                                      if (item['code'] ==
                                                          selectedToLanguage)
                                                        Icon(
                                                          Icons.check,
                                                          size: 16,
                                                          color: colors.primary,
                                                        ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              Divider(
                                                height: 1,
                                                thickness: 1,
                                                color: colors.textLight
                                                    .withValues(alpha: 0.1),
                                                indent: 24,
                                                endIndent: 24,
                                              ),
                                            ],
                                          ),
                                        )
                                        .toList(),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 16,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(width: 12),
                      Text(
                        LanguageService.getLocalizedTranslationLanguages(
                          AppLocalizations.of(context),
                        ).firstWhere(
                          (item) => item['code'] == selectedToLanguage,
                        )['name']!,
                        style: TextStyle(fontSize: 22, color: colors.primary),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.keyboard_arrow_down,
                        color: colors.text.withValues(alpha: 0.4),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
            // 검색창 영역 수정
            Showcase(
              key: _one,
              title: AppLocalizations.of(context).tutorial_search_title,
              description:
                  '${AppLocalizations.of(context).tutorial_search_desc}\n${AppLocalizations.of(context).tutorial_search_desc_detail}ㅤ',
              titleTextAlign: TextAlign.center,
              titleTextStyle: TextStyle(
                color: colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
              titlePadding: EdgeInsets.only(top: 8),
              descTextStyle: TextStyle(color: colors.white, fontSize: 13),
              descriptionPadding: EdgeInsets.only(top: 4),
              descriptionTextAlign: TextAlign.center,
              tooltipBackgroundColor: colors.primary,
              targetPadding: EdgeInsets.only(
                top: 150,
                left: 20,
                right: 20,
                bottom: 20,
              ),
              tooltipActions: [
                TooltipActionButton(
                  type: TooltipDefaultActionType.skip,
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                  name: AppLocalizations.of(context).tutorial_skip_all,
                  textStyle: TextStyle(
                    color: colors.white.withValues(alpha: 0.5),
                  ),
                  backgroundColor: Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                TooltipActionButton(
                  type: TooltipDefaultActionType.next,
                  padding: EdgeInsets.only(top: 3, right: 8),
                  name: '1/4',
                  textStyle: TextStyle(
                    color: colors.white.withValues(alpha: 0.5),
                    fontSize: 12,
                  ),
                  backgroundColor: Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                TooltipActionButton(
                  type: TooltipDefaultActionType.next,
                  padding: EdgeInsets.only(
                    left: 10,
                    right: 14,
                    top: 2,
                    bottom: 2,
                  ),
                  name: AppLocalizations.of(context).tutorial_next,
                  textStyle: TextStyle(color: colors.white),
                  backgroundColor: Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
              ],
              tooltipActionConfig: const TooltipActionConfig(
                alignment: MainAxisAlignment.spaceBetween,
                gapBetweenContentAndAction: 10,
                position: TooltipActionPosition.outside,
              ),

              child: GestureDetector(
                onTap: () {
                  // 검색 화면 진입 전 검색 쇼케이스 요청
                  TutorialService.requestSearchShowcase();
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
                    color: colors.background,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 4,
                  ),
                  child: IgnorePointer(
                    child: TextField(
                      decoration: InputDecoration(
                        icon: Icon(Icons.search, color: colors.text),
                        fillColor: colors.light,
                        hintText: AppLocalizations.of(context).main_search_hint,
                        hintStyle: TextStyle(
                          color: colors.textLight,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        border: InputBorder.none,
                      ),
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
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkTutorialStatus();
  }

  Future<void> _checkTutorialStatus() async {
    final isTutorialCompleted = await TutorialService.isTutorialCompleted();
    setState(() {
      _isLoading = false;
    });

    // 튜토리얼이 완료되지 않았다면 홈 화면 로딩 후 튜토리얼 표시
    if (!isTutorialCompleted && mounted) {
      // 메인 쇼케이스를 한 번 요청
      TutorialService.requestMainShowcase();
      TutorialService.markTutorialCompleted();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Consumer<AuthService>(
      builder: (context, authService, child) {
        // 로그인 상태와 관계없이 메인 화면을 보여줌
        return MyHomePage(
          key: myHomePageKey,
          title: AppLocalizations.of(context).get('app_title'),
        );
      },
    );
  }
}
