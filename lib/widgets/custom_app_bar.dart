import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart'; // 1. Import Wajib

/// Custom app bar for digital wallet application.
/// Implements clean professional look with Contemporary Financial Minimalism.
/// Supports various configurations for different screen contexts.
enum CustomAppBarVariant {
  /// Standard app bar with title and optional actions
  standard,

  /// App bar with back button and title
  withBack,

  /// App bar with close button (for modals)
  withClose,

  /// Transparent app bar for overlays
  transparent,

  /// App bar with search functionality
  withSearch,
}

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// Title text to display
  final String? title;

  /// Leading widget (overrides default back/close button)
  final Widget? leading;

  /// Action widgets to display on the right
  final List<Widget>? actions;

  /// App bar variant
  final CustomAppBarVariant variant;

  /// Whether to show elevation shadow
  final bool showElevation;

  /// Custom background color
  final Color? backgroundColor;

  /// Custom title color
  final Color? titleColor;

  /// Custom icon color
  final Color? iconColor;

  /// Callback when back/close button is pressed
  final VoidCallback? onLeadingPressed;

  /// Whether to center the title
  final bool centerTitle;

  /// Custom height for the app bar
  final double? height;

  /// Search controller for search variant
  final TextEditingController? searchController;

  /// Search hint text
  final String? searchHint;

  /// Search callback
  final Function(String)? onSearchChanged;

  const CustomAppBar({
    Key? key,
    this.title,
    this.leading,
    this.actions,
    this.variant = CustomAppBarVariant.standard,
    this.showElevation = false,
    this.backgroundColor,
    this.titleColor,
    this.iconColor,
    this.onLeadingPressed,
    this.centerTitle = true,
    this.height,
    this.searchController,
    this.searchHint,
    this.onSearchChanged,
  }) : super(key: key);

  @override
  Size get preferredSize => Size.fromHeight(height ?? 56.0);

  Widget? _buildLeading(BuildContext context, ThemeData theme) {
    if (leading != null) return leading;

    switch (variant) {
      case CustomAppBarVariant.withBack:
        return IconButton(
          icon: Icon(Icons.arrow_back_ios_new, size: 20),
          color: iconColor ?? theme.colorScheme.onSurface,
          onPressed: () {
            HapticFeedback.lightImpact();
            if (onLeadingPressed != null) {
              onLeadingPressed!();
            } else {
              Navigator.of(context).pop();
            }
          },
          // ✅ TRANSLATE: Back Tooltip
          tooltip: 'custom_app_bar_back_tooltip'.tr(),
        );

      case CustomAppBarVariant.withClose:
        return IconButton(
          icon: Icon(Icons.close, size: 24),
          color: iconColor ?? theme.colorScheme.onSurface,
          onPressed: () {
            HapticFeedback.lightImpact();
            if (onLeadingPressed != null) {
              onLeadingPressed!();
            } else {
              Navigator.of(context).pop();
            }
          },
          // ✅ TRANSLATE: Close Tooltip
          tooltip: 'custom_app_bar_close_tooltip'.tr(),
        );

      default:
        return null;
    }
  }

  Widget? _buildTitle(BuildContext context, ThemeData theme) {
    if (variant == CustomAppBarVariant.withSearch) {
      return _buildSearchField(context, theme);
    }

    if (title == null) return null;

    return Text(
      title!, // Title biasanya dikirim sudah terjemahan dari parent widget
      style: theme.appBarTheme.titleTextStyle?.copyWith(
        color: titleColor ?? theme.colorScheme.onSurface,
      ),
    );
  }

  Widget _buildSearchField(BuildContext context, ThemeData theme) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: TextField(
        controller: searchController,
        onChanged: onSearchChanged,
        style: theme.textTheme.bodyMedium,
        decoration: InputDecoration(
          // ✅ TRANSLATE: Search Hint (Default fallback)
          hintText: searchHint ?? 'custom_app_bar_search_hint_default'.tr(),
          hintStyle: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          prefixIcon: Icon(
            Icons.search,
            size: 20,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          suffixIcon: searchController?.text.isNotEmpty ?? false
              ? IconButton(
                  icon: Icon(Icons.clear, size: 20),
                  color: theme.colorScheme.onSurfaceVariant,
                  onPressed: () {
                    searchController?.clear();
                    onSearchChanged?.call('');
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          isDense: true,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final effectiveBackgroundColor = variant == CustomAppBarVariant.transparent
        ? Colors.transparent
        : backgroundColor ??
              theme.appBarTheme.backgroundColor ??
              colorScheme.surface;

    final effectiveElevation = variant == CustomAppBarVariant.transparent
        ? 0.0
        : showElevation
        ? 2.0
        : 0.0;

    return AppBar(
      leading: _buildLeading(context, theme),
      title: _buildTitle(context, theme),
      actions: actions,
      centerTitle: centerTitle,
      backgroundColor: effectiveBackgroundColor,
      foregroundColor: iconColor ?? theme.appBarTheme.foregroundColor,
      elevation: effectiveElevation,
      shadowColor: theme.shadowColor.withValues(alpha: 0.1),
      systemOverlayStyle: theme.brightness == Brightness.light
          ? SystemUiOverlayStyle.dark
          : SystemUiOverlayStyle.light,
      toolbarHeight: height ?? 56.0,
      automaticallyImplyLeading: false,
    );
  }
}

/// Helper class for creating common app bar action buttons
class CustomAppBarAction {
  /// Creates a notification action button with badge
  static Widget notification({
    required VoidCallback onPressed,
    int? badgeCount,
    Color? iconColor,
  }) {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        final showBadge = badgeCount != null && badgeCount > 0;

        return Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              icon: Icon(Icons.notifications_outlined, size: 24),
              color: iconColor ?? theme.colorScheme.onSurface,
              onPressed: () {
                HapticFeedback.lightImpact();
                onPressed();
              },
              // ✅ TRANSLATE: Notifications Tooltip
              tooltip: 'custom_app_bar_notifications_tooltip'.tr(),
            ),
            if (showBadge)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.error,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: theme.colorScheme.surface,
                      width: 1.5,
                    ),
                  ),
                  constraints: BoxConstraints(minWidth: 16, minHeight: 16),
                  child: Center(
                    child: Text(
                      // ✅ TRANSLATE: Badge Max (99+)
                      badgeCount > 99 
                          ? 'custom_app_bar_notifications_badge_max'.tr() 
                          : badgeCount.toString(),
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
        );
      },
    );
  }

  /// Creates a settings action button
  static Widget settings({required VoidCallback onPressed, Color? iconColor}) {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        return IconButton(
          icon: Icon(Icons.settings_outlined, size: 24),
          color: iconColor ?? theme.colorScheme.onSurface,
          onPressed: () {
            HapticFeedback.lightImpact();
            onPressed();
          },
          // ✅ TRANSLATE: Settings Tooltip
          tooltip: 'custom_app_bar_settings_tooltip'.tr(),
        );
      },
    );
  }

  /// Creates a more options action button
  static Widget moreOptions({
    required VoidCallback onPressed,
    Color? iconColor,
  }) {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        return IconButton(
          icon: Icon(Icons.more_vert, size: 24),
          color: iconColor ?? theme.colorScheme.onSurface,
          onPressed: () {
            HapticFeedback.lightImpact();
            onPressed();
          },
          // ✅ TRANSLATE: More Options Tooltip
          tooltip: 'custom_app_bar_more_options_tooltip'.tr(),
        );
      },
    );
  }

  /// Creates a filter action button
  static Widget filter({
    required VoidCallback onPressed,
    bool isActive = false,
    Color? iconColor,
  }) {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        return IconButton(
          icon: Icon(
            isActive ? Icons.filter_alt : Icons.filter_alt_outlined,
            size: 24,
          ),
          color: isActive
              ? theme.colorScheme.primary
              : iconColor ?? theme.colorScheme.onSurface,
          onPressed: () {
            HapticFeedback.lightImpact();
            onPressed();
          },
          // ✅ TRANSLATE: Filter Tooltip
          tooltip: 'custom_app_bar_filter_tooltip'.tr(),
        );
      },
    );
  }

  /// Creates a scan QR code action button
  static Widget scanQR({required VoidCallback onPressed, Color? iconColor}) {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        return IconButton(
          icon: Icon(Icons.qr_code_scanner, size: 24),
          color: iconColor ?? theme.colorScheme.onSurface,
          onPressed: () {
            HapticFeedback.lightImpact();
            onPressed();
          },
          // ✅ TRANSLATE: Scan QR Tooltip
          tooltip: 'custom_app_bar_scan_qr_tooltip'.tr(),
        );
      },
    );
  }
}