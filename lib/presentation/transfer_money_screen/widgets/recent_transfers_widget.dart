import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:easy_localization/easy_localization.dart'; // 1. Import Wajib

import '../../../core/app_export.dart';

/// Widget displaying recent transfer recipients for quick selection
/// Shows horizontal scrollable list with payment history indicators
class RecentTransfersWidget extends StatelessWidget {
  final List<Map<String, dynamic>> recentTransfers;
  final Function(Map<String, dynamic>) onRecipientSelected;
  final Map<String, dynamic>? selectedRecipient;

  const RecentTransfersWidget({
    Key? key,
    required this.recentTransfers,
    required this.onRecipientSelected,
    this.selectedRecipient,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(4.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  // ✅ TRANSLATE: Recent Transfers
                  'recent_transfers_title'.tr(),
                  style: theme.textTheme.titleMedium,
                ),
                TextButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    // Navigate to full contacts list
                  },
                  child: Text(
                    // ✅ TRANSLATE: See All
                    'recent_transfers_btn_see_all'.tr(),
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(
            height: 20.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              itemCount: recentTransfers.length,
              itemBuilder: (context, index) {
                final recipient = recentTransfers[index];
                final isSelected = selectedRecipient?['id'] == recipient['id'];
                final lastAmount = recipient['lastAmount'] as double;
                final frequency = recipient['frequency'] as int;

                return Padding(
                  padding: EdgeInsets.only(right: 3.w),
                  child: InkWell(
                    onTap: () {
                      onRecipientSelected(recipient);
                      HapticFeedback.lightImpact();
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 30.w,
                      padding: EdgeInsets.all(3.w),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? theme.colorScheme.primary.withValues(alpha: 0.1)
                            : theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? theme.colorScheme.primary
                              : theme.colorScheme.outline.withValues(
                                  alpha: 0.3,
                                ),
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(30),
                                child: CustomImageWidget(
                                  imageUrl: recipient['avatar'] as String,
                                  width: 15.w,
                                  height: 15.w,
                                  fit: BoxFit.cover,
                                  semanticLabel:
                                      recipient['semanticLabel'] as String,
                                ),
                              ),
                              if (frequency > 3)
                                Positioned(
                                  right: -1.w,
                                  top: -0.5.h,
                                  child: Container(
                                    padding: EdgeInsets.all(1.w),
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.secondary,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: theme.colorScheme.surface,
                                        width: 2,
                                      ),
                                    ),
                                    child: CustomIconWidget(
                                      iconName: 'star',
                                      size: 3.w,
                                      color: theme.colorScheme.onSecondary,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          SizedBox(height: 1.h),
                          Text(
                            recipient['name'] as String,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontSize: 11.sp,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 0.5.h),
                          Text(
                            '\$${lastAmount.toStringAsFixed(0)}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontSize: 10.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          SizedBox(height: 2.h),
        ],
      ),
    );
  }
}