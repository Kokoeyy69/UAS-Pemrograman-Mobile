import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:sizer/sizer.dart';
import 'package:easy_localization/easy_localization.dart'; // 1. Import wajib

import '../../../../core/app_export.dart';

/// Card Carousel Widget - Horizontal scrollable card display with parallax
class CardCarouselWidget extends StatelessWidget {
  final List<Map<String, dynamic>> cards;
  final int selectedIndex;
  final Function(int) onCardSelected;
  final Function(int) onCardLongPress;
  final Function(int) onCardTap;

  const CardCarouselWidget({
    Key? key,
    required this.cards,
    required this.selectedIndex,
    required this.onCardSelected,
    required this.onCardLongPress,
    required this.onCardTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Tidak perlu Theme.of(context) di sini jika tidak dipakai
    return Container(
      height: 25.h,
      margin: EdgeInsets.symmetric(vertical: 2.h),
      child: CardSwiper(
        cardsCount: cards.length,
        initialIndex: selectedIndex,
        onSwipe: (previousIndex, currentIndex, direction) {
          if (currentIndex != null) {
            onCardSelected(currentIndex);
          }
          return true;
        },
        cardBuilder: (context, index, percentThresholdX, percentThresholdY) {
          return _buildCardItem(context, cards[index], index);
        },
        scale: 0.9,
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        allowedSwipeDirection: AllowedSwipeDirection.symmetric(
          horizontal: true,
        ),
      ),
    );
  }

  Widget _buildCardItem(
    BuildContext context,
    Map<String, dynamic> card,
    int index,
  ) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onCardTap(index);
      },
      onLongPress: () {
        HapticFeedback.heavyImpact();
        onCardLongPress(index);
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 2.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withValues(alpha: 0.15),
              blurRadius: 16,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              // Card background image
              Positioned.fill(
                child: CustomImageWidget(
                  imageUrl: card['cardImage'] as String,
                  fit: BoxFit.cover,
                  semanticLabel: card['semanticLabel'] as String,
                ),
              ),

              // Gradient overlay
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withValues(alpha: 0.6),
                        Colors.black.withValues(alpha: 0.3),
                      ],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                  ),
                ),
              ),

              // Card content
              Padding(
                padding: EdgeInsets.all(4.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          card['cardType'] as String,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (card['isDefault'] == true)
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 2.w,
                              vertical: 0.5.h,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.secondary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              // ✅ TRANSLATE: Default
                              'card_carousel_label_default'.tr(),
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                    Spacer(),
                    Text(
                      card['cardNumber'] as String,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 2,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              // ✅ TRANSLATE: Card Holder
                              'card_carousel_label_card_holder'.tr(),
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: Colors.white.withValues(alpha: 0.7),
                              ),
                            ),
                            SizedBox(height: 0.5.h),
                            Text(
                              card['cardHolder'] as String,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              // ✅ TRANSLATE: Expires
                              'card_carousel_label_expires'.tr(),
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: Colors.white.withValues(alpha: 0.7),
                              ),
                            ),
                            SizedBox(height: 0.5.h),
                            Text(
                              card['expiryDate'] as String,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Contactless payment icon
              Positioned(
                top: 3.h,
                right: 4.w,
                child: CustomIconWidget(
                  iconName: 'contactless',
                  size: 32,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}