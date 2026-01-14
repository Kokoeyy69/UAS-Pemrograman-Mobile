import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:easy_localization/easy_localization.dart'; // 1. Import Wajib

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Widget for selecting source account for transfer
/// Displays available accounts with balances and limits
class SourceAccountWidget extends StatelessWidget {
  final List<Map<String, dynamic>> accounts;
  final Map<String, dynamic>? selectedAccount;
  final Function(Map<String, dynamic>) onAccountSelected;

  const SourceAccountWidget({
    Key? key,
    required this.accounts,
    required this.selectedAccount,
    required this.onAccountSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
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
        children: [
          Padding(
            padding: EdgeInsets.all(4.w),
            // ✅ TRANSLATE: From Account
            child: Text('source_account_title'.tr(), style: theme.textTheme.titleMedium),
          ),

          ListView.separated(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            itemCount: accounts.length,
            separatorBuilder: (context, index) => Divider(height: 1),
            itemBuilder: (context, index) {
              final account = accounts[index];
              final isSelected = selectedAccount?['id'] == account['id'];
              final balance = account['balance'] as double;

              return InkWell(
                onTap: () {
                  onAccountSelected(account);
                  HapticFeedback.lightImpact();
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 2.h),
                  child: Row(
                    children: [
                      Container(
                        width: 12.w,
                        height: 12.w,
                        decoration: BoxDecoration(
                          color: Color(
                            account['color'] as int,
                          ).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: CustomIconWidget(
                          iconName: account['icon'] as String,
                          size: 6.w,
                          color: Color(account['color'] as int),
                        ),
                      ),
                      SizedBox(width: 3.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              account['name'] as String,
                              style: theme.textTheme.titleSmall,
                            ),
                            SizedBox(height: 0.5.h),
                            Row(
                              children: [
                                Text(
                                  account['cardNumber'] as String,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                SizedBox(width: 2.w),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 2.w,
                                    vertical: 0.3.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getAccountTypeColor(
                                      account['type'] as String,
                                      theme,
                                    ),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    (account['type'] as String).toUpperCase(),
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: theme.colorScheme.onPrimary,
                                      fontSize: 9.sp,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '\$${balance.toStringAsFixed(2)}',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 0.5.h),
                          Text(
                            // ✅ TRANSLATE: Available
                            'source_account_label_available'.tr(),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(width: 2.w),
                      Radio<int>(
                        value: account['id'] as int,
                        groupValue: selectedAccount?['id'] as int?,
                        onChanged: (value) {
                          onAccountSelected(account);
                          HapticFeedback.lightImpact();
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          SizedBox(height: 2.h),
        ],
      ),
    );
  }

  Color _getAccountTypeColor(String type, ThemeData theme) {
    switch (type) {
      case 'checking':
        return theme.colorScheme.primary;
      case 'savings':
        return theme.colorScheme.secondary;
      case 'credit':
        return theme.colorScheme.tertiary;
      default:
        return theme.colorScheme.primary;
    }
  }
}