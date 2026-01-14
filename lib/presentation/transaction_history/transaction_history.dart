import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:easy_localization/easy_localization.dart'; // 1. Import Wajib

import '../../core/app_export.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_bottom_bar.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/empty_transaction_state.dart';
import './widgets/transaction_detail_modal.dart';
import './widgets/transaction_filter_sheet.dart';
import './widgets/transaction_list_item.dart';

class TransactionHistory extends StatefulWidget {
  const TransactionHistory({Key? key}) : super(key: key);

  @override
  State<TransactionHistory> createState() => _TransactionHistoryState();
}

class _TransactionHistoryState extends State<TransactionHistory> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool _isLoading = false;
  bool _isSearching = false;
  String _searchQuery = '';
  Map<String, dynamic> _activeFilters = {};
  DateTime? _lastSyncTime;

  // Mock transaction data (Data mentah backend biasanya tetap bahasa Inggris/Kode)
  // Nanti di TransactionListItem kita bisa translate kategorinya jika perlu.
  final List<Map<String, dynamic>> _allTransactions = [
    {
      'id': 'txn001',
      'merchant': 'Starbucks Coffee',
      'amount': 12.50,
      'type': 'debit',
      'category': 'Food & Dining',
      'date': DateTime.now().subtract(Duration(hours: 2)),
      'status': 'completed',
      'location': '123 Main St, New York, NY',
      'cardUsed': 'Visa **** 4532',
      'transactionId': 'TXN-2025-001234',
      'receiptUrl': 'https://img.rocket.new/generatedImages/rocket_gen_img_1da927192-1764760293662.png',
      'notes': 'Morning coffee with team',
    },
    {
      'id': 'txn002',
      'merchant': 'Amazon.com',
      'amount': 89.99,
      'type': 'debit',
      'category': 'Shopping',
      'date': DateTime.now().subtract(Duration(hours: 5)),
      'status': 'completed',
      'location': 'Online Purchase',
      'cardUsed': 'Mastercard **** 8765',
      'transactionId': 'TXN-2025-001235',
      'receiptUrl': 'https://images.unsplash.com/photo-1523474253046-8cd2748b5fd2?w=400',
      'notes': null,
    },
    {
      'id': 'txn003',
      'merchant': 'Uber',
      'amount': 24.30,
      'type': 'debit',
      'category': 'Transportation',
      'date': DateTime.now().subtract(Duration(days: 1)),
      'status': 'completed',
      'location': 'Downtown to Airport',
      'cardUsed': 'Visa **** 4532',
      'transactionId': 'TXN-2025-001236',
      'receiptUrl': null,
      'notes': 'Airport ride',
    },
    {
      'id': 'txn004',
      'merchant': 'Salary Deposit',
      'amount': 3500.00,
      'type': 'credit',
      'category': 'Others',
      'date': DateTime.now().subtract(Duration(days: 2)),
      'status': 'completed',
      'location': 'Direct Deposit',
      'cardUsed': null,
      'transactionId': 'TXN-2025-001237',
      'receiptUrl': null,
      'notes': 'Monthly salary',
    },
    {
      'id': 'txn005',
      'merchant': 'Netflix',
      'amount': 15.99,
      'type': 'debit',
      'category': 'Entertainment',
      'date': DateTime.now().subtract(Duration(days: 3)),
      'status': 'completed',
      'location': 'Subscription',
      'cardUsed': 'Amex **** 1234',
      'transactionId': 'TXN-2025-001238',
      'receiptUrl': null,
      'notes': 'Monthly subscription',
    },
    {
      'id': 'txn006',
      'merchant': 'Whole Foods',
      'amount': 156.78,
      'type': 'debit',
      'category': 'Food & Dining',
      'date': DateTime.now().subtract(Duration(days: 4)),
      'status': 'completed',
      'location': '456 Market St, San Francisco, CA',
      'cardUsed': 'Visa **** 4532',
      'transactionId': 'TXN-2025-001239',
      'receiptUrl': 'https://images.unsplash.com/photo-1632974632088-6c9c3b1b3c19',
      'notes': 'Weekly groceries',
    },
    {
      'id': 'txn007',
      'merchant': 'Shell Gas Station',
      'amount': 45.00,
      'type': 'debit',
      'category': 'Transportation',
      'date': DateTime.now().subtract(Duration(days: 5)),
      'status': 'completed',
      'location': '789 Highway Rd, Los Angeles, CA',
      'cardUsed': 'Mastercard **** 8765',
      'transactionId': 'TXN-2025-001240',
      'receiptUrl': null,
      'notes': null,
    },
    {
      'id': 'txn008',
      'merchant': 'Apple Store',
      'amount': 299.00,
      'type': 'debit',
      'category': 'Shopping',
      'date': DateTime.now().subtract(Duration(days: 6)),
      'status': 'pending',
      'location': 'Apple Store Fifth Avenue',
      'cardUsed': 'Amex **** 1234',
      'transactionId': 'TXN-2025-001241',
      'receiptUrl': 'https://images.unsplash.com/photo-1611532736597-de2d4265fba3?w=400',
      'notes': 'AirPods Pro purchase',
    },
    {
      'id': 'txn009',
      'merchant': 'CVS Pharmacy',
      'amount': 32.45,
      'type': 'debit',
      'category': 'Healthcare',
      'date': DateTime.now().subtract(Duration(days: 7)),
      'status': 'completed',
      'location': '321 Health Ave, Boston, MA',
      'cardUsed': 'Visa **** 4532',
      'transactionId': 'TXN-2025-001242',
      'receiptUrl': null,
      'notes': 'Prescription refill',
    },
    {
      'id': 'txn010',
      'merchant': 'Delta Airlines',
      'amount': 450.00,
      'type': 'debit',
      'category': 'Travel',
      'date': DateTime.now().subtract(Duration(days: 8)),
      'status': 'completed',
      'location': 'Flight Booking',
      'cardUsed': 'Mastercard **** 8765',
      'transactionId': 'TXN-2025-001243',
      'receiptUrl': 'https://images.unsplash.com/photo-1436491865332-7a61a109cc05?w=400',
      'notes': 'Business trip to Chicago',
    },
  ];

  List<Map<String, dynamic>> _filteredTransactions = [];

  @override
  void initState() {
    super.initState();
    _filteredTransactions = List.from(_allTransactions);
    _lastSyncTime = DateTime.now();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _loadMoreTransactions();
    }
  }

  Future<void> _loadMoreTransactions() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);
    await Future.delayed(Duration(seconds: 1));
    setState(() => _isLoading = false);
  }

  Future<void> _refreshTransactions() async {
    HapticFeedback.mediumImpact();

    setState(() => _isLoading = true);
    await Future.delayed(Duration(seconds: 1));

    setState(() {
      _lastSyncTime = DateTime.now();
      _isLoading = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          // ✅ TRANSLATE: Transactions updated
          content: Text('transaction_history_updated'.tr()),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
      _filterTransactions();
    });
  }

  void _filterTransactions() {
    List<Map<String, dynamic>> filtered = List.from(_allTransactions);

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((transaction) {
        final merchant = (transaction['merchant'] as String).toLowerCase();
        final category = (transaction['category'] as String).toLowerCase();
        final amount = transaction['amount'].toString();
        return merchant.contains(_searchQuery) ||
            category.contains(_searchQuery) ||
            amount.contains(_searchQuery);
      }).toList();
    }

    // Apply date range filter
    if (_activeFilters['dateRange'] != null) {
      final dateRange = _activeFilters['dateRange'] as DateTimeRange;
      filtered = filtered.where((transaction) {
        final date = transaction['date'] as DateTime;
        return date.isAfter(dateRange.start.subtract(Duration(days: 1))) &&
            date.isBefore(dateRange.end.add(Duration(days: 1)));
      }).toList();
    }

    // Apply amount range filter
    if (_activeFilters['amountRange'] != null) {
      final amountRange = _activeFilters['amountRange'] as RangeValues;
      filtered = filtered.where((transaction) {
        final amount = transaction['amount'] as double;
        return amount >= amountRange.start && amount <= amountRange.end;
      }).toList();
    }

    // Apply category filter
    if (_activeFilters['categories'] != null &&
        (_activeFilters['categories'] as List).isNotEmpty) {
      final categories = _activeFilters['categories'] as List<String>;
      filtered = filtered.where((transaction) {
        return categories.contains(transaction['category']);
      }).toList();
    }

    // Apply card filter
    if (_activeFilters['cards'] != null &&
        (_activeFilters['cards'] as List).isNotEmpty) {
      final cards = _activeFilters['cards'] as List<String>;
      filtered = filtered.where((transaction) {
        final cardUsed = transaction['cardUsed'] as String?;
        if (cardUsed == null) return false;
        return cards.any((card) => cardUsed.contains(card));
      }).toList();
    }

    setState(() {
      _filteredTransactions = filtered;
    });
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TransactionFilterSheet(
        currentFilters: _activeFilters,
        onApplyFilters: (filters) {
          setState(() {
            _activeFilters = filters;
            _filterTransactions();
          });
        },
      ),
    );
  }

  void _showTransactionDetail(Map<String, dynamic> transaction) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TransactionDetailModal(transaction: transaction),
    );
  }

  void _handleTransactionAction(
    Map<String, dynamic> transaction,
    String action,
  ) {
    HapticFeedback.lightImpact();

    String message = '';
    // ✅ TRANSLATE: Switch Actions
    switch (action) {
      case 'categorize':
        message = 'transaction_history_action_categorize'.tr();
        break;
      case 'note':
        message = 'transaction_history_action_note'.tr();
        break;
      case 'dispute':
        message = 'transaction_history_action_dispute'.tr();
        break;
      case 'receipt':
        message = 'transaction_history_action_receipt'.tr();
        break;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: Duration(seconds: 2)),
    );
  }

  Map<String, List<Map<String, dynamic>>> _groupTransactionsByDate() {
    final Map<String, List<Map<String, dynamic>>> grouped = {};

    for (var transaction in _filteredTransactions) {
      final date = transaction['date'] as DateTime;
      final dateKey = '${date.year}-${date.month}-${date.day}';

      grouped.putIfAbsent(dateKey, () => []);
      grouped[dateKey]!.add(transaction);
    }

    return grouped;
  }

  String _formatDateHeader(String dateKey) {
    final parts = dateKey.split('-');
    final date = DateTime(
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
    );

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(Duration(days: 1));

    if (date == today) {
      // ✅ TRANSLATE: Today
      return 'transaction_history_date_today'.tr();
    } else if (date == yesterday) {
      // ✅ TRANSLATE: Yesterday
      return 'transaction_history_date_yesterday'.tr();
    } else {
      // Fallback format (bisa pakai DateFormat juga)
      return '${date.month}/${date.day}/${date.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final groupedTransactions = _groupTransactionsByDate();
    final hasActiveFilters =
        _activeFilters.isNotEmpty &&
        (_activeFilters['dateRange'] != null ||
            (_activeFilters['categories'] as List?)?.isNotEmpty == true ||
            (_activeFilters['cards'] as List?)?.isNotEmpty == true);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomAppBar(
        variant: CustomAppBarVariant.withSearch,
        searchController: _searchController,
        // ✅ TRANSLATE: Search hint
        searchHint: 'transaction_history_search_hint'.tr(),
        onSearchChanged: _onSearchChanged,
        actions: [
          CustomAppBarAction.filter(
            onPressed: _showFilterSheet,
            isActive: hasActiveFilters,
          ),
        ],
      ),
      body: _filteredTransactions.isEmpty
          ? _searchQuery.isNotEmpty || hasActiveFilters
                ? _buildNoResultsState(theme)
                : EmptyTransactionState()
          : RefreshIndicator(
              onRefresh: _refreshTransactions,
              color: theme.colorScheme.primary,
              child: Column(
                children: [
                  // Last sync info
                  if (_lastSyncTime != null)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 4.w,
                        vertical: 1.h,
                      ),
                      color: theme.colorScheme.surfaceContainerHighest,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CustomIconWidget(
                            iconName: 'sync',
                            size: 14,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          SizedBox(width: 2.w),
                          Text(
                            // ✅ TRANSLATE: Last synced (Args)
                            'transaction_history_last_synced'.tr(args: [
                              '${_lastSyncTime!.hour.toString().padLeft(2, '0')}:${_lastSyncTime!.minute.toString().padLeft(2, '0')}'
                            ]),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Active filters indicator
                  if (hasActiveFilters)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 4.w,
                        vertical: 1.h,
                      ),
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      child: Row(
                        children: [
                          CustomIconWidget(
                            iconName: 'filter_alt',
                            size: 16,
                            color: theme.colorScheme.primary,
                          ),
                          SizedBox(width: 2.w),
                          Expanded(
                            child: Text(
                              // ✅ TRANSLATE: Filters active
                              'transaction_history_filter_active'.tr(),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _activeFilters.clear();
                                _filterTransactions();
                              });
                            },
                            // ✅ TRANSLATE: Clear
                            child: Text('transaction_history_btn_clear'.tr()),
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.symmetric(horizontal: 2.w),
                              minimumSize: Size(0, 0),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Transaction list
                  Expanded(
                    child: ListView.builder(
                      controller: _scrollController,
                      physics: AlwaysScrollableScrollPhysics(),
                      itemCount:
                          groupedTransactions.length + (_isLoading ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == groupedTransactions.length) {
                          return Center(
                            child: Padding(
                              padding: EdgeInsets.all(2.h),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }

                        final dateKey = groupedTransactions.keys.elementAt(
                          index,
                        );
                        final transactions = groupedTransactions[dateKey]!;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Date header (sticky)
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 4.w,
                                vertical: 1.5.h,
                              ),
                              color: theme.scaffoldBackgroundColor,
                              child: Text(
                                _formatDateHeader(dateKey),
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),

                            // Transactions for this date
                            ...transactions.map((transaction) {
                              return TransactionListItem(
                                transaction: transaction,
                                onTap: () =>
                                    _showTransactionDetail(transaction),
                                onAction: (action) => _handleTransactionAction(
                                  transaction,
                                  action,
                                ),
                              );
                            }).toList(),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
      bottomNavigationBar: CustomBottomBar(
        currentIndex: 2,
        onTap: (index) {
          // Navigation handled by CustomBottomBar
        },
        transactionBadgeCount: 3,
      ),
    );
  }

  Widget _buildNoResultsState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(6.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 30.w,
              height: 30.w,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: CustomIconWidget(
                  iconName: 'search_off',
                  size: 60,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            SizedBox(height: 3.h),
            Text(
              // ✅ TRANSLATE: No Transactions Found
              'transaction_history_no_results_title'.tr(),
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 1.h),
            Text(
              // ✅ TRANSLATE: Try adjusting filters...
              'transaction_history_no_results_subtitle'.tr(),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 3.h),
            OutlinedButton(
              onPressed: () {
                setState(() {
                  _searchController.clear();
                  _searchQuery = '';
                  _activeFilters.clear();
                  _filterTransactions();
                });
              },
              // ✅ TRANSLATE: Clear All Filters
              child: Text('transaction_history_btn_clear_all'.tr()),
            ),
          ],
        ),
      ),
    );
  }
}