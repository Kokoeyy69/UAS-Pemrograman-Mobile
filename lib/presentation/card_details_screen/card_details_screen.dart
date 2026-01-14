import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sizer/sizer.dart';
import 'package:easy_localization/easy_localization.dart'; // 1. Import Wajib

import '../../core/app_export.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_bottom_bar.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/card_display_widget.dart';
import './widgets/notification_preferences_widget.dart';
import './widgets/quick_actions_widget.dart';
import './widgets/security_controls_widget.dart';
import './widgets/transaction_section_widget.dart';

/// Card Details Screen - Comprehensive card management with security controls
class CardDetailsScreen extends StatefulWidget {
  const CardDetailsScreen({Key? key}) : super(key: key);

  @override
  State<CardDetailsScreen> createState() => _CardDetailsScreenState();
}

class _CardDetailsScreenState extends State<CardDetailsScreen> {
  // Mock card data
  final Map<String, dynamic> _cardData = {
    'type': 'Visa',
    'number': '**** **** **** 4532',
    'holder': 'JOHN DOE',
    'expiry': '12/25',
    'cvv': '123',
    'balance': '\$5,420.00',
  };

  // Security controls state
  bool _isCardFrozen = false;
  double _spendingLimit = 2500.0;

  // Notification preferences state
  final Map<String, bool> _notificationPreferences = {
    'transactionAlerts': true,
    'locationVerification': false,
    'securityAlerts': true,
    'balanceUpdates': false,
  };

  // Mock transaction data
  final List<Map<String, dynamic>> _transactions = [
    {
      'merchant': 'Amazon',
      'amount': '\$89.99',
      'date': 'Dec 20, 2025',
      'type': 'Expense',
      'category': 'Shopping',
    },
    {
      'merchant': 'Starbucks',
      'amount': '\$5.50',
      'date': 'Dec 19, 2025',
      'type': 'Expense',
      'category': 'Food & Drink',
    },
    {
      'merchant': 'Salary Deposit',
      'amount': '\$3,500.00',
      'date': 'Dec 18, 2025',
      'type': 'Income',
      'category': 'Salary',
    },
    {
      'merchant': 'Netflix',
      'amount': '\$15.99',
      'date': 'Dec 17, 2025',
      'type': 'Expense',
      'category': 'Entertainment',
    },
    {
      'merchant': 'Uber',
      'amount': '\$24.50',
      'date': 'Dec 16, 2025',
      'type': 'Expense',
      'category': 'Transportation',
    },
  ];

  void _handleFreezeToggle(bool isFrozen) {
    setState(() => _isCardFrozen = isFrozen);
    HapticFeedback.mediumImpact();
    Fluttertoast.showToast(
      // ✅ TRANSLATE: Toast Frozen/Activated
      msg: isFrozen
          ? 'card_details_toast_frozen'.tr()
          : 'card_details_toast_activated'.tr(),
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.black87,
      textColor: Colors.white,
    );
  }

  void _handleSpendingLimitChanged(double limit) {
    setState(() => _spendingLimit = limit);
    Fluttertoast.showToast(
      // ✅ TRANSLATE: Toast Limit Updated (Args)
      msg: 'card_details_toast_limit_updated'.tr(args: [limit.toStringAsFixed(0)]),
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.black87,
      textColor: Colors.white,
    );
  }

  void _handleNotificationPreferenceChanged(String key, bool value) {
    setState(() => _notificationPreferences[key] = value);
    Fluttertoast.showToast(
      // ✅ TRANSLATE: Toast Pref Updated
      msg: 'card_details_toast_pref_updated'.tr(),
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.black87,
      textColor: Colors.white,
    );
  }

  void _handleViewPin() {
    HapticFeedback.mediumImpact();
    _showBiometricAuthDialog();
  }

  void _handleReportLost() {
    HapticFeedback.mediumImpact();
    _showReportLostDialog();
  }

  void _handleRequestReplacement() {
    HapticFeedback.mediumImpact();
    _showReplacementDialog();
  }

