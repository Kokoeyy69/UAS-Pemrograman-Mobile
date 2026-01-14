import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:easy_localization/easy_localization.dart'; // 1. Import Wajib

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Widget providing quick action shortcuts for card management
class QuickActionsWidget extends StatelessWidget {
  final VoidCallback onViewPin;
  final VoidCallback onReportLost;
  final VoidCallback onRequestReplacement;
  final VoidCallback onUpdateExpiry;

  const QuickActionsWidget({
    Key? key,
    required this.onViewPin,
    required this.onReportLost,
    required this.onRequestReplacement,
    required this.onUpdateExpiry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            // ✅ TRANSLATE: Quick Actions
            'quick_actions_card_title'.tr(),
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 2.h),

          GridView.count(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 2.h,
            crossAxisSpacing: 3.w,
            childAspectRatio: 1.5,
            children: [
              _buildActionCard(
                context: context,
                theme: theme,
                icon: 'lock',
                // ✅ TRANSLATE: View PIN
                title: 'quick_actions_view_pin_title'.tr(),
                subtitle: 'quick_actions_view_pin_subtitle'.tr(),
                color: theme.colorScheme.primary,
                onTap: onViewPin,
              ),
              _buildActionCard(
                context: context,
                theme: theme,
                icon: 'report_problem',
                // ✅ TRANSLATE: Report Lost
                title: 'quick_actions_report_lost_title'.tr(),
                subtitle: 'quick_actions_report_lost_subtitle'.tr(),
                color: theme.colorScheme.error,
                onTap: onReportLost,
              ),
              _buildActionCard(
                context: context,
                theme: theme,
                icon: 'credit_card',
                // ✅ TRANSLATE: Replace Card
                title: 'quick_actions_replace_card_title'.tr(),
                subtitle: 'quick_actions_replace_card_subtitle'.tr(),
                color: theme.colorScheme.secondary,
                onTap: onRequestReplacement,
              ),
              _buildActionCard(
                context: context,
                theme: theme,
                icon: 'notifications',
                // ✅ TRANSLATE: Expiry Alert
                title: 'quick_actions_expiry_alert_title'.tr(),
                subtitle: 'quick_actions_expiry_alert_subtitle'.tr(),
                color: theme.colorScheme.tertiary,
                onTap: onUpdateExpiry,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required BuildContext context,
    required ThemeData theme,
    required String icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: CustomIconWidget(iconName: icon, color: color, size: 24),
            ),
            SizedBox(height: 1.5.h),
            Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 0.5.h),
            Text(
              subtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}