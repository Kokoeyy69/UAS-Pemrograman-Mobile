import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:easy_localization/easy_localization.dart'; // 1. Import Wajib

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class TransactionFilterSheet extends StatefulWidget {
  final Function(Map<String, dynamic>) onApplyFilters;
  final Map<String, dynamic> currentFilters;

  const TransactionFilterSheet({
    Key? key,
    required this.onApplyFilters,
    required this.currentFilters,
  }) : super(key: key);

  @override
  State<TransactionFilterSheet> createState() => _TransactionFilterSheetState();
}

class _TransactionFilterSheetState extends State<TransactionFilterSheet> {
  late DateTimeRange? _dateRange;
  late RangeValues _amountRange;
  late Set<String> _selectedCategories;
  late Set<String> _selectedCards;

  // Data mentah tetap bahasa Inggris agar cocok dengan _allTransactions di parent
  final List<String> _categories = [
    'Food & Dining',
    'Shopping',
    'Transportation',
    'Entertainment',
    'Bills & Utilities',
    'Healthcare',
    'Travel',
    'Others',
  ];

  final List<Map<String, dynamic>> _cards = [
    {'id': 'card1', 'name': 'Visa **** 4532', 'color': Color(0xFF1B365D)},
    {'id': 'card2', 'name': 'Mastercard **** 8765', 'color': Color(0xFF00C896)},
    {'id': 'card3', 'name': 'Amex **** 1234', 'color': Color(0xFFFF8A00)},
  ];

  @override
  void initState() {
    super.initState();
    _dateRange = widget.currentFilters['dateRange'] as DateTimeRange?;
    _amountRange =
        widget.currentFilters['amountRange'] as RangeValues? ??
        RangeValues(0, 10000);
    _selectedCategories = Set<String>.from(
      widget.currentFilters['categories'] ?? [],
    );
    _selectedCards = Set<String>.from(widget.currentFilters['cards'] ?? []);
  }

  void _resetFilters() {
    setState(() {
      _dateRange = null;
      _amountRange = RangeValues(0, 10000);
      _selectedCategories.clear();
      _selectedCards.clear();
    });
  }

  void _applyFilters() {
    widget.onApplyFilters({
      'dateRange': _dateRange,
      'amountRange': _amountRange,
      'categories': _selectedCategories.toList(),
      'cards': _selectedCards.toList(),
    });
    Navigator.pop(context);
  }

  // Helper untuk mendapatkan key terjemahan dari string kategori mentah
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
                // ✅ TRANSLATE: Filter Transactions
                Text('transaction_filter_title'.tr(), style: theme.textTheme.titleLarge),
                TextButton(
                  onPressed: _resetFilters,
                  child: Text(
                    // ✅ TRANSLATE: Reset
                    'transaction_filter_btn_reset'.tr(),
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Divider(height: 1, color: theme.colorScheme.outline),

          // Filter content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date Range
                  // ✅ TRANSLATE: Section Title
                  _buildSectionTitle(theme, 'transaction_filter_section_date'.tr()),
                  SizedBox(height: 1.h),
                  InkWell(
                    onTap: () async {
                      final picked = await showDateRangePicker(
                        context: context,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                        initialDateRange: _dateRange,
                        builder: (context, child) {
                          return Theme(
                            data: theme.copyWith(
                              colorScheme: theme.colorScheme.copyWith(
                                primary: theme.colorScheme.primary,
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (picked != null) {
                        setState(() => _dateRange = picked);
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.all(3.w),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: theme.colorScheme.outline.withValues(
                            alpha: 0.3,
                          ),
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _dateRange == null
                                // ✅ TRANSLATE: Select date range
                                ? 'transaction_filter_hint_date'.tr()
                                : '${_dateRange!.start.month}/${_dateRange!.start.day}/${_dateRange!.start.year} - ${_dateRange!.end.month}/${_dateRange!.end.day}/${_dateRange!.end.year}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: _dateRange == null
                                  ? theme.colorScheme.onSurfaceVariant
                                  : theme.colorScheme.onSurface,
                            ),
                          ),
                          CustomIconWidget(
                            iconName: 'calendar_today',
                            size: 20,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 3.h),

                  // Amount Range
                  // ✅ TRANSLATE: Section Title
                  _buildSectionTitle(theme, 'transaction_filter_section_amount'.tr()),
                  SizedBox(height: 1.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$${_amountRange.start.toInt()}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '\$${_amountRange.end.toInt()}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  SliderTheme(
                    data: SliderThemeData(
                      trackHeight: 0.5.h,
                      thumbShape: RoundSliderThumbShape(
                        enabledThumbRadius: 1.5.w,
                      ),
                      overlayShape: RoundSliderOverlayShape(overlayRadius: 3.w),
                    ),
                    child: RangeSlider(
                      values: _amountRange,
                      min: 0,
                      max: 10000,
                      divisions: 100,
                      onChanged: (values) {
                        setState(() => _amountRange = values);
                      },
                    ),
                  ),

                  SizedBox(height: 3.h),

                  // Categories
                  // ✅ TRANSLATE: Section Title
                  _buildSectionTitle(theme, 'transaction_filter_section_categories'.tr()),
                  SizedBox(height: 1.h),
                  Wrap(
                    spacing: 2.w,
                    runSpacing: 1.h,
                    children: _categories.map((category) {
                      final isSelected = _selectedCategories.contains(category);
                      return FilterChip(
                        // ✅ TRANSLATE: Category Name
                        label: Text(_getCategoryTranslationKey(category).tr()),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            selected
                                ? _selectedCategories.add(category)
                                : _selectedCategories.remove(category);
                          });
                        },
                        backgroundColor: theme.colorScheme.surface,
                        selectedColor: theme.colorScheme.primary.withValues(
                          alpha: 0.1,
                        ),
                        checkmarkColor: theme.colorScheme.primary,
                        labelStyle: theme.textTheme.bodySmall?.copyWith(
                          color: isSelected
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurface,
                        ),
                        side: BorderSide(
                          color: isSelected
                              ? theme.colorScheme.primary
                              : theme.colorScheme.outline.withValues(
                                  alpha: 0.3,
                                ),
                        ),
                      );
                    }).toList(),
                  ),

                  SizedBox(height: 3.h),

                  // Cards
                  // ✅ TRANSLATE: Section Title
                  _buildSectionTitle(theme, 'transaction_filter_section_cards'.tr()),
                  SizedBox(height: 1.h),
                  Column(
                    children: _cards.map((card) {
                      final isSelected = _selectedCards.contains(card['id']);
                      return CheckboxListTile(
                        value: isSelected,
                        onChanged: (selected) {
                          setState(() {
                            selected ?? false
                                ? _selectedCards.add(card['id'] as String)
                                : _selectedCards.remove(card['id']);
                          });
                        },
                        title: Text(
                          card['name'] as String,
                          style: theme.textTheme.bodyMedium,
                        ),
                        secondary: Container(
                          width: 8.w,
                          height: 8.w,
                          decoration: BoxDecoration(
                            color: card['color'] as Color,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        contentPadding: EdgeInsets.zero,
                        controlAffinity: ListTileControlAffinity.trailing,
                      );
                    }).toList(),
                  ),

                  SizedBox(height: 2.h),
                ],
              ),
            ),
          ),

          // Apply button
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: theme.shadowColor.withValues(alpha: 0.08),
                  blurRadius: 8,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _applyFilters,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 2.h),
                  ),
                  // ✅ TRANSLATE: Apply Filters
                  child: Text('transaction_filter_btn_apply'.tr()),
                ),
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
}