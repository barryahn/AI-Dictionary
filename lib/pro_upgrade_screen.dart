import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/theme_service.dart';

class ProUpgradeScreen extends StatelessWidget {
  const ProUpgradeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeService = context.watch<ThemeService>();
    final colors = themeService.colors;

    return Scaffold(
      appBar: AppBar(
        title: const Text('PRO'),
        backgroundColor: colors.background,
        iconTheme: IconThemeData(color: colors.text),
        elevation: 0,
      ),
      backgroundColor: colors.background,
      body: Center(
        child: Text(
          'pro로 업그레이드하세요.',
          style: TextStyle(color: colors.text, fontSize: 18),
        ),
      ),
    );
  }
}
