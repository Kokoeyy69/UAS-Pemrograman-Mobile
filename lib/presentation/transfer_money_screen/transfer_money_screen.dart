import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_bottom_bar.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/amount_entry_widget.dart';
import './widgets/recent_transfers_widget.dart';
import './widgets/recipient_selection_widget.dart';
import './widgets/source_account_widget.dart';
import './widgets/transfer_options_widget.dart';

/// Transfer Money Screen for peer-to-peer payments and account transfers
/// Implements mobile-optimized recipient selection and amount entry with security features
class TransferMoneyScreen extends StatefulWidget {
  const TransferMoneyScreen({Key? key}) : super(key: key);

  @override
  State<TransferMoneyScreen> createState() => _TransferMoneyScreenState();
}

class _TransferMoneyScreenState extends State<TransferMoneyScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _memoController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  // Selected values
  Map<String, dynamic>? _selectedRecipient;
  Map<String, dynamic>? _selectedAccount;
  String _transferType = 'standard'; // 'instant' or 'standard'
  double _enteredAmount = 0.0;
  bool _isProcessing = false;
  int _currentBottomNavIndex = 1; // Transfer tab

  // Mock data for accounts
  final List<Map<String, dynamic>> _accounts = [
    {
      "id": 1,
      "name": "Primary Checking",
      "cardNumber": "**** 4532",
      "balance": 5420.50,
      "type": "checking",
      "icon": "account_balance",
      "color": 0xFF1B365D,
    },
    {
      "id": 2,
      "name": "Savings Account",
      "cardNumber": "**** 7891",
      "balance": 12350.75,
      "type": "savings",
      "icon": "savings",
      "color": 0xFF2E5984,
    },
    {
      "id": 3,
      "name": "Visa Platinum",
      "cardNumber": "**** 2468",
      "balance": 3200.00,
      "type": "credit",
      "icon": "credit_card",
      "color": 0xFF00C896,
    },
  ];

  // Mock data for recent transfers
  final List<Map<String, dynamic>> _recentTransfers = [
    {
      "id": 1,
      "name": "Sarah Johnson",
      "email": "sarah.j@email.com",
      "phone": "+1 (555) 123-4567",
      "avatar":
          "https://img.rocket.new/generatedImages/rocket_gen_img_176e07230-1763293461602.png",
      "semanticLabel":
          "Profile photo of a woman with long brown hair wearing a blue top",
      "lastAmount": 150.00,
      "lastDate": DateTime.now().subtract(Duration(days: 2)),
      "frequency": 5,
    },
    {
      "id": 2,
      "name": "Michael Chen",
      "email": "m.chen@email.com",
      "phone": "+1 (555) 234-5678",
      "avatar":
          "https://img.rocket.new/generatedImages/rocket_gen_img_19b9f856b-1763296945059.png",
      "semanticLabel":
          "Profile photo of a man with short black hair wearing glasses and a white shirt",
      "lastAmount": 75.50,
      "lastDate": DateTime.now().subtract(Duration(days: 5)),
      "frequency": 3,
    },
    {
      "id": 3,
      "name": "Emily Rodriguez",
      "email": "emily.r@email.com",
      "phone": "+1 (555) 345-6789",
      "avatar":
          "https://img.rocket.new/generatedImages/rocket_gen_img_151b2e1e2-1765095634419.png",
      "semanticLabel":
          "Profile photo of a woman with curly dark hair wearing a red sweater",
      "lastAmount": 200.00,
      "lastDate": DateTime.now().subtract(Duration(days: 7)),
      "frequency": 8,
    },
  ];

  // Suggested amounts based on recent transfers
  final List<double> _suggestedAmounts = [25.0, 50.0, 100.0, 200.0];

  @override
  void initState() {
    super.initState();
    // Set default account
    _selectedAccount = _accounts.first;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _memoController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _handleRecipientSelected(Map<String, dynamic> recipient) {
    setState(() {
      _selectedRecipient = recipient;
    });
    HapticFeedback.lightImpact();
  }

  void _handleAccountSelected(Map<String, dynamic> account) {
    setState(() {
      _selectedAccount = account;
    });
    HapticFeedback.lightImpact();
  }

  void _handleTransferTypeChanged(String type) {
    setState(() {
      _transferType = type;
    });
    HapticFeedback.lightImpact();
  }

  void _handleAmountChanged(double amount) {
    setState(() {
      _enteredAmount = amount;
      _amountController.text = amount.toStringAsFixed(2);
    });
  }

  void _handleSuggestedAmountTap(double amount) {
    _handleAmountChanged(amount);
    HapticFeedback.mediumImpact();
  }

  Future<void> _handleSendMoney() async {
    // Validation
    if (_selectedRecipient == null) {
      _showErrorDialog('transfer_money_err_no_recipient'.tr());
      return;
    }

    if (_enteredAmount <= 0) {
      _showErrorDialog('transfer_money_err_invalid_amount'.tr());
      return;
    }

    if (_selectedAccount == null) {
      _showErrorDialog('transfer_money_err_no_source'.tr());
      return;
    }

    final double accountBalance = _selectedAccount!['balance'] as double;
    if (_enteredAmount > accountBalance) {
      _showErrorDialog('transfer_money_err_insufficient_funds'.tr());
      return;
    }

    // Check if biometric authentication is needed (amounts above \$500)
    if (_enteredAmount > 500) {
      final bool authenticated = await _authenticateUser();
      if (!authenticated) {
        _showErrorDialog('transfer_money_err_auth_required'.tr());
        return;
      }
    }

    // Show confirmation dialog
    final bool? confirmed = await _showConfirmationDialog();
    if (confirmed != true) return;

    // Process transfer
    setState(() {
      _isProcessing = true;
    });

    HapticFeedback.mediumImpact();

    // Simulate processing
    await Future.delayed(Duration(seconds: 2));

    setState(() {
      _isProcessing = false;
    });

    // Show success
    _showSuccessDialog();
  }

  Future<bool> _authenticateUser() async {
    // Simulate biometric authentication
    await Future.delayed(Duration(milliseconds: 500));
    return true; // In real app, use local_auth package
  }

  Future<bool?> _showConfirmationDialog() async {
    final theme = Theme.of(context);

    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('transfer_money_confirm_title'.tr(), style: theme.textTheme.titleLarge),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildConfirmationRow(
              'transfer_money_confirm_label_to'.tr(),
              _selectedRecipient!['name'] as String,
              theme,
            ),
            SizedBox(height: 12),
            _buildConfirmationRow(
              'transfer_money_confirm_label_amount'.tr(),
              '\$${_enteredAmount.toStringAsFixed(2)}',
              theme,
            ),
            SizedBox(height: 12),
            _buildConfirmationRow(
              'transfer_money_confirm_label_from'.tr(),
              _selectedAccount!['name'] as String,
              theme,
            ),
            SizedBox(height: 12),
            _buildConfirmationRow(
              'transfer_money_confirm_label_type'.tr(),
              _transferType == 'instant'
                  ? 'transfer_money_confirm_type_instant'.tr()
                  : 'transfer_money_confirm_type_standard'.tr(),
              theme,
            ),
            if (_memoController.text.isNotEmpty) ...[
              SizedBox(height: 12),
              _buildConfirmationRow('transfer_money_confirm_label_memo'.tr(), _memoController.text, theme),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('transfer_money_confirm_btn_cancel'.tr()),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('transfer_money_confirm_btn_confirm'.tr()),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmationRow(String label, String value, ThemeData theme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 20.w,
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  void _showSuccessDialog() {
    final theme = Theme.of(context);
    final transactionId = 'TXN${DateTime.now().millisecondsSinceEpoch}';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 20.w,
              height: 20.w,
              decoration: BoxDecoration(
                color: theme.colorScheme.secondary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: CustomIconWidget(
                iconName: 'check_circle',
                color: theme.colorScheme.secondary,
                size: 12.w,
              ),
            ),
            SizedBox(height: 3.h),
            Text(
              'transfer_money_success_title'.tr(),
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 1.h),
            Text(
              '${'transfer_money_success_subtitle'.tr()} \$${_enteredAmount.toStringAsFixed(2)} to ${_selectedRecipient!['name']}',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 2.h),
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.outline.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    'transfer_money_success_txn_id'.tr(),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    transactionId,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              _transferType == 'instant'
                  ? 'transfer_money_success_eta_instant'.tr()
                  : 'transfer_money_success_eta_standard'.tr(),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _resetForm();
            },
            child: Text('transfer_money_success_btn_done'.tr()),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/transaction-history');
            },
            child: Text('transfer_money_success_btn_receipt'.tr()),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            CustomIconWidget(
              iconName: 'error_outline',
              color: theme.colorScheme.error,
              size: 6.w,
            ),
            SizedBox(width: 2.w),
            Text('transfer_money_error_title'.tr(), style: theme.textTheme.titleLarge),
          ],
        ),
        content: Text(message, style: theme.textTheme.bodyMedium),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('transfer_money_error_btn_ok'.tr()),
          ),
        ],
      ),
    );
  }

  void _resetForm() {
    setState(() {
      _selectedRecipient = null;
      _enteredAmount = 0.0;
      _amountController.clear();
      _memoController.clear();
      _transferType = 'standard';
    });
  }

  void _handleCancel() {
    if (_selectedRecipient != null || _enteredAmount > 0) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('transfer_money_cancel_title'.tr()),
          content: Text('transfer_money_cancel_content'.tr()),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('transfer_money_cancel_btn_no'.tr()),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: Text('transfer_money_cancel_btn_yes'.tr()),
            ),
          ],
        ),
      );
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomAppBar(
        variant: CustomAppBarVariant.withBack,
        title: 'transfer_money_app_bar_title'.tr(),
        onLeadingPressed: _handleCancel,
        actions: [
          CustomAppBarAction.scanQR(
            onPressed: () {
              // QR code scanning functionality
              HapticFeedback.lightImpact();
            },
          ),
        ],
      ),
      body: _isProcessing
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 3.h),
                  Text(
                    'transfer_money_processing_title'.tr(),
                    style: theme.textTheme.titleMedium,
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    'transfer_money_processing_subtitle'.tr(),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(4.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Recent Transfers Section
                    RecentTransfersWidget(
                      recentTransfers: _recentTransfers,
                      onRecipientSelected: _handleRecipientSelected,
                      selectedRecipient: _selectedRecipient,
                    ),

                    SizedBox(height: 3.h),

                    // Recipient Selection Section
                    RecipientSelectionWidget(
                      searchController: _searchController,
                      selectedRecipient: _selectedRecipient,
                      onRecipientSelected: _handleRecipientSelected,
                      recentTransfers: _recentTransfers,
                    ),

                    SizedBox(height: 3.h),

                    // Amount Entry Section
                    AmountEntryWidget(
                      amountController: _amountController,
                      suggestedAmounts: _suggestedAmounts,
                      onAmountChanged: _handleAmountChanged,
                      onSuggestedAmountTap: _handleSuggestedAmountTap,
                      enteredAmount: _enteredAmount,
                    ),

                    SizedBox(height: 3.h),

                    // Source Account Selection
                    SourceAccountWidget(
                      accounts: _accounts,
                      selectedAccount: _selectedAccount,
                      onAccountSelected: _handleAccountSelected,
                    ),

                    SizedBox(height: 3.h),

                    // Transfer Options
                    TransferOptionsWidget(
                      transferType: _transferType,
                      onTransferTypeChanged: _handleTransferTypeChanged,
                      memoController: _memoController,
                    ),

                    SizedBox(height: 4.h),

                    // Send Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _handleSendMoney,
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 2.h),
                        ),
                        child: Text(
                          _selectedRecipient == null
                              ? 'transfer_money_btn_select_recipient'.tr()
                              : _enteredAmount <= 0
                              ? 'transfer_money_btn_enter_amount'.tr()
                              : '${'transfer_money_btn_send'.tr()}${_enteredAmount.toStringAsFixed(2)}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.onPrimary,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 2.h),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: CustomBottomBar(
        currentIndex: _currentBottomNavIndex,
        onTap: (index) {
          setState(() {
            _currentBottomNavIndex = index;
          });
        },
      ),
    );
  }
}
