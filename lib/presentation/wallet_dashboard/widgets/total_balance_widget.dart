import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:easy_localization/easy_localization.dart'; // 1. Import Wajib

import '../../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Total Balance Widget - Displays aggregate balance with privacy toggle
class TotalBalanceWidget extends StatelessWidget {
  final double totalBalance;
  final bool isVisible;
  final VoidCallback onToggleVisibility;
  final bool isRefreshing;

  const TotalBalanceWidget({
    Key? key,
    required this.totalBalance,
    required this.isVisible,
    required this.onToggleVisibility,
    this.isRefreshing = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primaryContainer,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                // ✅ TRANSLATE: Total Balance
                'total_balance_label'.tr(),
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onPrimary.withValues(alpha: 0.9),
                ),
              ),
              InkWell(
                onTap: onToggleVisibility,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: EdgeInsets.all(1.w),
                  child: CustomIconWidget(
                    iconName: isVisible ? 'visibility' : 'visibility_off',
                    size: 20,
                    color: theme.colorScheme.onPrimary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          AnimatedSwitcher(
            duration: Duration(milliseconds: 300),
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: Offset(0, 0.2),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              );
            },
            child: Text(
              isVisible ? '\$${totalBalance.toStringAsFixed(2)}' : '••••••',
              key: ValueKey(isVisible),
              style: theme.textTheme.displaySmall?.copyWith(
                color: theme.colorScheme.onPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          SizedBox(height: 0.5.h),
          Row(
            children: [
              CustomIconWidget(
                iconName: 'trending_up',
                size: 16,
                color: theme.colorScheme.secondary,
              ),
              SizedBox(width: 1.w),
              Text(
                // ✅ TRANSLATE: +$450.00 this month
                // Menggabungkan angka dummy dengan teks terjemahan "this month"
                '+\$450.00 ${'total_balance_monthly_growth'.tr()}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onPrimary.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
          if (isRefreshing) ...[
            SizedBox(height: 1.h),
            LinearProgressIndicator(
              backgroundColor: theme.colorScheme.onPrimary.withValues(
                alpha: 0.2,
              ),
              valueColor: AlwaysStoppedAnimation<Color>(
                theme.colorScheme.secondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}