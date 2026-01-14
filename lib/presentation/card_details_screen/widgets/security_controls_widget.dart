import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:easy_localization/easy_localization.dart'; // 1. Import Wajib

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Widget for card security controls including freeze/unfreeze and spending limits
class SecurityControlsWidget extends StatefulWidget {
  final bool isCardFrozen;
  final double spendingLimit;
  final Function(bool) onFreezeToggle;
  final Function(double) onSpendingLimitChanged;

  const SecurityControlsWidget({
    Key? key,
    required this.isCardFrozen,
    required this.spendingLimit,
    required this.onFreezeToggle,
    required this.onSpendingLimitChanged,
  }) : super(key: key);

  @override
  State<SecurityControlsWidget> createState() => _SecurityControlsWidgetState();
}

class _SecurityControlsWidgetState extends State<SecurityControlsWidget> {
  late double _currentLimit;

  @override
  void initState() {
    super.initState();
    _currentLimit = widget.spendingLimit;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
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
            // ✅ TRANSLATE: Security Controls
            'security_controls_title'.tr(),
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 2.h),

          // Freeze/Unfreeze toggle
          _buildFreezeControl(theme),

          SizedBox(height: 3.h),

          // Spending limit slider
          _buildSpendingLimitControl(theme),
        ],
      ),
    );
  }

  Widget _buildFreezeControl(ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: widget.isCardFrozen
            ? theme.colorScheme.error.withValues(alpha: 0.1)
            : theme.colorScheme.secondary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: widget.isCardFrozen
                  ? theme.colorScheme.error.withValues(alpha: 0.2)
                  : theme.colorScheme.secondary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: CustomIconWidget(
              iconName: widget.isCardFrozen ? 'ac_unit' : 'check_circle',
              color: widget.isCardFrozen
                  ? theme.colorScheme.error
                  : theme.colorScheme.secondary,
              size: 24,
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  // ✅ TRANSLATE: Frozen / Active
                  widget.isCardFrozen 
                      ? 'security_controls_status_frozen'.tr() 
                      : 'security_controls_status_active'.tr(),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  // ✅ TRANSLATE: Subtitle
                  widget.isCardFrozen
                      ? 'security_controls_subtitle_frozen'.tr()
                      : 'security_controls_subtitle_active'.tr(),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: widget.isCardFrozen,
            onChanged: (value) {
              HapticFeedback.lightImpact();
              widget.onFreezeToggle(value);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSpendingLimitControl(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              // ✅ TRANSLATE: Daily Spending Limit
              'security_controls_limit_label'.tr(),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '\$${_currentLimit.toStringAsFixed(0)}',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 2.h),

        SliderTheme(
          data: SliderThemeData(
            trackHeight: 6,
            thumbShape: RoundSliderThumbShape(enabledThumbRadius: 10),
            overlayShape: RoundSliderOverlayShape(overlayRadius: 20),
          ),
          child: Slider(
            value: _currentLimit,
            min: 100,
            max: 10000,
            divisions: 99,
            label: '\$${_currentLimit.toStringAsFixed(0)}',
            onChanged: (value) {
              setState(() => _currentLimit = value);
            },
            onChangeEnd: (value) {
              HapticFeedback.lightImpact();
              widget.onSpendingLimitChanged(value);
            },
          ),
        ),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '\$100',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            Text(
              '\$10,000',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ],
    );
  }
}