  void _handleUpdateExpiry() {
    HapticFeedback.mediumImpact();
    Fluttertoast.showToast(
      // ✅ TRANSLATE: Toast Expiry Updated
      msg: 'card_details_toast_expiry_updated'.tr(),
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.black87,
      textColor: Colors.white,
    );
  }

  void _showBiometricAuthDialog() {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        // ✅ TRANSLATE: Biometric Dialog
        title: Text('card_details_auth_dialog_title'.tr()),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomIconWidget(
              iconName: 'fingerprint',
              color: theme.colorScheme.primary,
              size: 64,
            ),
            SizedBox(height: 2.h),
            Text(
              'card_details_auth_dialog_content'.tr(),
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('card_details_btn_cancel'.tr()),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showPinDialog();
            },
            child: Text('card_details_btn_authenticate'.tr()),
          ),
        ],
      ),
    );
  }

  void _showPinDialog() {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        // ✅ TRANSLATE: PIN Dialog
        title: Text('card_details_pin_dialog_title'.tr()),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '1234',
                style: theme.textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 8,
                ),
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              'card_details_pin_dialog_footer'.tr(),
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: Text('card_details_btn_close'.tr()),
          ),
        ],
      ),
    );
  }

  void _showReportLostDialog() {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            CustomIconWidget(
              iconName: 'warning',
              color: theme.colorScheme.error,
              size: 24,
            ),
            SizedBox(width: 2.w),
            // ✅ TRANSLATE: Report Dialog
            Text('card_details_report_dialog_title'.tr()),
          ],
        ),
        content: Text(
          'card_details_report_dialog_content'.tr(),
          style: theme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('card_details_btn_cancel'.tr()),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => _isCardFrozen = true);
              Fluttertoast.showToast(
                // ✅ TRANSLATE: Toast Blocked
                msg: 'card_details_toast_blocked'.tr(),
                toastLength: Toast.LENGTH_LONG,
                gravity: ToastGravity.BOTTOM,
                backgroundColor: Colors.black87,
                textColor: Colors.white,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
            ),
            child: Text('card_details_btn_report_lost'.tr()),
          ),
        ],
      ),
    );
  }

  void _showReplacementDialog() {
    final theme = Theme.of(context);
    String selectedReason = 'Damaged';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          // ✅ TRANSLATE: Replacement Dialog
          title: Text('card_details_replace_dialog_title'.tr()),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'card_details_replace_reason_label'.tr(),
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 1.h),
              RadioListTile<String>(
                title: Text('card_details_reason_damaged'.tr()),
                value: 'Damaged',
                groupValue: selectedReason,
                onChanged: (value) => setDialogState(() => selectedReason = value!),
              ),
              RadioListTile<String>(
                title: Text('card_details_reason_lost'.tr()),
                value: 'Lost',
                groupValue: selectedReason,
                onChanged: (value) => setDialogState(() => selectedReason = value!),
              ),
              RadioListTile<String>(
                title: Text('card_details_reason_stolen'.tr()),
                value: 'Stolen',
                groupValue: selectedReason,
                onChanged: (value) => setDialogState(() => selectedReason = value!),
              ),
              RadioListTile<String>(
                title: Text('card_details_reason_expired'.tr()),
                value: 'Expired',
                groupValue: selectedReason,
                onChanged: (value) => setDialogState(() => selectedReason = value!),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('card_details_btn_cancel'.tr()),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Fluttertoast.showToast(
                  // ✅ TRANSLATE: Toast Replacement Submitted
                  msg: 'card_details_toast_replacement_submitted'.tr(),
                  toastLength: Toast.LENGTH_LONG,
                  gravity: ToastGravity.BOTTOM,
                  backgroundColor: Colors.black87,
                  textColor: Colors.white,
                );
              },
              child: Text('card_details_btn_submit_request'.tr()),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomAppBar(
        // ✅ TRANSLATE: Card Details
        title: 'card_details_title'.tr(),
        variant: CustomAppBarVariant.withBack,
        actions: [
          CustomAppBarAction.moreOptions(
            onPressed: () {
              HapticFeedback.lightImpact();
              _showMoreOptionsBottomSheet();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 2.h),

            // Card display with flip animation
            Center(
              child: CardDisplayWidget(
                cardData: _cardData,
                onCardTap: () {
                  HapticFeedback.lightImpact();
                },
              ),
            ),

            SizedBox(height: 3.h),

            // Security controls
            SecurityControlsWidget(
              isCardFrozen: _isCardFrozen,
              spendingLimit: _spendingLimit,
              onFreezeToggle: _handleFreezeToggle,
              onSpendingLimitChanged: _handleSpendingLimitChanged,
            ),

            // Quick actions
            QuickActionsWidget(
              onViewPin: _handleViewPin,
              onReportLost: _handleReportLost,
              onRequestReplacement: _handleRequestReplacement,
              onUpdateExpiry: _handleUpdateExpiry,
            ),

            // Notification preferences
            NotificationPreferencesWidget(
              preferences: _notificationPreferences,
              onPreferenceChanged: _handleNotificationPreferenceChanged,
            ),

            // Transaction section
            TransactionSectionWidget(
              transactions: _transactions,
              onFilterChanged: (filter) {
                HapticFeedback.lightImpact();
              },
            ),

            SizedBox(height: 2.h),

            // View all transactions button
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    Navigator.pushNamed(context, '/transaction-history');
                  },
                  // ✅ TRANSLATE: View All
                  child: Text('card_details_btn_view_all'.tr()),
                ),
              ),
            ),

            SizedBox(height: 10.h),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomBar(
        currentIndex: 4,
        onTap: (index) {
          HapticFeedback.lightImpact();
        },
      ),
    );
  }

  void _showMoreOptionsBottomSheet() {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
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
                iconName: 'edit',
                color: theme.colorScheme.primary,
                size: 24,
              ),
              // ✅ TRANSLATE: Edit Card
              title: Text('card_details_menu_edit'.tr()),
              onTap: () {
                Navigator.pop(context);
                // Placeholder action
              },
            ),

            ListTile(
              leading: CustomIconWidget(
                iconName: 'download',
                color: theme.colorScheme.primary,
                size: 24,
              ),
              // ✅ TRANSLATE: Statement
              title: Text('card_details_menu_statement'.tr()),
              onTap: () {
                Navigator.pop(context);
                // Placeholder action
              },
            ),

            ListTile(
              leading: CustomIconWidget(
                iconName: 'share',
                color: theme.colorScheme.primary,
                size: 24,
              ),
              // ✅ TRANSLATE: Share
              title: Text('card_details_menu_share'.tr()),
              onTap: () {
                Navigator.pop(context);
                // Placeholder action
              },
            ),

            Divider(),

            ListTile(
              leading: CustomIconWidget(
                iconName: 'delete',
                color: theme.colorScheme.error,
                size: 24,
              ),
              title: Text(
                // ✅ TRANSLATE: Remove
                'card_details_menu_remove'.tr(),
                style: TextStyle(color: theme.colorScheme.error),
              ),
              onTap: () {
                Navigator.pop(context);
                _showRemoveCardDialog();
              },
            ),

            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  void _showRemoveCardDialog() {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            CustomIconWidget(
              iconName: 'warning',
              color: theme.colorScheme.error,
              size: 24,
            ),
            SizedBox(width: 2.w),
            // ✅ TRANSLATE: Remove Dialog
            Text('card_details_remove_dialog_title'.tr()),
          ],
        ),
        content: Text(
          'card_details_remove_dialog_content'.tr(),
          style: theme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('card_details_btn_cancel'.tr()),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/wallet-dashboard');
              Fluttertoast.showToast(
                // ✅ TRANSLATE: Toast Removed
                msg: 'card_details_toast_removed'.tr(),
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                backgroundColor: Colors.black87,
                textColor: Colors.white,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
            ),
            child: Text('card_details_btn_remove'.tr()),
          ),
        ],
      ),
    );
  }
}