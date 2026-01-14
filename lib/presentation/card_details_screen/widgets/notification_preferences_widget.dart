import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:easy_localization/easy_localization.dart'; // 1. Import Wajib

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Widget for managing card notification preferences
class NotificationPreferencesWidget extends StatefulWidget {
  final Map<String, bool> preferences;
  final Function(String, bool) onPreferenceChanged;

  const NotificationPreferencesWidget({
    Key? key,
    required this.preferences,
    required this.onPreferenceChanged,
  }) : super(key: key);

  @override
  State<NotificationPreferencesWidget> createState() =>
      _NotificationPreferencesWidgetState();
}

class _NotificationPreferencesWidgetState
    extends State<NotificationPreferencesWidget> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            // ✅ TRANSLATE: Notification Preferences
            'notifications_pref_title'.tr(),
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 2.h),

          _buildPreferenceItem(
            theme: theme,
            icon: 'notifications_active',
            // ✅ TRANSLATE: Transaction Alerts
            title: 'notifications_pref_txn_alerts_title'.tr(),
            subtitle: 'notifications_pref_txn_alerts_subtitle'.tr(),
            preferenceKey: 'transactionAlerts',
          ),

          SizedBox(height: 1.5.h),

          _buildPreferenceItem(
            theme: theme,
            icon: 'location_on',
            // ✅ TRANSLATE: Location Verification
            title: 'notifications_pref_location_title'.tr(),
            subtitle: 'notifications_pref_location_subtitle'.tr(),
            preferenceKey: 'locationVerification',
          ),

          SizedBox(height: 1.5.h),

          _buildPreferenceItem(
            theme: theme,
            icon: 'security',
            // ✅ TRANSLATE: Security Alerts
            title: 'notifications_pref_security_title'.tr(),
            subtitle: 'notifications_pref_security_subtitle'.tr(),
            preferenceKey: 'securityAlerts',
          ),

          SizedBox(height: 1.5.h),

          _buildPreferenceItem(
            theme: theme,
            icon: 'account_balance',
            // ✅ TRANSLATE: Balance Updates
            title: 'notifications_pref_balance_title'.tr(),
            subtitle: 'notifications_pref_balance_subtitle'.tr(),
            preferenceKey: 'balanceUpdates',
          ),
        ],
      ),
    );
  }

  Widget _buildPreferenceItem({
    required ThemeData theme,
    required String icon,
    required String title,
    required String subtitle,
    required String preferenceKey,
  }) {
    final isEnabled = widget.preferences[preferenceKey] ?? false;

    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: isEnabled
            ? theme.colorScheme.primary.withValues(alpha: 0.05)
            : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isEnabled
              ? theme.colorScheme.primary.withValues(alpha: 0.3)
              : theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: isEnabled
                  ? theme.colorScheme.primary.withValues(alpha: 0.1)
                  : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: CustomIconWidget(
              iconName: icon,
              color: isEnabled
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant,
              size: 20,
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: isEnabled,
            onChanged: (value) {
              HapticFeedback.lightImpact();
              widget.onPreferenceChanged(preferenceKey, value);
            },
          ),
        ],
      ),
    );
  }
}