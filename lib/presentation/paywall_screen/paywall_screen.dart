import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../core/app_export.dart';

class PaywallScreen extends StatelessWidget {
  final String? triggerSource;

  const PaywallScreen({Key? key, this.triggerSource}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: theme.colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 6.w),
          child: Column(
            children: [
              SizedBox(height: 2.h),
              Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: CustomIconWidget(
                  iconName: 'workspace_premium',
                  color: theme.colorScheme.primary,
                  size: 12.w,
                ),
              ),
              SizedBox(height: 3.h),
              Text(
                'Upgrade to Pro',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 1.h),
              Text(
                'Unlock unlimited plant care',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              SizedBox(height: 4.h),
              _FeatureRow(
                icon: 'photo_camera',
                title: 'Unlimited Plant ID',
                subtitle: 'Identify as many plants as you want',
                freeText: '5/day',
                proText: 'Unlimited',
                theme: theme,
              ),
              _FeatureRow(
                icon: 'yard',
                title: 'Unlimited Plants',
                subtitle: 'Track your entire garden',
                freeText: '3 plants',
                proText: 'Unlimited',
                theme: theme,
              ),
              _FeatureRow(
                icon: 'smart_toy',
                title: 'AI Diagnosis',
                subtitle: 'Advanced AI recovery plans',
                freeText: 'Basic',
                proText: 'Advanced',
                theme: theme,
              ),
              _FeatureRow(
                icon: 'bar_chart',
                title: 'Analytics',
                subtitle: 'Track growth and care trends',
                freeText: '—',
                proText: 'Included',
                theme: theme,
              ),
              _FeatureRow(
                icon: 'block',
                title: 'No Ads',
                subtitle: 'Clean, distraction-free experience',
                freeText: 'Ads',
                proText: 'None',
                theme: theme,
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    padding: EdgeInsets.symmetric(vertical: 2.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    '\$29.99/year',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 1.h),
              TextButton(
                onPressed: () {},
                child: Text(
                  'Restore Purchase',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              SizedBox(height: 2.h),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final String icon;
  final String title;
  final String subtitle;
  final String freeText;
  final String proText;
  final ThemeData theme;

  const _FeatureRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.freeText,
    required this.proText,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 1.h),
      child: Row(
        children: [
          CustomIconWidget(
            iconName: icon,
            color: theme.colorScheme.primary,
            size: 6.w,
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
            decoration: BoxDecoration(
              color: theme.colorScheme.errorContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              freeText,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ),
          Icon(Icons.chevron_right, color: theme.colorScheme.onSurfaceVariant, size: 4.w),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              proText,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
