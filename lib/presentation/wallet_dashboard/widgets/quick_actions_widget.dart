import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:easy_localization/easy_localization.dart'; // 1. Import Wajib

import '../../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Quick Actions Widget - Toolbar for frequently used features
class QuickActionsWidget extends StatelessWidget {
  final VoidCallback onBillPayPressed;
  final VoidCallback onTransferPressed;
  final VoidCallback onAddCardPressed;
  final VoidCallback onScanQRPressed;

  const QuickActionsWidget({
    Key? key,
    required this.onBillPayPressed,
    required this.onTransferPressed,
    required this.onAddCardPressed,
    required this.onScanQRPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildActionButton(
            context: context,
            icon: 'receipt_long',
            // ✅ TRANSLATE: Bill Pay
            label: 'quick_actions_btn_bill_pay'.tr(),
            onPressed: () {
              HapticFeedback.lightImpact();
              onBillPayPressed();
            },
          ),
          _buildActionButton(
            context: context,
            icon: 'swap_horiz',
            // ✅ TRANSLATE: Transfer
            label: 'quick_actions_btn_transfer'.tr(),
            onPressed: () {
              HapticFeedback.lightImpact();
              onTransferPressed();
            },
          ),
          _buildActionButton(
            context: context,
            icon: 'add_card',
            // ✅ TRANSLATE: Add Card
            label: 'quick_actions_btn_add_card'.tr(),
            onPressed: () {
              HapticFeedback.lightImpact();
              onAddCardPressed();
            },
          ),
          _buildActionButton(
            context: context,
            icon: 'qr_code_scanner',
            // ✅ TRANSLATE: Scan QR
            label: 'quick_actions_btn_scan_qr'.tr(),
            onPressed: () {
              HapticFeedback.lightImpact();
              onScanQRPressed();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required String icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 20.w,
        padding: EdgeInsets.symmetric(vertical: 1.0.h),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomIconWidget(
              iconName: icon,
              size: 28,
              color: theme.colorScheme.primary,
            ),
            SizedBox(height: 0.5.h),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}