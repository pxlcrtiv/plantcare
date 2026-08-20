import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../services/plant_ai_service.dart';

class AiScheduleSuggestionCard extends StatelessWidget {
  const AiScheduleSuggestionCard({
    super.key,
    required this.suggestion,
    required this.onConfirm,
    required this.onTryAgain,
    required this.onCancel,
  });

  final ScheduleSuggestion suggestion;
  final VoidCallback onConfirm;
  final VoidCallback onTryAgain;
  final VoidCallback onCancel;

  static String frequencyLabel(int days) {
    if (days == 1) return 'Daily';
    if (days == 7) return 'Weekly';
    if (days == 14) return 'Bi-weekly';
    if (days == 30) return 'Monthly';
    return 'Every $days days';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
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
            children: [
              Container(
                padding: EdgeInsets.all(2.5.w),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.auto_awesome,
                  size: 5.w,
                  color: colorScheme.primary,
                ),
              ),
              SizedBox(width: 3.w),
              Flexible(
                child: Text(
                  'Suggested schedule',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          _scheduleRow(
            context,
            'Watering',
            frequencyLabel(suggestion.wateringFrequency),
          ),
          if (suggestion.fertilizingEnabled) ...[
            SizedBox(height: 1.h),
            _scheduleRow(
              context,
              'Fertilizing',
              frequencyLabel(suggestion.fertilizingFrequency),
            ),
          ],
          if (suggestion.mistingEnabled) ...[
            SizedBox(height: 1.h),
            _scheduleRow(
              context,
              'Misting',
              frequencyLabel(suggestion.mistingFrequency),
            ),
          ],
          if (suggestion.rotatingEnabled) ...[
            SizedBox(height: 1.h),
            _scheduleRow(
              context,
              'Rotating',
              frequencyLabel(suggestion.rotatingFrequency),
            ),
          ],
          if (suggestion.reason != null && suggestion.reason!.isNotEmpty) ...[
            SizedBox(height: 2.h),
            Text(
              suggestion.reason!,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.white70 : const Color(0xFF888888),
              ),
            ),
          ],
          SizedBox(height: 2.h),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onTryAgain,
                  child: const Text('Try again'),
                ),
              ),
              SizedBox(width: 2.w),
              TextButton(
                onPressed: onCancel,
                child: const Text('Cancel'),
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: FilledButton(
                  onPressed: onConfirm,
                  child: const Text('Confirm'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _scheduleRow(BuildContext context, String label, String value) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
        ),
      ],
    );
  }
}