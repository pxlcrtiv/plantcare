import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../services/plant_ai_service.dart';

class AiErrorCard extends StatelessWidget {
  const AiErrorCard({super.key, required this.error, this.onRetry});

  final PlantAiException error;
  final VoidCallback? onRetry;

  static String titleFor(PlantAiException error) => switch (error) {
        QuotaExceededError() => 'The assistant is resting',
        BlockedError() => 'The assistant could not answer',
        TimeoutError() => 'The assistant took too long',
        MalformedOutputError() => 'The assistant is resting',
        OfflineError() => "You're offline",
        UnknownError() => 'Something went wrong',
      };

  static String messageFor(PlantAiException error) => switch (error) {
        QuotaExceededError() => 'Try again in a moment.',
        BlockedError() => 'Try rephrasing or summarize again.',
        TimeoutError() => 'Try again in a moment.',
        MalformedOutputError() => 'Try again in a moment.',
        OfflineError() => 'Connect to the internet and try again.',
        UnknownError() => 'Try again in a moment.',
      };

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: isDark ? Theme.of(context).cardColor : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(2.5.w),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.self_improvement,
                  size: 5.w,
                  color: colorScheme.primary,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titleFor(error),
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    SizedBox(height: 0.3.h),
                    Text(
                      messageFor(error),
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white70 : const Color(0xFF888888),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (onRetry != null) ...[
            SizedBox(height: 1.5.h),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: onRetry,
                child: const Text('Try again'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}