import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:easy_localization/easy_localization.dart'; // 1. Import Wajib

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';
import '../../../widgets/custom_image_widget.dart'; // Jangan lupa import ini jika belum ada

class TransactionDetailModal extends StatelessWidget {
  final Map<String, dynamic> transaction;

  const TransactionDetailModal({Key? key, required this.transaction})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCredit = transaction['type'] == 'credit';
    final amount = transaction['amount'] as double;
    final merchant = transaction['merchant'] as String;
    final category = transaction['category'] as String;
    final date = transaction['date'] as DateTime;
    final location = transaction['location'] as String?;
    final cardUsed = transaction['cardUsed'] as String?;
    final transactionId = transaction['transactionId'] as String?;
    final receiptUrl = transaction['receiptUrl'] as String?;
    final notes = transaction['notes'] as String?;

    return Container(
      height: 85.h,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: EdgeInsets.only(top: 1.h),
            width: 10.w,
            height: 0.5.h,
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // ✅ TRANSLATE: Transaction Details
                Text('transaction_detail_title'.tr(), style: theme.textTheme.titleLarge),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: CustomIconWidget(
                    iconName: 'close',
                    size: 24,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),

          Divider(height: 1, color: theme.colorScheme.outline),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Amount section
                  Center(
                    child: Column(
                      children: [
                        Text(
                          '${isCredit ? '+' : '-'}\$${amount.toStringAsFixed(2)}',
                          style: theme.textTheme.displaySmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: isCredit
                                ? Color(0xFF00C896)
                                : theme.colorScheme.onSurface,
                          ),
                        ),
                        SizedBox(height: 1.h),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 3.w,
                            vertical: 1.h,
                          ),
                          decoration: BoxDecoration(
                            color: isCredit
                                ? Color(0xFF00C896).withValues(alpha: 0.1)
                                : theme.colorScheme.error.withValues(
                                    alpha: 0.1,
                                  ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            // ✅ TRANSLATE: Credit / Debit
                            isCredit 
                                ? 'transaction_detail_label_credit'.tr() 
                                : 'transaction_detail_label_debit'.tr(),
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: isCredit
                                  ? Color(0xFF00C896)
                                  : theme.colorScheme.error,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 3.h),

                  // Merchant info
                  _buildInfoCard(
                    theme, 
                    // ✅ TRANSLATE: Merchant Information
                    'transaction_detail_section_merchant'.tr(), 
                    [
                      _buildInfoRow(theme, 'transaction_detail_row_name'.tr(), merchant),
                      if (location != null)
                        _buildInfoRow(theme, 'transaction_detail_row_location'.tr(), location),
                      _buildInfoRow(theme, 'transaction_detail_row_category'.tr(), category),
                    ],
                  ),

                  SizedBox(height: 2.h),

                  // Transaction info
                  _buildInfoCard(
                    theme, 
                    // ✅ TRANSLATE: Transaction Information
                    'transaction_detail_section_transaction'.tr(), 
                    [
                      _buildInfoRow(
                        theme,
                        'transaction_detail_row_date'.tr(),
                        '${date.month}/${date.day}/${date.year}',
                      ),
                      _buildInfoRow(
                        theme,
                        'transaction_detail_row_time'.tr(),
                        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}',
                      ),
                      if (transactionId != null)
                        _buildInfoRow(theme, 'transaction_detail_row_id'.tr(), transactionId),
                      if (cardUsed != null)
                        _buildInfoRow(theme, 'transaction_detail_row_card'.tr(), cardUsed),
                    ],
                  ),

                  SizedBox(height: 2.h),

                  // Receipt section
                  if (receiptUrl != null) ...[
                    // ✅ TRANSLATE: Receipt
                    _buildSectionTitle(theme, 'transaction_detail_section_receipt'.tr()),
                    SizedBox(height: 1.h),
                    Container(
                      width: double.infinity,
                      height: 30.h,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: theme.colorScheme.outline.withValues(
                            alpha: 0.3,
                          ),
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: CustomImageWidget(
                          imageUrl: receiptUrl,
                          width: double.infinity,
                          height: 30.h,
                          fit: BoxFit.cover,
                          semanticLabel: 'Receipt image for $merchant',
                        ),
                      ),
                    ),
                    SizedBox(height: 2.h),
                  ],

                  // Notes section
                  // ✅ TRANSLATE: Notes
                  _buildSectionTitle(theme, 'transaction_detail_section_notes'.tr()),
                  SizedBox(height: 1.h),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(3.w),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: theme.colorScheme.outline.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      // ✅ TRANSLATE: Notes Content or Placeholder
                      notes ?? 'transaction_detail_no_notes'.tr(),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: notes == null
                            ? theme.colorScheme.onSurfaceVariant
                            : theme.colorScheme.onSurface,
                      ),
                    ),
                  ),

                  SizedBox(height: 3.h),

                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            // Add note functionality
                          },
                          icon: CustomIconWidget(
                            iconName: 'note_add',
                            size: 20,
                            color: theme.colorScheme.primary,
                          ),
                          // ✅ TRANSLATE: Add Note
                          label: Text('transaction_detail_btn_add_note'.tr()),
                        ),
                      ),
                      SizedBox(width: 3.w),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            // Report issue functionality
                          },
                          icon: CustomIconWidget(
                            iconName: 'report_problem',
                            size: 20,
                            color: theme.colorScheme.error,
                          ),
                          // ✅ TRANSLATE: Report
                          label: Text('transaction_detail_btn_report'.tr()),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: theme.colorScheme.error,
                            side: BorderSide(color: theme.colorScheme.error),
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 2.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(ThemeData theme, String title) {
    return Text(
      title,
      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
    );
  }

  Widget _buildInfoCard(ThemeData theme, String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 1.5.h),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(ThemeData theme, String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 1.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.right,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}