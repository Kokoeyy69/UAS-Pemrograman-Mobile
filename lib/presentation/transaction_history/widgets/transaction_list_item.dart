import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:sizer/sizer.dart';
import 'package:easy_localization/easy_localization.dart'; // 1. Import Wajib

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class TransactionListItem extends StatelessWidget {
  final Map<String, dynamic> transaction;
  final VoidCallback onTap;
  final Function(String) onAction;

  const TransactionListItem({
    Key? key,
    required this.transaction,
    required this.onTap,
    required this.onAction,
  }) : super(key: key);

  // Helper untuk mendapatkan key terjemahan kategori
  String _getCategoryTranslationKey(String rawCategory) {
    switch (rawCategory) {
      case 'Food & Dining': return 'transaction_filter_categories_food';
      case 'Shopping': return 'transaction_filter_categories_shopping';
      case 'Transportation': return 'transaction_filter_categories_transport';
      case 'Entertainment': return 'transaction_filter_categories_entertainment';
      case 'Bills & Utilities': return 'transaction_filter_categories_bills';
      case 'Healthcare': return 'transaction_filter_categories_healthcare';
      case 'Travel': return 'transaction_filter_categories_travel';
      default: return 'transaction_filter_categories_others';
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'food & dining':
        return Icons.restaurant;
      case 'shopping':
        return Icons.shopping_bag;
      case 'transportation':
        return Icons.directions_car;
      case 'entertainment':
        return Icons.movie;
      case 'bills & utilities':
        return Icons.receipt_long;
      case 'healthcare':
        return Icons.local_hospital;
      case 'travel':
        return Icons.flight;
      default:
        return Icons.category;
    }
  }

  Color _getCategoryColor(ThemeData theme, String category) {
    switch (category.toLowerCase()) {
      case 'food & dining':
        return Color(0xFFFF8A00);
      case 'shopping':
        return Color(0xFF00C896);
      case 'transportation':
        return Color(0xFF1B365D);
      case 'entertainment':
        return Color(0xFFE74C3C);
      case 'bills & utilities':
        return Color(0xFF2E5984);
      case 'healthcare':
        return Color(0xFFFF6B6B);
      case 'travel':
        return Color(0xFF4ECDC4);
      default:
        return theme.colorScheme.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCredit = transaction['type'] == 'credit';
    final amount = transaction['amount'] as double;
    final merchant = transaction['merchant'] as String;
    final category = transaction['category'] as String;
    final date = transaction['date'] as DateTime;
    final status = transaction['status'] as String? ?? 'completed';

    return Slidable(
      key: ValueKey(transaction['id']),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (_) => onAction('categorize'),
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
            icon: Icons.label,
            // ✅ TRANSLATE: Category
            label: 'transaction_list_item_slidable_category'.tr(),
            borderRadius: BorderRadius.circular(12),
          ),
          SlidableAction(
            onPressed: (_) => onAction('note'),
            backgroundColor: Color(0xFF00C896),
            foregroundColor: Colors.white,
            icon: Icons.note_add,
            // ✅ TRANSLATE: Note
            label: 'transaction_list_item_slidable_note'.tr(),
            borderRadius: BorderRadius.circular(12),
          ),
          SlidableAction(
            onPressed: (_) => onAction('dispute'),
            backgroundColor: Color(0xFFE74C3C),
            foregroundColor: Colors.white,
            icon: Icons.report_problem,
            // ✅ TRANSLATE: Dispute
            label: 'transaction_list_item_slidable_dispute'.tr(),
            borderRadius: BorderRadius.circular(12),
          ),
          SlidableAction(
            onPressed: (_) => onAction('receipt'),
            backgroundColor: Color(0xFFFF8A00),
            foregroundColor: Colors.white,
            icon: Icons.receipt,
            // ✅ TRANSLATE: Receipt
            label: 'transaction_list_item_slidable_receipt'.tr(),
            borderRadius: BorderRadius.circular(12),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: theme.colorScheme.outline.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              // Category icon
              Container(
                width: 12.w,
                height: 12.w,
                decoration: BoxDecoration(
                  color: _getCategoryColor(
                    theme,
                    category,
                  ).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: CustomIconWidget(
                    iconName: _getCategoryIcon(category).codePoint.toString(),
                    size: 24,
                    color: _getCategoryColor(theme, category),
                  ),
                ),
              ),

              SizedBox(width: 3.w),

              // Transaction details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            merchant,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (status == 'pending')
                          Container(
                            margin: EdgeInsets.only(left: 2.w),
                            padding: EdgeInsets.symmetric(
                              horizontal: 2.w,
                              vertical: 0.5.h,
                            ),
                            decoration: BoxDecoration(
                              color: Color(0xFFFF8A00).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              // ✅ TRANSLATE: Pending
                              'transaction_list_item_status_pending'.tr(),
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: Color(0xFFFF8A00),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 0.5.h),
                    Row(
                      children: [
                        Text(
                          // ✅ TRANSLATE: Category Name
                          _getCategoryTranslationKey(category).tr(),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        Text(
                          ' • ',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        Text(
                          '${date.month}/${date.day}/${date.year}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(width: 3.w),

              // Amount
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${isCredit ? '+' : '-'}\$${amount.toStringAsFixed(2)}',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: isCredit
                          ? Color(0xFF00C896)
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}