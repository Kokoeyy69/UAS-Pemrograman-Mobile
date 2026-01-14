import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:easy_localization/easy_localization.dart'; // 1. Import Wajib

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Widget displaying card-specific transaction history and analytics
class TransactionSectionWidget extends StatefulWidget {
  final List<Map<String, dynamic>> transactions;
  final Function(String)? onFilterChanged;

  const TransactionSectionWidget({
    Key? key,
    required this.transactions,
    this.onFilterChanged,
  }) : super(key: key);

  @override
  State<TransactionSectionWidget> createState() =>
      _TransactionSectionWidgetState();
}

class _TransactionSectionWidgetState extends State<TransactionSectionWidget> {
  // Gunakan key internal (lowercase) untuk logika, bukan teks tampilan
  String _selectedFilterKey = 'all';
  
  final List<String> _filterKeys = ['all', 'income', 'expense', 'pending'];

  // Helper untuk mendapatkan key terjemahan dari key internal
  String _getFilterLabelKey(String key) {
    switch (key) {
      case 'all': return 'transaction_section_filter_all';
      case 'income': return 'transaction_section_filter_income';
      case 'expense': return 'transaction_section_filter_expense';
      case 'pending': return 'transaction_section_filter_pending';
      default: return 'transaction_section_filter_all';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            // ✅ TRANSLATE: Transactions
            'transaction_section_title'.tr(),
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 2.h),

          // Filter chips
          _buildFilterChips(theme),

          SizedBox(height: 2.h),

          // Spending analytics chart
          _buildSpendingChart(theme),

          SizedBox(height: 2.h),

          // Transaction list
          _buildTransactionList(theme),
        ],
      ),
    );
  }

  Widget _buildFilterChips(ThemeData theme) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _filterKeys.map((filterKey) {
          final isSelected = _selectedFilterKey == filterKey;
          return Padding(
            padding: EdgeInsets.only(right: 2.w),
            child: FilterChip(
              // ✅ TRANSLATE: Filter Label
              label: Text(_getFilterLabelKey(filterKey).tr()),
              selected: isSelected,
              onSelected: (selected) {
                setState(() => _selectedFilterKey = filterKey);
                widget.onFilterChanged?.call(filterKey);
              },
              backgroundColor: theme.colorScheme.surface,
              selectedColor: theme.colorScheme.primary.withValues(alpha: 0.2),
              labelStyle: theme.textTheme.bodyMedium?.copyWith(
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
              side: BorderSide(
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.outline.withValues(alpha: 0.3),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSpendingChart(ThemeData theme) {
    return Container(
      height: 25.h,
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
            // ✅ TRANSLATE: Weekly Spending
            'transaction_section_weekly_spending'.tr(),
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 2.h),
          Expanded(
            child: Semantics(
              // ✅ TRANSLATE: Chart Label (Accessibility)
              label: 'transaction_section_chart_label'.tr(),
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 500,
                  barTouchData: BarTouchData(enabled: true),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          // ✅ TRANSLATE: Days of week
                          final days = [
                            'transaction_section_day_mon'.tr(),
                            'transaction_section_day_tue'.tr(),
                            'transaction_section_day_wed'.tr(),
                            'transaction_section_day_thu'.tr(),
                            'transaction_section_day_fri'.tr(),
                            'transaction_section_day_sat'.tr(),
                            'transaction_section_day_sun'.tr(),
                          ];
                          // Safety check for index
                          final index = value.toInt() % 7;
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              days[index],
                              style: theme.textTheme.bodySmall?.copyWith(fontSize: 9.sp),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '\$${value.toInt()}',
                            style: theme.textTheme.bodySmall,
                          );
                        },
                      ),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 100,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: theme.colorScheme.outline.withValues(alpha: 0.2),
                        strokeWidth: 1,
                      );
                    },
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: [
                    BarChartGroupData(
                      x: 0,
                      barRods: [
                        BarChartRodData(
                          toY: 350,
                          color: theme.colorScheme.primary,
                        ),
                      ],
                    ),
                    BarChartGroupData(
                      x: 1,
                      barRods: [
                        BarChartRodData(
                          toY: 280,
                          color: theme.colorScheme.primary,
                        ),
                      ],
                    ),
                    BarChartGroupData(
                      x: 2,
                      barRods: [
                        BarChartRodData(
                          toY: 420,
                          color: theme.colorScheme.primary,
                        ),
                      ],
                    ),
                    BarChartGroupData(
                      x: 3,
                      barRods: [
                        BarChartRodData(
                          toY: 310,
                          color: theme.colorScheme.primary,
                        ),
                      ],
                    ),
                    BarChartGroupData(
                      x: 4,
                      barRods: [
                        BarChartRodData(
                          toY: 390,
                          color: theme.colorScheme.primary,
                        ),
                      ],
                    ),
                    BarChartGroupData(
                      x: 5,
                      barRods: [
                        BarChartRodData(
                          toY: 450,
                          color: theme.colorScheme.primary,
                        ),
                      ],
                    ),
                    BarChartGroupData(
                      x: 6,
                      barRods: [
                        BarChartRodData(
                          toY: 320,
                          color: theme.colorScheme.primary,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionList(ThemeData theme) {
    // Logika filter menggunakan _selectedFilterKey ('all', 'income', etc.)
    final filteredTransactions = _selectedFilterKey == 'all'
        ? widget.transactions
        : widget.transactions
            .where(
              (t) =>
                  (t['type'] as String).toLowerCase() ==
                  _selectedFilterKey.toLowerCase(),
            )
            .toList();

    return ListView.separated(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: filteredTransactions.length > 5
          ? 5
          : filteredTransactions.length,
      separatorBuilder: (context, index) => SizedBox(height: 1.h),
      itemBuilder: (context, index) {
        final transaction = filteredTransactions[index];
        return _buildTransactionItem(theme, transaction);
      },
    );
  }

  Widget _buildTransactionItem(
    ThemeData theme,
    Map<String, dynamic> transaction,
  ) {
    final merchant = transaction['merchant'] as String;
    final amount = transaction['amount'] as String;
    final date = transaction['date'] as String;
    final type = transaction['type'] as String;
    final category = transaction['category'] as String;

    final isExpense = type.toLowerCase() == 'expense';

    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: isExpense
                  ? theme.colorScheme.error.withValues(alpha: 0.1)
                  : theme.colorScheme.secondary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: CustomIconWidget(
              iconName: isExpense ? 'arrow_upward' : 'arrow_downward',
              color: isExpense
                  ? theme.colorScheme.error
                  : theme.colorScheme.secondary,
              size: 20,
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  merchant,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 0.5.h),
                Row(
                  children: [
                    Text(
                      category,
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
                      date,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Text(
            '${isExpense ? '-' : '+'}$amount',
            style: theme.textTheme.titleMedium?.copyWith(
              color: isExpense
                  ? theme.colorScheme.error
                  : theme.colorScheme.secondary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}