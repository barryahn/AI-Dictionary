import 'dart:io';

import 'package:flutter/material.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ai_dictionary/l10n/app_localizations.dart';

class ReviewService {
  static const String _reviewPromptShownKey = 'review_prompt_shown_v1';

  // ignore: unused_element
  static Future<bool> _wasPromptShown() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_reviewPromptShownKey) ?? false;
  }

  static Future<void> _markPromptShown() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_reviewPromptShownKey, true);
  }

  static Future<void> maybePromptForReview(BuildContext context) async {
    try {
      // 안드로이드에서만 진행 (요청 사항에 따라 Play 스토어로 유도)
      if (!Platform.isAndroid) return;

      final alreadyShown = await _wasPromptShown();
      if (alreadyShown) return;

      await _markPromptShown();

      if (!context.mounted) return;
      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: false,
        useSafeArea: true,
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        builder: (ctx) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 60),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: Text('🤩', style: TextStyle(fontSize: 48))),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    AppLocalizations.of(ctx).review_thanks_first_search,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                MySeparator(
                  color:
                      Theme.of(
                        ctx,
                      ).textTheme.bodyMedium?.color?.withValues(alpha: 0.2) ??
                      Colors.grey,
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Text(
                      AppLocalizations.of(ctx).review_like_app_question,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  AppLocalizations.of(ctx).review_recommend_play_store,
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: Icon(
                        Icons.star_rate_rounded,
                        color: Theme.of(ctx).colorScheme.primary,
                        size: 50,
                      ),
                    ),
                    Expanded(
                      child: Icon(
                        Icons.star_rate_rounded,
                        color: Theme.of(ctx).colorScheme.primary,
                        size: 50,
                      ),
                    ),
                    Expanded(
                      child: Icon(
                        Icons.star_rate_rounded,
                        color: Theme.of(ctx).colorScheme.primary,
                        size: 50,
                      ),
                    ),
                    Expanded(
                      child: Icon(
                        Icons.star_rate_rounded,
                        color: Theme.of(ctx).colorScheme.primary,
                        size: 50,
                      ),
                    ),
                    Expanded(
                      child: Icon(
                        Icons.star_rate_rounded,
                        color: Theme.of(ctx).colorScheme.primary,
                        size: 50,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: Theme.of(ctx).colorScheme.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () async {
                          Navigator.of(ctx).pop();
                          await _requestReviewOrOpenStore();
                        },
                        child: Text(
                          AppLocalizations.of(ctx).review_rate_now,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
              ],
            ),
          );
        },
      );
    } catch (_) {
      // 조용히 무시: UX 방해하지 않음
    }
  }

  static Future<void> _requestReviewOrOpenStore() async {
    final inAppReview = InAppReview.instance;
    try {
      final isAvailable = await inAppReview.isAvailable();
      if (isAvailable) {
        await inAppReview.requestReview();
        return;
      }
    } catch (_) {
      // fallthrough to open store listing
    }

    try {
      await InAppReview.instance.openStoreListing();
    } catch (_) {
      // 마지막까지 실패하면 무시
    }
  }
}

class MySeparator extends StatelessWidget {
  const MySeparator({Key? key, this.height = 1, this.color = Colors.black})
    : super(key: key);
  final double height;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final boxWidth = constraints.constrainWidth();
        const dashWidth = 10.0;
        final dashHeight = height;
        final dashCount = (boxWidth / (2 * dashWidth)).floor();
        return Flex(
          children: List.generate(dashCount, (_) {
            return SizedBox(
              width: dashWidth,
              height: dashHeight,
              child: DecoratedBox(decoration: BoxDecoration(color: color)),
            );
          }),
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          direction: Axis.horizontal,
        );
      },
    );
  }
}
