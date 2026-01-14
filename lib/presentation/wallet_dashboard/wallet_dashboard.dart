import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../core/app_export.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_bottom_bar.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/card_carousel_widget.dart';
import './widgets/quick_actions_widget.dart';
import './widgets/recent_transactions_widget.dart';
import './widgets/total_balance_widget.dart';

/// Wallet Dashboard - Primary hub for payment cards and financial overview
/// Implements Contemporary Financial Minimalism with secure mobile-first design
class WalletDashboard extends StatefulWidget {
  const WalletDashboard({Key? key}) : super(key: key);

  @override
  State<WalletDashboard> createState() => _WalletDashboardState();
}

class _WalletDashboardState extends State<WalletDashboard> {
  bool _isBalanceVisible = true;
  bool _isRefreshing = false;
  int _selectedCardIndex = 0;

  // Mock data for payment cards
  final List<Map<String, dynamic>> _paymentCards = [
    {
      "id": "card_001",
      "cardNumber": "**** **** **** 4532",
      "cardHolder": "JOHN ANDERSON",
      "expiryDate": "12/26",
      "balance": 12450.75,
      "cardType": "Visa",
      "cardColor": "primary",
      "isDefault": true,
      "lastFourDigits": "4532",
      "cardImage":
          "https://img.rocket.new/generatedImages/rocket_gen_img_13344ec5e-1764674818618.png",
      "semanticLabel":
          "Blue Visa credit card with chip and contactless payment symbol on gradient background",
    },
    {
      "id": "card_002",
      "cardNumber": "**** **** **** 8721",
      "cardHolder": "JOHN ANDERSON",
      "expiryDate": "09/27",
      "balance": 8320.50,
      "cardType": "Mastercard",
      "cardColor": "secondary",
      "isDefault": false,
      "lastFourDigits": "8721",
      "cardImage":
          "https://img.rocket.new/generatedImages/rocket_gen_img_1ab715d0d-1766070794931.png",
      "semanticLabel":
          "Black Mastercard credit card with gold chip and holographic security features",
    },
    {
      "id": "card_003",
      "cardNumber": "**** **** **** 2198",
      "cardHolder": "JOHN ANDERSON",
      "expiryDate": "03/28",
      "balance": 5680.25,
      "cardType": "American Express",
      "cardColor": "tertiary",
      "isDefault": false,
      "lastFourDigits": "2198",
      "cardImage":
          "https://img.rocket.new/generatedImages/rocket_gen_img_1a088acd7-1765096976693.png",
      "semanticLabel":
          "Silver American Express card with embossed numbers and centurion logo",
    },
  ];

