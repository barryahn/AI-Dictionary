import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'search_result_screen.dart';
import 'services/theme_service.dart';
import 'theme/app_theme.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  @override
  Widget build(BuildContext context) {
    final themeService = context.watch<ThemeService>();
    final colors = themeService.colors;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Text(
          '탐색',
          style: TextStyle(color: colors.text, fontWeight: FontWeight.bold),
        ),
        backgroundColor: colors.background,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 오늘의 추천 단어
            _buildWordOfTheDay(colors),
            const SizedBox(height: 30),

            // 인기 검색어 섹션
            _buildPopularSearches(colors),
            const SizedBox(height: 30),

            // 카테고리별 단어 섹션
            _buildWordCategories(colors),
            const SizedBox(height: 30),

            // 언어 학습 팁
            _buildLanguageTips(colors),
            const SizedBox(height: 30),

            // 최근 트렌드 단어
            _buildTrendingWords(colors),
            const SizedBox(height: 30),

            // 학습 통계
            _buildLearningStats(colors),
          ],
        ),
      ),
    );
  }

  Widget _buildWordOfTheDay(CustomColors colors) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colors.accent, colors.light],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.dark.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.star, color: colors.highlight, size: 28),
              const SizedBox(width: 12),
              Text(
                '오늘의 추천 단어',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: colors.text,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'Serendipity',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: colors.text,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '우연한 발견, 뜻밖의 행운',
            style: TextStyle(fontSize: 18, color: colors.textLight),
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
                  color: colors.background.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '영어',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: colors.text,
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
                  backgroundColor: colors.highlight,
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

  Widget _buildPopularSearches(CustomColors colors) {
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
            Icon(Icons.trending_up, color: colors.highlight, size: 24),
            const SizedBox(width: 8),
            Text(
              '인기 검색어',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: colors.text,
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
                    color: colors.light,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: colors.dark.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        word['word']!,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: colors.text,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        word['meaning']!,
                        style: TextStyle(fontSize: 15, color: colors.textLight),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: colors.accent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          word['language']!,
                          style: TextStyle(
                            fontSize: 12,
                            color: colors.text,
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

  Widget _buildWordCategories(CustomColors colors) {
    final categories = [
      {
        'name': '일상생활',
        'icon': Icons.home,
        'color': colors.highlight,
        'words': '가족, 음식, 집',
      },
      {
        'name': '비즈니스',
        'icon': Icons.business,
        'color': colors.primary,
        'words': '회의, 프로젝트, 협력',
      },
      {
        'name': '여행',
        'icon': Icons.flight,
        'color': colors.divider,
        'words': '호텔, 관광, 교통',
      },
      {
        'name': '감정',
        'icon': Icons.favorite,
        'color': colors.highlight,
        'words': '기쁨, 슬픔, 사랑',
      },
      {
        'name': '학습',
        'icon': Icons.school,
        'color': colors.primary,
        'words': '공부, 시험, 지식',
      },
      {
        'name': '취미',
        'icon': Icons.sports_esports,
        'color': colors.divider,
        'words': '운동, 음악, 독서',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.category, color: colors.highlight, size: 24),
            const SizedBox(width: 8),
            Text(
              '카테고리별 단어',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: colors.text,
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
                  color: colors.light,
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
                        color: colors.text,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      category['words'] as String,
                      style: TextStyle(fontSize: 12, color: colors.textLight),
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

  Widget _buildLanguageTips(CustomColors colors) {
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
            Icon(Icons.lightbulb, color: colors.highlight, size: 24),
            const SizedBox(width: 8),
            Text(
              '언어 학습 팁',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: colors.text,
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
                color: colors.light,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colors.dark.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colors.accent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      tip['icon'] as IconData,
                      color: colors.text,
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
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: colors.text,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          tip['description'] as String,
                          style: TextStyle(
                            fontSize: 14,
                            color: colors.textLight,
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

  Widget _buildTrendingWords(CustomColors colors) {
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
            Icon(Icons.trending_up, color: colors.highlight, size: 24),
            const SizedBox(width: 8),
            Text(
              '트렌드 단어',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: colors.text,
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
                  color: colors.light,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colors.dark.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: colors.accent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: colors.text,
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
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: colors.text,
                            ),
                          ),
                          Text(
                            word['meaning']!,
                            style: TextStyle(
                              fontSize: 14,
                              color: colors.textLight,
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
                        color: colors.highlight,
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

  Widget _buildLearningStats(CustomColors colors) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.light,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.dark.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.analytics, color: colors.highlight, size: 24),
              const SizedBox(width: 8),
              Text(
                '학습 통계',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: colors.text,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _buildStatItem('오늘 학습', '12', '단어', colors)),
              Expanded(child: _buildStatItem('이번 주', '89', '단어', colors)),
              Expanded(child: _buildStatItem('총 학습', '1,247', '단어', colors)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String title,
    String value,
    String unit,
    CustomColors colors,
  ) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: colors.highlight,
          ),
        ),
        const SizedBox(height: 4),
        Text(unit, style: TextStyle(fontSize: 14, color: colors.textLight)),
        const SizedBox(height: 4),
        Text(title, style: TextStyle(fontSize: 12, color: colors.textLight)),
      ],
    );
  }
}
