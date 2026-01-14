import 'package:flutter/material.dart';
import '../presentation/transfer_money_screen/transfer_money_screen.dart';
import '../presentation/splash_screen/splash_screen.dart';
import '../presentation/card_details_screen/card_details_screen.dart';
import '../presentation/wallet_dashboard/wallet_dashboard.dart';
import '../presentation/transaction_history/transaction_history.dart';
import '../presentation/add_card_screen/add_card_screen.dart';

class AppRoutes {
  // TODO: Add your routes here
  static const String initial = '/';
  static const String transferMoney = '/transfer-money-screen';
  static const String splash = '/splash-screen';
  static const String cardDetails = '/card-details-screen';
  static const String walletDashboard = '/wallet-dashboard';
  static const String transactionHistory = '/transaction-history';
  static const String addCard = '/add-card-screen';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const SplashScreen(),
    transferMoney: (context) => const TransferMoneyScreen(),
    splash: (context) => const SplashScreen(),
    cardDetails: (context) => const CardDetailsScreen(),
    walletDashboard: (context) => const WalletDashboard(),
    transactionHistory: (context) => const TransactionHistory(),
    addCard: (context) => const AddCardScreen(),
    // TODO: Add your other routes here
  };
}
