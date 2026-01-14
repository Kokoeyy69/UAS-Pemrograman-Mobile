import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:easy_localization/easy_localization.dart'; // 1. Import Wajib

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Widget for selecting transfer type and adding memo
/// Supports instant and standard transfer options
class TransferOptionsWidget extends StatelessWidget {
  final String transferType;
  final Function(String) onTransferTypeChanged;
  final TextEditingController memoController;

  const TransferOptionsWidget({
    Key? key,
    required this.transferType,
    required this.onTransferTypeChanged,
    required this.memoController,
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
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ✅ TRANSLATE: Transfer Options
          Text('transfer_options_title'.tr(), style: theme.textTheme.titleMedium),
          SizedBox(height: 2.h),

          // Transfer Type Selection
          _buildTransferTypeOption(
            context: context,
            theme: theme,
            type: 'standard',
            // ✅ TRANSLATE: Standard
            title: 'transfer_options_standard_title'.tr(),
            // ✅ TRANSLATE: 1-3 business days
            subtitle: 'transfer_options_standard_subtitle'.tr(),
            icon: 'schedule',
          ),

          SizedBox(height: 1.h),

          _buildTransferTypeOption(
            context: context,
            theme: theme,
            type: 'instant',
            // ✅ TRANSLATE: Instant
            title: 'transfer_options_instant_title'.tr(),
            // ✅ TRANSLATE: Arrives instantly
            subtitle: 'transfer_options_instant_subtitle'.tr(),
            icon: 'flash_on',
          ),

          SizedBox(height: 2.h),

          // Memo Field
          TextField(
            controller: memoController,
            decoration: InputDecoration(
              // ✅ TRANSLATE: Add a note
              labelText: 'transfer_options_memo_label'.tr(),
              // ✅ TRANSLATE: What's this for?
              hintText: 'transfer_options_memo_hint'.tr(),
              prefixIcon: Icon(Icons.note_outlined),
              suffixIcon: IconButton(
                icon: Icon(Icons.emoji_emotions_outlined),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  // Emoji picker would go here
                },
              ),
            ),
            maxLength: 100,
            maxLines: 2,
          ),

          SizedBox(height: 1.h),

          // Security Notice
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: theme.colorScheme.primary.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                CustomIconWidget(
                  iconName: 'security',
                  size: 5.w,
                  color: theme.colorScheme.primary,
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: Text(
                    // ✅ TRANSLATE: Encrypted and secure
                    'transfer_options_security_notice'.tr(),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransferTypeOption({
    required BuildContext context,
    required ThemeData theme,
    required String type,
    required String title,
    required String subtitle,
    required String icon,
  }) {
    final isSelected = transferType == type;

    return InkWell(
      onTap: () {
        onTransferTypeChanged(type);
        HapticFeedback.lightImpact();
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 10.w,
              height: 10.w,
              decoration: BoxDecoration(
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
              ),
              child: CustomIconWidget(
                iconName: icon,
                size: 5.w,
                color: isSelected
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface,
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
            Radio<String>(
              value: type,
              groupValue: transferType,
              onChanged: (value) {
                if (value != null) {
                  onTransferTypeChanged(value);
                  HapticFeedback.lightImpact();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}