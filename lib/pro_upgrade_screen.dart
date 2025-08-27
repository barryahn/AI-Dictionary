import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/theme_service.dart';
import 'services/pro_service.dart';

enum BillingCycle { monthly, yearly }

class ProUpgradeScreen extends StatefulWidget {
  const ProUpgradeScreen({super.key});

  @override
  State<ProUpgradeScreen> createState() => _ProUpgradeScreenState();
}

class _ProUpgradeScreenState extends State<ProUpgradeScreen> {
  BillingCycle _selectedCycle = BillingCycle.monthly;

  String get _priceLabel =>
      _selectedCycle == BillingCycle.monthly ? '월 ₩3,000' : '연 ₩20,000';

  void _select(BillingCycle cycle) {
    if (_selectedCycle != cycle) {
      setState(() {
        _selectedCycle = cycle;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeService = context.watch<ThemeService>();
    final colors = themeService.colors;
    final isPro = context.watch<ProService>().isPro;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pro'),
        backgroundColor: colors.background,
        iconTheme: IconThemeData(color: colors.text),
        elevation: 0,
      ),
      backgroundColor: colors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 8),
              isPro
                  ? Container(
                      width: 200,
                      height: 180,
                      alignment: Alignment.center,
                      child: const Text('🎉', style: TextStyle(fontSize: 100)),
                    )
                  : Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: colors.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: const Text('🚀', style: TextStyle(fontSize: 56)),
                    ),
              const SizedBox(height: 16),
              Text(
                isPro ? 'Pro를 구입해 주셔서 감사합니다.' : 'Pro로 업그레이드하세요.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: colors.text,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                isPro ? '오늘 하루도 행복하세요!' : '더 빠르고, 더 정확하고, 더 편리하게.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: colors.textLight,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 24),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Pro 혜택',
                  style: TextStyle(
                    color: colors.text,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Builder(
                builder: (context) {
                  final List<Map<String, String>> benefits = [
                    {'title': '무제한 검색', 'desc': '제한 없이 원하는 만큼 검색할 수 있어요.'},
                    {
                      'title': '더 높은 AI 모델',
                      'desc': '3배 이상 높은 정확도와 자연스러움을 느껴보세요.',
                    },
                    {'title': '더 긴 텍스트 번역', 'desc': '500자 제한이 3,000자로 확장돼요.'},
                    {'title': '고급 번역 품질', 'desc': '문맥과 뉘앙스를 더 잘 반영해요.'},
                    {'title': '광고 제거', 'desc': '깨끗하고 집중되는 화면을 제공해요.'},
                    {'title': '추가 기능', 'desc': '다가오는 업데이트 기능과 언어를 먼저 경험하세요.'},
                  ];
                  return Column(
                    children: benefits
                        .map(
                          (item) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  color: colors.primary,
                                  size: 24,
                                ),
                                const SizedBox(width: 20),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item['title']!,
                                        style: TextStyle(
                                          color: colors.text,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        item['desc']!,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: colors.textLight,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                  );
                },
              ),
              if (!isPro) const SizedBox(height: 24),
              if (!isPro)
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => _select(BillingCycle.monthly),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 16,
                          ),
                          decoration: BoxDecoration(
                            color: colors.background,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _selectedCycle == BillingCycle.monthly
                                  ? colors.primary
                                  : colors.textLight.withValues(alpha: 0.2),
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: Column(
                              children: [
                                Text(
                                  '월간',
                                  style: TextStyle(
                                    color: colors.text,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  '월 ₩3,000',
                                  style: TextStyle(
                                    color: colors.text.withValues(alpha: 0.8),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: InkWell(
                        onTap: () => _select(BillingCycle.yearly),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 16,
                          ),
                          decoration: BoxDecoration(
                            color: colors.background,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _selectedCycle == BillingCycle.yearly
                                  ? colors.primary
                                  : colors.textLight.withValues(alpha: 0.2),
                              width: 2,
                            ),
                          ),
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Center(
                                child: Column(
                                  children: [
                                    Text(
                                      '연간',
                                      style: TextStyle(
                                        color: colors.text,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          '연 ₩36,000',
                                          style: TextStyle(
                                            color: colors.textLight,
                                            fontSize: 10,
                                            decoration:
                                                TextDecoration.lineThrough,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '연 ₩20,000',
                                          style: TextStyle(
                                            color: colors.text.withValues(
                                              alpha: 0.8,
                                            ),
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Positioned(
                                right: -14,
                                top: -20,
                                child: Transform.rotate(
                                  angle: 0.2,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.orangeAccent,
                                      borderRadius: BorderRadius.circular(100),
                                    ),
                                    child: Text(
                                      '-44%',
                                      style: TextStyle(
                                        color: colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
      bottomNavigationBar: isPro
          ? null
          : SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '결제는 준비 중입니다.',
                            style: TextStyle(color: colors.white),
                          ),
                          backgroundColor: colors.primary,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.primary,
                      foregroundColor: colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Pro로 업그레이드',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          _priceLabel,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
