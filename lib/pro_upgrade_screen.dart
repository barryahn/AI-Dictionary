import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/theme_service.dart';
import 'l10n/app_localizations.dart';
import 'services/pro_service.dart';
import 'services/pricing_service.dart';
import 'package:intl/intl.dart';

enum BillingCycle { monthly, yearly }

class ProUpgradeScreen extends StatefulWidget {
  const ProUpgradeScreen({super.key});

  @override
  State<ProUpgradeScreen> createState() => _ProUpgradeScreenState();
}

class _ProUpgradeScreenState extends State<ProUpgradeScreen> {
  BillingCycle _selectedCycle = BillingCycle.monthly;

  String get _priceLabel => _selectedCycle == BillingCycle.monthly
      ? AppLocalizations.of(context).getWithParams('pro_monthly_price', {
          'currency': PricingService.getCurrencySymbol(
            AppLocalizations.of(context).locale,
          ),
          'price': NumberFormat('#,###.##').format(
            PricingService.getMonthlyPriceNumber(
              AppLocalizations.of(context).locale,
            ),
          ),
        })
      : AppLocalizations.of(context).getWithParams('pro_yearly_price', {
          'currency': PricingService.getCurrencySymbol(
            AppLocalizations.of(context).locale,
          ),
          'price': NumberFormat('#,###.##').format(
            PricingService.getYearlyPriceNumber(
              AppLocalizations.of(context).locale,
            ),
          ),
        });

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
                isPro
                    ? AppLocalizations.of(context).get('pro_thank_you')
                    : AppLocalizations.of(context).get('pro_headline'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: colors.text,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                isPro
                    ? AppLocalizations.of(context).get('pro_subtitle_thanks')
                    : AppLocalizations.of(context).get('pro_subtitle'),
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
                  AppLocalizations.of(context).get('pro_benefits_title'),
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
                  final loc = AppLocalizations.of(context);
                  final List<Map<String, String>> benefits = [
                    {
                      'title': loc.get('pro_benefit_unlimited_title'),
                      'desc': loc.get('pro_benefit_unlimited_desc'),
                    },
                    {
                      'title': loc.get('pro_benefit_better_model_title'),
                      'desc': loc.get('pro_benefit_better_model_desc'),
                    },
                    {
                      'title': loc.get('pro_benefit_longer_text_title'),
                      'desc': loc.get('pro_benefit_longer_text_desc'),
                    },
                    {
                      'title': loc.get('pro_benefit_quality_title'),
                      'desc': loc.get('pro_benefit_quality_desc'),
                    },
                    {
                      'title': loc.get('pro_benefit_no_ads_title'),
                      'desc': loc.get('pro_benefit_no_ads_desc'),
                    },
                    {
                      'title': loc.get('pro_benefit_extras_title'),
                      'desc': loc.get('pro_benefit_extras_desc'),
                    },
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
                                  AppLocalizations.of(
                                    context,
                                  ).get('pro_monthly'),
                                  style: TextStyle(
                                    color: colors.text,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  AppLocalizations.of(
                                    context,
                                  ).getWithParams('pro_monthly_price', {
                                    'currency':
                                        PricingService.getCurrencySymbol(
                                          AppLocalizations.of(context).locale,
                                        ),
                                    'price': NumberFormat('#,###.##').format(
                                      PricingService.getMonthlyPriceNumber(
                                        AppLocalizations.of(context).locale,
                                      ),
                                    ),
                                  }),
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
                    const SizedBox(width: 10),
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
                                      AppLocalizations.of(
                                        context,
                                      ).get('pro_yearly'),
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
                                          '${PricingService.getCurrencySymbol(AppLocalizations.of(context).locale)} ${NumberFormat('#,###.##').format(PricingService.getMonthlyPriceNumber(AppLocalizations.of(context).locale) * 12)}',
                                          style: TextStyle(
                                            color: colors.textLight,
                                            fontSize: 10,
                                            decoration:
                                                TextDecoration.lineThrough,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          AppLocalizations.of(
                                            context,
                                          ).getWithParams('pro_yearly_price', {
                                            'currency':
                                                PricingService.getCurrencySymbol(
                                                  AppLocalizations.of(
                                                    context,
                                                  ).locale,
                                                ),
                                            'price': NumberFormat('#,###.##')
                                                .format(
                                                  PricingService.getYearlyPriceNumber(
                                                    AppLocalizations.of(
                                                      context,
                                                    ).locale,
                                                  ),
                                                ),
                                          }),
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
                        Text(
                          AppLocalizations.of(context).get('pro_upgrade_cta'),
                          style: const TextStyle(
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