  // Mock data for recent transactions
  final List<Map<String, dynamic>> _recentTransactions = [
    {
      "id": "txn_001",
      "merchantName": "Amazon Prime",
      "category": "Shopping",
      "amount": -14.99,
      "timestamp": DateTime.now().subtract(Duration(hours: 2)),
      "status": "completed",
      "icon": "shopping_bag",
      "cardLastFour": "4532",
      "merchantLogo":
          "https://img.rocket.new/generatedImages/rocket_gen_img_178917247-1764648544264.png",
      "semanticLabel":
          "Amazon shopping bag icon with smile logo on white background",
    },
    {
      "id": "txn_002",
      "merchantName": "Starbucks Coffee",
      "category": "Food & Dining",
      "amount": -8.45,
      "timestamp": DateTime.now().subtract(Duration(hours: 5)),
      "status": "completed",
      "icon": "local_cafe",
      "cardLastFour": "4532",
      "merchantLogo":
          "https://images.unsplash.com/photo-1539365545689-8bdc450d3d18",
      "semanticLabel": "Green Starbucks coffee cup with white siren logo",
    },
    {
      "id": "txn_003",
      "merchantName": "Salary Deposit",
      "category": "Income",
      "amount": 4500.00,
      "timestamp": DateTime.now().subtract(Duration(days: 1)),
      "status": "completed",
      "icon": "account_balance",
      "cardLastFour": "4532",
      "merchantLogo":
          "https://img.rocket.new/generatedImages/rocket_gen_img_1a4f6437d-1766031449780.png",
      "semanticLabel":
          "Bank building icon with columns representing financial institution",
    },
    {
      "id": "txn_004",
      "merchantName": "Netflix Subscription",
      "category": "Entertainment",
      "amount": -15.99,
      "timestamp": DateTime.now().subtract(Duration(days: 2)),
      "status": "completed",
      "icon": "movie",
      "cardLastFour": "8721",
      "merchantLogo":
          "https://img.rocket.new/generatedImages/rocket_gen_img_1cf52285e-1764675872914.png",
      "semanticLabel": "Red Netflix logo on black background with play button",
    },
    {
      "id": "txn_005",
      "merchantName": "Uber Ride",
      "category": "Transportation",
      "amount": -22.50,
      "timestamp": DateTime.now().subtract(Duration(days: 3)),
      "status": "completed",
      "icon": "directions_car",
      "cardLastFour": "4532",
      "merchantLogo":
          "https://img.rocket.new/generatedImages/rocket_gen_img_1ff44f416-1764728583547.png",
      "semanticLabel": "Black Uber car icon on white background",
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    await Future.delayed(Duration(milliseconds: 500));
  }

  Future<void> _handleRefresh() async {
    setState(() => _isRefreshing = true);
    HapticFeedback.mediumImpact();

    await Future.delayed(Duration(seconds: 2));

    setState(() => _isRefreshing = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          // ✅ TRANSLATE: SnackBar Refresh
          content: Text('wallet_dashboard_balance_updated'.tr()),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _toggleBalanceVisibility() {
    HapticFeedback.lightImpact();
    setState(() => _isBalanceVisible = !_isBalanceVisible);
  }

  void _onCardSelected(int index) {
    HapticFeedback.selectionClick();
    setState(() => _selectedCardIndex = index);
  }

  void _showQuickPaymentOptions() {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildQuickPaymentSheet(),
    );
  }

  Widget _buildQuickPaymentSheet() {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 3.h),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurfaceVariant.withValues(
                  alpha: 0.3,
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 2.h),
            // ✅ TRANSLATE: Quick Payment Title
            Text('wallet_dashboard_quick_payment_title'.tr(), style: theme.textTheme.titleLarge),
            SizedBox(height: 3.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildPaymentOption(
                  icon: 'qr_code_scanner',
                  // ✅ TRANSLATE: Scan QR
                  label: 'wallet_dashboard_action_scan_qr'.tr(),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                _buildPaymentOption(
                  icon: 'nfc',
                  // ✅ TRANSLATE: NFC Tap
                  label: 'wallet_dashboard_action_nfc'.tr(),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                _buildPaymentOption(
                  icon: 'send',
                  // ✅ TRANSLATE: Transfer
                  label: 'wallet_dashboard_action_transfer'.tr(),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/transfer-money-screen');
                  },
                ),
              ],
            ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOption({
    required String icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 25.w,
        padding: EdgeInsets.symmetric(vertical: 2.h),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            CustomIconWidget(
              iconName: icon,
              size: 32,
              color: theme.colorScheme.primary,
            ),
            SizedBox(height: 1.h),
            Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _calculateTotalBalance() {
    return _paymentCards.fold(
      0.0,
      (sum, card) => sum + (card['balance'] as double),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomAppBar(
        variant: CustomAppBarVariant.standard,
        // ✅ TRANSLATE: My Wallet (AppBar)
        title: 'wallet_dashboard_app_bar_title'.tr(),
        actions: [
          CustomAppBarAction.notification(
            onPressed: () {
            },
            badgeCount: 3,
          ),
          CustomAppBarAction.settings(
            onPressed: () {
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        color: theme.colorScheme.primary,
        child: CustomScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          slivers: [
            // Total Balance Section
            SliverToBoxAdapter(
              child: TotalBalanceWidget(
                totalBalance: _calculateTotalBalance(),
                isVisible: _isBalanceVisible,
                onToggleVisibility: _toggleBalanceVisibility,
                isRefreshing: _isRefreshing,
              ),
            ),

            // Quick Actions Toolbar
            SliverToBoxAdapter(
              child: QuickActionsWidget(
                onBillPayPressed: () {
                },
                onTransferPressed: () {
                  Navigator.pushNamed(context, '/transfer-money-screen');
                },
                onAddCardPressed: () {
                  Navigator.pushNamed(context, '/add-card-screen');
                },
                onScanQRPressed: () {
                },
              ),
            ),

            // Card Carousel
            SliverToBoxAdapter(
              child: CardCarouselWidget(
                cards: _paymentCards,
                selectedIndex: _selectedCardIndex,
                onCardSelected: _onCardSelected,
                onCardLongPress: (index) {
                  HapticFeedback.heavyImpact();
                  _showCardContextMenu(index);
                },
                onCardTap: (index) {
                  Navigator.pushNamed(context, '/card-details-screen');
                },
              ),
            ),

            // Recent Transactions Section
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // ✅ TRANSLATE: Recent Activity
                    Text('wallet_dashboard_section_recent_activity'.tr(), style: theme.textTheme.titleLarge),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/transaction-history');
                      },
                      // ✅ TRANSLATE: View All
                      child: Text('wallet_dashboard_btn_view_all'.tr()),
                    ),
                  ],
                ),
              ),
            ),

            // Recent Transactions List
            SliverToBoxAdapter(
              child: RecentTransactionsWidget(
                transactions: _recentTransactions.take(5).toList(),
                onTransactionTap: (transaction) {
                  _showTransactionDetails(transaction);
                },
              ),
            ),

            // Bottom padding for FAB
            SliverToBoxAdapter(child: SizedBox(height: 10.h)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showQuickPaymentOptions,
        icon: CustomIconWidget(
          iconName: 'payment',
          size: 24,
          color: theme.colorScheme.onSecondary,
        ),
        // ✅ TRANSLATE: Pay (FAB)
        label: Text(
          'wallet_dashboard_fab_pay'.tr(),
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.onSecondary,
          ),
        ),
        backgroundColor: theme.colorScheme.secondary,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: CustomBottomBar(
        currentIndex: 0,
        onTap: (index) {
        },
        transactionBadgeCount: 2,
      ),
    );
  }

  void _showCardContextMenu(int index) {
    final card = _paymentCards[index];
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 12.w,
                height: 0.5.h,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurfaceVariant.withValues(
                    alpha: 0.3,
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(height: 2.h),
              ListTile(
                leading: CustomIconWidget(
                  iconName: 'ac_unit',
                  size: 24,
                  color: theme.colorScheme.primary,
                ),
                // ✅ TRANSLATE: Freeze Card
                title: Text('wallet_dashboard_menu_freeze'.tr()),
                onTap: () {
                  Navigator.pop(context);
                  _freezeCard(index);
                },
              ),
              ListTile(
                leading: CustomIconWidget(
                  iconName: 'info_outline',
                  size: 24,
                  color: theme.colorScheme.primary,
                ),
                // ✅ TRANSLATE: View Details
                title: Text('wallet_dashboard_menu_view_details'.tr()),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/card-details-screen');
                },
              ),
              ListTile(
                leading: CustomIconWidget(
                  iconName: card['isDefault'] ? 'star' : 'star_outline',
                  size: 24,
                  color: theme.colorScheme.primary,
                ),
                // ✅ TRANSLATE: Default Card / Set as Default
                title: Text(
                  card['isDefault'] 
                    ? 'wallet_dashboard_menu_is_default'.tr() 
                    : 'wallet_dashboard_menu_set_default'.tr(),
                ),
                onTap: () {
                  Navigator.pop(context);
                  if (!card['isDefault']) {
                    _setDefaultCard(index);
                  }
                },
              ),
              SizedBox(height: 1.h),
            ],
          ),
        ),
      ),
    );
  }

  void _freezeCard(int index) {
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        // ✅ TRANSLATE: Card Frozen Success
        content: Text('wallet_dashboard_card_frozen_success'.tr()),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _setDefaultCard(int index) {
    HapticFeedback.lightImpact();
    setState(() {
      for (var card in _paymentCards) {
        card['isDefault'] = false;
      }
      _paymentCards[index]['isDefault'] = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        // ✅ TRANSLATE: Default Card Updated
        content: Text('wallet_dashboard_card_default_updated'.tr()),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showTransactionDetails(Map<String, dynamic> transaction) {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 60.h,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 12.w,
                  height: 0.5.h,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurfaceVariant.withValues(
                      alpha: 0.3,
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              SizedBox(height: 3.h),
              Center(
                child: Container(
                  width: 20.w,
                  height: 20.w,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: CustomIconWidget(
                      iconName: transaction['icon'] as String,
                      size: 40,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 2.h),
              Center(
                child: Text(
                  transaction['merchantName'] as String,
                  style: theme.textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 1.h),
              Center(
                child: Text(
                  '\$${(transaction['amount'] as double).abs().toStringAsFixed(2)}',
                  style: theme.textTheme.displaySmall?.copyWith(
                    color: (transaction['amount'] as double) < 0
                        ? theme.colorScheme.error
                        : theme.colorScheme.secondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(height: 3.h),
              _buildDetailRow(
                'wallet_dashboard_detail_category'.tr(), // ✅ TRANSLATE
                transaction['category'] as String,
                theme,
              ),
              _buildDetailRow(
                'wallet_dashboard_detail_status'.tr(), // ✅ TRANSLATE
                transaction['status'] as String, 
                theme
              ),
              _buildDetailRow(
                'wallet_dashboard_detail_card'.tr(), // ✅ TRANSLATE
                '**** ${transaction['cardLastFour']}',
                theme,
              ),
              _buildDetailRow(
                'wallet_dashboard_detail_date'.tr(), // ✅ TRANSLATE
                _formatTransactionDate(transaction['timestamp'] as DateTime),
                theme,
              ),
              Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  // ✅ TRANSLATE: Close
                  child: Text('wallet_dashboard_btn_close'.tr()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, ThemeData theme) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 1.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTransactionDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      // ✅ TRANSLATE: "Today"
      return '${'transaction_history_date_today'.tr()}, ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      // ✅ TRANSLATE: "Yesterday"
      return '${'transaction_history_date_yesterday'.tr()}, ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}