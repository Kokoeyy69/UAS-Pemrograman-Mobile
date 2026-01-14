import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Recent Transactions Widget - Displays recent activity list
class RecentTransactionsWidget extends StatelessWidget {
  final List<Map<String, dynamic>> transactions;
  final Function(Map<String, dynamic>) onTransactionTap;

  const RecentTransactionsWidget({
    Key? key,
    required this.transactions,
    required this.onTransactionTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return _buildEmptyState(context);
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      itemCount: transactions.length,
      separatorBuilder: (context, index) => SizedBox(height: 1.h),
      itemBuilder: (context, index) {
        return _buildTransactionItem(context, transactions[index]);
      },
    );
  }

  Widget _buildTransactionItem(
    BuildContext context,
    Map<String, dynamic> transaction,
  ) {
    final theme = Theme.of(context);
    final amount = transaction['amount'] as double;
    final isIncome = amount > 0;
    
    // Ambil status (completed/pending/failed)
    final rawStatus = (transaction['status'] as String).toLowerCase();

    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        onTransactionTap(transaction);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Transaction icon
            Container(
              width: 12.w,
              height: 12.w,
              decoration: BoxDecoration(
                color: isIncome
                    ? theme.colorScheme.secondary.withValues(alpha: 0.1)
                    : theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: CustomIconWidget(
                  iconName: transaction['icon'] as String,
                  size: 24,
                  color: isIncome
                      ? theme.colorScheme.secondary
                      : theme.colorScheme.primary,
                ),
              ),
            ),
            SizedBox(width: 3.w),

            // Transaction details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction['merchantName'] as String,
                    style: theme.textTheme.titleSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 0.5.h),
                  Row(
                    children: [
                      // ✅ PERBAIKAN UTAMA: Bungkus dengan Flexible agar tidak Overflow
                      Flexible(
                        child: Text(
                          transaction['category'] as String,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 1, // Pastikan cuma 1 baris
                          overflow: TextOverflow.ellipsis, // Potong jadi "..." jika kepanjangan
                        ),
                      ),
                      
                      SizedBox(width: 2.w),
                      
                      // Divider Kecil
                      Container(
                        width: 1,
                        height: 12,
                        color: theme.colorScheme.outline.withValues(alpha: 0.3),
                      ),
                      
                      SizedBox(width: 2.w),
                      
                      // Waktu (Time)
                      Text(
                        _formatTransactionTime(
                          transaction['timestamp'] as DateTime,
                        ),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Transaction amount
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${isIncome ? '+' : '-'}\$${amount.abs().toStringAsFixed(2)}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: isIncome
                        ? theme.colorScheme.secondary
                        : theme.colorScheme.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 2.w,
                    vertical: 0.3.h,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(rawStatus, theme).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    // Translate Status
                    'status_$rawStatus'.tr().toUpperCase(),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: _getStatusColor(rawStatus, theme),
                      fontWeight: FontWeight.w600,
                      fontSize: 9,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(8.w),
      child: Column(
        children: [
          CustomIconWidget(
            iconName: 'receipt_long',
            size: 64,
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
          ),
          SizedBox(height: 2.h),
          Text(
            'recent_transactions_empty_title'.tr(),
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'recent_transactions_empty_subtitle'.tr(),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _formatTransactionTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    final ago = 'time_suffix_ago'.tr(); 

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m $ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h $ago';
    } else if (difference.inDays == 1) {
      return 'transaction_history_date_yesterday'.tr();
    } else {
      return '${difference.inDays}d $ago';
    }
  }

  Color _getStatusColor(String status, ThemeData theme) {
    switch (status.toLowerCase()) {
      case 'completed':
        return theme.colorScheme.secondary;
      case 'pending':
        return theme.colorScheme.tertiary;
      case 'failed':
        return theme.colorScheme.error;
      default:
        return theme.colorScheme.onSurfaceVariant;
    }
  }
}