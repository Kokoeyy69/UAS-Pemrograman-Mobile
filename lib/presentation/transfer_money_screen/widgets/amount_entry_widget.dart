import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:easy_localization/easy_localization.dart'; // 1. Import Wajib

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Widget for entering transfer amount with numeric keypad
/// Includes suggested amounts and currency formatting
class AmountEntryWidget extends StatelessWidget {
  final TextEditingController amountController;
  final List<double> suggestedAmounts;
  final Function(double) onAmountChanged;
  final Function(double) onSuggestedAmountTap;
  final double enteredAmount;

  const AmountEntryWidget({
    Key? key,
    required this.amountController,
    required this.suggestedAmounts,
    required this.onAmountChanged,
    required this.onSuggestedAmountTap,
    required this.enteredAmount,
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
          // ✅ TRANSLATE: Enter Amount
          Text('amount_entry_title'.tr(), style: theme.textTheme.titleMedium),
          SizedBox(height: 2.h),

          // Amount Display
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.primary.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '\$',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(width: 2.w),
                Flexible(
                  child: TextField(
                    controller: amountController,
                    keyboardType: TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.displaySmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      // ✅ TRANSLATE: Hint 0.00
                      hintText: 'amount_entry_hint'.tr(),
                      hintStyle: theme.textTheme.displaySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant.withValues(
                          alpha: 0.3,
                        ),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^\d+\.?\d{0,2}'),
                      ),
                    ],
                    onChanged: (value) {
                      final amount = double.tryParse(value) ?? 0.0;
                      onAmountChanged(amount);
                    },
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 2.h),

          // Suggested Amounts
          Text(
            // ✅ TRANSLATE: Quick Amounts
            'amount_entry_quick_amounts'.tr(),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 1.h),

          Wrap(
            spacing: 2.w,
            runSpacing: 1.h,
            children: suggestedAmounts.map((amount) {
              final isSelected = enteredAmount == amount;

              return InkWell(
                onTap: () => onSuggestedAmountTap(amount),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.outline.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    '\$${amount.toStringAsFixed(0)}',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: isSelected
                          ? theme.colorScheme.onPrimary
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          if (enteredAmount > 0) ...[
            SizedBox(height: 2.h),
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: theme.colorScheme.secondary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'info_outline',
                    size: 5.w,
                    color: theme.colorScheme.secondary,
                  ),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: Text(
                      enteredAmount > 500
                          // ✅ TRANSLATE: Biometric Notice
                          ? 'amount_entry_auth_notice'.tr()
                          // ✅ TRANSLATE: Limit Notice
                          : 'amount_entry_limit_notice'.tr(),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}