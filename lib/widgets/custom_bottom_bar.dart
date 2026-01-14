import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart'; // 1. Import Wajib

/// Custom bottom navigation bar for digital wallet application.
/// Implements bottom-heavy interaction zone with thumb-reach optimization.
/// Provides persistent access to core wallet functions with haptic feedback.
class CustomBottomBar extends StatefulWidget {
  /// Current selected index
  final int currentIndex;

  /// Callback when navigation item is tapped
  final Function(int) onTap;

  /// Optional badge count for transaction notifications
  final int? transactionBadgeCount;

  /// Whether to show labels
  final bool showLabels;

  const CustomBottomBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
    this.transactionBadgeCount,
    this.showLabels = true,
  }) : super(key: key);

  @override
  State<CustomBottomBar> createState() => _CustomBottomBarState();
}

class _CustomBottomBarState extends State<CustomBottomBar> {
  // Navigation items configuration based on Mobile Navigation Hierarchy
  // ✅ Ubah ke 'get' agar terjemahan diperbarui saat set state / ganti bahasa
  List<_NavigationItem> get _navigationItems => [
    _NavigationItem(
      icon: Icons.account_balance_wallet_outlined,
      activeIcon: Icons.account_balance_wallet,
      // ✅ TRANSLATE: Wallet
      label: 'bottom_bar_label_wallet'.tr(),
      route: '/wallet-dashboard',
    ),
    _NavigationItem(
      icon: Icons.send_outlined,
      activeIcon: Icons.send,
      // ✅ TRANSLATE: Transfer
      label: 'bottom_bar_label_transfer'.tr(),
      route: '/transfer-money-screen',
    ),
    _NavigationItem(
      icon: Icons.history_outlined,
      activeIcon: Icons.history,
      // ✅ TRANSLATE: History
      label: 'bottom_bar_label_history'.tr(),
      route: '/transaction-history',
    ),
    _NavigationItem(
      icon: Icons.add_card_outlined,
      activeIcon: Icons.add_card,
      // ✅ TRANSLATE: Add Card
      label: 'bottom_bar_label_add_card'.tr(),
      route: '/add-card-screen',
    ),
    _NavigationItem(
      icon: Icons.person_outline,
      activeIcon: Icons.person,
      // ✅ TRANSLATE: Profile
      label: 'bottom_bar_label_profile'.tr(),
      route: '/card-details-screen',
    ),
  ];

  void _handleTap(int index) {
    if (index != widget.currentIndex) {
      // Provide haptic feedback for navigation
      HapticFeedback.lightImpact();

      // Call the onTap callback
      widget.onTap(index);

      // Navigate to the selected route
      final route = _navigationItems[index].route;
      Navigator.pushNamed(context, route);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final items = _navigationItems; // Ambil item terbaru

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
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
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(
              items.length,
              (index) =>
                  _buildNavigationItem(context, items[index], index),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationItem(
    BuildContext context,
    _NavigationItem item,
    int index,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isSelected = widget.currentIndex == index;

    // Show badge on History tab if there are transaction notifications
    final showBadge =
        index == 2 &&
        widget.transactionBadgeCount != null &&
        widget.transactionBadgeCount! > 0;

    return Expanded(
      child: InkWell(
        onTap: () => _handleTap(index),
        borderRadius: BorderRadius.circular(12),
        splashColor: colorScheme.primary.withValues(alpha: 0.1),
        highlightColor: colorScheme.primary.withValues(alpha: 0.05),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon with badge
              Stack(
                clipBehavior: Clip.none,
                children: [
                  AnimatedContainer(
                    duration: Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? colorScheme.primary.withValues(alpha: 0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      isSelected ? item.activeIcon : item.icon,
                      size: 24,
                      color: isSelected
                          ? colorScheme.primary
                          : colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (showBadge)
                    Positioned(
                      right: -2,
                      top: -2,
                      child: Container(
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.error,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: colorScheme.surface,
                            width: 1.5,
                          ),
                        ),
                        constraints: BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Center(
                          child: Text(
                            widget.transactionBadgeCount! > 99
                                // ✅ TRANSLATE: 99+
                                ? 'bottom_bar_badge_max'.tr()
                                : widget.transactionBadgeCount.toString(),
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onError,
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              height: 1,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),

              // Label
              if (widget.showLabels) ...[
                SizedBox(height: 4),
                AnimatedDefaultTextStyle(
                  duration: Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  style: theme.textTheme.labelSmall!.copyWith(
                    color: isSelected
                        ? colorScheme.primary
                        : colorScheme.onSurfaceVariant,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    fontSize: 11,
                    height: 1,
                  ),
                  child: Text(
                    item.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Internal class to represent navigation items
class _NavigationItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String route;

  const _NavigationItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.route,
  });
}