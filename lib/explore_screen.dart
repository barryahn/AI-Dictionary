import 'package:flutter/material.dart';
import 'search_result_screen.dart';

// 베이지 색상 팔레트 정의
class BeigeColors {
  static const Color primary = Color(0xFFD4C4A8); // 메인 베이지
  static const Color extraLight = Color(0xFFF9F5ED); // 더 밝은 베이지
  static const Color light = Color(0xFFF5F1E8); // 밝은 베이지
  static const Color dark = Color(0xFFB8A898); // 어두운 베이지
  static const Color accent = Color(0xFFE8DCC0); // 액센트 베이지
  static const Color text = Color(0xFF5D4E37); // 텍스트 색상
  static const Color textLight = Color(0xFF8B7355); // 밝은 텍스트
  static const Color background = Color(0xFFFDFBF7); // 배경색
  static const Color divider = Color(0xFFE07A5F); // 구분선 색상
  static const Color highlight = Color(0xFFE07A5F); // 하이라이트 색상
}

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BeigeColors.background,
      appBar: AppBar(
        title: const Text(
          '탐색',
          style: TextStyle(
            color: BeigeColors.text,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: BeigeColors.background,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 오늘의 추천 단어
            _buildWordOfTheDay(),
            const SizedBox(height: 30),

            // 인기 검색어 섹션
            _buildPopularSearches(),
            const SizedBox(height: 30),

            // 카테고리별 단어 섹션
            _buildWordCategories(),
            const SizedBox(height: 30),

            // 언어 학습 팁
            _buildLanguageTips(),
            const SizedBox(height: 30),

            // 최근 트렌드 단어
            _buildTrendingWords(),
            const SizedBox(height: 30),

            // 학습 통계
            _buildLearningStats(),
          ],
        ),
      ),
    );
  }

  Widget _buildWordOfTheDay() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [BeigeColors.accent, BeigeColors.light],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: BeigeColors.dark.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.star, color: BeigeColors.highlight, size: 28),
              const SizedBox(width: 12),
              const Text(
                '오늘의 추천 단어',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: BeigeColors.text,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'Serendipity',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: BeigeColors.text,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '우연한 발견, 뜻밖의 행운',
            style: TextStyle(fontSize: 18, color: BeigeColors.textLight),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: BeigeColors.background.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  '영어',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: BeigeColors.text,
                  ),
                ),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const SearchResultScreen(initialQuery: 'Serendipity'),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: BeigeColors.highlight,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text('자세히 보기'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPopularSearches() {
    final popularWords = [
      {'word': 'Hello', 'meaning': '안녕하세요', 'language': '영어'},
      {'word': 'Bonjour', 'meaning': '안녕하세요', 'language': '프랑스어'},
      {'word': 'Hola', 'meaning': '안녕하세요', 'language': '스페인어'},
      {'word': '你好', 'meaning': '안녕하세요', 'language': '중국어'},
      {'word': 'こんにちは', 'meaning': '안녕하세요', 'language': '일본어'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.trending_up, color: BeigeColors.highlight, size: 24),
            const SizedBox(width: 8),
            const Text(
              '인기 검색어',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: BeigeColors.text,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: popularWords.length,
            itemBuilder: (context, index) {
              final word = popularWords[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          SearchResultScreen(initialQuery: word['word']!),
                    ),
                  );
                },
                child: Container(
                  width: 160,
                  margin: const EdgeInsets.only(right: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: BeigeColors.light,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: BeigeColors.dark.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        word['word']!,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: BeigeColors.text,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        word['meaning']!,
                        style: TextStyle(
                          fontSize: 15,
                          color: BeigeColors.textLight,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: BeigeColors.accent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          word['language']!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: BeigeColors.text,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildWordCategories() {
    final categories = [
      {
        'name': '일상생활',
        'icon': Icons.home,
        'color': BeigeColors.highlight,
        'words': '가족, 음식, 집',
      },
      {
        'name': '비즈니스',
        'icon': Icons.business,
        'color': BeigeColors.primary,
        'words': '회의, 프로젝트, 협력',
      },
      {
        'name': '여행',
        'icon': Icons.flight,
        'color': BeigeColors.divider,
        'words': '호텔, 관광, 교통',
      },
      {
        'name': '감정',
        'icon': Icons.favorite,
        'color': BeigeColors.highlight,
        'words': '기쁨, 슬픔, 사랑',
      },
      {
        'name': '학습',
        'icon': Icons.school,
        'color': BeigeColors.primary,
        'words': '공부, 시험, 지식',
      },
      {
        'name': '취미',
        'icon': Icons.sports_esports,
        'color': BeigeColors.divider,
        'words': '운동, 음악, 독서',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.category, color: BeigeColors.highlight, size: 24),
            const SizedBox(width: 8),
            const Text(
              '카테고리별 단어',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: BeigeColors.text,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.3,
          ),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            final color = category['color'] as Color;
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SearchResultScreen(
                      initialQuery: (category['words'] as String)
                          .split(', ')
                          .first,
                    ),
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: BeigeColors.light,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: color.withValues(alpha: 0.4)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(category['icon'] as IconData, size: 36, color: color),
                    const SizedBox(height: 12),
                    Text(
                      category['name'] as String,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: BeigeColors.text,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      category['words'] as String,
                      style: TextStyle(
                        fontSize: 12,
                        color: BeigeColors.textLight,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildLanguageTips() {
    final tips = [
      {
        'title': '매일 10분씩 학습하기',
        'description': '짧은 시간이라도 꾸준히 학습하는 것이 중요합니다',
        'icon': Icons.schedule,
      },
      {
        'title': '실제 대화에서 사용하기',
        'description': '배운 단어를 실제 상황에서 사용해보세요',
        'icon': Icons.chat,
      },
      {
        'title': '문장 속에서 기억하기',
        'description': '단어를 문장과 함께 기억하면 더 오래 기억됩니다',
        'icon': Icons.text_fields,
      },
      {
        'title': '발음 연습하기',
        'description': '소리 내어 따라하며 발음을 익혀보세요',
        'icon': Icons.record_voice_over,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.lightbulb, color: BeigeColors.highlight, size: 24),
            const SizedBox(width: 8),
            const Text(
              '언어 학습 팁',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: BeigeColors.text,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: tips.length,
          itemBuilder: (context, index) {
            final tip = tips[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: BeigeColors.light,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: BeigeColors.dark.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: BeigeColors.accent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      tip['icon'] as IconData,
                      color: BeigeColors.text,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tip['title'] as String,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: BeigeColors.text,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          tip['description'] as String,
                          style: TextStyle(
                            fontSize: 14,
                            color: BeigeColors.textLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildTrendingWords() {
    final trendingWords = [
      {'word': 'Sustainability', 'trend': '+15%', 'meaning': '지속가능성'},
      {'word': 'Metaverse', 'trend': '+23%', 'meaning': '메타버스'},
      {'word': 'Cryptocurrency', 'trend': '+8%', 'meaning': '암호화폐'},
      {'word': 'Artificial Intelligence', 'trend': '+31%', 'meaning': '인공지능'},
      {'word': 'Blockchain', 'trend': '+12%', 'meaning': '블록체인'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.trending_up, color: BeigeColors.highlight, size: 24),
            const SizedBox(width: 8),
            const Text(
              '트렌드 단어',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: BeigeColors.text,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: trendingWords.length,
          itemBuilder: (context, index) {
            final word = trendingWords[index];
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        SearchResultScreen(initialQuery: word['word']!),
                  ),
                );
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: BeigeColors.light,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: BeigeColors.dark.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: BeigeColors.accent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: BeigeColors.text,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            word['word']!,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: BeigeColors.text,
                            ),
                          ),
                          Text(
                            word['meaning']!,
                            style: TextStyle(
                              fontSize: 14,
                              color: BeigeColors.textLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: BeigeColors.highlight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        word['trend']!,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildLearningStats() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: BeigeColors.light,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: BeigeColors.dark.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.analytics, color: BeigeColors.highlight, size: 24),
              const SizedBox(width: 8),
              const Text(
                '학습 통계',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: BeigeColors.text,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _buildStatItem('오늘 학습', '12', '단어')),
              Expanded(child: _buildStatItem('이번 주', '89', '단어')),
              Expanded(child: _buildStatItem('총 학습', '1,247', '단어')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String title, String value, String unit) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: BeigeColors.highlight,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          unit,
          style: TextStyle(fontSize: 14, color: BeigeColors.textLight),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(fontSize: 12, color: BeigeColors.textLight),
        ),
      ],
    );
  }
}
