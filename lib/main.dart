import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'search_result_screen.dart';
import 'search_history_screen.dart';
import 'profile_screen.dart';
import 'services/language_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// 앱의 진입점
void main() async {
  await dotenv.load(fileName: ".env");
  await LanguageService.initialize(); // 언어 서비스 초기화
  runApp(const MyApp());
}

// 앱의 기본 설정을 정의하는 StatelessWidget
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
      ),
      home: const MyHomePage(title: 'AI Dictionary'),
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
      const Center(child: Text('Explore Page')),
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
      body: IndexedStack(index: _selectedIndex, children: _widgetOptions),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.explore), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
        ],
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
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
  final List<String> languages = ['영어', '한국어', '중국어', '스페인어', '프랑스어'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'AI Dictionary',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
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
                  width: 160,
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
                      items: languages
                          // .where((item) => item != selectedToLanguage) // 이 부분을 잠시 제거하여 모든 언어 표시
                          .map(
                            (String item) => DropdownMenuItem<String>(
                              value: item,
                              child: Text(
                                item,
                                style: const TextStyle(fontSize: 20),
                              ),
                            ),
                          )
                          .toList(),
                      value: selectedFromLanguage,
                      onChanged: (String? newValue) {
                        if (newValue == null) return;
                        setState(() {
                          if (newValue == selectedToLanguage) {
                            // 같은 언어를 선택하면 서로 위치를 바꿈
                            selectedToLanguage = selectedFromLanguage;
                          }
                          selectedFromLanguage = newValue;
                        });
                      },
                      buttonStyleData: const ButtonStyleData(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        height: 40,
                        width: 140,
                      ),
                      menuItemStyleData: const MenuItemStyleData(height: 40),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      final temp = selectedFromLanguage;
                      selectedFromLanguage = selectedToLanguage;
                      selectedToLanguage = temp;
                    });
                  },
                  child: const Icon(Icons.arrow_forward_ios),
                ),
                const SizedBox(width: 20),
                // 도착 언어 선택 드롭다운
                SizedBox(
                  width: 160,
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
                      items: languages
                          // .where((item) => item != selectedFromLanguage) // 이 부분을 잠시 제거하여 모든 언어 표시
                          .map(
                            (String item) => DropdownMenuItem<String>(
                              value: item,
                              child: Text(
                                item,
                                style: const TextStyle(fontSize: 20),
                              ),
                            ),
                          )
                          .toList(),
                      value: selectedToLanguage,
                      onChanged: (String? newValue) {
                        if (newValue == null) return;
                        setState(() {
                          if (newValue == selectedFromLanguage) {
                            // 같은 언어를 선택하면 서로 위치를 바꿈
                            selectedFromLanguage = selectedToLanguage;
                          }
                          selectedToLanguage = newValue;
                        });
                      },
                      buttonStyleData: const ButtonStyleData(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        height: 40,
                        width: 140,
                      ),
                      menuItemStyleData: const MenuItemStyleData(height: 40),
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
                    builder: (context) => const SearchResultScreen(),
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: const IgnorePointer(
                  child: TextField(
                    decoration: InputDecoration(
                      icon: Icon(Icons.search),
                      hintText: 'Search',
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
