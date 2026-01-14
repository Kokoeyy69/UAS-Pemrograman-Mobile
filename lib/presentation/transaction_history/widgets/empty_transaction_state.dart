import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:easy_localization/easy_localization.dart'; // 1. Import Wajib

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class EmptyTransactionState extends StatelessWidget {
  const EmptyTransactionState({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: EdgeInsets.all(6.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: CustomIconWidget(
                  iconName: 'receipt_long',
                  size: 80,
                  color: theme.colorScheme.primary.withValues(alpha: 0.5),
                ),
              ),
            ),
            SizedBox(height: 3.h),
            Text(
              // ✅ TRANSLATE: No Transactions Yet
              'empty_transaction_title'.tr(),
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 1.h),
            Text(
              // ✅ TRANSLATE: Your transaction history will appear here...
              'empty_transaction_subtitle'.tr(),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 3.h),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/transfer-money-screen');
              },
              icon: CustomIconWidget(
                iconName: 'send',
                size: 20,
                color: theme.colorScheme.onPrimary,
              ),
              // ✅ TRANSLATE: Make a Transfer
              label: Text('empty_transaction_btn_transfer'.tr()),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
              ),
            ),
            SizedBox(height: 1.5.h),
            OutlinedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/add-card-screen');
              },
              icon: CustomIconWidget(
                iconName: 'add_card',
                size: 20,
                color: theme.colorScheme.primary,
              ),
              // ✅ TRANSLATE: Add a Card
              label: Text('empty_transaction_btn_add_card'.tr()),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
              ),
            ),
          ],
        ),
      ),
    );
  }
}