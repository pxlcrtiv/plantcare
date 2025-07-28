import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class QuickActionsSheetWidget extends StatelessWidget {
  final Map<String, dynamic> plant;
  final VoidCallback onWaterNow;
  final VoidCallback onViewDetails;
  final VoidCallback onEdit;
  final VoidCallback onRemove;

  const QuickActionsSheetWidget({
    Key? key,
    required this.plant,
    required this.onWaterNow,
    required this.onViewDetails,
    required this.onEdit,
    required this.onRemove,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Theme.of(context).bottomSheetTheme.backgroundColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 12.w,
            height: 0.5.h,
            decoration: BoxDecoration(
              color: Theme.of(context).dividerColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(height: 3.h),
          // Plant Info
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CustomImageWidget(
                  imageUrl: plant['image'] as String? ?? '',
                  width: 15.w,
                  height: 15.w,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plant['name'] as String? ?? 'Unknown Plant',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      plant['species'] as String? ?? 'Unknown Species',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          // Actions
          Column(
            children: [
              _buildActionTile(
                context,
                icon: 'water_drop',
                title: 'Water Now',
                subtitle: 'Mark as watered today',
                color: AppTheme.getSuccessColor(isDarkMode),
                onTap: () {
                  Navigator.pop(context);
                  onWaterNow();
                },
              ),
              _buildActionTile(
                context,
                icon: 'visibility',
                title: 'View Details',
                subtitle: 'See full plant information',
                color: Theme.of(context).colorScheme.primary,
                onTap: () {
                  Navigator.pop(context);
                  onViewDetails();
                },
              ),
              _buildActionTile(
                context,
                icon: 'edit',
                title: 'Edit Plant',
                subtitle: 'Update plant information',
                color: AppTheme.getWarningColor(isDarkMode),
                onTap: () {
                  Navigator.pop(context);
                  onEdit();
                },
              ),
              _buildActionTile(
                context,
                icon: 'delete',
                title: 'Remove Plant',
                subtitle: 'Delete from your collection',
                color: Theme.of(context).colorScheme.error,
                onTap: () {
                  Navigator.pop(context);
                  onRemove();
                },
              ),
            ],
          ),
          SizedBox(height: 2.h),
        ],
      ),
    );
  }

  Widget _buildActionTile(
    BuildContext context, {
    required String icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: EdgeInsets.all(2.w),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: CustomIconWidget(
          iconName: icon,
          color: color,
          size: 6.w,
        ),
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
      ),
      subtitle: Text(
        subtitle,
        style: Theme.of(context).textTheme.bodySmall,
      ),
      trailing: CustomIconWidget(
        iconName: 'chevron_right',
        color: Theme.of(context).colorScheme.onSurfaceVariant,
        size: 5.w,
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}
